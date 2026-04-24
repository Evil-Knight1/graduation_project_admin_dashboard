import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project_admin_dashboard/models/statistics.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/loading_view.dart';
import '../../../widgets/summary_card.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedGrowthPeriod = 'Last 6 Months';
  bool _isBarView = true;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading) {
          return const LoadingView();
        }
        if (state.status == DashboardStatus.error) {
          return ErrorView(
            message: state.message ?? 'Failed to load dashboard',
            onRetry: () =>
                context.read<DashboardBloc>().add(const DashboardFetched()),
          );
        }

        final stats = state.stats ?? _getMockStats();
        final width = MediaQuery.of(context).size.width;
        final isDesktop = Responsive.isDesktop(width);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical Overview',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Welcome back, Admin. Here’s a summary of today's hospital performance.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppConstants.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),

              // Bento Stat Grid
              LayoutBuilder(builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200
                    ? 4
                    : (constraints.maxWidth > 800 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 24.h,
                  crossAxisSpacing: 24.w,
                  childAspectRatio: constraints.maxWidth > 400 ? 1.6 : 1.2,
                  children: [
                    SummaryCard(
                      title: 'Total Doctors',
                      value: stats.totalDoctors > 1000
                          ? '${(stats.totalDoctors / 1000).toStringAsFixed(1)}k'
                          : stats.totalDoctors.toString(),
                      icon: Icons.medical_services,
                      color: AppConstants.primary,
                      // Only show badge if we have real percentage data (placeholder logic here)
                      badge: null,
                    ),
                    SummaryCard(
                      title: 'Total Patients',
                      value: stats.totalPatients > 1000
                          ? '${(stats.totalPatients / 1000).toStringAsFixed(1)}k'
                          : stats.totalPatients.toString(),
                      icon: Icons.group,
                      color: AppConstants.secondary,
                      badge: null,
                    ),
                    SummaryCard(
                      title: "Today's Revenue",
                      value:
                          '\$${NumberFormat.compact().format(stats.todayRevenue)}',
                      icon: Icons.payments,
                      color: AppConstants.primary,
                      isHighlight: true,
                      badge: 'Target: 95%',
                    ),
                    SummaryCard(
                      title: 'Pending Approvals',
                      value: stats.pendingApprovals.toString(),
                      icon: Icons.assignment_late,
                      color: AppConstants.tertiary,
                      badge: stats.pendingApprovals == 0
                          ? 'Accept'
                          : 'Action Required',
                      badgeColor: stats.pendingApprovals == 0
                          ? Colors.green
                          : AppConstants.tertiary,
                    ),
                  ],
                );
              }),
              SizedBox(height: 32.h),

              // Charts & Alerts Section
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 2,
                          child: _buildUserGrowthChart(stats.userGrowth)),
                      SizedBox(width: 32.w),
                      Expanded(flex: 1, child: _buildAlertsPanel(stats.alerts)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildUserGrowthChart(stats.userGrowth),
                      SizedBox(height: 32.h),
                      _buildAlertsPanel(stats.alerts),
                    ],
                  );
                }
              }),
              SizedBox(height: 32.h),

              // Revenue Overview
              _buildRevenueOverview(stats.revenueOverview),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserGrowthChart(List<MonthlyData> data) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191B22),
            blurRadius: 48,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Growth',
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Monthly registrations across all departments',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppConstants.textSecondary),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    setState(() => _selectedGrowthPeriod = value),
                offset: Offset(0, 40.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
                itemBuilder: (context) => [
                  'Last 3 Months',
                  'Last 6 Months',
                  'Last Year',
                ]
                    .map((e) => PopupMenuItem(
                          value: e,
                          child: Text(e, style: TextStyle(fontSize: 13.sp)),
                        ))
                    .toList(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedGrowthPeriod,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primary)),
                      Icon(Icons.keyboard_arrow_down,
                          size: 16.sp, color: AppConstants.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 48.h),
          SizedBox(
            height: 240.h,
            child: data.isEmpty
                ? Center(
                    child: Text('No growth data available',
                        style: TextStyle(fontSize: 14.sp)))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: data.isEmpty
                          ? 100
                          : data
                                  .map((e) => e.value)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 ||
                                  value.toInt() >= data.length)
                                return const SizedBox();
                              return Padding(
                                padding: EdgeInsets.only(top: 12.h),
                                child: Text(
                                  data[value.toInt()].label,
                                  style: TextStyle(
                                    color: AppConstants.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: data.asMap().entries.map((e) {
                        final index = e.key;
                        final item = e.value;
                        final isCurrent = index == data.length - 1;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: item.value,
                              color: isCurrent
                                  ? AppConstants.primary
                                  : AppConstants.surfaceContainerLow,
                              width: 40.w,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.r)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel(List<DashboardAlert> alerts) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191B22),
            blurRadius: 48,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerts',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.priority_high, color: AppConstants.error, size: 20.sp),
            ],
          ),
          SizedBox(height: 24.h),
          ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppConstants.surfaceContainer,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text(
                'VIEW ALL NOTIFICATIONS',
                style: TextStyle(
                  color: AppConstants.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(DashboardAlert alert) {
    Color iconColor;
    Color bgColor;
    IconData icon;

    switch (alert.type) {
      case 'warning':
        iconColor = AppConstants.tertiary;
        bgColor = AppConstants.tertiary.withValues(alpha: 0.1);
        icon = Icons.warning_rounded;
        break;
      case 'error':
        iconColor = AppConstants.error;
        bgColor = AppConstants.error.withValues(alpha: 0.1);
        icon = Icons.error_rounded;
        break;
      default:
        iconColor = AppConstants.primary;
        bgColor = AppConstants.primary.withValues(alpha: 0.1);
        icon = Icons.info_rounded;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                Text(
                  alert.message,
                  style: TextStyle(
                      color: AppConstants.textSecondary, fontSize: 11.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  alert.time.toUpperCase(),
                  style: TextStyle(
                      color: AppConstants.outline,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueOverview(List<MonthlyData> data) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191B22),
            blurRadius: 48,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Overview',
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Monthly revenue trends compared to last fiscal year',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppConstants.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isBarView = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: _isBarView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: _isBarView
                              ? const [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 4)
                                ]
                              : null,
                        ),
                        child: Text('Bar View',
                            style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: _isBarView
                                    ? AppConstants.primary
                                    : AppConstants.textSecondary)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isBarView = false),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text('Area View',
                            style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: !_isBarView
                                    ? AppConstants.primary
                                    : AppConstants.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          SizedBox(
            height: 200.h,
            child: data.isEmpty
                ? Center(
                    child: Text('No revenue data available',
                        style: TextStyle(fontSize: 14.sp)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      final maxVal = data
                          .map((e) => e.value)
                          .reduce((a, b) => a > b ? a : b);
                      final heightFactor =
                          maxVal == 0 ? 0.1 : (item.value / maxVal);

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              height: 160.h * heightFactor,
                              decoration: BoxDecoration(
                                color: index == data.length - 1
                                    ? AppConstants.primary
                                    : AppConstants.primary
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              item.label,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppConstants.textSecondary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          SizedBox(height: 32.h),
          const Divider(color: AppConstants.surfaceContainer),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _StatItem(label: 'TOTAL GROSS', value: '\$1.24M'),
              const _StatItem(label: 'PROFIT MARGIN', value: '24.8%'),
              _StatItem(label: 'GROWTH RATE', value: '+5.2%', isPositive: true),
            ],
          ),
        ],
      ),
    );
  }

  DashboardStats _getMockStats() {
    return const DashboardStats(
      totalDoctors: 0,
      totalPatients: 0,
      todayRevenue: 0,
      pendingApprovals: 0,
      userGrowth: [],
      revenueOverview: [],
      alerts: [],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _StatItem(
      {required this.label, required this.value, this.isPositive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textSecondary,
                letterSpacing: 1)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: isPositive ? AppConstants.tertiary : AppConstants.primary,
          ),
        ),
      ],
    );
  }
}
