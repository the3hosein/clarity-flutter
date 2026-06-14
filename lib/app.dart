import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/adaptive_layout.dart';

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          title: 'Clarity',
          debugShowCheckedModeBanner: false,
          theme: appState.lightTheme,
          darkTheme: appState.darkTheme,
          themeMode: appState.effectiveThemeMode,
          home: const AdaptiveLayoutScreen(),
        );
      },
    );
  }
}
