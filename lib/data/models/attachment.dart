/// Represents a file/image attachment
class Attachment {
  final String id;
  final String url;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? thumbnailUrl;
  final int? width;
  final int? height;

  const Attachment({
    required this.id,
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.thumbnailUrl,
    this.width,
    this.height,
  });

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isAudio => mimeType.startsWith('audio/');
  bool get isDocument => 
      mimeType.contains('pdf') || 
      mimeType.contains('epub') || 
      mimeType.contains('document');

  String get sizeDisplay {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }
}
