import 'dart:convert';
import 'package:http/http.dart' as http;

class AppleRSSItem {
  final String id;
  final String name;
  final String artistName;
  final String artworkUrl;
  final String url;
  final List<String> genres;

  AppleRSSItem({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artworkUrl,
    required this.url,
    required this.genres,
  });

  factory AppleRSSItem.fromJson(Map<String, dynamic> json) => AppleRSSItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        artistName: json['artistName'] ?? '',
        artworkUrl: (json['artworkUrl100'] ?? '').replaceAll('100x100', '400x400'),
        url: json['url'] ?? '',
        genres: (json['genres'] as List<dynamic>?)?.map((g) => g['name']?.toString() ?? '').toList() ?? [],
      );
}

class AppleRSSService {
  static Future<List<AppleRSSItem>> fetchTopMovies() async {
    final r = await http.get(Uri.parse('https://rss.applemarketingtools.com/api/v2/us/movies/top/25/movies.json'));
    final data = jsonDecode(r.body);
    return (data['feed']['results'] as List).map((e) => AppleRSSItem.fromJson(e)).toList();
  }

  static Future<List<AppleRSSItem>> fetchTopMusic() async {
    final r = await http.get(Uri.parse('https://rss.applemarketingtools.com/api/v2/us/music/most-played/25/songs.json'));
    final data = jsonDecode(r.body);
    return (data['feed']['results'] as List).map((e) => AppleRSSItem.fromJson(e)).toList();
  }

  static Future<List<AppleRSSItem>> fetchTopBooks() async {
    final r = await http.get(Uri.parse('https://rss.applemarketingtools.com/api/v2/us/books/top/25/books.json'));
    final data = jsonDecode(r.body);
    return (data['feed']['results'] as List).map((e) => AppleRSSItem.fromJson(e)).toList();
  }

  static Future<List<AppleRSSItem>> search(String term) async {
    if (term.trim().isEmpty) return [];
    final r = await http.get(Uri.parse('https://itunes.apple.com/search?term=${Uri.encodeComponent(term)}&media=all&limit=20'));
    final data = jsonDecode(r.body);
    return (data['results'] as List).map((e) {
      final wrapper = e['wrapperType'] ?? '';
      final kind = e['kind'] ?? '';
      final isMovie = kind == 'feature-movie';
      final isMusic = wrapper == 'track' && kind != 'feature-movie';
      final isBook = wrapper == 'ebook';
      return AppleRSSItem(
        id: '${e['trackId'] ?? e['collectionId'] ?? ''}',
        name: e['trackName'] ?? e['collectionName'] ?? '',
        artistName: e['artistName'] ?? '',
        artworkUrl: (e['artworkUrl100'] ?? '').replaceAll('100x100', '400x400'),
        url: e['trackViewUrl'] ?? e['collectionViewUrl'] ?? '',
        genres: e['primaryGenreName'] != null ? [e['primaryGenreName']] : [],
      );
    }).toList();
  }
}
