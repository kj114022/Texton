import '../models/book.dart';

/// Abstract interface for book search sources
abstract class BookSource {
  String get name;
  String get baseUrl;

  Future<List<Book>> search(String query);
  Future<Book?> getDetails(String bookId);
}
