class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawItems = (json['items'] as List?) ?? [];
    return PagedResult(
      items: rawItems.map((e) => fromItem(e as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] ?? rawItems.length,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? rawItems.length,
      totalPages: json['totalPages'] ?? 1,
      hasPreviousPage: json['hasPreviousPage'] == true,
      hasNextPage: json['hasNextPage'] == true,
    );
  }
}
