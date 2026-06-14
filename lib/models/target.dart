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
        createdAt: DateTime.parse(json['createdAt']),
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
