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
    final a = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t1 = dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final t2 = dark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = dark ? const Color(0xFF161622) : const Color(0xFFFAFAF8);
    final card = dark ? const Color(0xFF1C1C2B) : Colors.white;
    final target = mind.mainTarget;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            _header(context),
            const SizedBox(height: 24),
            _mainTarget(context, mind, a, dark, t1, t2, card),
            const SizedBox(height: 28),
            _thoughtChannels(context, mind, a, dark, t1, t2, card),
            const SizedBox(height: 28),
            _dailyJournal(context, mind, a, dark, t1, t2, card),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t1 = dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final a = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCkZbkBPBu9iO1S2-DDw18hI-FwDBn6a2GlcPzE0g1ThgN43_4703sJ-MErZyjCH1w8PBeeA33Yk8VDywMaT5bCehnzrnHFPOKOz_csLl66lxoBjtTwf2G5eU5kTW05-8puNASsDg8B-0kegPeP1La9wiSpEwVFfdCMscvMNpH59W7a3qw1gFHZwxwmOmCqWgNtV8PTx9ccLS5lumn-2Gzshu0q-Jt4smBpr0LNle4BFkLaP9IsJOQ_ocRgvXZM91OyX2QHJ80985Q',
            width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: a.withOpacity(0.1), borderRadius: BorderRadius.circular(16))),
          ),
        ),
        const SizedBox(width: 12),
        Text('Mind', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: t1)),
      ],
    );
  }

  Widget _mainTarget(BuildContext c, MindProvider mind, Color a, bool dark, Color t1, Color t2, Color card) {
    final target = mind.mainTarget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Main Target', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: a.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('Priority 1', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: a)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Goal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: t2)),
              const SizedBox(height: 4),
              Text(target?.title ?? 'Set Your Main Target', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: t1)),
              if (target != null) ...[
                const SizedBox(height: 20),
                ...target.subGoals.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(child: Text(g.title, style: GoogleFonts.inter(fontSize: 13, color: t2))),
                            Text('${(g.progress * 100).round()}%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: a)),
                          ]),
                          const SizedBox(height: 8),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(3)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: g.progress,
                              child: Container(decoration: BoxDecoration(color: a, borderRadius: BorderRadius.circular(3))),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Row(children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => _showTargetEdit(c, target, mind),
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: Text('Continue Focus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => _showTargetEdit(c, target, mind),
                    child: Text('Details', style: GoogleFonts.inter(color: t2)),
                  ),
                ]),
              ],
              if (target == null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => _showTargetEdit(c, null, mind),
                    child: Text('Add Target', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _thoughtChannels(BuildContext c, MindProvider mind, Color a, bool dark, Color t1, Color t2, Color card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thought Channels', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...mind.channels.take(3).map((ch) => _channelCircle(ch, a, dark, t1)),
              _channelCircleAdd(c, mind, a, dark, t1),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: card.withOpacity(0.5), borderRadius: BorderRadius.circular(24), border: Border.all(color: dark ? const Color(0xFF2A2A3D) : Colors.black.withOpacity(0.05))),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFEEEDF3), borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    Expanded(child: Text(mind.channels.isNotEmpty && mind.channels.first.messages.isNotEmpty
                        ? mind.channels.first.messages.last.content
                        : 'Start a thought...', style: GoogleFonts.inter(fontSize: 14, color: t2))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: a, borderRadius: BorderRadius.circular(18)),
                  child: Text('Tap a channel to chat', style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _channelCircle(Channel ch, Color a, bool dark, Color t1) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: a.withOpacity(0.15), borderRadius: BorderRadius.circular(28)),
            child: Icon(Icons.tag_rounded, color: a, size: 28),
          ),
          const SizedBox(height: 6),
          Text(ch.name, style: GoogleFonts.inter(fontSize: 11, color: t1)),
        ],
      ),
    );
  }

  Widget _channelCircleAdd(BuildContext c, MindProvider mind, Color a, bool dark, Color t1) {
    return GestureDetector(
      onTap: () => _createChannel(c, mind),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFE3E2E7), borderRadius: BorderRadius.circular(28)),
              child: Icon(Icons.add_rounded, color: a, size: 28),
            ),
            const SizedBox(height: 6),
            Text('New', style: GoogleFonts.inter(fontSize: 11, color: t1)),
          ],
        ),
      ),
    );
  }

  Widget _dailyJournal(BuildContext c, MindProvider mind, Color a, bool dark, Color t1, Color t2, Color card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Daily Journal', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: t1)),
            const Spacer(),
            GestureDetector(
              onTap: () => _newJournalEntry(c, mind),
              child: Icon(Icons.add_rounded, color: a, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D).withOpacity(0.3) : const Color(0xFFF4F3F8).withOpacity(0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  children: [
                    Text('How are you feeling?', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: t2)),
                    const SizedBox(height: 12),
                    _moodSelector(c, mind),
                  ],
                ),
              ),
              ...mind.journalEntries.take(3).map((e) => InkWell(
                    onTap: () => _editJournalEntry(c, e, mind),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: dark ? const Color(0xFF2A2A3D) : Colors.black.withOpacity(0.05)))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.title.isEmpty ? 'New Note' : e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: t1)),
                            Text(e.body.replaceAll('\n', ' '), style: GoogleFonts.inter(fontSize: 14, color: t2), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                          Text(e.createdAt.toString().substring(11, 16), style: GoogleFonts.inter(fontSize: 12, color: t2)),
                        ],
                      ),
                    ),
                  )),
              if (mind.journalEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text('No entries yet', style: GoogleFonts.inter(color: t2))),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moodSelector(BuildContext c, MindProvider mind) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _moodEmoji(c, '🤩', 5, mind),
        _moodEmoji(c, '😊', 4, mind),
        _moodEmoji(c, '😌', 3, mind),
        _moodEmoji(c, '🤔', 2, mind),
        _moodEmoji(c, '😴', 1, mind),
      ],
    );
  }

  Widget _moodEmoji(BuildContext c, String emoji, int value, MindProvider mind) {
    return GestureDetector(
      onTap: () => mind.setCurrentMood(value),
      child: Opacity(
        opacity: mind.currentMood == value ? 1.0 : 0.4,
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  void _createChannel(BuildContext c, MindProvider mind) {
    final tc = TextEditingController();
    final a = Theme.of(c).colorScheme.primary;
    showDialog(
      context: c,
      builder: (ctx) => AlertDialog(
        title: Text('New Channel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(controller: tc, decoration: const InputDecoration(labelText: 'Channel name', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: a), onPressed: () {
            if (tc.text.isNotEmpty) { mind.addChannel(Channel(name: tc.text)); Navigator.pop(ctx); }
          }, child: const Text('Create')),
        ],
      ),
    );
  }

  void _newJournalEntry(BuildContext c, MindProvider mind) {
    _showJournalEditor(c, null, mind);
  }

  void _editJournalEntry(BuildContext c, JournalEntry entry, MindProvider mind) {
    _showJournalEditor(c, entry, mind);
  }

  void _showJournalEditor(BuildContext c, JournalEntry? entry, MindProvider mind) {
    final titleC = TextEditingController(text: entry?.title ?? '');
    final bodyC = TextEditingController(text: entry?.body ?? '');
    final a = Theme.of(c).colorScheme.primary;
    final dark = Theme.of(c).brightness == Brightness.dark;
    final t1 = dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);

    showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          TextField(controller: titleC, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: t1), decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none)),
          const SizedBox(height: 8),
          TextField(controller: bodyC, maxLines: 6, style: GoogleFonts.inter(color: t1), decoration: const InputDecoration(hintText: 'Start writing...', border: InputBorder.none)),
          const SizedBox(height: 12),
          Row(children: [
            const Spacer(),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: a), onPressed: () {
              mind.saveJournalEntry(JournalEntry(id: entry?.id, title: titleC.text, body: bodyC.text, mood: mind.currentMood));
              Navigator.pop(ctx);
            }, child: const Text('Save')),
          ]),
        ]),
      ),
    );
  }

  void _showTargetEdit(BuildContext context, Target? existing, MindProvider mind) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final a = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t1 = dark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: dark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          TextField(controller: titleC, style: GoogleFonts.inter(fontSize: 18, color: t1), decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(style: FilledButton.styleFrom(backgroundColor: a, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () {
              mind.saveTarget(Target(id: existing?.id, title: titleC.text, subGoals: existing?.subGoals ?? []));
              Navigator.pop(ctx);
            }, child: const Text('Save')),
          ),
        ]),
      ),
    );
  }
}
