class BookItem {
  final String id;
  String googleBooksID;
  String title;
  List<String> authors;
  String publisher;
  String publishedDate;
  int pageCount;
  String descriptionText;
  List<String> categories;
  double averageRating;
  String isbn;
  String coverURL;
  String status;
  int currentPage;
  String notes;

  BookItem({String? id, this.googleBooksID = "", this.title = "", List<String>? authors, this.publisher = "",
      this.publishedDate = "", this.pageCount = 0, this.descriptionText = "", List<String>? categories,
      this.averageRating = 0.0, this.isbn = "", this.coverURL = "", this.status = "want_to_read",
      this.currentPage = 0, this.notes = ""})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        authors = authors ?? [],
        categories = categories ?? [];

  double get progress => pageCount > 0 ? currentPage / pageCount : 0;

  Map<String, dynamic> toJson() => {
        "id": id, "googleBooksID": googleBooksID, "title": title, "authors": authors,
        "publisher": publisher, "publishedDate": publishedDate, "pageCount": pageCount,
        "descriptionText": descriptionText, "categories": categories, "averageRating": averageRating,
        "isbn": isbn, "coverURL": coverURL, "status": status, "currentPage": currentPage, "notes": notes,
      };

  BookItem copyWith({String? status, int? currentPage}) => BookItem(
        id: id, googleBooksID: googleBooksID, title: title, authors: authors,
        publisher: publisher, publishedDate: publishedDate, pageCount: pageCount,
        descriptionText: descriptionText, categories: categories, averageRating: averageRating,
        isbn: isbn, coverURL: coverURL, status: status ?? this.status,
        currentPage: currentPage ?? this.currentPage, notes: notes,
      );

  factory BookItem.fromJson(Map<String, dynamic> j) => BookItem(
        id: j["id"], googleBooksID: j["googleBooksID"] ?? "", title: j["title"] ?? "",
        authors: List<String>.from(j["authors"] ?? []), publisher: j["publisher"] ?? "",
        publishedDate: j["publishedDate"] ?? "", pageCount: j["pageCount"] ?? 0,
        descriptionText: j["descriptionText"] ?? "",
        categories: List<String>.from(j["categories"] ?? []),
        averageRating: (j["averageRating"] ?? 0).toDouble(), isbn: j["isbn"] ?? "",
        coverURL: j["coverURL"] ?? "", status: j["status"] ?? "want_to_read",
        currentPage: j["currentPage"] ?? 0, notes: j["notes"] ?? "",
      );
}
