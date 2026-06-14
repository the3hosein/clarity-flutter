import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_state.dart';
import '../../providers/daily_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';
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
  bool _weatherLoaded = false;

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
        _weatherLoaded = true;
      });
    } catch (_) {
      setState(() => _weatherLoaded = true);
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

    if (appState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting with gradient border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(1.5),
              child: GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(appState.avatarEmoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appState.greeting}, ${appState.userName}',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatter.format(now),
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 16),

            // Weather
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(_weatherEmoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Text(
                    _temperature,
                    style: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Forecast",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 16),

            // Summary rings
            Row(
              children: [
                _buildSummaryRing(label: 'Lessons', value: '${daily.lessons.where((l) => l.status == 'done').length}'),
                _buildSummaryRing(label: 'Sleep', value: '${daily.averageSleep.toStringAsFixed(1)}h'),
                _buildSummaryRing(label: 'Habits', value: '${daily.habits.where((h) => daily.isHabitDoneToday(h.id)).length}'),
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
                      width: 4, height: 40,
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Up',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            calendar.nextEvent!.title,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(calendar.nextEvent!.startDate),
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: accent),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 16),

            // Quick actions
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(icon: Icons.bed, label: 'Sleep', onTap: () => context.read<AppState>().setActiveTab(2)),
                      _buildActionButton(icon: Icons.check_circle_outline, label: 'Habit', onTap: () => context.read<AppState>().setActiveTab(2)),
                      _buildActionButton(icon: Icons.edit_note, label: 'Note', onTap: () => context.read<AppState>().setActiveTab(1)),
                      _buildActionButton(icon: Icons.event, label: 'Event', onTap: () => context.read<AppState>().setActiveTab(4)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRing({required String label, required String value}) {
    final accent = Theme.of(context).colorScheme.primary;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          SizedBox(
            width: 56, height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          GlassCard(
            borderRadius: 14,
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
