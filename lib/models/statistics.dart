class MonthlyData {
  final String label;
  final double value;

  const MonthlyData({required this.label, required this.value});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardAlert {
  final String title;
  final String message;
  final String time;
  final String type; // 'warning', 'info', 'success', 'error'

  const DashboardAlert({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    return DashboardAlert(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? 'info',
    );
  }
}

class DashboardStats {
  final int totalDoctors;
  final int totalPatients;
  final double todayRevenue;
  final int pendingApprovals;
  final String? doctorGrowth;
  final String? patientGrowth;
  final List<MonthlyData> userGrowth;
  final List<MonthlyData> revenueOverview;
  final List<DashboardAlert> alerts;

  const DashboardStats({
    required this.totalDoctors,
    required this.totalPatients,
    required this.todayRevenue,
    required this.pendingApprovals,
    this.doctorGrowth,
    this.patientGrowth,
    required this.userGrowth,
    required this.revenueOverview,
    required this.alerts,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    List<MonthlyData> parseMonthly(dynamic list) =>
        (list as List?)
            ?.map((e) => MonthlyData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    List<DashboardAlert> parseAlerts(dynamic list) =>
        (list as List?)
            ?.map((e) => DashboardAlert.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DashboardStats(
      totalDoctors: json['totalDoctors'] ?? 0,
      totalPatients: json['totalUsers'] ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingApprovals: json['pendingDoctors'] ?? 0,
      doctorGrowth: json['doctorGrowth'],
      patientGrowth: json['patientGrowth'],
      userGrowth: parseMonthly(json['userGrowth']),
      revenueOverview: parseMonthly(json['revenueOverview']),
      alerts: parseAlerts(json['alerts']),
    );
  }
}
