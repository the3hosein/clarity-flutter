import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mind_provider.dart';
import '../../widgets/animated_progress.dart';
import '../../models/target.dart';
import '../../models/journal_entry.dart';
import '../../models/channel.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Targets'),
            Tab(text: 'Channels'),
            Tab(text: 'Journal'),
          ],
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
    final target = mind.mainTarget;

    if (target == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.track_changes_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Set Your Main Target', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            FilledButton(onPressed: () => _showTargetEdit(context, null, mind), child: const Text('Add Target')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quote
        Card(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('"${mind.dailyQuote}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
          ),
        ),
        const SizedBox(height: 16),

        // Main target
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 My Main Target', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(target.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...target.subGoals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w500))),
                              Text('${(goal.progress * 100).round()}%'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedProgressBar(value: goal.progress, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    onPressed: () => _showTargetEdit(context, target, mind),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTargetEdit(BuildContext context, Target? existing, MindProvider mind) {
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
              Text(existing != null ? 'Edit Target' : 'New Target', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Main Target', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const Text('Sub-Goals', style: TextStyle(fontWeight: FontWeight.w500)),
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
                        TextField(controller: subC[i], decoration: const InputDecoration(labelText: 'Goal', border: OutlineInputBorder())),
                        Slider(value: prog[i], onChanged: (v) => setInnerState(() => prog[i] = v)),
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
                onPressed: () {
                  final target = Target(
                    id: existing?.id,
                    title: titleC.text,
                    subGoals: List.generate(subC.length, (i) => SubGoal(id: existing?.subGoals[i].id, title: subC[i].text, progress: prog[i])),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Channels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showNewChannel(context, mind),
            ),
          ],
        ),
        if (mind.channels.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Text('No channels yet', style: TextStyle(color: Colors.grey[400])),
            ),
          )
        else
          ...mind.channels.map((channel) => Card(
                child: ListTile(
                  leading: const Icon(Icons.tag, color: Colors.blue),
                  title: Text(channel.name),
                  subtitle: Text('${channel.messages.length} messages'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChannelChat(context, channel, mind),
                ),
              )),
      ],
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No entries yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                return Card(
                  child: ListTile(
                    title: Text(e.title.isEmpty ? 'New Note' : e.title),
                    subtitle: Text(e.body.replaceAll('\n', ' '), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(e.createdAt.toString().substring(0, 10), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () => _showJournalEditor(context, e, mind),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
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
