import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            onRetry: () => context.read<DashboardBloc>().add(const DashboardFetched()),
          );
        }

        final stats = state.stats!;
        final formatCurrency = NumberFormat.compactCurrency(symbol: '\$');
        final width = MediaQuery.of(context).size.width;
        final isDesktop = Responsive.isDesktop(width);
        final crossAxisCount = isDesktop ? 4 : 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  SummaryCard(
                    title: 'Total Doctors',
                    value: stats.totalDoctors.toString(),
                    icon: Icons.medical_services,
                    color: AppConstants.primary,
                  ),
                  SummaryCard(
                    title: 'Active Bookings',
                    value: stats.activeBookings.toString(),
                    icon: Icons.calendar_today,
                    color: AppConstants.secondary,
                  ),
                  SummaryCard(
                    title: 'Total Patients',
                    value: stats.totalPatients.toString(),
                    icon: Icons.people_alt,
                    color: const Color(0xFF5B8DEF),
                  ),
                  SummaryCard(
                    title: 'Revenue',
                    value: formatCurrency.format(stats.revenue),
                    icon: Icons.payments,
                    color: const Color(0xFFEE8D52),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bookings Trend (Last 7 Days)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 260,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true, drawVerticalLine: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= stats.trends.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final date = stats.trends[index].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(DateFormat('E').format(date)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  stats.trends.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    stats.trends[index].count.toDouble(),
                                  ),
                                ),
                                isCurved: true,
                                color: AppConstants.primary,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppConstants.primary.withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
