import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'data/movie_database.dart';
import 'models/movie.dart';
import 'services/local_storage.dart';

const Color _red = Color(0xFFE50914);
const Color _background = Color(0xFF090909);
const Color _surface = Color(0xFF171717);
const Color _muted = Color(0xFF9A9A9A);
const List<String> _categories = [
  'Action',
  'Adventure',
  'Animation',
  'Comedy',
  'Crime',
  'Documentary',
  'Drama',
  'Family',
  'Fantasy',
  'History',
  'Horror',
  'Music',
  'Mystery',
  'Romance',
  'Science Fiction',
  'TV Movie',
  'Thriller',
  'War',
];

void main() => runApp(const TimeMoviesApp());

class TimeMoviesApp extends StatelessWidget {
  const TimeMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIME MOVIES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(seedColor: _red, brightness: Brightness.dark),
        fontFamily: 'sans-serif',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _red, width: 1.5),
          ),
        ),
      ),
      home: const _SessionGate(),
    );
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate();

  Future<bool> _signedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('signed_in') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _signedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _red)),
          );
        }
        return snapshot.data! ? const AppShell() : const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password.')),
      );
      return;
    }

    setState(() => _busy = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('signed_in', true);
    await prefs.setString('display_name', _email.text.trim().split('@').first);

    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'TIME',
                    style: TextStyle(
                      color: _red,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const Text(
                    'MOVIES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 7,
                    ),
                  ),
                  const SizedBox(height: 70),
                  const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _red,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      _busy ? 'Please wait...' : 'Sign In',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Your library stays on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(key: GlobalKey<HomeScreenState>()),
      const MyListScreen(),
      const DiscoverScreen(),
      const SearchScreen(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: const Color(0xFF101010),
        indicatorColor: _red.withValues(alpha: 0x33),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: _red),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark, color: _red),
            label: 'My List',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: _red),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: _red),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: _red),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

Future<void> removeMovie(
  BuildContext context,
  Movie movie, {
  VoidCallback? onRemoved,
}) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _surface,
          title: const Text('Remove from library?'),
          content: Text('Remove "${movie.title}" from your library?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: _red),
              child: const Text('Remove'),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirmed) return;

  await MovieDatabase.instance.deleteMovie(movie);
  await LocalStorage.instance.deleteMedia(movie.videoPath, movie.thumbnailPath);
  onRemoved?.call();
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
    if (!mounted) return;
    setState(() {
      movies = loaded;
      loading = false;
    });
  }

  Future<void> importMovie() async {
    final sourcePath = await LocalStorage.instance.chooseVideo();
    if (sourcePath == null || !mounted) return;

    String? copiedPath;
    try {
      copiedPath = await LocalStorage.instance.copyVideo(sourcePath);
      if (!mounted) return;

      final details = await showDialog<ImportDetails>(
        context: context,
        builder: (_) => const ImportDialog(),
      );

      if (details == null) {
        if (File(copiedPath).existsSync()) {
          await File(copiedPath).delete();
        }
        return;
      }

      final posterPath = details.posterPath == null
          ? await LocalStorage.instance.createThumbnail(copiedPath)
          : await LocalStorage.instance.copyPoster(details.posterPath!);

      await MovieDatabase.instance.addMovie(
        Movie(
          title: details.title,
          category: details.category,
          videoPath: copiedPath,
          thumbnailPath: posterPath,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      await refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to your offline library.')),
        );
      }
    } catch (error) {
      if (copiedPath != null && File(copiedPath).existsSync()) {
        await File(copiedPath).delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import this video: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: _background,
          title: const Text(
            'TIME MOVIES',
            style: TextStyle(
              color: _red,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          actions: [
            IconButton(
              onPressed: importMovie,
              tooltip: 'Add movie or series',
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        if (loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _red)),
          )
        else if (movies.isEmpty)
          SliverFillRemaining(child: _EmptyLibrary(onAdd: importMovie))
        else ...[
            SliverToBoxAdapter(child: _HeroMovie(movie: movies.first)),
            ..._groupedRows(movies),
          ],
      ],
    );
  }

  List<Widget> _groupedRows(List<Movie> values) {
    final grouped = <String, List<Movie>>{};
    for (final movie in values) {
      grouped.putIfAbsent(movie.category, () => <Movie>[]).add(movie);
    }
    return grouped.entries
        .map(
          (entry) => SliverToBoxAdapter(
            child: MovieRow(
              title: entry.key,
              movies: entry.value,
              onChanged: refresh,
            ),
          ),
        )
        .toList();
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_creation_outlined, size: 58, color: _muted),
            const SizedBox(height: 18),
            const Text(
              'Your library is empty',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import a video to start watching offline.',
              style: TextStyle(color: _muted),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add movie or series'),
              style: FilledButton.styleFrom(backgroundColor: _red),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMovie extends StatelessWidget {
  const _HeroMovie({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.45,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(movie.thumbnailPath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: _surface),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  _background.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => openMovie(context, movie),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieRow extends StatelessWidget {
  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    required this.onChanged,
  });

  final String title;
  final List<Movie> movies;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 250,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) => _MovieCard(
                movie: movies[index],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, required this.onChanged});

  final Movie movie;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => showMovieDetails(context, movie, onChanged: onChanged),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(movie.thumbnailPath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: _surface,
                        child: const Icon(Icons.movie, color: _muted),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          removeMovie(context, movie, onRemoved: onChanged);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'delete', child: Text('Remove')),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await MovieDatabase.instance.setMovieInList(movie, !movie.isInList);
                  onChanged();
                },
                icon: Icon(
                  movie.isInList ? Icons.bookmark : Icons.bookmark_border,
                  color: _red,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImportDetails {
  const ImportDetails({
    required this.title,
    required this.category,
    this.posterPath,
  });

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
  final TextEditingController _title = TextEditingController();
  String _category = _categories.first;
  String? _posterPath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surface,
      title: const Text('Add to library'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Genre'),
              items: _categories
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () async {
                final path = await LocalStorage.instance.choosePoster();
                if (mounted) {
                  setState(() => _posterPath = path);
                }
              },
              icon: const Icon(Icons.image_outlined),
              label: Text(
                _posterPath == null ? 'Choose poster (optional)' : 'Poster selected',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_title.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              ImportDetails(
                title: _title.text.trim(),
                category: _category,
                posterPath: _posterPath,
              ),
            );
          },
          style: FilledButton.styleFrom(backgroundColor: _red),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

Future<void> openMovie(BuildContext context, Movie movie) async {
  if (!File(movie.videoPath).existsSync()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The local video file is missing.')),
    );
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
  );
}

void showMovieDetails(
  BuildContext context,
  Movie movie, {
  VoidCallback? onChanged,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DetailsScreen(movie: movie, onChanged: onChanged),
    ),
  );
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.movie, this.onChanged});

  final Movie movie;
  final VoidCallback? onChanged;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late bool inList = widget.movie.isInList;

  Future<void> _toggleList() async {
    await MovieDatabase.instance.setMovieInList(widget.movie, !inList);
    if (mounted) {
      setState(() => inList = !inList);
      widget.onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.fromMillisecondsSinceEpoch(widget.movie.createdAt).year;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => removeMovie(
              context,
              widget.movie,
              onRemoved: () {
                widget.onChanged?.call();
                if (mounted) Navigator.pop(context);
              },
            ),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 1.8,
                child: Image.file(
                  File(widget.movie.thumbnailPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: _surface),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _background.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: -60,
                child: SizedBox(
                  width: 110,
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.movie.thumbnailPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _surface,
                        child: const Icon(Icons.movie, color: _muted),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.movie.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Text(
                  widget.movie.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                const Text('•', style: TextStyle(color: _muted)),
                const SizedBox(width: 12),
                Text('$year', style: const TextStyle(color: _muted)),
                const Spacer(),
                IconButton(
                  onPressed: _toggleList,
                  icon: Icon(
                    inList ? Icons.bookmark : Icons.bookmark_border,
                    color: _red,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(widget.movie.category),
                  backgroundColor: _surface,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_red, Color(0xFFFF5A36)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: FilledButton.icon(
                onPressed: () => openMovie(context, widget.movie),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Watch'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Text(
              'This title is stored on your device and plays offline.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoPlayerController controller;
  Timer? hideTimer;
  bool controlsVisible = true;
  bool isFullscreen = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.movie.videoPath))
      ..addListener(_onControllerChange)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _scheduleAutoHide();
        }
      });
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  void _scheduleAutoHide() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && controller.value.isPlaying) {
        setState(() => controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => controlsVisible = !controlsVisible);
    if (controlsVisible) _scheduleAutoHide();
  }

  void _seekBy(int seconds) {
    final target = controller.value.position + Duration(seconds: seconds);
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : target > controller.value.duration
            ? controller.value.duration
            : target;
    controller.seekTo(safeTarget);
    _scheduleAutoHide();
  }

  Future<void> _toggleFullscreen() async {
    isFullscreen = !isFullscreen;
    final orientations = isFullscreen
        ? [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : [DeviceOrientation.portraitUp];

    await SystemChrome.setPreferredOrientations(orientations);
    await SystemChrome.setEnabledSystemUIMode(
      isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    controller.removeListener(_onControllerChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _red)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: isFullscreen ? null : AppBar(title: Text(widget.movie.title)),
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
              if (controlsVisible)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.black26),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _toggleFullscreen,
                                  icon: Icon(
                                    isFullscreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              children: [
                                VideoProgressIndicator(
                                  controller,
                                  allowScrubbing: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  colors: const VideoProgressColors(
                                    playedColor: _red,
                                    bufferedColor: Colors.white54,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      _formatDuration(controller.value.position),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => _seekBy(-10),
                                      icon: const Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (controller.value.isPlaying) {
                                          controller.pause();
                                        } else {
                                          controller.play();
                                        }
                                        _scheduleAutoHide();
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        controller.value.isPlaying
                                            ? Icons.pause_circle
                                            : Icons.play_circle,
                                        color: Colors.white,
                                        size: 42,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _seekBy(10),
                                      icon: const Icon(
                                        Icons.forward_10,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDuration(controller.value.duration),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final movies = await MovieDatabase.instance.listMovies();
    if (mounted) {
      setState(() => _movies = movies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _MovieGridPage(
      title: 'My List',
      movies: _movies,
      empty: 'Bookmark titles to find them here.',
      onChanged: _load,
    );
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String? _selectedGenre;

  @override
  Widget build(BuildContext context) {
    if (_selectedGenre != null) {
      return FutureBuilder<List<Movie>>(
        future: MovieDatabase.instance.moviesByCategory(_selectedGenre!),
        builder: (context, snapshot) {
          final movies = snapshot.data ?? const <Movie>[];
          return _MovieGridPage(
            title: _selectedGenre!,
            movies: movies,
            empty: 'No imported titles in this genre.',
            back: () => setState(() => _selectedGenre = null),
            onChanged: () => setState(() {}),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisExtent: 82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final name = _categories[index];
          return OutlinedButton(
            onPressed: () => setState(() => _selectedGenre = name),
            child: Text(name),
          );
        },
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();
  List<Movie> _movies = [];

  Future<void> _search(String value) async {
    final movies = await MovieDatabase.instance.searchMovies(value.trim());
    if (mounted) {
      setState(() => _movies = movies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          onChanged: _search,
          decoration: const InputDecoration(
            hintText: 'Search your library',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _MovieGridPage(
        title: 'Results',
        movies: _movies,
        empty: 'Search imported titles.',
      ),
    );
  }
}

class _MovieGridPage extends StatelessWidget {
  const _MovieGridPage({
    required this.title,
    required this.movies,
    required this.empty,
    this.back,
    this.onChanged,
  });

  final String title;
  final List<Movie> movies;
  final String empty;
  final VoidCallback? back;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: back == null
            ? null
            : IconButton(onPressed: back, icon: const Icon(Icons.arrow_back)),
      ),
      body: movies.isEmpty
          ? Center(
              child: Text(
                empty,
                style: const TextStyle(color: _muted),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 170,
                childAspectRatio: 0.58,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return _MovieCard(
                  movie: movies[index],
                  onChanged: onChanged ?? () {},
                );
              },
            ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _name = TextEditingController();
  int _storageBytes = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = await LocalStorage.instance.importedStorageBytes();
    if (mounted) {
      setState(() {
        _name.text = prefs.getString('display_name') ?? 'My profile';
        _storageBytes = storage;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('signed_in');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 46,
            backgroundColor: _red,
            child: Icon(Icons.person, size: 54),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Display name'),
            onSubmitted: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('display_name', value.trim());
            },
          ),
          const SizedBox(height: 28),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage used'),
            trailing: Text(_formatBytes(_storageBytes)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(backgroundColor: _red),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
