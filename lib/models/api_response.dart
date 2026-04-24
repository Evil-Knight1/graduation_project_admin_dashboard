class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null ? fromData(json['data']) : null,
      errors: _parseErrors(json['errors']),
    );
  }

  static List<String>? _parseErrors(dynamic errors) {
    if (errors == null) return null;
    if (errors is List) {
      return errors.map((e) => e.toString()).toList();
    }
    if (errors is Map) {
      final list = <String>[];
      errors.forEach((key, value) {
        if (value is List) {
          list.addAll(value.map((e) => e.toString()));
        } else {
          list.add(value.toString());
        }
      });
      return list;
    }
    return [errors.toString()];
  }
}
