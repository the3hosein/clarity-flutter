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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;
    final border = isDark ? const Color(0xFF2A2A3D) : const Color(0xFFE8E8F0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('World', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 0.5),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              dividerHeight: 0,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: w.movies.isEmpty
          ? EmptyState(
              icon: Icons.movie_rounded,
              title: 'No Movies Yet',
              subtitle: 'Add your favorite movies to keep track',
              actionLabel: 'Add Movie',
              onAction: () => _addMovie(context, w),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.movies.length,
              itemBuilder: (_, i) {
                final m = w.movies[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: m.posterURL.isNotEmpty
                            ? Image.network(m.posterURL, width: 44, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 44, height: 60, color: accent.withOpacity( 0.12), child: Icon(Icons.movie_rounded, color: accent)))
                            : Container(width: 44, height: 60, color: accent.withOpacity( 0.12), child: Icon(Icons.movie_rounded, color: accent)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${m.year} · ${m.imdbRating}', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
                        itemBuilder: (_) => [
                          if (m.status != 'watched') PopupMenuItem(value: 'watched', child: Text('Watched', style: GoogleFonts.inter())),
                          if (m.status != 'watchlist') PopupMenuItem(value: 'watchlist', child: Text('Watchlist', style: GoogleFonts.inter())),
                          PopupMenuItem(value: 'delete', child: Text('Delete', style: GoogleFonts.inter())),
                        ],
                        onSelected: (v) {
                          if (v == 'delete') w.deleteMovie(m.id);
                          else w.updateMovie(m.copyWith(status: v));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMovie(context, w),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _addMovie(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Movie', style: GoogleFonts.spaceGrotesk()),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Movie title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
            if (c.text.isNotEmpty) { w.addMovie(MovieItem(title: c.text)); Navigator.pop(ctx); }
          }, child: const Text('Add')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: w.playlists.isEmpty
          ? EmptyState(
              icon: Icons.queue_music_rounded,
              title: 'No Playlists',
              subtitle: 'Create playlists to organize your music',
              actionLabel: 'New Playlist',
              onAction: () => _addPlaylist(context, w),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.playlists.length,
              itemBuilder: (_, i) {
                final pl = w.playlists[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: accent.withOpacity( 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.queue_music_rounded, color: accent, size: 20),
                    ),
                    title: Text(pl.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                    subtitle: Text('${pl.tracks.length} tracks', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                    iconColor: textSecondary,
                    collapsedIconColor: textSecondary,
                    children: pl.tracks.map((t) => ListTile(
                      dense: true,
                      title: Text(t.trackName, style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                      subtitle: Text(t.artistName, style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
                        onPressed: () { pl.tracks.remove(t); w.savePlaylist(pl); },
                      ),
                    )).toList(),
                    trailing: IconButton(
                      icon: Icon(Icons.add_rounded, size: 20, color: accent),
                      onPressed: () => _addTrack(context, pl, w),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPlaylist(context, w),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _addPlaylist(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Playlist', style: GoogleFonts.spaceGrotesk()),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Playlist name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
            if (c.text.isNotEmpty) { w.addPlaylist(MusicPlaylist(name: c.text)); Navigator.pop(ctx); }
          }, child: const Text('Create')),
        ],
      ),
    );
  }

  void _addTrack(BuildContext context, MusicPlaylist pl, WorldProvider w) {
    final titleC = TextEditingController();
    final artistC = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Track', style: GoogleFonts.spaceGrotesk()),
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
          FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
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
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: w.books.isEmpty
          ? EmptyState(
              icon: Icons.book_rounded,
              title: 'No Books',
              subtitle: 'Track your reading list',
              actionLabel: 'Add Book',
              onAction: () => _addBook(context, w),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: w.books.length,
              itemBuilder: (_, i) {
                final b = w.books[i];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: b.coverURL.isNotEmpty
                            ? Image.network(b.coverURL, width: 36, height: 52, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 36, height: 52, color: accent.withOpacity( 0.12), child: Icon(Icons.book_rounded, color: accent)))
                            : Container(width: 36, height: 52, color: accent.withOpacity( 0.12), child: Icon(Icons.book_rounded, color: accent)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${b.authors.isNotEmpty ? b.authors.first : ''} · ${b.status}', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      if (b.averageRating > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('⭐' * b.averageRating.round(), style: const TextStyle(fontSize: 12)),
                        ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
                        itemBuilder: (_) => [
                          if (b.status != 'reading') PopupMenuItem(value: 'reading', child: Text('Reading', style: GoogleFonts.inter())),
                          if (b.status != 'done') PopupMenuItem(value: 'done', child: Text('Done', style: GoogleFonts.inter())),
                          if (b.status != 'wishlist') PopupMenuItem(value: 'wishlist', child: Text('Wishlist', style: GoogleFonts.inter())),
                          PopupMenuItem(value: 'delete', child: Text('Delete', style: GoogleFonts.inter())),
                        ],
                        onSelected: (v) {
                          if (v == 'delete') w.deleteBook(b.id);
                          else w.updateBook(b.copyWith(status: v));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBook(context, w),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _addBook(BuildContext context, WorldProvider w) {
    final c = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Book', style: GoogleFonts.spaceGrotesk()),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Book title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
            if (c.text.isNotEmpty) { w.addBook(BookItem(title: c.text)); Navigator.pop(ctx); }
          }, child: const Text('Add')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Folders', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.create_new_folder_rounded, color: accent),
                onPressed: () {
                  final c = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('New Folder', style: GoogleFonts.spaceGrotesk()),
                      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Folder name')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
                          if (c.text.isNotEmpty) { w.addYouTubeFolder(YouTubeFolder(name: c.text)); Navigator.pop(ctx); }
                        }, child: const Text('Create')),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          if (w.youTubeFolders.isEmpty)
            EmptyState(
              icon: Icons.video_library_rounded,
              title: 'No Folders',
              subtitle: 'Create folders to organize your videos',
              actionLabel: 'New Folder',
              onAction: () {
                final c = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('New Folder', style: GoogleFonts.spaceGrotesk()),
                    content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Folder name')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
                        if (c.text.isNotEmpty) { w.addYouTubeFolder(YouTubeFolder(name: c.text)); Navigator.pop(ctx); }
                      }, child: const Text('Create')),
                    ],
                  ),
                );
              },
            )
          else
            ...w.youTubeFolders.map((folder) {
              final folderVideos = w.videosForFolder(folder.id);
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: accent.withOpacity( 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.folder_rounded, color: accent, size: 20),
                  ),
                  title: Text(folder.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                  subtitle: Text('${folderVideos.length} videos', style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                  iconColor: textSecondary,
                  collapsedIconColor: textSecondary,
                  children: folderVideos.map((v) => ListTile(
                    dense: true,
                    leading: v.thumbnailURL.isNotEmpty
                        ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(v.thumbnailURL, width: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.videocam_rounded, color: textSecondary)))
                        : Icon(Icons.videocam_rounded, color: textSecondary),
                    title: Text(v.title, style: GoogleFonts.inter(color: textPrimary, fontSize: 14)),
                    subtitle: Text(DateFormat('d MMM').format(v.dateAdded), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textSecondary)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
                      onPressed: () => w.deleteVideo(v.id),
                    ),
                  )).toList(),
                  trailing: IconButton(
                    icon: Icon(Icons.add_rounded, size: 20, color: accent),
                    onPressed: () {
                      final urlC = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Add Video', style: GoogleFonts.spaceGrotesk()),
                          content: TextField(controller: urlC, decoration: const InputDecoration(labelText: 'YouTube URL')),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            FilledButton(style: FilledButton.styleFrom(backgroundColor: accent), onPressed: () {
                              if (urlC.text.isNotEmpty) { w.addVideoToFolder(folder.id, YouTubeVideo(url: urlC.text)); Navigator.pop(ctx); }
                            }, child: const Text('Add')),
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
