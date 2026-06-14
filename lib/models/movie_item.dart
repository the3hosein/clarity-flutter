class MovieItem {
  final String id;
  String imdbID;
  String title;
  String year;
  String posterURL;
  String genre;
  String plot;
  String imdbRating;
  String director;
  List<String> cast;
  String runtime;
  String rated;
  String awards;
  String status;
  int userRating;

  MovieItem({String? id, this.imdbID = "", this.title = "", this.year = "", this.posterURL = "",
      this.genre = "", this.plot = "", this.imdbRating = "", this.director = "", List<String>? cast,
      this.runtime = "", this.rated = "", this.awards = "", this.status = "want_to_watch", this.userRating = 0})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(), cast = cast ?? [];

  Map<String, dynamic> toJson() => {
        "id": id, "imdbID": imdbID, "title": title, "year": year, "posterURL": posterURL,
        "genre": genre, "plot": plot, "imdbRating": imdbRating, "director": director,
        "cast": cast, "runtime": runtime, "rated": rated, "awards": awards,
        "status": status, "userRating": userRating,
      };

  MovieItem copyWith({String? id, String? imdbID, String? title, String? year, String? posterURL, String? genre, String? plot, String? imdbRating, String? director, List<String>? cast, String? runtime, String? rated, String? awards, String? status, int? userRating}) => MovieItem(
        id: id ?? this.id, imdbID: imdbID ?? this.imdbID, title: title ?? this.title,
        year: year ?? this.year, posterURL: posterURL ?? this.posterURL, genre: genre ?? this.genre,
        plot: plot ?? this.plot, imdbRating: imdbRating ?? this.imdbRating, director: director ?? this.director,
        cast: cast ?? this.cast, runtime: runtime ?? this.runtime, rated: rated ?? this.rated,
        awards: awards ?? this.awards, status: status ?? this.status, userRating: userRating ?? this.userRating,
      );

  factory MovieItem.fromJson(Map<String, dynamic> j) => MovieItem(
        id: j["id"], imdbID: j["imdbID"], title: j["title"], year: j["year"],
        posterURL: j["posterURL"] ?? "", genre: j["genre"] ?? "", plot: j["plot"] ?? "",
        imdbRating: j["imdbRating"] ?? "", director: j["director"] ?? "",
        cast: List<String>.from(j["cast"] ?? []), runtime: j["runtime"] ?? "",
        rated: j["rated"] ?? "", awards: j["awards"] ?? "",
        status: j["status"] ?? "want_to_watch", userRating: j["userRating"] ?? 0,
      );
}
