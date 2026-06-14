import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/daily_provider.dart';
import '../../models/lesson.dart';
import '../../models/sleep_log.dart';
import '../../models/social_platform.dart';
import '../../models/habit.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily OS'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Lessons'),
            Tab(text: 'Sleep'),
            Tab(text: 'Social'),
            Tab(text: 'Habits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LessonsTab(daily: daily),
          _SleepTab(daily: daily),
          _SocialTab(daily: daily),
          _HabitsTab(daily: daily),
        ],
      ),
    );
  }
}

class _LessonsTab extends StatelessWidget {
  final DailyProvider daily;
  const _LessonsTab({required this.daily});

  @override
  Widget build(BuildContext context) {
    final lessons = daily.lessons;
    return Scaffold(
      body: lessons.isEmpty
          ? const Center(child: Text('No lessons'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (_, i) {
                final l = lessons[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(l.subject[0])),
                    title: Text(l.subject),
                    subtitle: Text(l.status),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (l.status == 'pending')
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => daily.updateLesson(Lesson(
                              id: l.id, subject: l.subject, dayOfWeek: l.dayOfWeek,
                              startTime: l.startTime, endTime: l.endTime, colorHex: l.colorHex,
                              status: 'done',
                            )),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => daily.deleteLesson(l.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addLesson(context, daily),
      ),
    );
  }

  void _addLesson(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Lesson'),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Lesson subject')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              d.addLesson(Lesson(subject: c.text));
              Navigator.pop(ctx);
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}

class _SleepTab extends StatelessWidget {
  final DailyProvider daily;
  const _SleepTab({required this.daily});

  @override
  Widget build(BuildContext context) {
    final logs = daily.sleepLogs;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Average Sleep', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('${daily.averageSleep.toStringAsFixed(1)}h', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...logs.reversed.take(7).map((log) => Card(
                child: ListTile(
                  leading: const Icon(Icons.bed, color: Colors.indigo),
                  title: Text(log.date.toString().substring(0, 10)),
                  trailing: Text('${log.durationHours.toStringAsFixed(1)}h'),
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _logSleep(context, daily),
      ),
    );
  }

  void _logSleep(BuildContext context, DailyProvider d) {
    final now = DateTime.now();
    final bedtime = DateTime(now.year, now.month, now.day, 23, 0);
    final wakeTime = DateTime(now.year, now.month, now.day, 7, 0);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Log Sleep', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text('${wakeTime.difference(bedtime).inHours}h', style: const TextStyle(fontSize: 32)),
              FilledButton(
                onPressed: () {
                  d.addSleepLog(SleepLog(date: DateTime(now.year, now.month, now.day), bedtime: bedtime, wakeTime: wakeTime));
                  Navigator.pop(ctx);
                },
                child: const Text('Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialTab extends StatelessWidget {
  final DailyProvider daily;
  const _SocialTab({required this.daily});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: daily.socialPlatforms.isEmpty
          ? const Center(child: Text('No platforms'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daily.socialPlatforms.length,
              itemBuilder: (_, i) {
                final p = daily.socialPlatforms[i];
                return Card(
                  child: ListTile(
                    leading: Icon(_platformIcon(p.name), color: _platformColor(p.name)),
                    title: Text(p.name),
                    subtitle: Text('Daily limit: ${p.dailyLimitMinutes}min'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => daily.deleteSocialPlatform(p.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addPlatform(context, daily),
      ),
    );
  }

  IconData _platformIcon(String name) {
    switch (name.toLowerCase()) {
      case 'instagram': return Icons.camera_alt;
      case 'youtube': return Icons.play_circle;
      case 'twitter': return Icons.alternate_email;
      case 'github': return Icons.code;
      default: return Icons.public;
    }
  }

  Color _platformColor(String name) {
    switch (name.toLowerCase()) {
      case 'instagram': return Colors.purple;
      case 'youtube': return Colors.red;
      case 'twitter': return Colors.blue;
      case 'github': return Colors.black87;
      default: return Colors.grey;
    }
  }

  void _addPlatform(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Platform'),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Platform name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              d.addSocialPlatform(SocialPlatform(name: c.text));
              Navigator.pop(ctx);
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}

class _HabitsTab extends StatelessWidget {
  final DailyProvider daily;
  const _HabitsTab({required this.daily});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Today\'s Habits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (daily.habits.isEmpty)
            const Center(child: Text('No habits yet'))
          else
            ...daily.habits.map((h) => Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: daily.isHabitDoneToday(h.id),
                      onChanged: (_) => daily.toggleHabit(h.id),
                    ),
                    title: Text(h.name),
                    subtitle: Text('Done ${h.completedDates.length} times'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => daily.deleteHabit(h.id),
                    ),
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addHabit(context, daily),
      ),
    );
  }

  void _addHabit(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Habit'),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Habit name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              d.addHabit(Habit(name: c.text));
              Navigator.pop(ctx);
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}
