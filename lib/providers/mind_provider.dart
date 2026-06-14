import 'package:flutter/material.dart';
import '../models/target.dart';
import '../models/journal_entry.dart';
import '../models/channel.dart';
import '../services/storage_service.dart';

class MindProvider extends ChangeNotifier {
  List<Target> _targets = [];
  List<JournalEntry> _journalEntries = [];
  List<Channel> _channels = [];

  List<Target> get targets => _targets;
  List<JournalEntry> get journalEntries => _journalEntries;
  List<Channel> get channels => _channels;

  Target? get mainTarget => _targets.isNotEmpty ? _targets.first : null;

  Future<void> load() async {
    _targets = await StorageService.loadList('targets', Target.fromJson);
    _journalEntries = await StorageService.loadList('journalEntries', JournalEntry.fromJson);
    _channels = await StorageService.loadList('channels', Channel.fromJson);
    notifyListeners();
  }

  Future<void> saveTarget(Target target) async {
    if (_targets.isEmpty) {
      _targets.add(target);
    } else {
      _targets[0] = target;
    }
    await StorageService.saveList('targets', _targets, (t) => t.toJson());
    notifyListeners();
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    final index = _journalEntries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      _journalEntries[index] = entry;
    } else {
      _journalEntries.insert(0, entry);
    }
    await StorageService.saveList('journalEntries', _journalEntries, (e) => e.toJson());
    notifyListeners();
  }

  Future<void> deleteJournalEntry(String id) async {
    _journalEntries.removeWhere((e) => e.id == id);
    await StorageService.saveList('journalEntries', _journalEntries, (e) => e.toJson());
    notifyListeners();
  }

  Future<void> addChannel(Channel channel) async {
    _channels.add(channel);
    await StorageService.saveList('channels', _channels, (c) => c.toJson());
    notifyListeners();
  }

  Future<void> deleteChannel(String id) async {
    _channels.removeWhere((c) => c.id == id);
    await StorageService.saveList('channels', _channels, (c) => c.toJson());
    notifyListeners();
  }

  Future<void> addMessage(String channelId, ChannelMessage message) async {
    final channel = _channels.firstWhere((c) => c.id == channelId);
    channel.messages.add(message);
    await StorageService.saveList('channels', _channels, (c) => c.toJson());
    notifyListeners();
  }

  static const quotes = [
    'The secret of getting ahead is getting started.',
    'Success is not final, failure is not fatal.',
    'Believe you can and you\'re halfway there.',
    'The only way to do great work is to love what you do.',
    'It does not matter how slowly you go as long as you do not stop.',
    'The future belongs to those who believe in the beauty of their dreams.',
    'You are never too old to set another goal or to dream a new dream.',
    'Act as if what you do makes a difference. It does.',
  ];

  String get dailyQuote {
    final day = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    return quotes[day % quotes.length];
  }
}
