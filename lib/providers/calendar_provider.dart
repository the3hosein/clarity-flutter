import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/storage_service.dart';

class CalendarProvider extends ChangeNotifier {
  List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();
  int _viewMode = 0; // 0=month, 1=week, 2=agenda

  List<CalendarEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;
  int get viewMode => _viewMode;

  Future<void> load() async {
    _events = await StorageService.loadList('calendarEvents', CalendarEvent.fromJson);
    notifyListeners();
  }

  void setViewMode(int mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> saveEvent(CalendarEvent event) async {
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i >= 0) {
      _events[i] = event;
    } else {
      _events.add(event);
    }
    await StorageService.saveList('calendarEvents', _events, (e) => e.toJson());
    notifyListeners();
  }

  Future<void> addEvent(CalendarEvent event) async {
    _events.add(event);
    await StorageService.saveList('calendarEvents', _events, (e) => e.toJson());
    notifyListeners();
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i >= 0) _events[i] = event;
    await StorageService.saveList('calendarEvents', _events, (e) => e.toJson());
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await StorageService.saveList('calendarEvents', _events, (e) => e.toJson());
    notifyListeners();
  }

  List<CalendarEvent> eventsForDate(DateTime date) {
    return _events.where((e) =>
        e.startDate.year == date.year &&
        e.startDate.month == date.month &&
        e.startDate.day == date.day).toList();
  }

  CalendarEvent? get nextEvent {
    final now = DateTime.now();
    final upcoming = _events.where((e) => e.startDate.isAfter(now)).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.first;
  }
}
