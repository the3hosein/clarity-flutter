DateTime _tryParse(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}

class Target {
  final String id;
  String title;
  String quote;
  List<SubGoal> subGoals;
  DateTime createdAt;

  Target({
    String? id,
    this.title = '',
    this.quote = '',
    List<SubGoal>? subGoals,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        subGoals = subGoals ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'quote': quote,
        'subGoals': subGoals.map((g) => g.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Target.fromJson(Map<String, dynamic> json) => Target(
        id: json['id'],
        title: json['title'],
        quote: json['quote'] ?? '',
        subGoals: (json['subGoals'] as List)
            .map((g) => SubGoal.fromJson(g))
            .toList(),
        createdAt: _tryParse(json['createdAt']),
      );

  Target copyWith({String? id, String? title, String? quote, List<SubGoal>? subGoals, DateTime? createdAt}) => Target(
        id: id ?? this.id, title: title ?? this.title, quote: quote ?? this.quote,
        subGoals: subGoals ?? this.subGoals, createdAt: createdAt ?? this.createdAt,
      );
}

class SubGoal {
  final String id;
  String title;
  double progress;

  SubGoal({String? id, this.title = '', this.progress = 0.0})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'progress': progress};

  factory SubGoal.fromJson(Map<String, dynamic> json) => SubGoal(
        id: json['id'],
        title: json['title'],
        progress: (json['progress'] ?? 0.0).toDouble(),
      );
}
