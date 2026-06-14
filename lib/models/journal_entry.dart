DateTime _tryParse(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}

class JournalEntry {
  final String id;
  String title;
  String body;
  int mood;
  List<String> tags;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;

  JournalEntry({
    String? id,
    this.title = "",
    this.body = "",
    this.mood = 3,
    List<String>? tags,
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "id": id, "title": title, "body": body, "mood": mood,
        "tags": tags, "isPinned": isPinned,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j["id"], title: j["title"], body: j["body"], mood: j["mood"],
        tags: List<String>.from(j["tags"] ?? []), isPinned: j["isPinned"] ?? false,
        createdAt: _tryParse(j["createdAt"]),
        updatedAt: _tryParse(j["updatedAt"]),
      );

  JournalEntry copyWith({String? id, String? title, String? body, int? mood, List<String>? tags, bool? isPinned, DateTime? createdAt, DateTime? updatedAt}) => JournalEntry(
        id: id ?? this.id, title: title ?? this.title, body: body ?? this.body,
        mood: mood ?? this.mood, tags: tags ?? this.tags, isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
      );
}

