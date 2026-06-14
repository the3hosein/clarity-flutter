class Lesson {
  final String id;
  String subject;
  int dayOfWeek;
  String startTime;
  String endTime;
  String colorHex;
  String status;

  Lesson({String? id, this.subject = "", this.dayOfWeek = 0, this.startTime = "", this.endTime = "", this.colorHex = "#007AFF", this.status = "pending"})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        "id": id, "subject": subject, "dayOfWeek": dayOfWeek,
        "startTime": startTime, "endTime": endTime, "colorHex": colorHex, "status": status,
      };

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j["id"], subject: j["subject"], dayOfWeek: j["dayOfWeek"],
        startTime: j["startTime"], endTime: j["endTime"],
        colorHex: j["colorHex"] ?? "#007AFF", status: j["status"] ?? "pending",
      );

  Lesson copyWith({String? id, String? subject, int? dayOfWeek, String? startTime, String? endTime, String? colorHex, String? status}) => Lesson(
        id: id ?? this.id, subject: subject ?? this.subject, dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime, endTime: endTime ?? this.endTime,
        colorHex: colorHex ?? this.colorHex, status: status ?? this.status,
      );
}

