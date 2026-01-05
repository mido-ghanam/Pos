import 'package:json_annotation/json_annotation.dart';
part 'api_error_model.g.dart';

@JsonSerializable()
class ApiErrorModel {
  final String? message;
  final int? code;

  /// ✅ server validation errors like { "password": ["msg"] }
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> errors;

  ApiErrorModel({
    required this.message,
    this.code,
    this.errors = const {},
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorModelToJson(this);

  /// ✅ message جاهزة للمستخدم (Unified)
  String get readableMessage {
    // 1) لو message موجود
    if (message != null && message!.trim().isNotEmpty) return message!;

    // 2) لو في errors map (validation)
    if (errors.isNotEmpty) {
      // خد أول field error
      final firstKey = errors.keys.first;
      final value = errors[firstKey];

      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }

      if (value is String && value.isNotEmpty) {
        return value;
      }

      // fallback
      return "خطأ في $firstKey";
    }

    return "حدث خطأ غير معروف";
  }
}
