import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/usage_tracking_service.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _trackingService = UsageTrackingService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  HomeMetrics? _currentMetrics;
  bool _isLoading = true;
  bool _hasInitialLoad = false;
  StreamSubscription<DateTime>? _refreshSubscription;

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDay.year == now.year &&
        _selectedDay.month == now.month &&
        _selectedDay.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _loadMetricsForDate(_selectedDay);
    // Only auto-refresh when viewing today — historical data is static
    _refreshSubscription = _trackingService.refreshTick.listen((_) {
      if (mounted && _isToday) _loadMetricsForDate(_selectedDay);
    });
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMetricsForDate(DateTime date) async {
    final bool isNewDate = !isSameDay(_selectedDay, date);
    
    // Only show loading spinner if it's a new date or absolute first load
    if (!_hasInitialLoad || isNewDate) {
      if (mounted) setState(() => _isLoading = true);
    }
    
    try {
      final metrics = await _trackingService.getHomeMetricsForDate(date);
      if (mounted) {
        // Deep comparison to prevent flickering if data hasn't changed
        final bool hasChanged = _currentMetrics == null ||
            metrics.focusScore != _currentMetrics!.focusScore ||
            metrics.microLeaks != _currentMetrics!.microLeaks ||
            metrics.totalScreenTime != _currentMetrics!.totalScreenTime ||
            !_trackingService.listEquals(metrics.leakRadarHeatmap, _currentMetrics!.leakRadarHeatmap);

        if (hasChanged || _isLoading) {
          setState(() {
            _currentMetrics = metrics;
            _isLoading = false;
            _hasInitialLoad = true;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.chronosPurple.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildCalendarHeader(),
                
                Expanded(
                  child: (_isLoading && !_hasInitialLoad) 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.chronosPurple))
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildTopHUD(_currentMetrics),
                            const SizedBox(height: 24),
                            
                            // Weekly/Daily Intensity
                            _buildIntensityChart(_currentMetrics?.leakRadarHeatmap ?? []),
                            const SizedBox(height: 24),
                            
                            // Category Radar
                            _buildLeakRadar(_currentMetrics?.categoryBreakdown ?? {}),
                            const SizedBox(height: 24),
                            
                            // Chronos Archive Summary
                            _buildArchiveSummary(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _loadMetricsForDate(selectedDay);
          }
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          titleTextStyle: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          formatButtonTextStyle: GoogleFonts.manrope(color: Colors.white, fontSize: 12),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.chronosPurpleGlow),
            borderRadius: BorderRadius.circular(12),
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.chronosPurple),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.chronosPurple),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.chronosPurple.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.chronosPurple,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: GoogleFonts.manrope(color: Colors.white70),
          weekendTextStyle: GoogleFonts.manrope(color: Colors.white38),
          outsideTextStyle: GoogleFonts.manrope(color: Colors.white10),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.manrope(color: Colors.white38, fontSize: 12),
          weekendStyle: GoogleFonts.manrope(color: Colors.white38, fontSize: 12),
        ),
      ),
    ).animate(autoPlay: !_hasInitialLoad).fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTopHUD(HomeMetrics? metrics) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHUDSlot('HYGIENE', '${metrics?.focusScore ?? 0}%', AppColors.chronosPurpleGlow),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildHUDSlot('LEAKS', '${metrics?.microLeaks ?? 0}', Colors.orangeAccent),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildHUDSlot('VORTEX', '${metrics?.vortexes.length ?? 0}', Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildHUDSlot(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIntensityChart(List<int> heatmap) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHRONOS INTENSITY',
            style: GoogleFonts.manrope(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['0h', '4h', '8h', '12h', '16h', '20h'];
                        final idx = value.toInt();
                        if (idx % 4 == 0 && idx < 24) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[idx ~/ 4],
                              style: GoogleFonts.manrope(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (i) {
                  final val = heatmap.isEmpty ? 0.0 : (i < heatmap.length ? heatmap[i].toDouble() : 0.0);
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val == 0 ? 1 : (val > 60 ? 60 : val),
                        color: i > 18 || i < 8 ? Colors.orangeAccent.withValues(alpha: 0.6) : AppColors.chronosPurpleGlow,
                        width: 4,
                        borderRadius: BorderRadius.circular(2),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 60,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeakRadar(Map<int, Duration> breakdown) {
    final categories = ['WORK', 'PLAY', 'SOCIAL', 'FLOW', 'REST'];
    final data = List.generate(5, (i) {
        if (breakdown.isEmpty) return 20.0;
        return breakdown.containsKey(i) ? (breakdown[i]!.inMinutes.toDouble().clamp(10.0, 100.0)) : 10.0;
    });

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEURAL BALANCE',
                style: GoogleFonts.manrope(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(Icons.radar, color: AppColors.chronosPurple, size: 14),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: RadarChart(
              RadarChartData(
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                tickCount: 3,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
                titleTextStyle: GoogleFonts.manrope(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w900),
                getTitle: (index, angle) => RadarChartTitle(text: categories[index % categories.length]),
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.chronosPurpleGlow.withValues(alpha: 0.1),
                    borderColor: AppColors.chronosPurpleGlow,
                    entryRadius: 2,
                    dataEntries: data.map((e) => RadarEntry(value: e)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveSummary() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 8),
              Text(
                'NEURAL HYGIENE REPORT',
                style: GoogleFonts.manrope(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isLoading || _currentMetrics == null 
              ? 'Analyzing neural signatures...'
              : _generateSummaryText(_currentMetrics!),
            style: GoogleFonts.manrope(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildHealthIndicator(),
        ],
      ),
    );
  }

  String _generateSummaryText(HomeMetrics m) {
    if (m.focusScore > 85) return 'Your digital hygiene was exceptional on this day. Minimal context switching and high focus in productive categories preserved your neural energy.';
    if (m.focusScore > 60) return 'Noticeable micro-leaks detected during transitions. While focus remained stable, frequent app-switching suggests early signs of digital fatigue.';
    if (m.focusScore > 0) return 'Critical focus depletion observed. High vortex activity and frequent unlocks suggest a recursive feedback loop of distraction.';
    return 'No usage data archived for this signature.';
  }

  Widget _buildHealthIndicator() {
    final score = _currentMetrics?.focusScore ?? 0;
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: score / 100,
        child: Container(
          decoration: BoxDecoration(
            color: score > 70 ? AppColors.chronosPurple : (score > 40 ? Colors.orange : Colors.red),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: (score > 70 ? AppColors.chronosPurple : Colors.orange).withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
