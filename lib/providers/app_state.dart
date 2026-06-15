import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  int _activeTab = 0;
  bool _sidebarCollapsed = false;
  ThemeMode _themeMode = ThemeMode.dark;
  String _accentColorHex = '#7C5CFC';
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
    _accentColorHex = await StorageService.loadString('accentColor', defaultValue: '#7C5CFC');
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
    (index: 0, label: 'Home', icon: Icons.house_outlined),
    (index: 1, label: 'Mind', icon: Icons.psychology_outlined),
    (index: 2, label: 'Daily', icon: Icons.wb_sunny_outlined),
    (index: 3, label: 'World', icon: Icons.language_outlined),
    (index: 4, label: 'Calendar', icon: Icons.calendar_month_outlined),
    (index: 5, label: 'Settings', icon: Icons.settings_outlined),
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
      return const Color(0xFF7C5CFC);
    }
  }

  static const _scaffoldDark = Color(0xFF0A0A0F);
  static const _surfaceDark = Color(0xFF1A1A2E);
  static const _cardGlass = Color(0x1AFFFFFF);

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: accentColor,
        scaffoldBackgroundColor: _scaffoldDark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: _cardGlass,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0x1AFFFFFF),
          elevation: 0,
          selectedItemColor: Color(0xFF7C5CFC),
          unselectedItemColor: Color(0x99FFFFFF),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: _surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x0DFFFFFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor.withValues(alpha: 0.5)),
          ),
          labelStyle: const TextStyle(color: Color(0x99FFFFFF)),
        ),
        dividerTheme: const DividerThemeData(color: Color(0x1AFFFFFF), thickness: 1),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0x1AFFFFFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: accentColor,
        scaffoldBackgroundColor: const Color(0xFFF0F0F5),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0x0A000000),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0x0A000000),
          elevation: 0,
          selectedItemColor: Color(0xFF7C5CFC),
          unselectedItemColor: Color(0x99000000),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x0A000000),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor.withValues(alpha: 0.5)),
          ),
          labelStyle: const TextStyle(color: Color(0x99000000)),
        ),
        dividerTheme: const DividerThemeData(color: Color(0x0A000000), thickness: 1),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0x0A000000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
