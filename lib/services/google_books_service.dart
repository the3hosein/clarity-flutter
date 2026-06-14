import "dart:convert";
import "package:http/http.dart" as http;

class GoogleBooksService {
  static Future<List<Map<String, dynamic>>> searchBooks(String query, {int maxResults = 10}) async {
    final url = Uri.parse("https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=$maxResults");
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["items"] ?? []);
  }
}
