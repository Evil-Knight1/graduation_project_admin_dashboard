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
      errors: (json['errors'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}
