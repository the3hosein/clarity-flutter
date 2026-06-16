import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = isDark ? const Color(0xFF161622) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            GestureDetector(
              onTap: () => _editProfile(context, appState),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(appState.avatarEmoji, style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appState.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 16)),
                        Text('Tap to edit profile', style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: textSecondary, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('APPEARANCE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _themeTile(context, 'System', ThemeMode.system, appState, isDark),
                  Divider(height: 0.5, color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)),
                  _themeTile(context, 'Light', ThemeMode.light, appState, isDark),
                  Divider(height: 0.5, color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)),
                  _themeTile(context, 'Dark', ThemeMode.dark, appState, isDark),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('ACCENT COLOR', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Wrap(
                spacing: 14, runSpacing: 12,
                children: ['#7B68EE', '#6C5CE7', '#007AFF', '#34C759', '#FF9500', '#FF5757'].map((hex) {
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final isActive = appState.accentColorHex == hex;
                  return GestureDetector(
                    onTap: () => appState.setAccentColor(hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: isActive ? Border.all(color: textPrimary, width: 2.5) : null,
                        boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)] : null,
                      ),
                      child: isActive ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            Text('PREFERENCES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Text('Sleep Goal', style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: Slider(
                      value: appState.sleepGoalHours, min: 4, max: 12, divisions: 16,
                      activeColor: accent,
                      label: '${appState.sleepGoalHours.toStringAsFixed(1)}h',
                      onChanged: (v) => appState.setSleepGoalHours(v),
                    ),
                  ),
                  Text('${appState.sleepGoalHours.toStringAsFixed(0)}h', style: GoogleFonts.jetBrainsMono(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(child: Text('Clarity v3.0', style: GoogleFonts.inter(color: textSecondary, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, AppState appState) {
    final nameC = TextEditingController(text: appState.userName);
    final a = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t1 = dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Edit Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: t1)),
          const SizedBox(height: 20),
          TextField(controller: nameC, style: GoogleFonts.inter(color: t1), decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          Text('Pick Avatar', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: t1)),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 8, children: ['😊', '🦁', '🐱', '🐶', '🦄', '🌟', '🔥', '🧠', '💪', '🎯'].map((e) => GestureDetector(
            onTap: () { appState.setAvatarEmoji(e); Navigator.pop(ctx); },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: appState.avatarEmoji == e ? a.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: appState.avatarEmoji == e ? Border.all(color: a) : null,
              ),
              child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
            ),
          )).toList()),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () { appState.setUserName(nameC.text); Navigator.pop(ctx); },
              child: Text('Save', style: GoogleFonts.inter()),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _themeTile(BuildContext context, String label, ThemeMode mode, AppState appState, bool isDark) {
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final accent = Theme.of(context).colorScheme.primary;
    return ListTile(
      title: Text(label, style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
      trailing: appState.themeMode == mode
          ? Icon(Icons.check_circle_rounded, color: accent, size: 22)
          : Icon(Icons.circle_outlined, color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), size: 22),
      onTap: () => appState.setThemeMode(mode),
    );
  }
}
