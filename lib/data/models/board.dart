import 'package:flutter/cupertino.dart';

/// Represents a board/topic category (like /b/, /v/, /books/)
class Board {
  final String id;
  final String shortName;    // e.g., "b", "v", "books"
  final String displayName;  // e.g., "Random", "Video Games", "Books"
  final String description;
  final Color accentColor;
  final bool requiresImage;  // OP must include image
  final int maxFileSize;     // In bytes

  const Board({
    required this.id,
    required this.shortName,
    required this.displayName,
    required this.description,
    required this.accentColor,
    this.requiresImage = true,
    this.maxFileSize = 6 * 1024 * 1024, // 6MB default
  });

  String get path => '/$shortName/';

  static const List<Board> defaultBoards = [
    Board(
      id: 'books',
      shortName: 'books',
      displayName: 'Books & Literature',
      description: 'Share and discuss books, PDFs, EPUBs',
      accentColor: Color(0xFFBA0109),
    ),
    Board(
      id: 'tech',
      shortName: 'tech',
      displayName: 'Technology',
      description: 'Programming, software, hardware',
      accentColor: Color(0xFF7B0005),
    ),
    Board(
      id: 'random',
      shortName: 'b',
      displayName: 'Random',
      description: 'Anything goes',
      accentColor: Color(0xFF44010A),
    ),
    Board(
      id: 'files',
      shortName: 'f',
      displayName: 'File Sharing',
      description: 'Share any type of file',
      accentColor: Color(0xFFCC1D2C),
      requiresImage: false,
    ),
  ];
}
