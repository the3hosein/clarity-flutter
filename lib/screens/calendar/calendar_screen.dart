import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<CalendarProvider>().setViewMode(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;
    final border = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(cal.selectedDate), style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 0.5),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, color: textSecondary),
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Month'),
                Tab(text: 'Week'),
                Tab(text: 'Agenda'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonthView(cal: cal),
          _WeekView(cal: cal),
          _AgendaView(cal: cal, onEditEvent: (e) => _showEventEditor(context, e, cal)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventEditor(context, null, cal),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showEventEditor(BuildContext context, CalendarEvent? existing, CalendarProvider cal) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final titleC = TextEditingController(text: existing?.title ?? '');
    final descC = TextEditingController(text: existing?.notes ?? '');
    DateTime startDate = existing?.startDate ?? DateTime.now();
    DateTime endDate = existing?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    TimeOfDay startTime = TimeOfDay.fromDateTime(existing?.startDate ?? DateTime.now());
    TimeOfDay endTime = TimeOfDay.fromDateTime(existing?.endDate ?? DateTime.now().add(const Duration(hours: 1)));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(existing != null ? 'Edit Event' : 'New Event', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
              const SizedBox(height: 20),
              TextField(
                controller: titleC,
                style: GoogleFonts.inter(color: textPrimary),
                decoration: InputDecoration(labelText: 'Title', labelStyle: GoogleFonts.inter(color: textSecondary)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                style: GoogleFonts.inter(color: textPrimary),
                decoration: InputDecoration(labelText: 'Description', labelStyle: GoogleFonts.inter(color: textSecondary)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today_rounded, size: 16, color: textSecondary),
                      label: Text(DateFormat('MMM d').format(startDate), style: GoogleFonts.inter(color: textPrimary, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(context: ctx, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) setInner(() { startDate = d; });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                      label: Text(startTime.format(ctx), style: GoogleFonts.inter(color: textPrimary, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: startTime);
                        if (t != null) setInner(() => startTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today_rounded, size: 16, color: textSecondary),
                      label: Text(DateFormat('MMM d').format(endDate), style: GoogleFonts.inter(color: textPrimary, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(context: ctx, initialDate: endDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) setInner(() => endDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                      label: Text(endTime.format(ctx), style: GoogleFonts.inter(color: textPrimary, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: endTime);
                        if (t != null) setInner(() => endTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final event = CalendarEvent(
                      id: existing?.id,
                      title: titleC.text,
                      notes: descC.text,
                      startDate: DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute),
                      endDate: DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute),
                    );
                    cal.saveEvent(event);
                    Navigator.pop(ctx);
                  },
                  child: Text('Save', style: GoogleFonts.inter()),
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

class _MonthView extends StatelessWidget {
  final CalendarProvider cal;
  const _MonthView({required this.cal});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;
    final border = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    final firstDay = DateTime(cal.selectedDate.year, cal.selectedDate.month, 1);
    final lastDay = DateTime(cal.selectedDate.year, cal.selectedDate.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final totalDays = lastDay.day;

    final daysBefore = List.generate(startWeekday, (_) => null);
    final days = List.generate(totalDays, (i) => DateTime(cal.selectedDate.year, cal.selectedDate.month, i + 1));
    final allCells = [...daysBefore, ...days];
    final weeks = (allCells.length / 7).ceil();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary)),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: weeks * 7,
            itemBuilder: (_, i) {
              final d = i < allCells.length ? allCells[i] : null;
              if (d == null) return const SizedBox();
              final today = DateTime.now();
              final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
              final isSelected = d.year == cal.selectedDate.year && d.month == cal.selectedDate.month && d.day == cal.selectedDate.day;
              final hasEvent = cal.events.any((e) => e.startDate.year == d.year && e.startDate.month == d.month && e.startDate.day == d.day);

              return GestureDetector(
                onTap: () => cal.setSelectedDate(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : (isToday ? accent.withValues(alpha: 0.12) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${d.day}',
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : (isToday ? accent : textPrimary),
                          fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      if (hasEvent && !isSelected)
                        Container(
                          width: 4, height: 4,
                          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text('Events for ${DateFormat('MMM d').format(cal.selectedDate)}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
              const Spacer(),
              TextButton(
                onPressed: () => cal.setSelectedDate(DateTime.now()),
                child: Text('Today', style: GoogleFonts.inter(color: accent, fontSize: 13)),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: cal.eventsForDate(cal.selectedDate).isEmpty
                ? [const EmptyState(icon: Icons.event_busy_rounded, title: 'No Events', subtitle: 'Tap + to add an event')]
                : cal.eventsForDate(cal.selectedDate).map((e) => GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(width: 3, height: 36, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}',
                                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
                            onPressed: () => cal.deleteEvent(e.id),
                          ),
                        ],
                      ),
                    )).toList(),
          ),
        ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  final CalendarProvider cal;
  const _WeekView({required this.cal});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final weekStart = cal.selectedDate.subtract(Duration(days: cal.selectedDate.weekday % 7));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: weekDays.map((d) {
              final isSelected = d.day == cal.selectedDate.day && d.month == cal.selectedDate.month;
              return Expanded(
                child: GestureDetector(
                  onTap: () => cal.setSelectedDate(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(['S', 'M', 'T', 'W', 'T', 'F', 'S'][d.weekday % 7],
                            style: GoogleFonts.inter(fontSize: 11, color: isSelected ? Colors.white : textSecondary)),
                        const SizedBox(height: 2),
                        Text('${d.day}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : textPrimary, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: cal.eventsForDate(cal.selectedDate).isEmpty
                ? [const EmptyState(icon: Icons.event_busy_rounded, title: 'No Events', subtitle: 'Tap + to add an event')]
                : cal.eventsForDate(cal.selectedDate).map((e) => GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(width: 3, height: 36, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
                                const SizedBox(height: 2),
                                e.notes.isNotEmpty
                                    ? Text(e.notes, style: GoogleFonts.inter(fontSize: 12, color: textSecondary))
                                    : Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}',
                                        style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
                            onPressed: () => cal.deleteEvent(e.id),
                          ),
                        ],
                      ),
                    )).toList(),
          ),
        ),
      ],
    );
  }
}

class _AgendaView extends StatelessWidget {
  final CalendarProvider cal;
  final void Function(CalendarEvent) onEditEvent;
  const _AgendaView({required this.cal, required this.onEditEvent});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final sorted = List<CalendarEvent>.from(cal.events)..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (sorted.isEmpty) {
      return const EmptyState(icon: Icons.event_busy_rounded, title: 'No Events', subtitle: 'Your calendar is clear');
    }

    final grouped = <String, List<CalendarEvent>>{};
    for (final e in sorted) {
      final key = DateFormat('EEEE, MMMM d').format(e.startDate);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(entry.key, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary)),
            ),
            ...entry.value.map((e) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () => onEditEvent(e),
                  child: Row(
                    children: [
                      Container(width: 3, height: 36, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}',
                                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
                        onPressed: () => cal.deleteEvent(e.id),
                      ),
                    ],
                  ),
                )),
          ],
        );
      }).toList(),
    );
  }
}
