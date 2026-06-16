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
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;
    final border = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Daily OS', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 0.5),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              dividerHeight: 0,
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
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final lessons = daily.lessons;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: lessons.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_rounded,
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
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: accent.withOpacity( 0.12), borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(l.subject.isNotEmpty ? l.subject[0].toUpperCase() : '?',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: accent, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.subject, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                            const SizedBox(height: 2),
                            Text(l.status, style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      if (l.status == 'pending')
                        IconButton(
                          icon: Icon(Icons.check_circle_outline_rounded, color: accent, size: 22),
                          onPressed: () => daily.updateLesson(Lesson(
                            id: l.id, subject: l.subject, dayOfWeek: l.dayOfWeek,
                            startTime: l.startTime, endTime: l.endTime, colorHex: l.colorHex,
                            status: 'done',
                          )),
                        ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 20, color: textSecondary),
                        onPressed: () => daily.deleteLesson(l.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addLesson(context, daily),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _addLesson(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    int selectedDay = DateTime.now().weekday;
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text('New Lesson', style: GoogleFonts.spaceGrotesk(color: textPrimary)),
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
                onChanged: (v) { if (v != null) { selectedDay = v; setInner(() {}); } },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
              if (c.text.isNotEmpty) { d.addLesson(Lesson(subject: c.text, dayOfWeek: selectedDay)); Navigator.pop(ctx); }
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
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final logs = daily.sleepLogs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Average Sleep', style: GoogleFonts.inter(color: textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Text('${daily.averageSleep.toStringAsFixed(1)}h', style: GoogleFonts.jetBrainsMono(fontSize: 36, fontWeight: FontWeight.w700, color: accent)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            EmptyState(
              icon: Icons.bedtime_rounded,
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
                      Icon(Icons.bed_rounded, color: accent, size: 20),
                      const SizedBox(width: 12),
                      Text(log.date.toString().substring(0, 10), style: GoogleFonts.inter(color: textPrimary)),
                      const Spacer(),
                      Text('${log.durationHours.toStringAsFixed(1)}h', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, color: accent)),
                    ],
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logSleep(context, daily),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _logSleep(BuildContext context, DailyProvider d) {
    final now = DateTime.now();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
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
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Log Sleep', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(Icons.bedtime_rounded, size: 18, color: textSecondary),
                label: Text('Bedtime: ${bedtime.format(ctx)}', style: GoogleFonts.inter(color: textPrimary)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: bedtime);
                  if (t != null) setInner(() => bedtime = t);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: Icon(Icons.wb_sunny_rounded, size: 18, color: textSecondary),
                label: Text('Wake: ${wakeTime.format(ctx)}', style: GoogleFonts.inter(color: textPrimary)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: wakeTime);
                  if (t != null) setInner(() => wakeTime = t);
                },
              ),
              const SizedBox(height: 16),
              Text(_sleepDuration(bedtime, wakeTime), style: GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final bedDT = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
                    var wakeDT = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
                    if (wakeDT.isBefore(bedDT)) wakeDT = wakeDT.add(const Duration(days: 1));
                    d.addSleepLog(SleepLog(date: DateTime(now.year, now.month, now.day), bedtime: bedDT, wakeTime: wakeDT));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Log'),
                ),
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
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: daily.socialPlatforms.isEmpty
          ? EmptyState(
              icon: Icons.public_rounded,
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
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: _platformColor(p.name).withOpacity( 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(_platformIcon(p.name), color: _platformColor(p.name), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                            const SizedBox(height: 2),
                            Text('Daily limit: ${p.dailyLimitMinutes}min', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 20, color: textSecondary),
                        onPressed: () => daily.deleteSocialPlatform(p.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPlatform(context, daily),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  IconData _platformIcon(String name) {
    switch (name.toLowerCase()) {
      case 'instagram': return Icons.camera_alt_rounded;
      case 'youtube': return Icons.play_circle_rounded;
      case 'twitter': return Icons.alternate_email_rounded;
      case 'github': return Icons.code_rounded;
      default: return Icons.public_rounded;
    }
  }

  Color _platformColor(String name) {
    switch (name.toLowerCase()) {
      case 'instagram': return const Color(0xFFE1306C);
      case 'youtube': return const Color(0xFFFF0000);
      case 'twitter': return const Color(0xFF1DA1F2);
      case 'github': return const Color(0xFF8E8EA0);
      default: return const Color(0xFF8E8EA0);
    }
  }

  void _addPlatform(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Platform', style: GoogleFonts.spaceGrotesk()),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Platform name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
            if (c.text.isNotEmpty) { d.addSocialPlatform(SocialPlatform(name: c.text)); Navigator.pop(ctx); }
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
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final ringBg = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Today's Habits", style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 12),
          if (daily.habits.isEmpty)
            EmptyState(
              icon: Icons.checklist_rounded,
              title: 'No habits yet',
              subtitle: 'Create habits to build your daily routine',
              actionLabel: 'Add Habit',
              onAction: () => _addHabit(context, daily),
            )
          else
            ...daily.habits.map((h) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => daily.toggleHabit(h.id),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: daily.isHabitDoneToday(h.id) ? accent : ringBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: daily.isHabitDoneToday(h.id)
                              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                            const SizedBox(height: 2),
                            Text('Done ${h.completedDates.length} times', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 20, color: textSecondary),
                        onPressed: () => daily.deleteHabit(h.id),
                      ),
                    ],
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addHabit(context, daily),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _addHabit(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Habit', style: GoogleFonts.spaceGrotesk()),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Habit name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
            if (c.text.isNotEmpty) { d.addHabit(Habit(name: c.text)); Navigator.pop(ctx); }
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}
