import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';

class MovieDatabase {
  MovieDatabase._();

  static final MovieDatabase instance = MovieDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'time_movies.sqlite');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE movies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            video_path TEXT NOT NULL,
            thumbnail_path TEXT NOT NULL,
            created_at INTEGER NOT NULL
            ,is_in_list INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE movies ADD COLUMN is_in_list INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
    return _database!;
  }

  Future<List<Movie>> allMovies() async {
    final rows = await (await database).query('movies', orderBy: 'created_at DESC');
    return rows.map(Movie.fromMap).toList();
  }

  Future<int> addMovie(Movie movie) async => (await database).insert('movies', movie.toMap());

  Future<void> setMovieInList(Movie movie, bool isInList) async {
    if (movie.id == null) return;
    await (await database).update('movies', {'is_in_list': isInList ? 1 : 0}, where: 'id = ?', whereArgs: [movie.id]);
  }

  Future<List<Movie>> listMovies() async {
    final rows = await (await database).query('movies', where: 'is_in_list = 1', orderBy: 'created_at DESC');
    return rows.map(Movie.fromMap).toList();
  }

  Future<List<Movie>> moviesByCategory(String category) async {
    final rows = await (await database).query('movies', where: 'category = ?', whereArgs: [category], orderBy: 'created_at DESC');
    return rows.map(Movie.fromMap).toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    final rows = await (await database).query('movies', where: 'title LIKE ?', whereArgs: ['%$query%'], orderBy: 'created_at DESC');
    return rows.map(Movie.fromMap).toList();
  }

  Future<void> deleteMovie(Movie movie) async {
    if (movie.id == null) return;
    await (await database).delete('movies', where: 'id = ?', whereArgs: [movie.id]);
  }
}
