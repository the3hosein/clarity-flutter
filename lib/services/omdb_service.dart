import "dart:convert";
import "package:http/http.dart" as http;

class OMDbService {
  static const apiKey = "YOUR_OMDB_API_KEY";

  static Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final url = Uri.parse("https://www.omdbapi.com/?s=${Uri.encodeComponent(query)}&apikey=$apiKey");
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["Search"] ?? []);
  }

  static Future<Map<String, dynamic>> fetchDetail(String imdbID) async {
    final url = Uri.parse("https://www.omdbapi.com/?i=$imdbID&apikey=$apiKey&plot=full");
    final res = await http.get(url);
    return jsonDecode(res.body);
  }
}
