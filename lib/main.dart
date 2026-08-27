import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'data/movie_database.dart';
import 'models/movie.dart';
import 'services/local_storage.dart';

const _red = Color(0xFFE50914);
const _background = Color(0xFF090909);
const _surface = Color(0xFF171717);
const _muted = Color(0xFF9A9A9A);
const _categories = ['Action', 'Comedy', 'Anime', 'Adventure', 'Drama', 'Documentary', 'Other'];

void main() => runApp(const TimeMoviesApp());

class TimeMoviesApp extends StatelessWidget {
  const TimeMoviesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TIME MOVIES',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _background,
          colorScheme: ColorScheme.fromSeed(seedColor: _red, brightness: Brightness.dark),
          fontFamily: ' sans-serif',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: _red, width: 1.5)),
          ),
        ),
        home: const LoginScreen(),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signUp = false;
  bool busy = false;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email and password.')));
      return;
    }
    setState(() => busy = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('signed_in', true);
    if (!mounted) return;
    setState(() => busy = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('TIME', style: TextStyle(color: _red, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 3)),
                  const Text('MOVIES', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: 7)),
                  const SizedBox(height: 70),
                  Text(signUp ? 'Create your account' : 'Sign in', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email')),
                  const SizedBox(height: 14),
                  TextField(controller: password, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    style: FilledButton.styleFrom(backgroundColor: _red, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    child: Text(busy ? 'Please wait...' : signUp ? 'Sign Up' : 'Sign In', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => setState(() => signUp = !signUp),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), side: const BorderSide(color: Color(0xFF555555)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    child: Text(signUp ? 'Sign In' : 'Sign Up'),
                  ),
                  const SizedBox(height: 22),
                  const Text('Your library stays on this device.', textAlign: TextAlign.center, style: TextStyle(color: _muted)),
                ]),
              ),
            ),
          ),
        ),
      );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Who's watching?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 34),
              InkWell(
                onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell())),
                borderRadius: BorderRadius.circular(6),
                child: Column(children: [
                  Container(width: 104, height: 104, decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.person, size: 62, color: Colors.white)),
                  const SizedBox(height: 12),
                  const Text('My profile', style: TextStyle(color: _muted, fontSize: 16)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final homeKey = GlobalKey<HomeScreenState>();

  @override
  Widget build(BuildContext context) {
    final pages = [HomeScreen(key: homeKey), const MyListScreen(), const DiscoverScreen(), const ProfileTab()];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        backgroundColor: const Color(0xFF101010),
        indicatorColor: _red.withOpacity(.18),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: _red), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark, color: _red), label: 'My List'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore, color: _red), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: _red), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final loaded = await MovieDatabase.instance.allMovies();
    if (mounted) setState(() { movies = loaded; loading = false; });
  }

  Future<void> importMovie() async {
    final source = await LocalStorage.instance.chooseVideo();
    if (source == null || !mounted) return;
    String? copiedPath;
    try {
      copiedPath = await LocalStorage.instance.copyVideo(source);
      if (!mounted) return;
      final details = await showDialog<ImportDetails>(context: context, builder: (_) => const ImportDialog());
      if (details == null) {
        try {
          await File(copiedPath).delete();
        } catch (_) {}
        return;
      }
      final thumbnail = details.posterPath == null
          ? await LocalStorage.instance.createThumbnail(copiedPath)
          : await LocalStorage.instance.copyPoster(details.posterPath!);
      await MovieDatabase.instance.addMovie(Movie(title: details.title, category: details.category, videoPath: copiedPath, thumbnailPath: thumbnail, createdAt: DateTime.now().millisecondsSinceEpoch));
      await refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to your offline library.')));
    } catch (error) {
      if (copiedPath != null) await File(copiedPath).delete().catchError((_) {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not import this video: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: _background,
          title: const Text('TIME MOVIES', style: TextStyle(color: _red, fontWeight: FontWeight.w900, letterSpacing: 2)),
          actions: [IconButton(onPressed: importMovie, tooltip: 'Add movie or series', icon: const Icon(Icons.add, color: Colors.white))],
        ),
        if (loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _red)))
        else if (movies.isEmpty)
          SliverFillRemaining(child: _EmptyLibrary(onAdd: importMovie))
        else ...[
          SliverToBoxAdapter(child: _HeroMovie(movie: movies.first)),
          ..._groupedRows(movies),
        ],
      ]);

  List<Widget> _groupedRows(List<Movie> values) {
    final categories = <String, List<Movie>>{};
    for (final movie in values) categories.putIfAbsent(movie.category, () => []).add(movie);
    return categories.entries.map((entry) => SliverToBoxAdapter(child: MovieRow(title: entry.key, movies: entry.value))).toList();
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.movie_creation_outlined, size: 58, color: _muted), const SizedBox(height: 18), const Text('Your library is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Import a video to start watching offline.', style: TextStyle(color: _muted)), const SizedBox(height: 24), FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add movie or series'), style: FilledButton.styleFrom(backgroundColor: _red))])));
}

class _HeroMovie extends StatelessWidget {
  const _HeroMovie({required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => AspectRatio(aspectRatio: 1.45, child: Stack(fit: StackFit.expand, children: [Image.file(File(movie.thumbnailPath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: _surface)), DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, _background.withOpacity(.96)]))), Padding(padding: const EdgeInsets.all(20), child: Align(alignment: Alignment.bottomLeft, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(movie.category.toUpperCase(), style: const TextStyle(color: _red, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 5), Text(movie.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 5), const Text('Your local copy, ready to watch offline.', style: TextStyle(color: Colors.white70)), const SizedBox(height: 12), Row(children: [FilledButton.icon(onPressed: () => openMovie(context, movie), icon: const Icon(Icons.play_arrow), label: const Text('Play'), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black)), const SizedBox(width: 10), OutlinedButton.icon(onPressed: () => showMovieDetails(context, movie), icon: const Icon(Icons.info_outline), label: const Text('View Details'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)))])])))]));
}

class MovieRow extends StatelessWidget {
  const MovieRow({super.key, required this.title, required this.movies});
  final String title;
  final List<Movie> movies;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))), const SizedBox(height: 11), SizedBox(height: 220, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: movies.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (context, index) => _MovieCard(movie: movies[index])))]));
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => openMovie(context, movie),
        child: SizedBox(
          width: 142,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    File(movie.thumbnailPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: _surface,
                      child: const Icon(Icons.movie, color: _muted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
}

class ImportDetails {
  const ImportDetails({required this.title, required this.category, this.posterPath});
  final String title;
  final String category;
  final String? posterPath;
}

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});
  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final title = TextEditingController();
  String category = _categories.first;
  String? posterPath;
  bool choosingPoster = false;

  Future<void> pickPoster() async {
    setState(() => choosingPoster = true);
    final path = await LocalStorage.instance.choosePoster();
    if (mounted) setState(() { posterPath = path; choosingPoster = false; });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(backgroundColor: _surface, title: const Text('Add to library'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, autofocus: true, decoration: const InputDecoration(labelText: 'Title')), const SizedBox(height: 14), DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Category'), items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) { if (value != null) setState(() => category = value); }), const SizedBox(height: 14), OutlinedButton.icon(onPressed: choosingPoster ? null : pickPoster, icon: const Icon(Icons.image_outlined), label: Text(posterPath == null ? 'Choose poster (optional)' : 'Poster selected'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { if (title.text.trim().isEmpty) return; Navigator.pop(context, ImportDetails(title: title.text.trim(), category: category, posterPath: posterPath)); }, style: FilledButton.styleFrom(backgroundColor: _red), child: const Text('Add'))]);
}

Future<void> openMovie(BuildContext context, Movie movie) async {
  if (!File(movie.videoPath).existsSync()) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The local video file is missing.')));
    return;
  }
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)));
}

void showMovieDetails(BuildContext context, Movie movie) => showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: Text(movie.title),
        content: Text('${movie.category}  •  Stored on this device\n\nThis title plays from the app\'s copied local file and does not require internet access.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.movie});
  final Movie movie;
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoPlayerController controller;
  @override
  void initState() { super.initState(); controller = VideoPlayerController.file(File(widget.movie.videoPath))..initialize().then((_) { if (mounted) setState(() {}); }); }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.movie.title)), body: Center(child: controller.value.isInitialized ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)), const SizedBox(height: 22), IconButton(onPressed: () { setState(() => controller.value.isPlaying ? controller.pause() : controller.play()); }, iconSize: 54, icon: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: _red))]) : const CircularProgressIndicator(color: _red)));
}

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});
  @override
  Widget build(BuildContext context) => const _SimpleTab(icon: Icons.bookmark_border, title: 'My List', message: 'Your saved titles will appear here.');
}
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) => const _SimpleTab(icon: Icons.explore_outlined, title: 'Discover', message: 'Import videos to build your own collection.');
}
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => _SimpleTab(icon: Icons.person_outline, title: 'My profile', message: 'Everything in TIME MOVIES is stored locally on this device.');
}
class _SimpleTab extends StatelessWidget {
  const _SimpleTab({required this.icon, required this.title, required this.message});
  final IconData icon; final String title; final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 54, color: _red), const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted))])));
}
