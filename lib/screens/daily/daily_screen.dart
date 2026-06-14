import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_provider.dart';
import '../../models/lesson.dart';
import '../../models/sleep_log.dart';
import '../../models/social_platform.dart';
import '../../models/habit.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

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
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('Daily OS', style: GoogleFonts.inter()),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: const Color(0xFF7C5CFC).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Lessons'),
                    Tab(text: 'Sleep'),
                    Tab(text: 'Social'),
                    Tab(text: 'Habits'),
                  ],
                ),
              ),
            ),
          ),
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: lessons.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No lessons yet',
              subtitle: 'Add your first lesson to get started',
              actionLabel: 'Add Lesson',
              onAction: () => _addLesson(context, daily),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (_, i) {
                final l = lessons[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GlassCard(
                        borderRadius: 100,
                        padding: EdgeInsets.zero,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: Text(l.subject.isNotEmpty ? l.subject[0].toUpperCase() : '?', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF7C5CFC))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.subject, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(l.status, style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                          ],
                        ),
                      ),
                      if (l.status == 'pending')
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Color(0xFF7C5CFC)),
                          onPressed: () => daily.updateLesson(Lesson(
                            id: l.id, subject: l.subject, dayOfWeek: l.dayOfWeek,
                            startTime: l.startTime, endTime: l.endTime, colorHex: l.colorHex,
                            status: 'done',
                          )),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Color(0x66FFFFFF)),
                        onPressed: () => daily.deleteLesson(l.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C5CFC),
        child: const Icon(Icons.add),
        onPressed: () => _addLesson(context, daily),
      ),
    );
  }

  void _addLesson(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    int selectedDay = DateTime.now().weekday;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text('New Lesson', style: GoogleFonts.inter()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: c, decoration: const InputDecoration(labelText: 'Lesson subject')),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Day of Week'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    selectedDay = v;
                    setInner(() {});
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (c.text.isNotEmpty) {
                d.addLesson(Lesson(subject: c.text, dayOfWeek: selectedDay));
                Navigator.pop(ctx);
              }
            }, child: const Text('Add')),
          ],
        ),
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                Text('Average Sleep', style: GoogleFonts.inter(color: const Color(0x99FFFFFF), fontSize: 13)),
                const SizedBox(height: 8),
                Text('${daily.averageSleep.toStringAsFixed(1)}h', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF7C5CFC))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            EmptyState(
              icon: Icons.bedtime_outlined,
              title: 'No sleep logs',
              subtitle: 'Log your sleep to track patterns',
              actionLabel: 'Log Sleep',
              onAction: () => _logSleep(context, daily),
            )
          else
            ...logs.reversed.take(7).map((log) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.bed, color: Color(0xFF7C5CFC), size: 20),
                      const SizedBox(width: 12),
                      Text(log.date.toString().substring(0, 10), style: GoogleFonts.inter(color: Colors.white)),
                      const Spacer(),
                      Text('${log.durationHours.toStringAsFixed(1)}h', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF7C5CFC))),
                    ],
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C5CFC),
        child: const Icon(Icons.add),
        onPressed: () => _logSleep(context, daily),
      ),
    );
  }

  void _logSleep(BuildContext context, DailyProvider d) {
    final now = DateTime.now();
    TimeOfDay bedtime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);
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
              OutlinedButton.icon(
                icon: const Icon(Icons.bedtime, size: 18),
                label: Text('Bedtime: ${bedtime.format(ctx)}'),
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: bedtime);
                  if (t != null) setInner(() => bedtime = t);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.wb_sunny, size: 18),
                label: Text('Wake: ${wakeTime.format(ctx)}'),
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: wakeTime);
                  if (t != null) setInner(() => wakeTime = t);
                },
              ),
              const SizedBox(height: 16),
              Text(_sleepDuration(bedtime, wakeTime), style: const TextStyle(fontSize: 32)),
              FilledButton(
                onPressed: () {
                  final bedDT = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
                  var wakeDT = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
                  if (wakeDT.isBefore(bedDT)) wakeDT = wakeDT.add(const Duration(days: 1));
                  d.addSleepLog(SleepLog(date: DateTime(now.year, now.month, now.day), bedtime: bedDT, wakeTime: wakeDT));
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

  String _sleepDuration(TimeOfDay bed, TimeOfDay wake) {
    final bedMin = bed.hour * 60 + bed.minute;
    final wakeMin = wake.hour * 60 + wake.minute;
    final diff = wakeMin >= bedMin ? wakeMin - bedMin : (wakeMin + 1440) - bedMin;
    return '${(diff / 60).toStringAsFixed(1)}h';
  }
}

class _SocialTab extends StatelessWidget {
  final DailyProvider daily;
  const _SocialTab({required this.daily});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: daily.socialPlatforms.isEmpty
          ? EmptyState(
              icon: Icons.public_outlined,
              title: 'No platforms',
              subtitle: 'Add social platforms to track your usage',
              actionLabel: 'Add Platform',
              onAction: () => _addPlatform(context, daily),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daily.socialPlatforms.length,
              itemBuilder: (_, i) {
                final p = daily.socialPlatforms[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        child: Icon(_platformIcon(p.name), color: _platformColor(p.name), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Daily limit: ${p.dailyLimitMinutes}min', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Color(0x66FFFFFF)),
                        onPressed: () => daily.deleteSocialPlatform(p.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C5CFC),
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Today\'s Habits', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          if (daily.habits.isEmpty)
            EmptyState(
              icon: Icons.checklist_outlined,
              title: 'No habits yet',
              subtitle: 'Create habits to build your daily routine',
              actionLabel: 'Add Habit',
              onAction: () => _addHabit(context, daily),
            )
          else
            ...daily.habits.map((h) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => daily.toggleHabit(h.id),
                        child: GlassCard(
                          borderRadius: 8,
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: daily.isHabitDoneToday(h.id)
                                ? const Icon(Icons.check, size: 18, color: Color(0xFF7C5CFC))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Done ${h.completedDates.length} times', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Color(0x66FFFFFF)),
                        onPressed: () => daily.deleteHabit(h.id),
                      ),
                    ],
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C5CFC),
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
