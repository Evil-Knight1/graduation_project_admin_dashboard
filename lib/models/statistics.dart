class BookingTrend {
  final DateTime date;
  final int count;

  const BookingTrend({required this.date, required this.count});

  factory BookingTrend.fromJson(Map<String, dynamic> json) {
    return BookingTrend(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      count: json['count'] ?? 0,
    );
  }
}

class DashboardStats {
  final int totalDoctors;
  final int activeBookings;
  final int totalPatients;
  final double revenue;
  final List<BookingTrend> trends;

  const DashboardStats({
    required this.totalDoctors,
    required this.activeBookings,
    required this.totalPatients,
    required this.revenue,
    required this.trends,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final trendsRaw = json['bookingTrends'] ?? json['bookingsLast7Days'];
    final List<BookingTrend> parsedTrends = trendsRaw is List
        ? trendsRaw
            .whereType<Map>()
            .map((e) => BookingTrend.fromJson(e.cast<String, dynamic>()))
            .toList()
        : [];

    return DashboardStats(
      totalDoctors: json['totalDoctors'] ?? json['doctors'] ?? 0,
      activeBookings: json['activeBookings'] ?? json['bookings'] ?? 0,
      totalPatients: json['totalPatients'] ?? json['patients'] ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      trends: parsedTrends,
    );
  }
}
