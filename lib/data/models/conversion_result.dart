/// Result of a book format conversion operation
sealed class ConversionResult {
  const ConversionResult();
}

class ConversionSuccess extends ConversionResult {
  final String downloadUrl;
  final String fileName;

  const ConversionSuccess({
    required this.downloadUrl,
    required this.fileName,
  });
}

class ConversionError extends ConversionResult {
  final String message;

  const ConversionError(this.message);
}

class ConversionEmptyContents extends ConversionResult {
  const ConversionEmptyContents();
}

class ConversionEmptyFilename extends ConversionResult {
  const ConversionEmptyFilename();
}

class ConversionAlreadyInFormat extends ConversionResult {
  const ConversionAlreadyInFormat();
}

class ConversionLimitReached extends ConversionResult {
  const ConversionLimitReached();
}

class ConversionFileSizeExceeded extends ConversionResult {
  final int maxSizeMb;

  const ConversionFileSizeExceeded(this.maxSizeMb);
}
