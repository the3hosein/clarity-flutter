import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';

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
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(cal.selectedDate)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Month'),
            Tab(text: 'Week'),
            Tab(text: 'Agenda'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonthView(cal: cal),
          _WeekView(cal: cal),
          _AgendaView(cal: cal),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(existing != null ? 'Edit Event' : 'New Event', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('MMM d').format(startDate)),
                      onPressed: () async {
                        final d = await showDatePicker(context: ctx, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) setInner(() { startDate = d; endDate = d; });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(startTime.format(ctx)),
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
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('MMM d').format(endDate)),
                      onPressed: () async {
                        final d = await showDatePicker(context: ctx, initialDate: endDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) setInner(() => endDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(endTime.format(ctx)),
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
                child: const Text('Save'),
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
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)))))
                .toList(),
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
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
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isToday ? Theme.of(context).colorScheme.primary : null),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
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
              Text('Events for ${DateFormat('MMM d').format(cal.selectedDate)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: () => cal.setSelectedDate(DateTime.now()), child: const Text('Today')),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: cal.eventsForDate(cal.selectedDate).isEmpty
                ? [const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No events', style: TextStyle(color: Colors.grey))))]
                : cal.eventsForDate(cal.selectedDate).map((e) => Card(
                      child: ListTile(
                        leading: Container(width: 4, height: 40, color: Theme.of(context).colorScheme.primary),
                        title: Text(e.title),
                        subtitle: Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => cal.deleteEvent(e.id),
                        ),
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

    return Column(
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
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][d.weekday % 7],
                            style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey)),
                        Text('${d.day}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : null)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(),
        // Events
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: cal.eventsForDate(cal.selectedDate).isEmpty
                ? [Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('No events', style: TextStyle(color: Colors.grey[400]))))]
                : cal.eventsForDate(cal.selectedDate).map((e) => Card(
                      child: ListTile(
                        leading: Container(width: 4, height: 40, color: Theme.of(context).colorScheme.primary),
                        title: Text(e.title),
                        subtitle: e.notes.isNotEmpty
                            ? Text(e.notes)
                            : Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => cal.deleteEvent(e.id),
                        ),
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
  const _AgendaView({required this.cal});

  @override
  Widget build(BuildContext context) {
    final sorted = List<CalendarEvent>.from(cal.events)..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (sorted.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No events', style: TextStyle(color: Colors.grey)),
          ],
        ),
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
              child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...entry.value.map((e) => Card(
                  child: ListTile(
                    leading: Container(width: 4, height: 40, color: Theme.of(context).colorScheme.primary),
                    title: Text(e.title),
                    subtitle: Text('${DateFormat('HH:mm').format(e.startDate)} - ${DateFormat('HH:mm').format(e.endDate)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => cal.deleteEvent(e.id),
                    ),
                    onTap: () => _showEventEditor(context, e, cal),
                  ),
                )),
          ],
        );
      }).toList(),
    );
  }

  void _showEventEditor(BuildContext context, CalendarEvent e, CalendarProvider cal) {
    // Reuse same logic as parent — in production extract to a method
    final calProv = cal;
    final titleC = TextEditingController(text: e.title);
    final descC = TextEditingController(text: e.notes ?? '');
    DateTime startDate = e.startDate;
    DateTime endDate = e.endDate;
    TimeOfDay startTime = TimeOfDay.fromDateTime(e.startDate);
    TimeOfDay endTime = TimeOfDay.fromDateTime(e.endDate);

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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Edit Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('MMM d').format(startDate)),
                      onPressed: () async {
                        final d = await showDatePicker(context: ctx, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) setInner(() { startDate = d; endDate = d; });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(startTime.format(ctx)),
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
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('MMM d').format(endDate)),
                      onPressed: () async {
                        final d = await showDatePicker(context: ctx, initialDate: endDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (d != null) setInner(() => endDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(endTime.format(ctx)),
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
                onPressed: () {
                  calProv.saveEvent(CalendarEvent(
                    id: e.id,
                    title: titleC.text,
                    notes: descC.text,
                    startDate: DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute),
                    endDate: DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
