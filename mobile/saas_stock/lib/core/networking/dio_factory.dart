import 'dart:async';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/material.dart';
import 'package:saas_stock/core/helpers/constants.dart';
import 'package:saas_stock/core/helpers/shared_pref_helper.dart';
import 'package:saas_stock/core/networking/api_constants.dart';
import 'package:saas_stock/core/routing/routers.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;
  static final navigatorKey = GlobalKey<NavigatorState>();

  static bool _isRefreshing = false;
  static final List<_QueuedRequest> _queuedRequests = [];

  static Dio getDio() {
    const timeOut = Duration(seconds: 30);

    dio ??= Dio(
      BaseOptions(
        baseUrl: 'https://pos.tests.midoghanam.site',
        connectTimeout: timeOut,
        receiveTimeout: timeOut,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio!.interceptors.clear();
    _addInterceptors();
    return dio!;
  }

  static void setTokenIntoHeaderAfterLogin(String token) {
    dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  static void _addInterceptors() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ skip refresh نفسه عشان ما تعملش loop
          if (options.path.contains(ApiConstants.refreshToken)) {
            return handler.next(options);
          }

          // ✅ لو الريكويست مش محتاج توكن
          if (options.extra['requiresToken'] == false) {
            return handler.next(options);
          }

          String accessToken =
              await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);

          String refreshToken = await SharedPrefHelper.getSecuredString(
              SharedPrefKeys.refreshToken);

          // ✅ لو مفيش access token (login/register)
          if (accessToken.isEmpty) {
            return handler.next(options);
          }

          // ✅ لو انتهى access
          if (_isTokenExpired(accessToken)) {
            if (refreshToken.isEmpty) {
              await _logoutAll();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                  error: 'Session expired. Please login again.',
                ),
              );
            }

            // ✅ لو فيه refresh شغال → queue
            if (_isRefreshing) {
              final completer = Completer<Response>();
              _queuedRequests
                  .add(_QueuedRequest(options: options, completer: completer));

              try {
                final response = await completer.future;
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(e as DioException);
              }
            }

            _isRefreshing = true;

            final refreshed = await _refreshAccessToken(refreshToken);

            _isRefreshing = false;

            if (!refreshed) {
              await _failQueuedRequests();
              await _logoutAll();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                  error: 'Failed to refresh token. Please login again.',
                ),
              );
            }

            // ✅ بعد refresh → جيب access الجديد
            accessToken = await SharedPrefHelper.getSecuredString(
              SharedPrefKeys.userToken,
            );

            // ✅ نفذ queued requests
            await _processQueuedRequests(accessToken);
          }

          // ✅ ضيف التوكن للريكويست الحالي
          options.headers['Authorization'] = 'Bearer $accessToken';
          if (options.path.contains(ApiConstants.refreshToken) ||
              options.path.contains(ApiConstants.logout)) {
            return handler.next(options);
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // ✅ لو 401 -> جرب refresh + retry مرة واحدة
          if (error.response?.statusCode == 401) {
            final refreshToken = await SharedPrefHelper.getSecuredString(
              SharedPrefKeys.refreshToken,
            );

            if (refreshToken.isNotEmpty && !_isRefreshing) {
              _isRefreshing = true;
              final refreshed = await _refreshAccessToken(refreshToken);
              _isRefreshing = false;

              if (refreshed) {
                final newAccess = await SharedPrefHelper.getSecuredString(
                  SharedPrefKeys.userToken,
                );

                // ✅ retry نفس الريكويست
                final requestOptions = error.requestOptions;
                requestOptions.headers['Authorization'] = 'Bearer $newAccess';

                try {
                  final response = await dio!.fetch(requestOptions);
                  return handler.resolve(response);
                } catch (e) {
                  await _logoutAll();
                }
              } else {
                await _logoutAll();
              }
            } else {
              await _logoutAll();
            }
          }

          return handler.next(error);
        },
      ),
    );

    dio?.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  static bool _isTokenExpired(String token) {
    try {
      if (token.isEmpty || token.split('.').length != 3) return true;

      final expiryDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();

      const buffer = Duration(minutes: 1);
      return expiryDate.subtract(buffer).isBefore(now);
    } catch (_) {
      return true;
    }
  }

  static Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: 'https://pos.tests.midoghanam.site',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {"refresh": refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final newAccess = data['access'];
        final newRefresh = data['refresh'];

        if (newAccess != null && newAccess.isNotEmpty) {
          await SharedPrefHelper.setSecuredString(
            SharedPrefKeys.userToken,
            newAccess,
          );

          if (newRefresh != null && newRefresh.isNotEmpty) {
            await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.refreshToken,
              newRefresh,
            );
          }

          setTokenIntoHeaderAfterLogin(newAccess);
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _processQueuedRequests(String accessToken) async {
    for (final q in _queuedRequests) {
      try {
        q.options.headers['Authorization'] = 'Bearer $accessToken';
        final response = await dio!.fetch(q.options);
        q.completer.complete(response);
      } catch (e) {
        q.completer.completeError(e);
      }
    }
    _queuedRequests.clear();
  }

  static Future<void> _failQueuedRequests() async {
    for (final q in _queuedRequests) {
      q.completer.completeError(
        DioException(
          requestOptions: q.options,
          type: DioExceptionType.cancel,
          error: "Refresh failed",
        ),
      );
    }
    _queuedRequests.clear();
  }

  static Future<void> _logoutAll() async {
    await SharedPrefHelper.clearAllSecuredData();
    _queuedRequests.clear();
    _isRefreshing = false;

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        Routers.login,
        (route) => false,
      );
    }
  }

  static void clearToken() {
    dio?.options.headers.remove('Authorization');
  }
}

class _QueuedRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _QueuedRequest({required this.options, required this.completer});
}
