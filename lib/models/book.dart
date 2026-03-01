import 'dart:convert';

enum BookStatus { toRead, reading, read }

class Book {
  final String id;
  String title;
  String author;
  String genre;
  String description;
  BookStatus status;
  int totalPages;
  int currentPage;
  double rating;
  DateTime addedDate;
  String? coverColor;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.genre = '',
    this.description = '',
    this.status = BookStatus.toRead,
    this.totalPages = 0,
    this.currentPage = 0,
    this.rating = 0.0,
    DateTime? addedDate,
    this.coverColor,
  }) : addedDate = addedDate ?? DateTime.now();

  double get readingProgress {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  String get statusLabel {
    switch (status) {
      case BookStatus.toRead:
        return 'To Read';
      case BookStatus.reading:
        return 'Reading';
      case BookStatus.read:
        return 'Read';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'status': status.index,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'rating': rating,
      'addedDate': addedDate.toIso8601String(),
      'coverColor': coverColor,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      genre: (map['genre'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      status: BookStatus.values[map['status'] as int],
      totalPages: map['totalPages'] as int,
      currentPage: map['currentPage'] as int,
      rating: (map['rating'] as num).toDouble(),
      addedDate: DateTime.parse(map['addedDate'] as String),
      coverColor: map['coverColor'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory Book.fromJson(String source) => Book.fromMap(json.decode(source) as Map<String, dynamic>);

  Book copyWith({
    String? title,
    String? author,
    String? genre,
    String? description,
    BookStatus? status,
    int? totalPages,
    int? currentPage,
    double? rating,
    String? coverColor,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      status: status ?? this.status,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      rating: rating ?? this.rating,
      addedDate: addedDate,
      coverColor: coverColor ?? this.coverColor,
    );
  }
}