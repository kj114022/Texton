/// Book format enumeration with display properties
enum BookFormat {
  pdf('PDF', 'pdf'),
  epub('EPUB', 'epub'),
  mobi('MOBI', 'mobi'),
  azw3('AZW3', 'azw3');

  const BookFormat(this.displayName, this.extension);

  final String displayName;
  final String extension;

  static BookFormat? fromString(String value) {
    final lower = value.toLowerCase();
    return BookFormat.values.cast<BookFormat?>().firstWhere(
          (format) => format?.extension == lower,
          orElse: () => null,
        );
  }

  static BookFormat? fromExtension(String ext) {
    final lower = ext.toLowerCase().replaceAll('.', '');
    return BookFormat.values.cast<BookFormat?>().firstWhere(
          (format) => format?.extension == lower,
          orElse: () => null,
        );
  }
}
