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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBVGe8Bv2qVXj9YOXaMX8bdCacpqJS3qX9dYzfweIhYDhkC-Wr9bzFa7YgKpwv6JFc-ENr02rAptMIdkmq5QdM55UQi5dkAZmvJ9tnoFrJmj0_fWINhHdN4-oN5dVxWIMJsQ1S3TnYq9OVkhcOXSVpJlx3KoQMVZm8UngYzIt6RPFIYxKlL6MIiPOnjPPHd9s6zUJxQ7kbmQq3U2ZNCp1XDQqKHNAgSwOmggmxlmOiXcoDVnOIT_q1mJhZLqXLP5wL9HuNf0iwizkQ',
                    width: 32, height: 32, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 32, height: 32, color: accent, child: Icon(Icons.person, color: Colors.white, size: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Daily', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text("Today's Lessons", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                const Spacer(),
                Text('${daily.lessons.where((l) => l.status != 'done').length} Left', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
              ],
            ),
            const SizedBox(height: 12),
            ...daily.lessons.isEmpty
                ? [Container(padding: const EdgeInsets.all(20), child: Text('No lessons yet', style: GoogleFonts.inter(color: textSecondary)))]
                : daily.lessons.map((l) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(l.subject.isNotEmpty ? l.subject[0].toUpperCase() : '?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: accent))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.subject, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                            Text(l.status, style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ])),
                          if (l.status == 'pending')
                            GestureDetector(
                              onTap: () => context.read<DailyProvider>().updateLesson(Lesson(id: l.id, subject: l.subject, dayOfWeek: l.dayOfWeek, startTime: l.startTime, endTime: l.endTime, colorHex: l.colorHex, status: 'done')),
                              child: Container(
                                width: 26, height: 26,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: accent, width: 2)),
                                child: const Icon(Icons.check, size: 16, color: Colors.transparent),
                              ),
                            ),
                        ],
                      ),
                    )),
            const SizedBox(height: 24),
            Text('Sleep Reporter', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Text('Quality: Restorative', style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _statTile('Bedtime', '11:15 PM', isDark),
                      _statTile('Wake Time', '6:45 AM', isDark),
                      _statTile('Duration', '${daily.averageSleep.toStringAsFixed(1)}h', isDark, accent: accent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () => _logSleep(context, daily),
                      child: Text('Log Sleep', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Social Limits', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            ...daily.socialPlatforms.isEmpty
                ? [Container(padding: const EdgeInsets.all(20), child: Text('No platforms', style: GoogleFonts.inter(color: textSecondary)))]
                : daily.socialPlatforms.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(left: BorderSide(color: _platformColor(p.name), width: 4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: _platformColor(p.name).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(_platformIcon(p.name), color: _platformColor(p.name), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                            Text('${p.dailyLimitMinutes}min limit', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ])),
                        ],
                      ),
                    )),
            const SizedBox(height: 24),
            Text('Focus Habits', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: accent.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text('Low', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                const SizedBox(width: 16),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text('High Intensity', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(30, (i) {
                final intensity = (i % 5) / 5;
                return Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: intensity > 0.8 ? accent : (intensity > 0.4 ? accent.withOpacity(0.5) : (intensity > 0.1 ? accent.withOpacity(0.2) : (isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)))),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text('Deep Work Streak: ${daily.habits.length} days', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, bool isDark, {Color? accent}) {
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF4F3F8), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: accent ?? textSecondary)),
          ],
        ),
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

  void _logSleep(BuildContext context, DailyProvider d) {
    final now = DateTime.now();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    TimeOfDay bedtime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Log Last Night\'s Sleep', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: bedtime);
                        if (t != null) setInner(() => bedtime = t);
                      },
                      child: Text('Bed: ${bedtime.format(ctx)}', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: wakeTime);
                        if (t != null) setInner(() => wakeTime = t);
                      },
                      child: Text('Wake: ${wakeTime.format(ctx)}', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
