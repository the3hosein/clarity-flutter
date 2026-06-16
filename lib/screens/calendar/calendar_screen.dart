import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = isDark ? const Color(0xFF161622) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;

    final now = DateTime.now();
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              children: [
                Text('Calendar', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: textPrimary),
                  onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                ),
                Text(DateFormat('MMMM yyyy').format(_focusedMonth), style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: textPrimary),
                  onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) =>
                      SizedBox(width: 36, child: Center(child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary))))
                    ).toList(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    ((startWeekday + daysInMonth) / 7).ceil(),
                    (weekIndex) {
                      final children = <Widget>[];
                      for (int d = 0; d < 7; d++) {
                        final day = weekIndex * 7 + d - startWeekday + 1;
                        if (day < 1 || day > daysInMonth) {
                          children.add(const SizedBox(width: 36, height: 36));
                        } else {
                          final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                          final hasEvent = cal.events.any((e) => e.startDate.day == day && e.startDate.month == _focusedMonth.month);
                          children.add(
                            GestureDetector(
                              onTap: () => _showDayDetail(context, date, cal),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: isToday ? accent : (hasEvent ? accent.withOpacity(0.12) : Colors.transparent),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text('$day', style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                                    color: isToday ? Colors.white : textPrimary,
                                  )),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: children),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Upcoming', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _addEvent(context, cal),
                  child: Icon(Icons.add_rounded, color: accent, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cal.events.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Center(child: Text('No events yet', style: GoogleFonts.inter(color: textSecondary))),
              )
            else
              ...cal.events.where((e) => e.startDate.isAfter(now.subtract(const Duration(days: 1)))).take(5).map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(left: BorderSide(color: accent, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                            Text('${DateFormat('MMM d').format(e.startDate)} · ${DateFormat('HH:mm').format(e.startDate)}', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, CalendarProvider cal) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final events = cal.events.where((e) => e.startDate.day == date.day && e.startDate.month == date.month).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 48, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(DateFormat('EEEE, MMMM d').format(date), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 16),
            if (events.isEmpty)
              Text('No events', style: GoogleFonts.inter(color: textSecondary))
            else
              ...events.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C2B) : const Color(0xFFF4F3F8), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                        const Spacer(),
                        Text(DateFormat('HH:mm').format(e.startDate), style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () { Navigator.pop(ctx); _addEvent(context, cal); },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add Event', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent(BuildContext context, CalendarProvider cal) {
    final titleC = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            TextField(controller: titleC, style: GoogleFonts.inter(color: textPrimary), decoration: InputDecoration(labelText: 'Event title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  if (titleC.text.isNotEmpty) {
                    cal.addEvent(CalendarEvent(title: titleC.text, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(hours: 1))));
                    Navigator.pop(ctx);
                  }
                },
                child: Text('Add Event', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
