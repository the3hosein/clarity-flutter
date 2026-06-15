import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/mind_provider.dart';
import '../../widgets/animated_progress.dart';
import '../../models/target.dart';
import '../../models/journal_entry.dart';
import '../../models/channel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

class MindScreen extends StatefulWidget {
  const MindScreen({super.key});

  @override
  State<MindScreen> createState() => _MindScreenState();
}

class _MindScreenState extends State<MindScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;
    final border = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Mind', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 0.5),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Targets'),
                Tab(text: 'Channels'),
                Tab(text: 'Journal'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TargetsTab(),
          _ChannelsTab(),
          _JournalTab(),
        ],
      ),
    );
  }
}

class _TargetsTab extends StatelessWidget {
  const _TargetsTab();

  @override
  Widget build(BuildContext context) {
    final mind = context.watch<MindProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final target = mind.mainTarget;

    if (target == null) {
      return EmptyState(
        icon: Icons.track_changes_rounded,
        title: 'Set Your Main Target',
        subtitle: 'Define a target and track your progress',
        actionLabel: 'Add Target',
        onAction: () => _showTargetEdit(context, null, mind),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Text('"${mind.dailyQuote}"', style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: textSecondary, fontSize: 14)),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.flag_rounded, size: 18, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Text('My Main Target', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Text(target.title, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 16),
              ...target.subGoals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(goal.title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textPrimary))),
                            Text('${(goal.progress * 100).round()}%', style: GoogleFonts.jetBrainsMono(color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AnimatedProgressBar(value: goal.progress, color: accent),
                      ],
                    ),
                  )),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.edit_rounded, size: 16, color: accent),
                  label: Text('Edit', style: GoogleFonts.inter(color: accent)),
                  onPressed: () => _showTargetEdit(context, target, mind),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTargetEdit(BuildContext context, Target? existing, MindProvider mind) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final titleC = TextEditingController(text: existing?.title ?? '');
    final subC = List<TextEditingController>.generate(
        existing?.subGoals.length ?? 1, (i) => TextEditingController(text: existing?.subGoals[i].title ?? ''));
    final prog = List<double>.from(existing?.subGoals.map((g) => g.progress) ?? [0.0]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInnerState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(existing != null ? 'Edit Target' : 'New Target', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
              const SizedBox(height: 20),
              TextField(controller: titleC, style: GoogleFonts.inter(color: textPrimary), decoration: InputDecoration(labelText: 'Main Target', labelStyle: GoogleFonts.inter(color: textSecondary))),
              const SizedBox(height: 16),
              Text('Sub-Goals', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textPrimary)),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subC.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        TextField(controller: subC[i], style: GoogleFonts.inter(color: textPrimary), decoration: InputDecoration(labelText: 'Goal', labelStyle: GoogleFonts.inter(color: textSecondary))),
                        Slider(value: prog[i], activeColor: accent, onChanged: (v) => setInnerState(() => prog[i] = v)),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.add_rounded, color: accent),
                label: Text('Add Sub-Goal', style: GoogleFonts.inter(color: accent)),
                onPressed: () => setInnerState(() { subC.add(TextEditingController()); prog.add(0.0); }),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final target = Target(
                      id: existing?.id,
                      title: titleC.text,
                      subGoals: List.generate(subC.length, (i) => SubGoal(
                        id: existing != null && i < existing.subGoals.length ? existing.subGoals[i].id : null,
                        title: subC[i].text, progress: prog[i],
                      )),
                    );
                    mind.saveTarget(target);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelsTab extends StatelessWidget {
  const _ChannelsTab();

  @override
  Widget build(BuildContext context) {
    final mind = context.watch<MindProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Channels', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: accent),
                onPressed: () => _showNewChannel(context, mind),
              ),
            ],
          ),
          if (mind.channels.isEmpty)
            EmptyState(
              icon: Icons.tag_rounded,
              title: 'No channels yet',
              subtitle: 'Create channels to organize your thoughts',
              actionLabel: 'Create Channel',
              onAction: () => _showNewChannel(context, mind),
            )
          else
            ...mind.channels.map((channel) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () => _showChannelChat(context, channel, mind),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.tag_rounded, color: accent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(channel.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                            Text('${channel.messages.length} messages', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  void _showNewChannel(BuildContext context, MindProvider mind) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Channel', style: GoogleFonts.spaceGrotesk()),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Channel name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              mind.addChannel(Channel(name: c.text));
              Navigator.pop(ctx);
            }
          }, child: const Text('Create')),
        ],
      ),
    );
  }

  void _showChannelChat(BuildContext context, Channel channel, MindProvider mind) {
    final msgC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            Text('# ${channel.name}', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(
              height: 300,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: channel.messages.map((m) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C2B) : const Color(0xFFF0F0F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.content),
                        Text(m.timestamp.toString().substring(11, 16), style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: msgC, decoration: const InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder()))),
                  IconButton(icon: const Icon(Icons.send_rounded), onPressed: () {
                    if (msgC.text.isNotEmpty) {
                      mind.addMessage(channel.id, ChannelMessage(channelId: channel.id, content: msgC.text));
                      msgC.clear();
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalTab extends StatelessWidget {
  const _JournalTab();

  @override
  Widget build(BuildContext context) {
    final mind = context.watch<MindProvider>();
    final entries = mind.journalEntries;
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: entries.isEmpty
          ? EmptyState(
              icon: Icons.edit_note_rounded,
              title: 'No entries yet',
              subtitle: 'Start journaling to capture your thoughts',
              actionLabel: 'New Entry',
              onAction: () => _showJournalEditor(context, null, mind),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () => _showJournalEditor(context, e, mind),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(e.title.isEmpty ? 'New Note' : e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary)),
                          ),
                          Text(e.createdAt.toString().substring(0, 10), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(e.body.replaceAll('\n', ' '), style: GoogleFonts.inter(fontSize: 14, color: textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJournalEditor(context, null, mind),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showJournalEditor(BuildContext context, JournalEntry? entry, MindProvider mind) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final titleC = TextEditingController(text: entry?.title ?? '');
    final bodyC = TextEditingController(text: entry?.body ?? '');
    int mood = entry?.mood ?? 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              TextField(controller: titleC, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary), decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none)),
              const SizedBox(height: 8),
              TextField(controller: bodyC, maxLines: 8, style: GoogleFonts.inter(color: textPrimary), decoration: const InputDecoration(hintText: 'Start writing...', border: InputBorder.none)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Mood: ', style: GoogleFonts.inter(color: textPrimary)),
                  ...List.generate(5, (i) => GestureDetector(
                    onTap: () => setInner(() => mood = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(['😢', '😕', '😐', '😊', '😁'][i], style: TextStyle(fontSize: mood == i + 1 ? 28 : 22)),
                    ),
                  )),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: () {
                      final newEntry = JournalEntry(id: entry?.id, title: titleC.text, body: bodyC.text, mood: mood);
                      mind.saveJournalEntry(newEntry);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
