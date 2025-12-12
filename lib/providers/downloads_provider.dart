import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/book.dart';
import '../data/models/download_result.dart';

/// State for download management
class DownloadsState {
  final List<DownloadedBook> downloads;
  final Map<String, double> activeDownloads;
  final String? error;

  const DownloadsState({
    this.downloads = const [],
    this.activeDownloads = const {},
    this.error,
  });

  DownloadsState copyWith({
    List<DownloadedBook>? downloads,
    Map<String, double>? activeDownloads,
    String? error,
  }) {
    return DownloadsState(
      downloads: downloads ?? this.downloads,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      error: error,
    );
  }
}

/// Represents a downloaded book file
class DownloadedBook {
  final String id;
  final String title;
  final String filePath;
  final String format;
  final int fileSizeBytes;
  final DateTime downloadedAt;

  const DownloadedBook({
    required this.id,
    required this.title,
    required this.filePath,
    required this.format,
    required this.fileSizeBytes,
    required this.downloadedAt,
  });

  String get fileSizeDisplay {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Downloads notifier for managing book downloads
class DownloadsNotifier extends StateNotifier<DownloadsState> {
  final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};

  DownloadsNotifier()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 10),
        )),
        super(const DownloadsState()) {
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
        return;
      }

      final files = downloadsDir.listSync();
      final downloads = <DownloadedBook>[];

      for (final file in files) {
        if (file is File) {
          final stat = file.statSync();
          final name = file.path.split('/').last;
          final parts = name.split('.');

          downloads.add(DownloadedBook(
            id: name.hashCode.toString(),
            title: parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : name,
            filePath: file.path,
            format: parts.isNotEmpty ? parts.last.toUpperCase() : 'UNKNOWN',
            fileSizeBytes: stat.size,
            downloadedAt: stat.modified,
          ));
        }
      }

      // Sort by download date, newest first
      downloads.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));

      state = state.copyWith(downloads: downloads);
    } catch (_) {
      // Silently fail - downloads list will be empty
    }
  }

  Future<DownloadResult> downloadBook(Book book) async {
    final cancelToken = CancelToken();
    _cancelTokens[book.id] = cancelToken;

    // Update active downloads
    state = state.copyWith(
      activeDownloads: {...state.activeDownloads, book.id: 0.0},
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final fileName = '${book.title}.${book.format.extension}';
      final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\s\-.]'), '_');
      final filePath = '${downloadsDir.path}/$sanitizedFileName';

      await _dio.download(
        book.downloadUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = state.copyWith(
              activeDownloads: {...state.activeDownloads, book.id: progress},
            );
          }
        },
      );

      // Remove from active downloads
      final activeDownloads = Map<String, double>.from(state.activeDownloads);
      activeDownloads.remove(book.id);
      state = state.copyWith(activeDownloads: activeDownloads);

      // Reload downloads list
      await _loadDownloads();

      return DownloadSuccess(filePath: filePath, fileName: sanitizedFileName);
    } on DioException catch (e) {
      // Remove from active downloads
      final activeDownloads = Map<String, double>.from(state.activeDownloads);
      activeDownloads.remove(book.id);
      state = state.copyWith(activeDownloads: activeDownloads);

      if (e.type == DioExceptionType.cancel) {
        return const DownloadCancelled();
      }
      return DownloadError(e.message ?? 'Download failed');
    } catch (e) {
      final activeDownloads = Map<String, double>.from(state.activeDownloads);
      activeDownloads.remove(book.id);
      state = state.copyWith(activeDownloads: activeDownloads);

      return DownloadError(e.toString());
    } finally {
      _cancelTokens.remove(book.id);
    }
  }

  void cancelDownload(String bookId) {
    _cancelTokens[bookId]?.cancel();
    _cancelTokens.remove(bookId);

    final activeDownloads = Map<String, double>.from(state.activeDownloads);
    activeDownloads.remove(bookId);
    state = state.copyWith(activeDownloads: activeDownloads);
  }

  Future<void> deleteDownload(DownloadedBook download) async {
    try {
      final file = File(download.filePath);
      if (file.existsSync()) {
        await file.delete();
      }

      final downloads = List<DownloadedBook>.from(state.downloads);
      downloads.removeWhere((d) => d.id == download.id);
      state = state.copyWith(downloads: downloads);
    } catch (_) {
      state = state.copyWith(error: 'Failed to delete file');
    }
  }

  Future<void> refresh() async {
    await _loadDownloads();
  }
}

/// Provider for downloads state
final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, DownloadsState>(
  (ref) => DownloadsNotifier(),
);
