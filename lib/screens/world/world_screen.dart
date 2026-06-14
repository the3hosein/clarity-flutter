import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/world_provider.dart';
import '../../models/movie_item.dart';
import '../../models/music_item.dart';
import '../../models/book_item.dart';
import '../../models/youtube_item.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'Music'),
            Tab(text: 'Books'),
            Tab(text: 'YouTube'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MoviesTab(),
          _MusicTab(),
          _BooksTab(),
          _YouTubeTab(),
        ],
      ),
    );
  }
}

class _MoviesTab extends StatelessWidget {
  const _MoviesTab();

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorldProvider>();
    return Scaffold(
      body: w.movies.isEmpty
          ? const Center(child: Text('No movies'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.movies.length,
              itemBuilder: (_, i) {
                final m = w.movies[i];
                return Card(
                  child: ListTile(
                    leading: m.posterURL.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(m.posterURL, width: 44, fit: BoxFit.cover))
                        : const Icon(Icons.movie_outlined, size: 44),
                    title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${m.year} · ${m.imdbRating}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        if (m.status != 'watched')
                          const PopupMenuItem(value: 'watched', child: Text('Mark watched')),
                        if (m.status != 'watchlist')
                          const PopupMenuItem(value: 'watchlist', child: Text('Add to watchlist')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (v) {
                        if (v == 'delete') {
                          w.deleteMovie(m.id);
                        } else {
                          w.updateMovie(m.copyWith(status: v));
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final c = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Add Movie'),
              content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Movie title')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(onPressed: () {
                  if (c.text.isNotEmpty) {
                    w.addMovie(MovieItem(title: c.text));
                    Navigator.pop(ctx);
                  }
                }, child: const Text('Add')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MusicTab extends StatelessWidget {
  const _MusicTab();

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorldProvider>();
    return Scaffold(
      body: w.playlists.isEmpty
          ? const Center(child: Text('No playlists'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.playlists.length,
              itemBuilder: (_, i) {
                final pl = w.playlists[i];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.queue_music, color: Colors.pink),
                    title: Text(pl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${pl.tracks.length} tracks'),
                    children: pl.tracks.map((t) => ListTile(
                      dense: true,
                      title: Text(t.trackName),
                      subtitle: Text(t.artistName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () {
                              pl.tracks.remove(t);
                              w.savePlaylist(pl);
                            },
                          ),
                        ],
                      ),
                    )).toList(),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => _addTrack(context, pl, w),
                        ),
                        const Icon(Icons.chevron_up),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addPlaylist(context, w),
      ),
    );
  }

  void _addPlaylist(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Playlist name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              w.addPlaylist(MusicPlaylist(name: c.text));
              Navigator.pop(ctx);
            }
          }, child: const Text('Create')),
        ],
      ),
    );
  }

  void _addTrack(BuildContext context, MusicPlaylist pl, WorldProvider w) {
    final titleC = TextEditingController();
    final artistC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Track'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: artistC, decoration: const InputDecoration(labelText: 'Artist')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (titleC.text.isNotEmpty) {
              pl.tracks.add(MusicTrack(trackName: titleC.text, artistName: artistC.text));
              w.savePlaylist(pl);
              Navigator.pop(ctx);
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}

class _BooksTab extends StatelessWidget {
  const _BooksTab();

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorldProvider>();
    return Scaffold(
      body: w.books.isEmpty
          ? const Center(child: Text('No books'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.books.length,
              itemBuilder: (_, i) {
                final b = w.books[i];
                return Card(
                  child: ListTile(
                    leading: b.coverURL.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(b.coverURL, width: 36, fit: BoxFit.cover))
                        : const Icon(Icons.book_outlined, size: 36),
                    title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${b.authors.isNotEmpty ? b.authors.first : ''} · ${b.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (b.averageRating > 0) Text('${'⭐' * b.averageRating.round()}'),
                        PopupMenuButton(
                          itemBuilder: (_) => [
                            if (b.status != 'reading') const PopupMenuItem(value: 'reading', child: Text('Reading')),
                            if (b.status != 'done') const PopupMenuItem(value: 'done', child: Text('Done')),
                            if (b.status != 'wishlist') const PopupMenuItem(value: 'wishlist', child: Text('Wishlist')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (v) {
                            if (v == 'delete') {
                              w.deleteBook(b.id);
                            } else {
                              w.updateBook(b.copyWith(status: v));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final c = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Add Book'),
              content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Book title')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(onPressed: () {
                  if (c.text.isNotEmpty) {
                    w.addBook(BookItem(title: c.text));
                    Navigator.pop(ctx);
                  }
                }, child: const Text('Add')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _YouTubeTab extends StatelessWidget {
  const _YouTubeTab();

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorldProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('Folders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined),
                onPressed: () {
                  final c = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('New Folder'),
                      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Folder name')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        FilledButton(onPressed: () {
                          if (c.text.isNotEmpty) {
                            w.addYouTubeFolder(YouTubeFolder(name: c.text));
                            Navigator.pop(ctx);
                          }
                        }, child: const Text('Create')),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          if (w.youTubeFolders.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.only(top: 32), child: Text('No folders')))
          else
            ...w.youTubeFolders.map((folder) {
              final folderVideos = w.videosForFolder(folder.id);
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.folder, color: Colors.red),
                  title: Text(folder.name),
                  subtitle: Text('${folderVideos.length} videos'),
                  children: folderVideos.map((v) => ListTile(
                    dense: true,
                    leading: v.thumbnailURL.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(v.thumbnailURL, width: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.videocam)))
                        : const Icon(Icons.videocam),
                    title: Text(v.title),
                    subtitle: Text(DateFormat('d MMM').format(v.dateAdded)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () {
                        w.videos.removeWhere((x) => x.id == v.id);
                        w.addVideoToFolder(folder.id, v);
                      },
                    ),
                  )).toList(),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          final urlC = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Add Video'),
                              content: TextField(controller: urlC, decoration: const InputDecoration(labelText: 'YouTube URL')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                FilledButton(onPressed: () {
                                  if (urlC.text.isNotEmpty) {
                                    w.addVideoToFolder(folder.id, YouTubeVideo(url: urlC.text));
                                    Navigator.pop(ctx);
                                  }
                                }, child: const Text('Add')),
                              ],
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.chevron_up),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
