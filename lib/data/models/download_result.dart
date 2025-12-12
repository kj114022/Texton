/// Result of a book download operation
sealed class DownloadResult {
  const DownloadResult();
}

class DownloadSuccess extends DownloadResult {
  final String filePath;
  final String fileName;

  const DownloadSuccess({
    required this.filePath,
    required this.fileName,
  });
}

class DownloadError extends DownloadResult {
  final String message;

  const DownloadError(this.message);
}

class DownloadProgress extends DownloadResult {
  final double progress;
  final int received;
  final int total;

  const DownloadProgress({
    required this.progress,
    required this.received,
    required this.total,
  });

  String get progressPercent => '${(progress * 100).toStringAsFixed(0)}%';
}

class DownloadCancelled extends DownloadResult {
  const DownloadCancelled();
}
