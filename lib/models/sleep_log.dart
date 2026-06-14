DateTime _tryParse(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}

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
        id: j["id"], date: _tryParse(j["date"]),
        bedtime: _tryParse(j["bedtime"]), wakeTime: _tryParse(j["wakeTime"]),
        quality: j["quality"] ?? 3, note: j["note"] ?? "",
      );

  SleepLog copyWith({String? id, DateTime? date, DateTime? bedtime, DateTime? wakeTime, int? quality, String? note}) => SleepLog(
        id: id ?? this.id, date: date ?? this.date, bedtime: bedtime ?? this.bedtime,
        wakeTime: wakeTime ?? this.wakeTime, quality: quality ?? this.quality, note: note ?? this.note,
      );
}

