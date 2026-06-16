import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'home/dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'mind/mind_screen.dart';
import 'daily/daily_screen.dart';
import 'world/world_screen.dart';
import 'calendar/calendar_screen.dart';

class AdaptiveLayoutScreen extends StatefulWidget {
  const AdaptiveLayoutScreen({super.key});

  @override
  State<AdaptiveLayoutScreen> createState() => _AdaptiveLayoutScreenState();
}

class _AdaptiveLayoutScreenState extends State<AdaptiveLayoutScreen> {
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.addListener(_onAppStateChanged);
    });
  }

  void _onAppStateChanged() {
    final appState = context.read<AppState>();
    if (appState.showToast) {
      _toastTimer?.cancel();
      try {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(appState.toastMessage ?? '', style: GoogleFonts.inter()),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (_) {}
      _toastTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) context.read<AppState>().dismissToast();
      });
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isWide = MediaQuery.of(context).size.width > 768;

    if (isWide) {
      return _buildWideLayout(context, appState);
    }
    return _buildNarrowLayout(context, appState);
  }

  Widget _buildWideLayout(BuildContext context, AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _Sidebar(
          activeTab: appState.activeTab,
          collapsed: appState.sidebarCollapsed,
          onTabChanged: (i) => appState.setActiveTab(i),
          onToggle: () => appState.toggleSidebar(),
          isDark: isDark,
        ),
        Container(width: 0.5, color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)),
        Expanded(child: _buildContent(appState)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, AppState appState) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: _buildContent(appState),
      ),
      bottomNavigationBar: _BottomTabBar(
        activeTab: appState.activeTab,
        onTabChanged: (i) => appState.setActiveTab(i),
      ),
    );
  }

  Widget _buildContent(AppState appState) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (appState.activeTab) {
      case 0: return const DashboardScreen();
      case 1: return const MindScreen();
      case 2: return const DailyScreen();
      case 3: return const WorldScreen();
      case 4: return const CalendarScreen();
      case 5: return const SettingsScreen();
      default: return const DashboardScreen();
    }
  }
}

class _Sidebar extends StatelessWidget {
  final int activeTab;
  final bool collapsed;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onToggle;
  final bool isDark;

  const _Sidebar({
    required this.activeTab,
    required this.collapsed,
    required this.onTabChanged,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tabs = appState.tabs;
    final accent = Theme.of(context).colorScheme.primary;
    final bgColor = isDark ? const Color(0xFF161622) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final activeBg = accent.withOpacity( 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: collapsed ? 72 : 220,
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            if (!collapsed) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Clarity',
                  style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 16),
            ],
            CircleAvatar(
              radius: collapsed ? 16 : 20,
              backgroundColor: activeBg,
              child: Text(appState.avatarEmoji, style: const TextStyle(fontSize: 22)),
            ),
            if (!collapsed) ...[
              const SizedBox(height: 8),
              Text(appState.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textColor, fontSize: 14)),
            ],
            const SizedBox(height: 24),
            ...tabs.map((tab) => _SidebarItem(
                  icon: tab.icon,
                  label: tab.label,
                  isActive: activeTab == tab.index,
                  collapsed: collapsed,
                  onTap: () => onTabChanged(tab.index),
                  accent: accent,
                  isDark: isDark,
                )),
            const Spacer(),
            IconButton(
              icon: Icon(
                collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                size: 20,
                color: textSecondary,
              ),
              onPressed: onToggle,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;
  final Color accent;
  final bool isDark;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final activeBg = accent.withOpacity( 0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isActive ? accent : textSecondary),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? textColor : textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const _BottomTabBar({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tabs = appState.tabs.toList();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF161622) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF5C5C6F) : const Color(0xFF9B9BB0);
    final activeBg = accent.withOpacity( 0.12);
    final borderColor = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) {
              final isActive = activeTab == tab.index;
              return GestureDetector(
                onTap: () => onTabChanged(tab.index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? activeBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 22,
                        color: isActive ? accent : textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? accent : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
