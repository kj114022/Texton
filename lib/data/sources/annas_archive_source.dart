import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/book.dart';
import '../models/book_format.dart';
import 'book_source.dart';

/// Anna's Archive book source implementation
/// Scrapes search results from annas-archive.org
class AnnasArchiveSource implements BookSource {
  final Dio _dio;

  AnnasArchiveSource({Dio? dio})
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
  String get name => "Anna's Archive";

  @override
  String get baseUrl => 'https://annas-archive.org';

  @override
  Future<List<Book>> search(String query) async {
    final books = <Book>[];
    final encodedQuery = Uri.encodeComponent(query);
    final searchUrl = '$baseUrl/search?q=$encodedQuery';

    try {
      final response = await _dio.get(searchUrl);
      final document = html_parser.parse(response.data);

      // Anna's Archive uses links with /md5/ in the href
      final bookLinks = document.querySelectorAll('a[href^="/md5/"]');

      for (final link in bookLinks.take(100)) {
        try {
          final href = link.attributes['href'] ?? '';
          final fullUrl = '$baseUrl$href';

          // Get the title from the link text
          final title = link.text.trim();
          if (title.isEmpty || title.length < 3) continue;

          // Extract MD5 from href
          final md5Match = RegExp(r'/md5/([a-f0-9]+)').firstMatch(href);
          if (md5Match == null) continue;
          final md5 = md5Match.group(1)!;

          // Try to find metadata near the link
          final parent = link.parent;
          if (parent == null) continue;
          final metaText = parent.text.toLowerCase();

          // Detect format
          BookFormat format = BookFormat.pdf;
          if (metaText.contains('epub')) {
            format = BookFormat.epub;
          } else if (metaText.contains('mobi')) {
            format = BookFormat.mobi;
          } else if (metaText.contains('azw3')) {
            format = BookFormat.azw3;
          }

          // Extract size if available
          final sizeMatch =
              RegExp(r'(\d+(?:\.\d+)?)\s*(MB|KB|GB)', caseSensitive: false)
                  .firstMatch(metaText);
          final size = sizeMatch?.group(0);

          final book = Book(
            id: md5,
            authors: const ['Unknown'],
            title: title,
            format: format,
            downloadUrl: fullUrl,
            imageUrl: null,
            size: size,
            source: name,
            detailsUrl: fullUrl,
          );

          books.add(book);
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      // Log error in production
      rethrow;
    }

    return books;
  }

  @override
  Future<Book?> getDetails(String bookId) async {
    final detailsUrl = '$baseUrl/md5/$bookId';

    try {
      final response = await _dio.get(detailsUrl);
      final document = html_parser.parse(response.data);

      // Extract title
      final titleElement = document.querySelector('h1');
      final title = titleElement?.text.trim() ?? 'Unknown Title';

      // Extract authors
      final authorElements = document.querySelectorAll('.author');
      final authors = authorElements.isNotEmpty
          ? authorElements.map((e) => e.text.trim()).toList()
          : ['Unknown'];

      // Extract description
      final descElement = document.querySelector('.description');
      final description = descElement?.text.trim();

      // Extract format from metadata
      final metaText = document.body?.text.toLowerCase() ?? '';
      BookFormat format = BookFormat.pdf;
      if (metaText.contains('epub')) {
        format = BookFormat.epub;
      } else if (metaText.contains('mobi')) {
        format = BookFormat.mobi;
      } else if (metaText.contains('azw3')) {
        format = BookFormat.azw3;
      }

      return Book(
        id: bookId,
        authors: authors,
        title: title,
        format: format,
        downloadUrl: detailsUrl,
        source: name,
        detailsUrl: detailsUrl,
        description: description,
      );
    } catch (_) {
      return null;
    }
  }
}
