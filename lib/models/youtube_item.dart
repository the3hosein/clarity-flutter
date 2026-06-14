class YouTubeVideo {
  final String id;
  String url;
  String title;
  String channelName;
  String thumbnailURL;
  String status;
  String folderId;
  DateTime dateAdded;

  YouTubeVideo({String? id, this.url = "", this.title = "", this.channelName = "", this.thumbnailURL = "",
      this.status = "to_watch", this.folderId = "", DateTime? dateAdded})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "id": id, "url": url, "title": title, "channelName": channelName,
        "thumbnailURL": thumbnailURL, "status": status, "folderId": folderId,
        "dateAdded": dateAdded.toIso8601String(),
      };

  factory YouTubeVideo.fromJson(Map<String, dynamic> j) => YouTubeVideo(
        id: j["id"], url: j["url"] ?? "", title: j["title"] ?? "",
        channelName: j["channelName"] ?? "", thumbnailURL: j["thumbnailURL"] ?? "",
        status: j["status"] ?? "to_watch", folderId: j["folderId"] ?? "",
        dateAdded: DateTime.parse(j["dateAdded"]),
      );
}

class YouTubeFolder {
  final String id;
  String name;
  String icon;

  YouTubeFolder({String? id, this.name = "", this.icon = "folder"})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {"id": id, "name": name, "icon": icon};

  factory YouTubeFolder.fromJson(Map<String, dynamic> j) => YouTubeFolder(
        id: j["id"], name: j["name"] ?? "", icon: j["icon"] ?? "folder",
      );
}
