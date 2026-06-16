import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/mind_provider.dart';
import '../../models/target.dart';
import '../../models/journal_entry.dart';
import '../../models/channel.dart';

class MindScreen extends StatelessWidget {
  const MindScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mind = context.watch<MindProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = isDark ? const Color(0xFF161622) : const Color(0xFFFAFAF8);
    final target = mind.mainTarget;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCkZbkBPBu9iO1S2-DDw18hI-FwDBn6a2GlcPzE0g1ThgN43_4703sJ-MErZyjCH1w8PBeeA33Yk8VDywMaT5bCehnzrnHFPOKOz_csLl66lxoBjtTwf2G5eU5kTW05-8puNASsDg8B-0kegPeP1La9wiSpEwVFfdCMscvMNpH59W7a3qw1gFHZwxwmOmCqWgNtV8PTx9ccLS5lumn-2Gzshu0q-Jt4smBpr0LNle4BFkLaP9IsJOQ_ocRgvXZM91OyX2QHJ80985Q',
                    width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Mind', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary)),
                const Spacer(),
                Icon(Icons.search_rounded, color: textSecondary),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Main Target', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Priority 1', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Goal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                  const SizedBox(height: 4),
                  Text(target?.title ?? 'Set Your Main Target', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary)),
                  if (target != null) ...[
                    const SizedBox(height: 20),
                    ...target.subGoals.map((g) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(g.title, style: GoogleFonts.inter(fontSize: 13, color: textSecondary))),
                                  Text('${(g.progress * 100).round()}%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 6,
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(3)),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: g.progress,
                                  child: Container(decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(3))),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          onPressed: () => _showTargetEdit(context, target, mind),
                          icon: Icon(Icons.bolt_rounded, size: 18),
                          label: Text('Continue Focus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          onPressed: () => _showTargetEdit(context, target, mind),
                          child: Text('Details', style: GoogleFonts.inter(color: textSecondary)),
                        ),
                      ],
                    ),
                  ] else
                    const SizedBox(height: 12),
                ],
              ),
            ),
            if (target == null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => _showTargetEdit(context, null, mind),
                  child: Text('Add Target', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text('Thought Channels', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _channelCircle(Icons.lightbulb_rounded, 'Ideas', accent, true, null, null),
                  _channelCircle(Icons.school_rounded, 'Study', accent, false, null, null),
                  _channelCircle(Icons.palette_rounded, 'Inspo', accent, false, null, null),
                  _channelCircle(Icons.add_rounded, 'New', accent, false, context, mind),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C2B).withOpacity(0.5) : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF2A2A3D) : Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFEEEDF3), borderRadius: BorderRadius.circular(18)),
                    child: Text('What if the sidebar could collapse into a single floating icon when not in use?', style: GoogleFonts.inter(fontSize: 14, color: textSecondary)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(18)),
                      child: Text('Great idea! We could use a spring animation.', style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: TextField(
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a quick thought...',
                        hintStyle: GoogleFonts.inter(color: textSecondary),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        suffixIcon: Icon(Icons.send_rounded, color: accent, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text('Daily Journal', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                const Spacer(),
                Text('View All', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C2B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A3D).withOpacity(0.3) : const Color(0xFFF4F3F8).withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Text('How are you feeling?', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('🤩', style: TextStyle(fontSize: 28)),
                            Text('😊', style: TextStyle(fontSize: 28)),
                            Text('😌', style: TextStyle(fontSize: 28)),
                            Text('🤔', style: TextStyle(fontSize: 28)),
                            Text('😴', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ...mind.journalEntries.take(3).map((e) => InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A3D) : Colors.black.withOpacity(0.05)))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title.isEmpty ? 'New Note' : e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                                    Text(e.body.replaceAll('\n', ' '), style: GoogleFonts.inter(fontSize: 14, color: textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Text(e.createdAt.toString().substring(11, 16), style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelCircle(IconData icon, String label, Color accent, bool active, BuildContext? context, MindProvider? mind) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: active ? accent : (context != null ? Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A3D) : const Color(0xFFE3E2E7) : accent.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, color: active ? Colors.white : accent, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: active ? accent : null)),
        ],
      ),
    );
  }

  void _showTargetEdit(BuildContext context, Target? existing, MindProvider mind) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            TextField(controller: titleC, style: GoogleFonts.inter(fontSize: 18), decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  mind.saveTarget(Target(id: existing?.id, title: titleC.text, subGoals: existing?.subGoals ?? []));
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
