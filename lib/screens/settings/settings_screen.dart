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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('Settings', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => _showProfileEdit(context, appState),
            child: Row(
              children: [
                Text(appState.avatarEmoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                      Text('Tap to edit', style: GoogleFonts.inter(fontSize: 13, color: const Color(0x99FFFFFF))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('APPEARANCE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0x99FFFFFF))),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('System', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                  activeColor: const Color(0xFF7C5CFC),
                  value: ThemeMode.system,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                RadioListTile<ThemeMode>(
                  title: Text('Light', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                  activeColor: const Color(0xFF7C5CFC),
                  value: ThemeMode.light,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                RadioListTile<ThemeMode>(
                  title: Text('Dark', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                  activeColor: const Color(0xFF7C5CFC),
                  value: ThemeMode.dark,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Accent Color
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('ACCENT COLOR', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0x99FFFFFF))),
          ),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16, runSpacing: 12,
              children: ['#007AFF', '#AF52DE', '#34C759', '#FF9500', '#FF3B30', '#FF2D55'].map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isActive = appState.accentColorHex == hex;
                return GestureDetector(
                  onTap: () => appState.setAccentColor(hex),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isActive ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Preferences
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('PREFERENCES', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0x99FFFFFF))),
          ),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Sleep Goal', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: appState.sleepGoalHours,
                    min: 4, max: 12, divisions: 16,
                    activeColor: const Color(0xFF7C5CFC),
                    label: '${appState.sleepGoalHours.toStringAsFixed(1)}h',
                    onChanged: (v) => appState.setSleepGoalHours(v),
                  ),
                ),
                Text('${appState.sleepGoalHours.toStringAsFixed(0)}h', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // About
          Center(child: Text('Clarity v1.0', style: GoogleFonts.inter(color: const Color(0x99FFFFFF)))),
        ],
      ),
    );
  }

  void _showProfileEdit(BuildContext context, AppState appState) {
    final nameController = TextEditingController(text: appState.userName);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Edit Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: GoogleFonts.inter(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
              ),
            ),
            const SizedBox(height: 16),
            Text('Pick Avatar', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: ['😊', '🦁', '🐱', '🐶', '🦄', '🌟', '🔥', '🧠', '💪', '🎯'].map((e) => GestureDetector(
                onTap: () {
                  appState.setAvatarEmoji(e);
                  Navigator.pop(ctx);
                },
                child: Text(e, style: const TextStyle(fontSize: 32)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C5CFC)),
              onPressed: () {
                appState.setUserName(nameController.text);
                Navigator.pop(ctx);
              },
              child: Text('Save', style: GoogleFonts.inter()),
            ),
          ],
        ),
      ),
    );
  }
}
