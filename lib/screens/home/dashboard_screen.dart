import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../providers/daily_provider.dart';
import '../../services/weather_service.dart';

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
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d');
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = isDark ? const Color(0xFF161622) : const Color(0xFFF2F2F7);

    if (appState.isLoading) {
      return Scaffold(backgroundColor: bg, body: const Center(child: CircularProgressIndicator()));
    }

    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWeather,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDBxubErjYZawevE40OY_6nCi1xIH-PnQLZAgu-VakcMCiNqZ0b21FKyM-xVdH3YD5Zm6cBtY_P8hF9lvnB5EScguea7G8tNWy1c4WQsh8TQNDsHr7qoPdx_AqmIAZAzoImvR_0iyjKZhPWaI7mxv893jJL-OLsOdE_LiHkNL474tTRpT_fBNWcqH-a9DsEHXeeTFrtc3-x9TMJmOiJna1VahiMTU7tMQot8I1uZw15DiTFG44rzciE0kB7mryiPjUMa3_BcXRJ4_c',
                      width: 40, height: 40, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Clarity', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary)),
                  const Spacer(),
                  Icon(Icons.notifications_outlined, color: accent),
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: accent),
                ],
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '$greeting,\n', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary)),
                    TextSpan(text: appState.userName, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: accent)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Text(_weatherEmoji, style: const TextStyle(fontSize: 42)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_temperature, style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary)),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('San Francisco', style: GoogleFonts.inter(fontSize: 14, color: textSecondary)),
                                  Text('High: 24° Low: 18°', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Activity', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                            Text('Summary', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.analytics_rounded, color: accent),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ring('Lessons', '${daily.lessons.where((l) => l.status == 'done').length}', 0.7, accent, isDark, daily),
                        const SizedBox(width: 16),
                        _ring('Sleep', '${daily.averageSleep.toStringAsFixed(1)}h', 0.85, const Color(0xFF0070EB), isDark, daily),
                        const SizedBox(width: 16),
                        _ring('Habits', '${daily.habits.where((h) => daily.isHabitDoneToday(h.id)).length}', 0.4, const Color(0xFFC64F00), isDark, daily),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Up Next', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Design Critique', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
                                  const SizedBox(width: 4),
                                  Text('11:30 AM - Room 4B', style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF4F3F8), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text('42', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: accent)),
                                  Text('Mins', style: GoogleFonts.inter(fontSize: 10, color: textSecondary)),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(':', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textSecondary)),
                              ),
                              Column(
                                children: [
                                  Text('15', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: accent)),
                                  Text('Secs', style: GoogleFonts.inter(fontSize: 10, color: textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Recent Activity', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                  const Spacer(),
                  Text('View All', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
                ],
              ),
              const SizedBox(height: 12),
              _activityCard(Icons.edit_note_rounded, 'Journal Entry Added', 'Reflections on morning meditation...', '10 mins ago', const Color(0xFF9E3D00), const Color(0xFFFFDBCC), textPrimary, textSecondary, isDark),
              const SizedBox(height: 10),
              _activityCard(Icons.task_alt_rounded, 'Habit: Hydration', 'Goal met: 2.5L / 2L', '1 hour ago', accent, const Color(0xFFD8E2FF), textPrimary, textSecondary, isDark),
              const SizedBox(height: 10),
              _activityCard(Icons.menu_book_rounded, 'Lesson Completed', 'Micro-interactions in Swift UI', '2 hours ago', const Color(0xFF4C4ACA), const Color(0xFFE2DFFF), textPrimary, textSecondary, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(String label, String value, double progress, Color color, bool isDark, DailyProvider daily) {
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    return Column(
      children: [
        SizedBox(
          width: 64, height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: 1, strokeWidth: 5, backgroundColor: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0))),
              CircularProgressIndicator(value: progress.clamp(0, 1), strokeWidth: 5, valueColor: AlwaysStoppedAnimation<Color>(color), backgroundColor: Colors.transparent),
              Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
      ],
    );
  }

  Widget _activityCard(IconData icon, String title, String subtitle, String time, Color iconBg, Color iconContainerBg, Color textPrimary, Color textSecondary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: iconContainerBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconBg, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }
}
