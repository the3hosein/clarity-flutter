import "dart:convert";
import "package:http/http.dart" as http;

class YouTubeService {
  static Future<Map<String, dynamic>> fetchVideoInfo(String url) async {
    final fetchUrl = Uri.parse("https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json");
    final res = await http.get(fetchUrl);
    return jsonDecode(res.body);
  }
}
