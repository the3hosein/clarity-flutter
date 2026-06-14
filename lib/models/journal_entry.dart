import "dart:convert";

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
        createdAt: DateTime.parse(j["createdAt"]),
        updatedAt: DateTime.parse(j["updatedAt"]),
      );
}
