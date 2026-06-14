import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_state.dart';
import 'providers/mind_provider.dart';
import 'providers/daily_provider.dart';
import 'providers/world_provider.dart';
import 'providers/calendar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  final mindProvider = MindProvider();
  final dailyProvider = DailyProvider();
  final worldProvider = WorldProvider();
  final calendarProvider = CalendarProvider();

  try {
    await appState.load();
  } catch (_) {}
  try {
    await mindProvider.load();
  } catch (_) {}
  try {
    await dailyProvider.load();
  } catch (_) {}
  try {
    await worldProvider.load();
  } catch (_) {}
  try {
    await calendarProvider.load();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: mindProvider),
        ChangeNotifierProvider.value(value: dailyProvider),
        ChangeNotifierProvider.value(value: worldProvider),
        ChangeNotifierProvider.value(value: calendarProvider),
      ],
      child: const ClarityApp(),
    ),
  );
}
