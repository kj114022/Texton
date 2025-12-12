import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/book.dart';
import '../models/book_format.dart';
import 'book_source.dart';

/// Library Genesis book source implementation
/// Scrapes search results from libgen.rs
class LibgenSource implements BookSource {
  final Dio _dio;

  LibgenSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              },
            ));

  @override
  String get name => 'Library Genesis';

  @override
  String get baseUrl => 'https://libgen.rs';

  @override
  Future<List<Book>> search(String query) async {
    final books = <Book>[];
    final encodedQuery = Uri.encodeComponent(query);
    final searchUrl =
        '$baseUrl/search.php?req=$encodedQuery&lg_topic=libgen&open=0&view=simple&res=50&phrase=1&column=def';

    try {
      final response = await _dio.get(searchUrl);
      final document = html_parser.parse(response.data);

      // Find the results table
      final tables = document.querySelectorAll('table.c');
      if (tables.isEmpty) return books;

      final resultsTable = tables.last;
      final rows = resultsTable.querySelectorAll('tr');

      // Skip the header row
      for (final row in rows.skip(1).take(50)) {
        try {
          final cells = row.querySelectorAll('td');
          if (cells.length < 9) continue;

          // Extract ID
          final idCell = cells[0];
          final id = idCell.text.trim();
          if (id.isEmpty) continue;

          // Extract authors
          final authorCell = cells[1];
          final authorLinks = authorCell.querySelectorAll('a');
          final authors = authorLinks.isNotEmpty
              ? authorLinks.map((a) => a.text.trim()).toList()
              : ['Unknown'];

          // Extract title
          final titleCell = cells[2];
          final titleLink = titleCell.querySelector('a');
          final title = titleLink?.text.trim() ?? '';
          if (title.isEmpty) continue;

          // Extract details URL
          final href = titleLink?.attributes['href'] ?? '';
          final detailsUrl = href.startsWith('http') ? href : '$baseUrl/$href';

          // Extract publisher
          final publisherCell = cells[3];
          final publisher = publisherCell.text.trim();

          // Extract year
          final yearCell = cells[4];
          final year = yearCell.text.trim();

          // Extract size
          final sizeCell = cells[7];
          final size = sizeCell.text.trim();

          // Extract extension/format
          final extensionCell = cells[8];
          final extension = extensionCell.text.trim().toLowerCase();
          final format = BookFormat.fromExtension(extension) ?? BookFormat.pdf;

          // Extract cover image from mirror
          String? imageUrl;
          final mirrors = cells.last.querySelectorAll('a');
          if (mirrors.isNotEmpty) {
            final mirrorHref = mirrors.first.attributes['href'] ?? '';
            if (mirrorHref.contains('library.lol')) {
              imageUrl = mirrorHref;
            }
          }

          final book = Book(
            id: id,
            authors: authors,
            title: title,
            format: format,
            downloadUrl: detailsUrl,
            imageUrl: imageUrl,
            size: size,
            source: name,
            detailsUrl: detailsUrl,
            publisher: publisher.isNotEmpty ? publisher : null,
            year: year.isNotEmpty ? year : null,
          );

          books.add(book);
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      rethrow;
    }

    return books;
  }

  @override
  Future<Book?> getDetails(String bookId) async {
    // LibGen requires navigating to the book page to get full details
    // For now, return null - details can be fetched from the list
    return null;
  }
}
