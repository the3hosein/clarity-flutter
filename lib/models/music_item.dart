class MusicPlaylist {
  final String id;
  String name;
  String moodTag;
  List<MusicTrack> tracks;

  MusicPlaylist({String? id, this.name = "", this.moodTag = "", List<MusicTrack>? tracks})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(), tracks = tracks ?? [];

  Map<String, dynamic> toJson() => {
        "id": id, "name": name, "moodTag": moodTag,
        "tracks": tracks.map((t) => t.toJson()).toList(),
      };

  factory MusicPlaylist.fromJson(Map<String, dynamic> j) => MusicPlaylist(
        id: j["id"], name: j["name"], moodTag: j["moodTag"] ?? "",
        tracks: (j["tracks"] as List).map((t) => MusicTrack.fromJson(t)).toList(),
      );
}

class MusicTrack {
  final String id;
  int trackId;
  String trackName;
  String artistName;
  String albumName;
  String artworkURL;
  String previewURL;
  int trackTimeMillis;

  MusicTrack({String? id, this.trackId = 0, this.trackName = "", this.artistName = "",
      this.albumName = "", this.artworkURL = "", this.previewURL = "", this.trackTimeMillis = 0})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  String get hdArtworkURL => artworkURL.replaceAll("100x100", "600x600");

  Map<String, dynamic> toJson() => {
        "id": id, "trackId": trackId, "trackName": trackName, "artistName": artistName,
        "albumName": albumName, "artworkURL": artworkURL, "previewURL": previewURL,
        "trackTimeMillis": trackTimeMillis,
      };

  factory MusicTrack.fromJson(Map<String, dynamic> j) => MusicTrack(
        id: j["id"], trackId: j["trackId"] ?? 0, trackName: j["trackName"] ?? "",
        artistName: j["artistName"] ?? "", albumName: j["albumName"] ?? "",
        artworkURL: j["artworkURL"] ?? "", previewURL: j["previewURL"] ?? "",
        trackTimeMillis: j["trackTimeMillis"] ?? 0,
      );
}
