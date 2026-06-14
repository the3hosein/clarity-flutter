import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/world_provider.dart';
import '../../models/movie_item.dart';
import '../../models/music_item.dart';
import '../../models/book_item.dart';
import '../../models/youtube_item.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

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
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('World', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              tabs: const [
                Tab(text: 'Movies'),
                Tab(text: 'Music'),
                Tab(text: 'Books'),
                Tab(text: 'YouTube'),
              ],
            ),
          ),
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
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: w.movies.isEmpty
          ? EmptyState(
              icon: Icons.movie_outlined,
              title: 'No Movies Yet',
              subtitle: 'Add your favorite movies to keep track of what you\'ve watched.',
              actionLabel: 'Add Movie',
              onAction: () => _addMovie(context, w),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.movies.length,
              itemBuilder: (_, i) {
                final m = w.movies[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      m.posterURL.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(m.posterURL, width: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.movie_outlined, size: 44, color: Colors.white54)))
                          : const Icon(Icons.movie_outlined, size: 44, color: Colors.white54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${m.year} · ${m.imdbRating}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                        itemBuilder: (_) => [
                          if (m.status != 'watched')
                            PopupMenuItem(value: 'watched', child: Text('Mark watched', style: GoogleFonts.inter())),
                          if (m.status != 'watchlist')
                            PopupMenuItem(value: 'watchlist', child: Text('Add to watchlist', style: GoogleFonts.inter())),
                          PopupMenuItem(value: 'delete', child: Text('Delete', style: GoogleFonts.inter())),
                        ],
                        onSelected: (v) {
                          if (v == 'delete') {
                            w.deleteMovie(m.id);
                          } else {
                            w.updateMovie(m.copyWith(status: v));
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _addMovie(context, w),
      ),
    );
  }

  void _addMovie(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('Add Movie', style: GoogleFonts.inter(color: Colors.white)),
        content: TextField(
          controller: c,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Movie title',
            labelStyle: GoogleFonts.inter(color: Colors.white54),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              w.addMovie(MovieItem(title: c.text));
              Navigator.pop(ctx);
            }
          }, child: Text('Add', style: GoogleFonts.inter())),
        ],
      ),
    );
  }
}

class _MusicTab extends StatelessWidget {
  const _MusicTab();

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorldProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: w.playlists.isEmpty
          ? EmptyState(
              icon: Icons.queue_music,
              title: 'No Playlists',
              subtitle: 'Create playlists to organize your music.',
              actionLabel: 'New Playlist',
              onAction: () => _addPlaylist(context, w),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.playlists.length,
              itemBuilder: (_, i) {
                final pl = w.playlists[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    leading: const Icon(Icons.queue_music, color: Color(0xFF7C5CFC)),
                    title: Text(pl.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                    subtitle: Text('${pl.tracks.length} tracks', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                    iconColor: Colors.white54,
                    collapsedIconColor: Colors.white54,
                    children: pl.tracks.map((t) => ListTile(
                      dense: true,
                      title: Text(t.trackName, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                      subtitle: Text(t.artistName, style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: Colors.white54,
                        onPressed: () {
                          pl.tracks.remove(t);
                          w.savePlaylist(pl);
                        },
                      ),
                    )).toList(),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      color: accent,
                      onPressed: () => _addTrack(context, pl, w),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _addPlaylist(context, w),
      ),
    );
  }

  void _addPlaylist(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('New Playlist', style: GoogleFonts.inter(color: Colors.white)),
        content: TextField(
          controller: c,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Playlist name',
            labelStyle: GoogleFonts.inter(color: Colors.white54),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              w.addPlaylist(MusicPlaylist(name: c.text));
              Navigator.pop(ctx);
            }
          }, child: Text('Create', style: GoogleFonts.inter())),
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
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('Add Track', style: GoogleFonts.inter(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: GoogleFonts.inter(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: artistC,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Artist',
                labelStyle: GoogleFonts.inter(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
          FilledButton(onPressed: () {
            if (titleC.text.isNotEmpty) {
              pl.tracks.add(MusicTrack(trackName: titleC.text, artistName: artistC.text));
              w.savePlaylist(pl);
              Navigator.pop(ctx);
            }
          }, child: Text('Add', style: GoogleFonts.inter())),
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
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: w.books.isEmpty
          ? EmptyState(
              icon: Icons.book_outlined,
              title: 'No Books',
              subtitle: 'Track your reading list and discover new books.',
              actionLabel: 'Add Book',
              onAction: () => _addBook(context, w),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.books.length,
              itemBuilder: (_, i) {
                final b = w.books[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      b.coverURL.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(b.coverURL, width: 36, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book_outlined, size: 36, color: Colors.white54)))
                          : const Icon(Icons.book_outlined, size: 36, color: Colors.white54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${b.authors.isNotEmpty ? b.authors.first : ''} · ${b.status}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                          ],
                        ),
                      ),
                      if (b.averageRating > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('${'⭐' * b.averageRating.round()}', style: const TextStyle(fontSize: 14)),
                        ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                        itemBuilder: (_) => [
                          if (b.status != 'reading') PopupMenuItem(value: 'reading', child: Text('Reading', style: GoogleFonts.inter())),
                          if (b.status != 'done') PopupMenuItem(value: 'done', child: Text('Done', style: GoogleFonts.inter())),
                          if (b.status != 'wishlist') PopupMenuItem(value: 'wishlist', child: Text('Wishlist', style: GoogleFonts.inter())),
                          PopupMenuItem(value: 'delete', child: Text('Delete', style: GoogleFonts.inter())),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _addBook(context, w),
      ),
    );
  }

  void _addBook(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text('Add Book', style: GoogleFonts.inter(color: Colors.white)),
        content: TextField(
          controller: c,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Book title',
            labelStyle: GoogleFonts.inter(color: Colors.white54),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
          FilledButton(onPressed: () {
            if (c.text.isNotEmpty) {
              w.addBook(BookItem(title: c.text));
              Navigator.pop(ctx);
            }
          }, child: Text('Add', style: GoogleFonts.inter())),
        ],
      ),
    );
  }
}

class _YouTubeTab extends StatelessWidget {
  const _YouTubeTab();

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorldProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Folders', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.create_new_folder_outlined, color: accent),
                onPressed: () {
                  final c = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF0A0A0F),
                      title: Text('New Folder', style: GoogleFonts.inter(color: Colors.white)),
                      content: TextField(
                        controller: c,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Folder name',
                          labelStyle: GoogleFonts.inter(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
                        FilledButton(onPressed: () {
                          if (c.text.isNotEmpty) {
                            w.addYouTubeFolder(YouTubeFolder(name: c.text));
                            Navigator.pop(ctx);
                          }
                        }, child: Text('Create', style: GoogleFonts.inter())),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          if (w.youTubeFolders.isEmpty)
            EmptyState(
              icon: Icons.video_library_outlined,
              title: 'No Folders',
              subtitle: 'Create folders to organize your YouTube videos.',
              actionLabel: 'New Folder',
              onAction: () {
                final c = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF0A0A0F),
                    title: Text('New Folder', style: GoogleFonts.inter(color: Colors.white)),
                    content: TextField(
                      controller: c,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Folder name',
                        labelStyle: GoogleFonts.inter(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
                      FilledButton(onPressed: () {
                        if (c.text.isNotEmpty) {
                          w.addYouTubeFolder(YouTubeFolder(name: c.text));
                          Navigator.pop(ctx);
                        }
                      }, child: Text('Create', style: GoogleFonts.inter())),
                    ],
                  ),
                );
              },
            )
          else
            ...w.youTubeFolders.map((folder) {
              final folderVideos = w.videosForFolder(folder.id);
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  leading: const Icon(Icons.folder, color: Color(0xFF7C5CFC)),
                  title: Text(folder.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                  subtitle: Text('${folderVideos.length} videos', style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                  iconColor: Colors.white54,
                  collapsedIconColor: Colors.white54,
                  children: folderVideos.map((v) => ListTile(
                    dense: true,
                    leading: v.thumbnailURL.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(v.thumbnailURL, width: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.videocam, color: Colors.white54)))
                        : const Icon(Icons.videocam, color: Colors.white54),
                    title: Text(v.title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                    subtitle: Text(DateFormat('d MMM').format(v.dateAdded), style: GoogleFonts.inter(fontSize: 12, color: const Color(0x99FFFFFF))),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.white54,
                      onPressed: () => w.deleteVideo(v.id),
                    ),
                  )).toList(),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, size: 20),
                      color: accent,
                      onPressed: () {
                          final urlC = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF0A0A0F),
                          title: Text('Add Video', style: GoogleFonts.inter(color: Colors.white)),
                          content: TextField(
                            controller: urlC,
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'YouTube URL',
                              labelStyle: GoogleFonts.inter(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF7C5CFC))),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
                            FilledButton(onPressed: () {
                              if (urlC.text.isNotEmpty) {
                                w.addVideoToFolder(folder.id, YouTubeVideo(url: urlC.text));
                                Navigator.pop(ctx);
                              }
                            }, child: Text('Add', style: GoogleFonts.inter())),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
