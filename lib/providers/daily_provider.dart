import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/sleep_log.dart';
import '../models/social_platform.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

class DailyProvider extends ChangeNotifier {
  List<Lesson> _lessons = [];
  List<SleepLog> _sleepLogs = [];
  List<SocialPlatform> _platforms = [];
  List<Habit> _habits = [];

  List<Lesson> get lessons => _lessons;
  List<SleepLog> get sleepLogs => _sleepLogs;
  List<SocialPlatform> get platforms => _platforms;
  List<Habit> get habits => _habits;

  Future<void> load() async {
    _lessons = await StorageService.loadList('lessons', Lesson.fromJson);
    _sleepLogs = await StorageService.loadList('sleepLogs', SleepLog.fromJson);
    _platforms = await StorageService.loadList('socialPlatforms', SocialPlatform.fromJson);
    _habits = await StorageService.loadList('habits', Habit.fromJson);
    notifyListeners();
  }

  List<Lesson> get todayLessons {
    final today = DateTime.now().weekday % 7;
    return _lessons.where((l) => l.dayOfWeek == today).toList();
  }

  int get doneToday => _lessons.where((l) => l.status == 'done').length;
  double get weeklyProgress => _lessons.isEmpty ? 0 : doneToday / _lessons.length;

  Future<void> addLesson(Lesson lesson) async {
    _lessons.add(lesson);
    await _saveLessons();
    notifyListeners();
  }

  Future<void> updateLesson(Lesson lesson) async {
    final i = _lessons.indexWhere((l) => l.id == lesson.id);
    if (i >= 0) _lessons[i] = lesson;
    await _saveLessons();
    notifyListeners();
  }

  Future<void> deleteLesson(String id) async {
    _lessons.removeWhere((l) => l.id == id);
    await _saveLessons();
    notifyListeners();
  }

  Future<void> _saveLessons() async {
    await StorageService.saveList('lessons', _lessons, (l) => l.toJson());
  }

  Future<void> addSleepLog(SleepLog log) async {
    _sleepLogs.insert(0, log);
    await StorageService.saveList('sleepLogs', _sleepLogs, (s) => s.toJson());
    notifyListeners();
  }

  Future<void> updateSleepLog(SleepLog log) async {
    final i = _sleepLogs.indexWhere((s) => s.id == log.id);
    if (i >= 0) _sleepLogs[i] = log;
    await StorageService.saveList('sleepLogs', _sleepLogs, (s) => s.toJson());
    notifyListeners();
  }

  Future<void> deleteSleepLog(String id) async {
    _sleepLogs.removeWhere((s) => s.id == id);
    await StorageService.saveList('sleepLogs', _sleepLogs, (s) => s.toJson());
    notifyListeners();
  }

  double get averageSleep => _sleepLogs.isEmpty ? 0 : _sleepLogs.map((s) => s.durationHours).reduce((a, b) => a + b) / _sleepLogs.length;
  double get bestNight => _sleepLogs.isEmpty ? 0 : _sleepLogs.map((s) => s.durationHours).reduce((a, b) => a > b ? a : b);
  double get worstNight => _sleepLogs.isEmpty ? 0 : _sleepLogs.map((s) => s.durationHours).reduce((a, b) => a < b ? a : b);

  List<SocialPlatform> get socialPlatforms => _platforms;

  Future<void> addPlatform(SocialPlatform platform) async {
    _platforms.add(platform);
    await _savePlatforms();
    notifyListeners();
  }

  Future<void> addSocialPlatform(SocialPlatform platform) async {
    await addPlatform(platform);
  }

  Future<void> updateSocialPlatform(SocialPlatform platform) async {
    final i = _platforms.indexWhere((p) => p.id == platform.id);
    if (i >= 0) _platforms[i] = platform;
    await _savePlatforms();
    notifyListeners();
  }

  Future<void> updatePlatformMinutes(String id, double minutes) async {
    final i = _platforms.indexWhere((p) => p.id == id);
    if (i >= 0) _platforms[i].todayMinutes = minutes;
    await _savePlatforms();
    notifyListeners();
  }

  Future<void> deleteSocialPlatform(String id) async {
    _platforms.removeWhere((p) => p.id == id);
    await _savePlatforms();
    notifyListeners();
  }

  Future<void> _savePlatforms() async {
    await StorageService.saveList('socialPlatforms', _platforms, (p) => p.toJson());
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> toggleHabit(String id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    final today = DateTime.now();
    final existing = habit.completedDates.indexWhere((d) => isSameDay(d, today));
    if (existing >= 0) {
      habit.completedDates.removeAt(existing);
    } else {
      habit.completedDates.add(today);
    }
    await _saveHabits();
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    await StorageService.saveList('habits', _habits, (h) => h.toJson());
  }

  bool isHabitDoneToday(String id) {
    final habit = _habits.firstWhere((h) => h.id == id);
    return habit.completedDates.any((d) => isSameDay(d, DateTime.now()));
  }

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
