import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  String _searchQuery = '';
  BookStatus? _filterStatus;
  String _filterGenre = '';
  bool _isDarkTheme = false;
  final _uuid = const Uuid();

  List<Book> get books => _filteredBooks;
  bool get isDarkTheme => _isDarkTheme;
  String get searchQuery => _searchQuery;
  BookStatus? get filterStatus => _filterStatus;
  String get filterGenre => _filterGenre;

  List<String> get allGenres {
    final genres = _books
        .map((b) => b.genre)
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    genres.sort();
    return genres;
  }

  int get totalBooks => _books.length;
  int get readBooks => _books.where((b) => b.status == BookStatus.read).length;
  int get readingBooks => _books.where((b) => b.status == BookStatus.reading).length;
  int get toReadBooks => _books.where((b) => b.status == BookStatus.toRead).length;

  List<Book> get _filteredBooks {
    List<Book> result = List.from(_books);

    if (_searchQuery.isNotEmpty) {
      result = result.where((b) =>
        b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.genre.toLowerCase().contains(_searchQuery.toLowerCase()),
      ).toList();
    }

    if (_filterStatus != null) {
      result = result.where((b) => b.status == _filterStatus).toList();
    }

    if (_filterGenre.isNotEmpty) {
      result = result.where((b) => b.genre == _filterGenre).toList();
    }

    return result;
  }

  BookProvider() {
    _loadBooks();
  }

  // ─── CREATE ───────────────────────────────────────────────────────────────
  void addBook({
    required String title,
    required String author,
    String genre = '',
    String description = '',
    BookStatus status = BookStatus.toRead,
    int totalPages = 0,
    double rating = 0.0,
    String? coverColor,
  }) {
    final book = Book(
      id: _uuid.v4(),
      title: title,
      author: author,
      genre: genre,
      description: description,
      status: status,
      totalPages: totalPages,
      rating: rating,
      coverColor: coverColor,
    );
    _books.add(book);
    _saveBooks();
    notifyListeners();
  }

  // ─── READ ─────────────────────────────────────────────────────────────────
  Book? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────
  void updateBook(Book updatedBook) {
    final index = _books.indexWhere((b) => b.id == updatedBook.id);
    if (index != -1) {
      _books[index] = updatedBook;
      _saveBooks();
      notifyListeners();
    }
  }

  void updateReadingProgress(String id, int currentPage) {
    final book = getBookById(id);
    if (book != null) {
      updateBook(book.copyWith(currentPage: currentPage));
    }
  }

  void updateStatus(String id, BookStatus status) {
    final book = getBookById(id);
    if (book != null) {
      final updated = book.copyWith(status: status);
      if (status == BookStatus.read && book.totalPages > 0) {
        updateBook(updated.copyWith(currentPage: book.totalPages));
      } else {
        updateBook(updated);
      }
    }
  }

  void updateRating(String id, double rating) {
    final book = getBookById(id);
    if (book != null) {
      updateBook(book.copyWith(rating: rating));
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    _saveBooks();
    notifyListeners();
  }

  // ─── SEARCH & FILTER ──────────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(BookStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterGenre(String genre) {
    _filterGenre = genre;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterGenre = '';
    notifyListeners();
  }

  // ─── THEME ────────────────────────────────────────────────────────────────
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _savePrefs();
    notifyListeners();
  }

  // ─── PERSISTENCE ──────────────────────────────────────────────────────────
  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _books.map((b) => b.toJson()).toList();
    await prefs.setString('books', json.encode(list));
  }

  Future<void> _loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('darkTheme') ?? false;
    final data = prefs.getString('books');
    if (data != null) {
      final list = json.decode(data) as List<dynamic>;
      _books = list.map((e) => Book.fromJson(e as String)).toList();
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', _isDarkTheme);
  }
}