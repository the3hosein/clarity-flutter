import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_provider.dart';
import '../../models/lesson.dart';
import '../../models/sleep_log.dart';
import '../../models/social_platform.dart';
import '../../models/habit.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = isDark ? const Color(0xFF161622) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            _header(context, daily),
            const SizedBox(height: 24),
            _todayLessons(context, daily, accent, isDark, textPrimary, textSecondary, cardBg),
            const SizedBox(height: 24),
            _sleepReporter(context, daily, accent, isDark, textPrimary, textSecondary, cardBg),
            const SizedBox(height: 24),
            _socialLimits(context, daily, accent, isDark, textPrimary, textSecondary, cardBg),
            const SizedBox(height: 24),
            _focusHabits(context, daily, accent, isDark, textPrimary, textSecondary, cardBg),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, DailyProvider daily) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBVGe8Bv2qVXj9YOXaMX8bdCacpqJS3qX9dYzfweIhYDhkC-Wr9bzFa7YgKpwv6JFc-ENr02rAptMIdkmq5QdM55UQi5dkAZmvJ9tnoFrJmj0_fWINhHdN4-oN5dVxWIMJsQ1S3TnYq9OVkhcOXSVpJlx3KoQMVZm8UngYzIt6RPFIYxKlL6MIiPOnjPPHd9s6zUJxQ7kbmQq3U2ZNCp1XDQqKHNAgSwOmggmxlmOiXcoDVnOIT_q1mJhZLqXLP5wL9HuNf0iwizkQ',
            width: 32, height: 32, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 32, height: 32, color: Theme.of(context).colorScheme.primary, child: Icon(Icons.person, color: Colors.white, size: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Text('Daily', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _todayLessons(BuildContext c, DailyProvider d, Color a, bool dark, Color t1, Color t2, Color card) {
    return Column(
      children: [
        Row(
          children: [
            Text("Today's Lessons", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
            const Spacer(),
            Text('${d.lessons.where((l) => l.status != 'done').length} Left', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: a)),
          ],
        ),
        const SizedBox(height: 12),
        ...d.lessons.isEmpty
            ? [Container(padding: const EdgeInsets.all(20), child: Text('No lessons yet', style: GoogleFonts.inter(color: t2)))]
            : d.lessons.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
                  child: Row(
                    children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: a.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(l.subject.isNotEmpty ? l.subject[0].toUpperCase() : '?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: a)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.subject, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: t1)),
                        Text(l.status, style: GoogleFonts.inter(fontSize: 12, color: t2)),
                      ])),
                      if (l.status == 'pending')
                        GestureDetector(
                          onTap: () => d.updateLesson(Lesson(id: l.id, subject: l.subject, dayOfWeek: l.dayOfWeek, startTime: l.startTime, endTime: l.endTime, colorHex: l.colorHex, status: 'done')),
                          child: Container(width: 26, height: 26, decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: a, width: 2)),
                              child: Icon(Icons.check, size: 16, color: Colors.transparent)),
                        ),
                    ],
                  ),
                )),
        if (d.lessons.isEmpty || d.lessons.every((l) => l.status == 'done'))
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () => _addLesson(c, d),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add Lesson', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  Widget _sleepReporter(BuildContext c, DailyProvider d, Color a, bool dark, Color t1, Color t2, Color card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sleep Reporter', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
          child: Column(
            children: [
              Text('Quality: Restorative', style: GoogleFonts.inter(fontSize: 13, color: t2)),
              const SizedBox(height: 20),
              Row(children: [
                _statTile('Bedtime', '11:15 PM', dark, a),
                const SizedBox(width: 8),
                _statTile('Wake Time', '6:45 AM', dark, a),
                const SizedBox(width: 8),
                _statTile('Duration', '${d.averageSleep.toStringAsFixed(1)}h', dark, a),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => _logSleep(c, d),
                  child: Text('Log Sleep', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialLimits(BuildContext c, DailyProvider d, Color a, bool dark, Color t1, Color t2, Color card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Social Limits', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
            const Spacer(),
            GestureDetector(
              onTap: () => _addPlatform(c, d),
              child: Icon(Icons.add_rounded, color: a, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...d.socialPlatforms.isEmpty
            ? [Container(padding: const EdgeInsets.all(20), child: Text('No platforms added', style: GoogleFonts.inter(color: t2)))]
            : d.socialPlatforms.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20), border: Border(left: BorderSide(color: _platformColor(p.name), width: 4))),
                  child: Row(
                    children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: _platformColor(p.name).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(_platformIcon(p.name), color: _platformColor(p.name), size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: t1)),
                        Text('${p.dailyLimitMinutes}min limit', style: GoogleFonts.inter(fontSize: 12, color: t2)),
                      ])),
                    ],
                  ),
                )),
      ],
    );
  }

  Widget _focusHabits(BuildContext c, DailyProvider d, Color a, bool dark, Color t1, Color t2, Color card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Focus Habits', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
            const Spacer(),
            GestureDetector(
              onTap: () => _addHabit(c, d),
              child: Icon(Icons.add_rounded, color: a, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...d.habits.isEmpty
            ? [Container(padding: const EdgeInsets.all(20), child: Text('No habits yet', style: GoogleFonts.inter(color: t2)))]
            : d.habits.map((h) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => d.toggleHabit(h.id),
                        child: Container(width: 28, height: 28,
                          decoration: BoxDecoration(color: d.isHabitDoneToday(h.id) ? a : (dark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)), borderRadius: BorderRadius.circular(8)),
                          child: d.isHabitDoneToday(h.id) ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: t1)),
                        Text('Done ${h.completedDates.length} times', style: GoogleFonts.inter(fontSize: 12, color: t2)),
                      ])),
                      IconButton(icon: Icon(Icons.delete_outline_rounded, size: 20, color: t2), onPressed: () => d.deleteHabit(h.id)),
                    ],
                  ),
                )),
      ],
    );
  }

  Widget _statTile(String label, String value, bool dark, Color accent) {
    final t2 = dark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFF4F3F8), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: t2)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: accent)),
        ]),
      ),
    );
  }

  IconData _platformIcon(String name) {
    switch (name.toLowerCase()) {
      case 'instagram': return Icons.camera_alt_rounded;
      case 'youtube': return Icons.play_circle_rounded;
      case 'twitter': return Icons.alternate_email_rounded;
      default: return Icons.public_rounded;
    }
  }

  Color _platformColor(String name) {
    switch (name.toLowerCase()) {
      case 'instagram': return const Color(0xFFE1306C);
      case 'youtube': return const Color(0xFFFF0000);
      case 'twitter': return const Color(0xFF1DA1F2);
      default: return const Color(0xFF8E8EA0);
    }
  }

  void _addLesson(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    int selectedDay = DateTime.now().weekday;
    final a = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text('New Lesson', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: c, decoration: const InputDecoration(labelText: 'Lesson subject', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedDay,
              decoration: const InputDecoration(labelText: 'Day of Week', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Monday')), DropdownMenuItem(value: 2, child: Text('Tuesday')),
                DropdownMenuItem(value: 3, child: Text('Wednesday')), DropdownMenuItem(value: 4, child: Text('Thursday')),
                DropdownMenuItem(value: 5, child: Text('Friday')), DropdownMenuItem(value: 6, child: Text('Saturday')),
                DropdownMenuItem(value: 7, child: Text('Sunday')),
              ],
              onChanged: (v) { if (v != null) { selectedDay = v; setInner(() {}); } },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: a), onPressed: () {
              if (c.text.isNotEmpty) { d.addLesson(Lesson(subject: c.text, dayOfWeek: selectedDay)); Navigator.pop(ctx); }
            }, child: const Text('Add')),
          ],
        ),
      ),
    );
  }

  void _addPlatform(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    final a = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Platform', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Platform name', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: a), onPressed: () {
            if (c.text.isNotEmpty) { d.addSocialPlatform(SocialPlatform(name: c.text)); Navigator.pop(ctx); }
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _addHabit(BuildContext context, DailyProvider d) {
    final c = TextEditingController();
    final a = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Habit', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Habit name', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: a), onPressed: () {
            if (c.text.isNotEmpty) { d.addHabit(Habit(name: c.text)); Navigator.pop(ctx); }
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _logSleep(BuildContext context, DailyProvider d) {
    final now = DateTime.now();
    final a = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t1 = dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    TimeOfDay bedtime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 48, height: 4, decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("Log Last Night's Sleep", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async { final t = await showTimePicker(context: ctx, initialTime: bedtime); if (t != null) setInner(() => bedtime = t); },
                child: Text('Bed: ${bedtime.format(ctx)}', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async { final t = await showTimePicker(context: ctx, initialTime: wakeTime); if (t != null) setInner(() => wakeTime = t); },
                child: Text('Wake: ${wakeTime.format(ctx)}', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              )),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  final bedDT = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
                  var wakeDT = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
                  if (wakeDT.isBefore(bedDT)) wakeDT = wakeDT.add(const Duration(days: 1));
                  d.addSleepLog(SleepLog(date: DateTime(now.year, now.month, now.day), bedtime: bedDT, wakeTime: wakeDT));
                  Navigator.pop(ctx);
                },
                child: Text('Save Entry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
