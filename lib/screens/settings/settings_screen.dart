import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          Card(
            child: ListTile(
              leading: Text(appState.avatarEmoji, style: const TextStyle(fontSize: 36)),
              title: Text(appState.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Tap to edit'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showProfileEdit(context, appState),
            ),
          ),
          const SizedBox(height: 16),

          // Appearance
          const Text('APPEARANCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System'),
                  value: ThemeMode.system,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Accent Color
          const Text('ACCENT COLOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
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
          ),
          const SizedBox(height: 16),

          // Preferences
          const Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Sleep Goal'),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: Slider(
                      value: appState.sleepGoalHours,
                      min: 4, max: 12, divisions: 16,
                      label: '${appState.sleepGoalHours.toStringAsFixed(1)}h',
                      onChanged: (v) => appState.setSleepGoalHours(v),
                    ),
                  ),
                  Text('${appState.sleepGoalHours.toStringAsFixed(0)}h'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // About
          Center(child: Text('Clarity v1.0', style: TextStyle(color: Colors.grey[400]))),
        ],
      ),
    );
  }

  void _showProfileEdit(BuildContext context, AppState appState) {
    final nameController = TextEditingController(text: appState.userName);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Pick Avatar', style: TextStyle(fontWeight: FontWeight.w500)),
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
            FilledButton(onPressed: () {
              appState.setUserName(nameController.text);
              Navigator.pop(ctx);
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
