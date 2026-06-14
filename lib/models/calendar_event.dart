class CalendarEvent {
  final String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  String category;
  String notes;
  String repeatOption;
  String colorHex;

  CalendarEvent({String? id, this.title = "", DateTime? startDate, DateTime? endDate,
      this.category = "study", this.notes = "", this.repeatOption = "none", this.colorHex = "#007AFF"})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(hours: 1));

  Map<String, dynamic> toJson() => {
        "id": id, "title": title, "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(), "category": category,
        "notes": notes, "repeatOption": repeatOption, "colorHex": colorHex,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
        id: j["id"], title: j["title"] ?? "",
        startDate: DateTime.parse(j["startDate"]),
        endDate: DateTime.parse(j["endDate"]),
        category: j["category"] ?? "study", notes: j["notes"] ?? "",
        repeatOption: j["repeatOption"] ?? "none", colorHex: j["colorHex"] ?? "#007AFF",
      );
}
