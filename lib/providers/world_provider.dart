import 'package:flutter/material.dart';
import '../models/movie_item.dart';
import '../models/music_item.dart';
import '../models/book_item.dart';
import '../models/youtube_item.dart';
import '../services/storage_service.dart';

class WorldProvider extends ChangeNotifier {
  List<MovieItem> _movies = [];
  List<MusicPlaylist> _playlists = [];
  List<BookItem> _books = [];
  List<YouTubeVideo> _videos = [];
  List<YouTubeFolder> _folders = [];

  List<MovieItem> get movies => _movies;
  List<MusicPlaylist> get playlists => _playlists;
  List<BookItem> get books => _books;
  List<YouTubeVideo> get videos => _videos;
  List<YouTubeFolder> get folders => _folders;

  Future<void> load() async {
    _movies = await StorageService.loadList('movies', MovieItem.fromJson);
    _playlists = await StorageService.loadList('playlists', MusicPlaylist.fromJson);
    _books = await StorageService.loadList('books', BookItem.fromJson);
    _videos = await StorageService.loadList('youtubeVideos', YouTubeVideo.fromJson);
    _folders = await StorageService.loadList('youtubeFolders', YouTubeFolder.fromJson);
    notifyListeners();
  }

  Future<void> addMovie(MovieItem movie) async {
    _movies.add(movie);
    await _saveMovies();
    notifyListeners();
  }

  Future<void> updateMovie(MovieItem movie) async {
    final i = _movies.indexWhere((m) => m.id == movie.id);
    if (i >= 0) _movies[i] = movie;
    await _saveMovies();
    notifyListeners();
  }

  Future<void> deleteMovie(String id) async {
    _movies.removeWhere((m) => m.id == id);
    await _saveMovies();
    notifyListeners();
  }

  Future<void> _saveMovies() async {
    await StorageService.saveList('movies', _movies, (m) => m.toJson());
  }

  Future<void> addPlaylist(MusicPlaylist playlist) async {
    _playlists.add(playlist);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> savePlaylist(MusicPlaylist playlist) async {
    final i = _playlists.indexWhere((p) => p.id == playlist.id);
    if (i >= 0) {
      _playlists[i] = playlist;
    } else {
      _playlists.add(playlist);
    }
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    await StorageService.saveList('playlists', _playlists, (p) => p.toJson());
  }

  Future<void> addBook(BookItem book) async {
    _books.add(book);
    await _saveBooks();
    notifyListeners();
  }

  Future<void> updateBook(BookItem book) async {
    final i = _books.indexWhere((b) => b.id == book.id);
    if (i >= 0) _books[i] = book;
    await _saveBooks();
    notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
    await _saveBooks();
    notifyListeners();
  }

  Future<void> _saveBooks() async {
    await StorageService.saveList('books', _books, (b) => b.toJson());
  }

  List<YouTubeFolder> get youTubeFolders => _folders;

  List<YouTubeVideo> videosForFolder(String folderId) =>
      _videos.where((v) => v.folderId == folderId).toList();

  Future<void> addYouTubeFolder(YouTubeFolder folder) async {
    _folders.add(folder);
    await _saveFolders();
    notifyListeners();
  }

  Future<void> saveYouTubeFolder(YouTubeFolder folder) async {
    final i = _folders.indexWhere((f) => f.id == folder.id);
    if (i >= 0) {
      _folders[i] = folder;
    } else {
      _folders.add(folder);
    }
    await _saveFolders();
    notifyListeners();
  }

  Future<void> _saveFolders() async {
    await StorageService.saveList('youtubeFolders', _folders, (f) => f.toJson());
  }

  Future<void> addVideoToFolder(String folderId, YouTubeVideo video) async {
    final copy = video.copyWith(folderId: folderId);
    _videos.add(copy);
    await _saveVideos();
    notifyListeners();
  }

  Future<void> deleteVideo(String id) async {
    _videos.removeWhere((v) => v.id == id);
    await _saveVideos();
    notifyListeners();
  }

  Future<void> _saveVideos() async {
    await StorageService.saveList('youtubeVideos', _videos, (v) => v.toJson());
  }
}
