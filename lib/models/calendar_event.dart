DateTime _tryParse(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}

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
        startDate: _tryParse(j["startDate"]),
        endDate: _tryParse(j["endDate"]),
        category: j["category"] ?? "study", notes: j["notes"] ?? "",
        repeatOption: j["repeatOption"] ?? "none", colorHex: j["colorHex"] ?? "#007AFF",
      );

  CalendarEvent copyWith({String? id, String? title, DateTime? startDate, DateTime? endDate, String? category, String? notes, String? repeatOption, String? colorHex}) => CalendarEvent(
        id: id ?? this.id, title: title ?? this.title, startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate, category: category ?? this.category, notes: notes ?? this.notes,
        repeatOption: repeatOption ?? this.repeatOption, colorHex: colorHex ?? this.colorHex,
      );
}

