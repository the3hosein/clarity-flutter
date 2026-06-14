class SocialPlatform {
  final String id;
  String name;
  String iconName;
  double dailyLimitMinutes;
  double todayMinutes;
  Map<String, double> weeklyLog;

  SocialPlatform({String? id, this.name = "", this.iconName = "", this.dailyLimitMinutes = 60, this.todayMinutes = 0, Map<String, double>? weeklyLog})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        weeklyLog = weeklyLog ?? {};

  Map<String, dynamic> toJson() => {
        "id": id, "name": name, "iconName": iconName,
        "dailyLimitMinutes": dailyLimitMinutes, "todayMinutes": todayMinutes,
        "weeklyLog": weeklyLog,
      };

  factory SocialPlatform.fromJson(Map<String, dynamic> j) => SocialPlatform(
        id: j["id"], name: j["name"], iconName: j["iconName"] ?? "",
        dailyLimitMinutes: (j["dailyLimitMinutes"] ?? 60).toDouble(),
        todayMinutes: (j["todayMinutes"] ?? 0).toDouble(),
        weeklyLog: Map<String, double>.from(j["weeklyLog"] ?? {}),
      );
}
