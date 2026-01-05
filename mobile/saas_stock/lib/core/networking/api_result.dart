import 'package:freezed_annotation/freezed_annotation.dart';
import 'api_error_handler.dart';
part 'api_result.freezed.dart';

@freezed

abstract class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = _Success<T>;
  const factory ApiResult.failure(ErrorHandler errorHandler) = _Failure<T>;
}
