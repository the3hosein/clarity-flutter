import 'dart:ui';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('Mind', style: GoogleFonts.inter()),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: accent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Targets'),
                    Tab(text: 'Channels'),
                    Tab(text: 'Journal'),
                  ],
                ),
              ),
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
    final target = mind.mainTarget;

    if (target == null) {
      return EmptyState(
        icon: Icons.track_changes_outlined,
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
          child: Text('"${mind.dailyQuote}"', style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: const Color(0x99FFFFFF), fontSize: 15)),
        ),
        const SizedBox(height: 16),

        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎯 My Main Target', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
              const SizedBox(height: 8),
              Text(target.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ...target.subGoals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(goal.title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white))),
                            Text('${(goal.progress * 100).round()}%', style: GoogleFonts.inter(color: accent)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AnimatedProgressBar(value: goal.progress, color: accent),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.edit, size: 16, color: accent),
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(existing != null ? 'Edit Target' : 'New Target', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(controller: titleC, style: GoogleFonts.inter(color: Colors.white), decoration: InputDecoration(labelText: 'Main Target', labelStyle: GoogleFonts.inter(color: Colors.white54))),
              const SizedBox(height: 16),
              Text('Sub-Goals', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
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
                        TextField(controller: subC[i], style: GoogleFonts.inter(color: Colors.white), decoration: InputDecoration(labelText: 'Goal', labelStyle: GoogleFonts.inter(color: Colors.white54))),
                        Slider(value: prog[i], activeColor: accent, onChanged: (v) => setInnerState(() => prog[i] = v)),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Sub-Goal'),
                onPressed: () => setInnerState(() {
                  subC.add(TextEditingController());
                  prog.add(0.0);
                }),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () {
                  final target = Target(
                    id: existing?.id,
                    title: titleC.text,
                    subGoals: List.generate(subC.length, (i) => SubGoal(
  id: existing != null && i < existing.subGoals.length ? existing.subGoals[i].id : null,
  title: subC[i].text,
  progress: prog[i]
)),
                  );
                  mind.saveTarget(target);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Channels', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: accent),
                onPressed: () => _showNewChannel(context, mind),
              ),
            ],
          ),
          if (mind.channels.isEmpty)
            EmptyState(
              icon: Icons.tag,
              title: 'No channels yet',
              subtitle: 'Create channels to organize your thoughts',
              actionLabel: 'Create Channel',
              onAction: () => _showNewChannel(context, mind),
            )
          else
            ...mind.channels.map((channel) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.zero,
                  onTap: () => _showChannelChat(context, channel, mind),
                  child: ListTile(
                    leading: GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.tag, color: accent, size: 20),
                    ),
                    title: Text(channel.name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
                    subtitle: Text('${channel.messages.length} messages', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                    trailing: const Icon(Icons.chevron_right, color: Color(0x66FFFFFF)),
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
        title: const Text('New Channel'),
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
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            Text('# ${channel.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (msgC.text.isNotEmpty) {
                        mind.addMessage(channel.id, ChannelMessage(channelId: channel.id, content: msgC.text));
                        msgC.clear();
                      }
                    },
                  ),
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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: entries.isEmpty
          ? EmptyState(
              icon: Icons.edit_note_outlined,
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
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () => _showJournalEditor(context, e, mind),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(e.title.isEmpty ? 'New Note' : e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                          Text(e.createdAt.toString().substring(0, 10), style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(e.body.replaceAll('\n', ' '), style: GoogleFonts.inter(fontSize: 14, color: const Color(0xCCFFFFFF)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C5CFC),
        child: const Icon(Icons.add),
        onPressed: () => _showJournalEditor(context, null, mind),
      ),
    );
  }

  void _showJournalEditor(BuildContext context, JournalEntry? entry, MindProvider mind) {
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              TextField(controller: titleC, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none)),
              const SizedBox(height: 8),
              TextField(controller: bodyC, maxLines: 8, decoration: const InputDecoration(hintText: 'Start writing...', border: InputBorder.none)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Mood: '),
                  ...List.generate(5, (i) => GestureDetector(
                    onTap: () => setInner(() => mood = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(['😢', '😕', '😐', '😊', '😁'][i],
                        style: TextStyle(fontSize: mood == i + 1 ? 28 : 22)),
                    ),
                  )),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      final newEntry = JournalEntry(
                        id: entry?.id,
                        title: titleC.text,
                        body: bodyC.text,
                        mood: mood,
                      );
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
