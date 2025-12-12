import 'book_format.dart';

/// Represents a book from any source
class Book {
  final String id;
  final List<String> authors;
  final String title;
  final BookFormat format;
  final String downloadUrl;
  final String? imageUrl;
  final String? size;
  final String source;
  final String? detailsUrl;
  final String? description;
  final String? publisher;
  final String? year;
  final String? language;
  final String? isbn;

  const Book({
    required this.id,
    required this.authors,
    required this.title,
    required this.format,
    required this.downloadUrl,
    this.imageUrl,
    this.size,
    required this.source,
    this.detailsUrl,
    this.description,
    this.publisher,
    this.year,
    this.language,
    this.isbn,
  });

  String get authorsDisplay {
    if (authors.isEmpty) return 'Unknown Author';
    if (authors.length == 1) return authors.first;
    if (authors.length == 2) return authors.join(' & ');
    return '${authors.first} et al.';
  }

  String get formatExtension => format.extension;

  Book copyWith({
    String? id,
    List<String>? authors,
    String? title,
    BookFormat? format,
    String? downloadUrl,
    String? imageUrl,
    String? size,
    String? source,
    String? detailsUrl,
    String? description,
    String? publisher,
    String? year,
    String? language,
    String? isbn,
  }) {
    return Book(
      id: id ?? this.id,
      authors: authors ?? this.authors,
      title: title ?? this.title,
      format: format ?? this.format,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      source: source ?? this.source,
      detailsUrl: detailsUrl ?? this.detailsUrl,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
      language: language ?? this.language,
      isbn: isbn ?? this.isbn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id && other.source == source;
  }

  @override
  int get hashCode => id.hashCode ^ source.hashCode;

  @override
  String toString() => 'Book(id: $id, title: $title, format: ${format.displayName})';
}
