import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  int _activeTab = 0;
  bool _sidebarCollapsed = false;
  ThemeMode _themeMode = ThemeMode.dark;
  String _accentColorHex = '#7B68EE';
  String _userName = 'Hossein';
  String _avatarEmoji = '🧠';
  double _sleepGoalHours = 8.0;
  String? _toastMessage;
  bool _showToast = false;
  Timer? _toastTimer;
  bool _isLoading = false;

  Future<void> load() async {
    final themeName = await StorageService.loadString('themeMode');
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeName,
      orElse: () => ThemeMode.dark,
    );
    _accentColorHex = await StorageService.loadString('accentColor', defaultValue: '#7B68EE');
    _userName = await StorageService.loadString('userName', defaultValue: 'Hossein');
    _avatarEmoji = await StorageService.loadString('avatarEmoji', defaultValue: '🧠');
    _sleepGoalHours = await StorageService.loadDouble('sleepGoal', defaultValue: 8.0);
  }

  int get activeTab => _activeTab;
  bool get sidebarCollapsed => _sidebarCollapsed;
  ThemeMode get themeMode => _themeMode;
  ThemeMode get effectiveThemeMode => _themeMode;
  String get accentColorHex => _accentColorHex;
  String get userName => _userName;
  String get avatarEmoji => _avatarEmoji;
  double get sleepGoalHours => _sleepGoalHours;
  String? get toastMessage => _toastMessage;
  bool get showToast => _showToast;
  bool get isLoading => _isLoading;

  List<({int index, String label, IconData icon})> get tabs => const [
    (index: 0, label: 'Home', icon: Icons.home_rounded),
    (index: 1, label: 'Mind', icon: Icons.psychology_rounded),
    (index: 2, label: 'Daily', icon: Icons.wb_sunny_rounded),
    (index: 3, label: 'World', icon: Icons.explore_rounded),
    (index: 4, label: 'Calendar', icon: Icons.calendar_month_rounded),
    (index: 5, label: 'Settings', icon: Icons.settings_rounded),
  ];

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 22) return 'Good evening';
    return 'Good night';
  }

  Color get accentColor {
    try {
      return Color(int.parse(_accentColorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7B68EE);
    }
  }

  static const _scaffoldDark = Color(0xFF0D0D14);
  static const _surfaceDark = Color(0xFF161622);
  static const _cardDark = Color(0xFF1C1C2B);
  static const _borderDark = Color(0xFF2A2A3D);

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: accentColor,
        scaffoldBackgroundColor: _scaffoldDark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: _cardDark,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _scaffoldDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFFF1F1F6)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceDark,
          elevation: 0,
          selectedItemColor: Color(0xFF7B68EE),
          unselectedItemColor: Color(0xFF5C5C6F),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: _surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x0AFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor),
          ),
          labelStyle: const TextStyle(color: Color(0xFF8E8EA0)),
          hintStyle: const TextStyle(color: Color(0xFF5C5C6F)),
        ),
        dividerTheme: const DividerThemeData(color: _borderDark, thickness: 0.5),
        chipTheme: ChipThemeData(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: _borderDark),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _cardDark,
          contentTextStyle: GoogleFonts.inter(color: const Color(0xFFF1F1F6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: accentColor,
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5F5FA),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Color(0xFF6C5CE7),
          unselectedItemColor: Color(0xFF9B9BB0),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x08000000),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
          ),
          labelStyle: const TextStyle(color: Color(0xFF6B6B80)),
          hintStyle: const TextStyle(color: Color(0xFF9B9BB0)),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFE8E8F0), thickness: 0.5),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Color(0xFFE8E8F0)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          contentTextStyle: GoogleFonts.inter(color: const Color(0xFF1A1A2E)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarCollapsed = !_sidebarCollapsed;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    StorageService.saveString('themeMode', mode.name);
    notifyListeners();
  }

  void setAccentColor(String hex) {
    _accentColorHex = hex;
    StorageService.saveString('accentColor', hex);
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    StorageService.saveString('userName', name);
    notifyListeners();
  }

  void setAvatarEmoji(String emoji) {
    _avatarEmoji = emoji;
    StorageService.saveString('avatarEmoji', emoji);
    notifyListeners();
  }

  void setSleepGoalHours(double hours) {
    _sleepGoalHours = hours;
    StorageService.saveDouble('sleepGoal', hours);
    notifyListeners();
  }

  void showSuccess(String message) {
    _toastTimer?.cancel();
    _toastMessage = message;
    _showToast = true;
    notifyListeners();
    _toastTimer = Timer(const Duration(seconds: 2), () {
      _showToast = false;
      notifyListeners();
    });
  }

  void dismissToast() {
    _showToast = false;
    _toastTimer?.cancel();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
