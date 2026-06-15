import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: () => _showProfileEdit(context, appState),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(appState.avatarEmoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                      Text('Tap to edit profile', style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: textSecondary, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Appearance
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('APPEARANCE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1)),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('System', style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                  activeColor: accent,
                  value: ThemeMode.system,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
                Divider(height: 0.5, color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)),
                RadioListTile<ThemeMode>(
                  title: Text('Light', style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                  activeColor: accent,
                  value: ThemeMode.light,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
                Divider(height: 0.5, color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0)),
                RadioListTile<ThemeMode>(
                  title: Text('Dark', style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                  activeColor: accent,
                  value: ThemeMode.dark,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Accent Color
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('ACCENT COLOR', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1)),
          ),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 14,
              runSpacing: 12,
              children: ['#7B68EE', '#6C5CE7', '#007AFF', '#34C759', '#FF9500', '#FF5757'].map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isActive = appState.accentColorHex == hex;
                return GestureDetector(
                  onTap: () => appState.setAccentColor(hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isActive ? Border.all(color: textPrimary, width: 2.5) : null,
                      boxShadow: isActive ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)] : null,
                    ),
                    child: isActive ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),

          // Preferences
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('PREFERENCES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1)),
          ),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Sleep Goal', style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: appState.sleepGoalHours,
                    min: 4,
                    max: 12,
                    divisions: 16,
                    activeColor: accent,
                    label: '${appState.sleepGoalHours.toStringAsFixed(1)}h',
                    onChanged: (v) => appState.setSleepGoalHours(v),
                  ),
                ),
                Text(
                  '${appState.sleepGoalHours.toStringAsFixed(0)}h',
                  style: GoogleFonts.jetBrainsMono(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // About
          Center(
            child: Text(
              'Clarity v2.0',
              style: GoogleFonts.inter(color: textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileEdit(BuildContext context, AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final nameController = TextEditingController(text: appState.userName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Edit Profile', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: GoogleFonts.inter(color: textPrimary),
              decoration: InputDecoration(labelText: 'Name', labelStyle: GoogleFonts.inter(color: textSecondary)),
            ),
            const SizedBox(height: 16),
            Text('Pick Avatar', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: ['😊', '🦁', '🐱', '🐶', '🦄', '🌟', '🔥', '🧠', '💪', '🎯'].map((e) => GestureDetector(
                onTap: () {
                  appState.setAvatarEmoji(e);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appState.avatarEmoji == e ? accent.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: appState.avatarEmoji == e ? Border.all(color: accent) : null,
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  appState.setUserName(nameController.text);
                  Navigator.pop(ctx);
                },
                child: Text('Save', style: GoogleFonts.inter()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
