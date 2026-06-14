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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text(DateFormat('MMMM yyyy').format(cal.selectedDate), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF7C5CFC),
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
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
        backgroundColor: const Color(0xFF7C5CFC),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showEventEditor(context, null, cal),
      ),
    );
  }

  void _showEventEditor(BuildContext context, CalendarEvent? existing, CalendarProvider cal) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final descC = TextEditingController(text: existing?.notes ?? '');
    DateTime startDate = existing?.startDate ?? DateTime.now();
    DateTime endDate = existing?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    TimeOfDay startTime = TimeOfDay.fromDateTime(existing?.startDate ?? DateTime.now());
    TimeOfDay endTime = TimeOfDay.fromDateTime(existing?.endDate ?? DateTime.now().add(const Duration(hours: 1)));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(existing != null ? 'Edit Event' : 'New Event', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: titleC,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.inter(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.inter(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.white54),
                      label: Text(DateFormat('MMM d').format(startDate), style: GoogleFonts.inter(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
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
                      icon: const Icon(Icons.access_time, size: 18, color: Colors.white54),
                      label: Text(startTime.format(ctx), style: GoogleFonts.inter(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: startTime);
                        if (t != null) setInner(() => startTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.white54),
                      label: Text(DateFormat('MMM d').format(endDate), style: GoogleFonts.inter(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
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
                      icon: const Icon(Icons.access_time, size: 18, color: Colors.white54),
                      label: Text(endTime.format(ctx), style: GoogleFonts.inter(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: endTime);
                        if (t != null) setInner(() => endTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C5CFC)),
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
        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(child: Center(child: Text(d, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0x99FFFFFF))))))
                .toList(),
          ),
        ),
        // Grid
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
              final hasEvent = cal.events.any((e) =>
                  e.startDate.year == d.year && e.startDate.month == d.month && e.startDate.day == d.day);

              return GestureDetector(
                onTap: () => cal.setSelectedDate(d),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7C5CFC) : const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${d.day}',
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : (isToday ? const Color(0xFF7C5CFC) : Colors.white),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          width: 5, height: 5,
                          decoration: const BoxDecoration(color: Color(0xFF7C5CFC), shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Events for selected day
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Events for ${DateFormat('MMM d').format(cal.selectedDate)}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
              const Spacer(),
              TextButton(
                onPressed: () => cal.setSelectedDate(DateTime.now()),
                child: Text('Today', style: GoogleFonts.inter(color: const Color(0xFF7C5CFC))),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: cal.eventsForDate(cal.selectedDate).isEmpty
                ? [EmptyState(
                    icon: Icons.event_busy,
                    title: 'No Events',
                    subtitle: 'Tap + to add an event for this day.',
                  )]
                : cal.eventsForDate(cal.selectedDate).map((e) => GlassCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C5CFC), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}',
                                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0x99FFFFFF))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.white54,
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
    final weekStart = cal.selectedDate.subtract(Duration(days: cal.selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Column(
        children: [
          // Week header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: weekDays.map((d) {
                final isSelected = d.day == cal.selectedDate.day;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => cal.setSelectedDate(d),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C5CFC) : const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        children: [
                          Text(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][d.weekday % 7],
                              style: GoogleFonts.inter(fontSize: 11, color: isSelected ? Colors.white : const Color(0x99FFFFFF))),
                          Text('${d.day}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Events
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: cal.eventsForDate(cal.selectedDate).isEmpty
                  ? [EmptyState(
                      icon: Icons.event_busy,
                      title: 'No Events',
                      subtitle: 'Tap + to add an event for this day.',
                    )]
                  : cal.eventsForDate(cal.selectedDate).map((e) => GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C5CFC), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  e.notes.isNotEmpty
                                      ? Text(e.notes, style: GoogleFonts.inter(fontSize: 11, color: const Color(0x99FFFFFF)))
                                      : Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}',
                                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0x99FFFFFF))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.white54,
                              onPressed: () => cal.deleteEvent(e.id),
                            ),
                          ],
                        ),
                      )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaView extends StatelessWidget {
  final CalendarProvider cal;
  final void Function(CalendarEvent) onEditEvent;
  const _AgendaView({required this.cal, required this.onEditEvent});

  @override
  Widget build(BuildContext context) {
    final sorted = List<CalendarEvent>.from(cal.events)..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (sorted.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        title: 'No Events',
        subtitle: 'Your calendar is clear. Tap + to add an event.',
      );
    }

    // Group by date
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(entry.key, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
            ...entry.value.map((e) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onTap: () => onEditEvent(e),
                  child: Row(
                    children: [
                      Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C5CFC), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0x99FFFFFF))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.white54,
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
