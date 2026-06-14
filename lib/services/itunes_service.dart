import "dart:convert";
import "package:http/http.dart" as http;

class iTunesService {
  static Future<List<Map<String, dynamic>>> searchTracks(String query, {int limit = 15}) async {
    final url = Uri.parse("https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=musicTrack&limit=$limit&media=music");
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["results"] ?? []);
  }
}
