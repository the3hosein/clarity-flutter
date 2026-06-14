import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../providers/daily_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';
import '../../services/weather_service.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting
            Text('${appState.greeting}, ${appState.userName} ${appState.avatarEmoji}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(formatter.format(now), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 16),

            // Weather
            _buildWeatherCard(),
            const SizedBox(height: 16),

            // Summary rings
            _buildSummaryRow(daily),
            const SizedBox(height: 16),

            // Next event
            if (calendar.nextEvent != null) _buildNextEvent(calendar.nextEvent!),
            const SizedBox(height: 16),

            // Quick actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(_weatherEmoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Text(_temperature, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Text("Today's Forecast", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(DailyProvider daily) {
    return Row(
      children: [
        _SummaryRing(label: 'Lessons', value: '${daily.lessons.where((l) => l.status == 'done').length}'),
        _SummaryRing(label: 'Sleep', value: '${daily.averageSleep.toStringAsFixed(1)}h'),
        _SummaryRing(label: 'Habits', value: '${daily.habits.where((h) => daily.isHabitDoneToday(h.id)).length}'),
      ].map((w) => Expanded(child: w)).toList(),
    );
  }

  Widget _buildNextEvent(CalendarEvent event) {
    return Card(
      child: ListTile(
        leading: Container(width: 4, height: 40, color: Theme.of(context).colorScheme.primary),
        title: Text('Next Up', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        subtitle: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(DateFormat('HH:mm').format(event.startDate)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(icon: Icons.bed, label: 'Sleep'),
                _ActionButton(icon: Icons.check_circle_outline, label: 'Habit'),
                _ActionButton(icon: Icons.edit_note, label: 'Note'),
                _ActionButton(icon: Icons.event, label: 'Event'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRing extends StatelessWidget {
  final String label, value;
  const _SummaryRing({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3)),
            child: Center(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
