import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../providers/mind_provider.dart';
import '../providers/daily_provider.dart';
import '../providers/world_provider.dart';
import '../providers/calendar_provider.dart';
import 'home/dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'mind/mind_screen.dart';
import 'daily/daily_screen.dart';
import 'world/world_screen.dart';
import 'calendar/calendar_screen.dart';
import '../widgets/glass_card.dart';

class AdaptiveLayoutScreen extends StatefulWidget {
  const AdaptiveLayoutScreen({super.key});

  @override
  State<AdaptiveLayoutScreen> createState() => _AdaptiveLayoutScreenState();
}

class _AdaptiveLayoutScreenState extends State<AdaptiveLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MindProvider>().load();
      context.read<DailyProvider>().load();
      context.read<WorldProvider>().load();
      context.read<CalendarProvider>().load();
    });
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
    return Row(
      children: [
        _Sidebar(
          activeTab: appState.activeTab,
          collapsed: appState.sidebarCollapsed,
          onTabChanged: (i) => appState.setActiveTab(i),
          onToggle: () => appState.toggleSidebar(),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildContent(appState)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, AppState appState) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        ),
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

  const _Sidebar({
    required this.activeTab,
    required this.collapsed,
    required this.onTabChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tabs = appState.tabs;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: collapsed ? 72 : 220,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: collapsed ? 18 : 24,
                    backgroundColor: Colors.transparent,
                    child: Text(appState.avatarEmoji, style: const TextStyle(fontSize: 28)),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(height: 4),
                    Text(
                      appState.userName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ...tabs.map((tab) => _SidebarItem(
                        icon: tab.icon,
                        label: tab.label,
                        isActive: activeTab == tab.index,
                        collapsed: collapsed,
                        onTap: () => onTabChanged(tab.index),
                      )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(collapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios, size: 16, color: Colors.white70),
                    onPressed: onToggle,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
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

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? accent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: accent.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: isActive ? accent : Colors.white70),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.white70,
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...tabs.map((tab) => GestureDetector(
                        onTap: () => onTabChanged(tab.index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeTab == tab.index ? accent.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: activeTab == tab.index ? Border.all(color: accent.withOpacity(0.3)) : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab.icon,
                                size: 22,
                                color: activeTab == tab.index ? accent : Colors.white54,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: activeTab == tab.index ? FontWeight.w600 : FontWeight.normal,
                                  color: activeTab == tab.index ? accent : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
