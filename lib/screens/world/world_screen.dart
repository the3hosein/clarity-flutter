import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/apple_rss_service.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  List<AppleRSSItem> _movies = [];
  List<AppleRSSItem> _music = [];
  List<AppleRSSItem> _books = [];
  List<AppleRSSItem> _searchResults = [];
  bool _loading = true;
  bool _searching = false;

  final _searchCtl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _searchCtl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_onSearchChanged);
    _searchCtl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = _searchCtl.text.trim();
      if (q.isEmpty) {
        if (mounted) setState(() => _searchResults = []);
        return;
      }
      _doSearch(q);
    });
  }

  Future<void> _doSearch(String term) async {
    setState(() => _searching = true);
    try {
      final results = await AppleRSSService.search(term);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AppleRSSService.fetchTopMovies(),
        AppleRSSService.fetchTopMusic(),
        AppleRSSService.fetchTopBooks(),
      ]);
      if (!mounted) return;
      setState(() {
        _movies = results[0];
        _music = results[1];
        _books = results[2];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isSearching => _searchCtl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF8E8EA0) : const Color(0xFF6B6B80);
    final bg = isDark ? const Color(0xFF161622) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C2B) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Explore the World', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('Sync your inspiration across all media.', style: GoogleFonts.inter(fontSize: 14, color: textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchCtl,
                          focusNode: _focusNode,
                          style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search Movies, Books, Music...',
                            hintStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
                            prefixIcon: Icon(_searching ? Icons.hourglass_top_rounded : Icons.search_rounded, color: textSecondary, size: 20),
                            suffixIcon: _searchCtl.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close_rounded, color: textSecondary, size: 20),
                                    onPressed: () {
                                      _searchCtl.clear();
                                      _focusNode.unfocus();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: cardBg,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isSearching ? _buildSearchResults(textPrimary, textSecondary, cardBg) : _buildBrowse(textPrimary, textSecondary, cardBg),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchResults(Color textPrimary, Color textSecondary, Color cardBg) {
    if (_searchResults.isEmpty && !_searching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 60, color: textSecondary),
              const SizedBox(height: 16),
              Text('No results found', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
              const SizedBox(height: 6),
              Text('Try a different search term.', style: GoogleFonts.inter(fontSize: 14, color: textSecondary)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _doSearch(_searchCtl.text.trim()),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: _searchResults.length,
        itemBuilder: (_, i) {
          final item = _searchResults[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.artworkUrl, width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: textSecondary.withOpacity(0.2), child: Icon(Icons.search_rounded, color: textSecondary))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item.artistName, style: GoogleFonts.inter(fontSize: 12, color: textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowse(Color textPrimary, Color textSecondary, Color cardBg) {
    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          if (_movies.isNotEmpty) ...[
            Text('Top Movies', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _movies.length > 5 ? 5 : _movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final m = _movies[i];
                  return Container(
                    width: 160,
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(m.artworkUrl, height: 120, width: 160, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 120, color: textSecondary.withOpacity(0.2), child: Icon(Icons.movie_rounded, color: textSecondary))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(m.artistName, style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
          if (_music.isNotEmpty) ...[
            Text('Top Music', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _music.length > 5 ? 5 : _music.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final m = _music[i];
                  return Container(
                    width: 140,
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(m.artworkUrl, height: 120, width: 140, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 120, color: textSecondary.withOpacity(0.2), child: Icon(Icons.music_note_rounded, color: textSecondary))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(m.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
          if (_books.isNotEmpty) ...[
            Text('Top Books', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 12),
            ..._books.take(4).map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(b.artworkUrl, width: 44, height: 60, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 44, height: 60, color: textSecondary.withOpacity(0.2))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(b.artistName, style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
