class SleepLog {
  final String id;
  DateTime date;
  DateTime bedtime;
  DateTime wakeTime;
  int quality;
  String note;

  SleepLog({String? id, DateTime? date, DateTime? bedtime, DateTime? wakeTime, this.quality = 3, this.note = ""})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date = date ?? DateTime.now(),
        bedtime = bedtime ?? DateTime.now(),
        wakeTime = wakeTime ?? DateTime.now();

  double get durationHours => wakeTime.difference(bedtime).inMinutes / 60.0;

  Map<String, dynamic> toJson() => {
        "id": id, "date": date.toIso8601String(), "bedtime": bedtime.toIso8601String(),
        "wakeTime": wakeTime.toIso8601String(), "quality": quality, "note": note,
      };

  factory SleepLog.fromJson(Map<String, dynamic> j) => SleepLog(
        id: j["id"], date: DateTime.parse(j["date"]),
        bedtime: DateTime.parse(j["bedtime"]), wakeTime: DateTime.parse(j["wakeTime"]),
        quality: j["quality"] ?? 3, note: j["note"] ?? "",
      );
}
