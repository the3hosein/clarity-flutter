import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../providers/daily_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../services/weather_service.dart';
import '../../widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _weatherEmoji = '☀️';
  String _temperature = '--°';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final data = await WeatherService.fetchWeather(35.6895, 51.3890);
      final current = data['current'];
      setState(() {
        _weatherEmoji = WeatherService.weatherEmoji(current['weather_code'] ?? 0, current['is_day'] ?? 1);
        _temperature = '${current['temperature_2m']?.round() ?? '--'}°';
      });
    } catch (_) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final daily = context.watch<DailyProvider>();
    final calendar = context.watch<CalendarProvider>();
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d');
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    if (appState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            // Greeting
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(1.5),
              child: GlassCard(
                borderRadius: 15,
                color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(appState.avatarEmoji, style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${appState.greeting},',
                            style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
                          ),
                          Text(
                            appState.userName,
                            style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weather
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(_weatherEmoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Text(
                    _temperature,
                    style: GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Forecast",
                    style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Summary rings
            Row(
              children: [
                _buildSummaryRing(label: 'Lessons', value: '${daily.lessons.where((l) => l.status == 'done').length}', daily: daily, accent: accent, isDark: isDark),
                _buildSummaryRing(label: 'Sleep', value: '${daily.averageSleep.toStringAsFixed(1)}h', daily: daily, accent: accent, isDark: isDark),
                _buildSummaryRing(label: 'Habits', value: '${daily.habits.where((h) => daily.isHabitDoneToday(h.id)).length}', daily: daily, accent: accent, isDark: isDark),
              ].map((w) => Expanded(child: w)).toList(),
            ),

            const SizedBox(height: 16),

            // Next event
            if (calendar.nextEvent != null)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Next Up', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            calendar.nextEvent!.title,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(calendar.nextEvent!.startDate),
                      style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.w600, color: accent),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Quick actions
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(icon: Icons.bed_rounded, label: 'Sleep', onTap: () => context.read<AppState>().setActiveTab(2), accent: accent, isDark: isDark),
                      _buildActionButton(icon: Icons.check_circle_outline_rounded, label: 'Habit', onTap: () => context.read<AppState>().setActiveTab(2), accent: accent, isDark: isDark),
                      _buildActionButton(icon: Icons.edit_note_rounded, label: 'Note', onTap: () => context.read<AppState>().setActiveTab(1), accent: accent, isDark: isDark),
                      _buildActionButton(icon: Icons.event_rounded, label: 'Event', onTap: () => context.read<AppState>().setActiveTab(4), accent: accent, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRing({required String label, required String value, required DailyProvider daily, required Color accent, required bool isDark}) {
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final ringBg = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: label == 'Lessons'
                      ? (daily.todayLessons.isEmpty ? 0 : daily.doneToday / daily.todayLessons.length)
                      : label == 'Habits'
                          ? (daily.habits.isEmpty ? 0 : daily.habits.where((h) => daily.isHabitDoneToday(h.id)).length / daily.habits.length)
                          : (daily.averageSleep / 12).clamp(0, 1),
                  strokeWidth: 3,
                  backgroundColor: ringBg,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, required Color accent, required bool isDark}) {
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          GlassCard(
            borderRadius: 12,
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }
}
