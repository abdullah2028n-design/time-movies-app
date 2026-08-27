class Movie {
  const Movie({
    this.id,
    required this.title,
    required this.category,
    required this.videoPath,
    required this.thumbnailPath,
    required this.createdAt,
    this.isInList = false,
  });

  final int? id;
  final String title;
  final String category;
  final String videoPath;
  final String thumbnailPath;
  final int createdAt;
  final bool isInList;

  factory Movie.fromMap(Map<String, Object?> map) => Movie(
        id: map['id'] as int?,
        title: map['title'] as String,
        category: map['category'] as String,
        videoPath: map['video_path'] as String,
        thumbnailPath: map['thumbnail_path'] as String,
        createdAt: map['created_at'] as int,
        isInList: (map['is_in_list'] as int? ?? 0) == 1,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'video_path': videoPath,
        'thumbnail_path': thumbnailPath,
        'created_at': createdAt,
        'is_in_list': isInList ? 1 : 0,
      };
}
