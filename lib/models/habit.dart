DateTime _tryParse(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}

class Habit {
  final String id;
  String name;
  List<DateTime> completedDates;
  DateTime createdAt;

  Habit({String? id, this.name = "", List<DateTime>? completedDates, DateTime? createdAt})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "id": id, "name": name,
        "completedDates": completedDates.map((d) => d.toIso8601String()).toList(),
        "createdAt": createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j["id"], name: j["name"],
        completedDates: (j["completedDates"] as List).map((d) => _tryParse(d)).toList(),
        createdAt: _tryParse(j["createdAt"]),
      );

  Habit copyWith({String? id, String? name, List<DateTime>? completedDates, DateTime? createdAt}) => Habit(
        id: id ?? this.id, name: name ?? this.name,
        completedDates: completedDates ?? this.completedDates, createdAt: createdAt ?? this.createdAt,
      );
}

