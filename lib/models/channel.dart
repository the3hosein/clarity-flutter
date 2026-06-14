class Channel {
  final String id;
  String name;
  String icon;
  List<ChannelMessage> messages;
  DateTime createdAt;

  Channel({String? id, this.name = "", this.icon = "message", List<ChannelMessage>? messages, DateTime? createdAt})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "id": id, "name": name, "icon": icon,
        "messages": messages.map((m) => m.toJson()).toList(),
        "createdAt": createdAt.toIso8601String(),
      };

  factory Channel.fromJson(Map<String, dynamic> j) => Channel(
        id: j["id"], name: j["name"], icon: j["icon"] ?? "message",
        messages: (j["messages"] as List).map((m) => ChannelMessage.fromJson(m)).toList(),
        createdAt: DateTime.parse(j["createdAt"]),
      );
}

class ChannelMessage {
  final String id;
  String channelId;
  String type;
  String content;
  DateTime timestamp;

  ChannelMessage({String? id, this.channelId = "", this.type = "text", this.content = "", DateTime? timestamp})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "id": id, "channelId": channelId, "type": type,
        "content": content, "timestamp": timestamp.toIso8601String(),
      };

  factory ChannelMessage.fromJson(Map<String, dynamic> j) => ChannelMessage(
        id: j["id"], channelId: j["channelId"], type: j["type"] ?? "text",
        content: j["content"], timestamp: DateTime.parse(j["timestamp"]),
      );
}
