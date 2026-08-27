class Movie {
  const Movie({
    this.id,
    required this.title,
    required this.category,
    required this.videoPath,
    required this.thumbnailPath,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String category;
  final String videoPath;
  final String thumbnailPath;
  final int createdAt;

  factory Movie.fromMap(Map<String, Object?> map) => Movie(
        id: map['id'] as int?,
        title: map['title'] as String,
        category: map['category'] as String,
        videoPath: map['video_path'] as String,
        thumbnailPath: map['thumbnail_path'] as String,
        createdAt: map['created_at'] as int,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'video_path': videoPath,
        'thumbnail_path': thumbnailPath,
        'created_at': createdAt,
      };
}
