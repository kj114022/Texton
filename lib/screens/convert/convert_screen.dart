import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/book_format.dart';

/// Convert screen for eBook format conversion
class ConvertScreen extends ConsumerStatefulWidget {
  const ConvertScreen({super.key});

  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen> {
  BookFormat _fromFormat = BookFormat.pdf;
  BookFormat _toFormat = BookFormat.epub;
  String? _selectedFileName;
  bool _isConverting = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            largeTitle: Text(
              'Convert',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  _buildHeaderSection(),
                  const SizedBox(height: 32),

                  // File upload section
                  _buildUploadSection(),
                  const SizedBox(height: 24),

                  // Format selection
                  _buildFormatSelection(),
                  const SizedBox(height: 32),

                  // Convert button
                  _buildConvertButton(),
                  const SizedBox(height: 24),

                  // Supported formats info
                  _buildFormatInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.xBlue.withValues(alpha: 0.15),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.xBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.xBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.arrow_2_squarepath,
              color: AppColors.xBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Format Converter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Convert between PDF, EPUB, MOBI, and AZW3',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedFileName != null
                ? AppColors.xBlue
                : AppColors.border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFileName != null
                  ? CupertinoIcons.doc_checkmark
                  : CupertinoIcons.cloud_upload,
              color: _selectedFileName != null
                  ? AppColors.success
                  : AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFileName ?? 'Tap to select a file',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFileName != null
                  ? 'Tap to change file'
                  : 'PDF, EPUB, MOBI, or AZW3 (Max 50MB)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Convert Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // From format
        _buildFormatRow(
          label: 'From',
          selectedFormat: _fromFormat,
          onChanged: (format) => setState(() => _fromFormat = format),
        ),
        const SizedBox(height: 16),

        // Arrow indicator
        Center(
          child: Icon(
            CupertinoIcons.arrow_down,
            color: AppColors.xBlue,
            size: 24,
          ),
        ),
        const SizedBox(height: 16),

        // To format
        _buildFormatRow(
          label: 'To',
          selectedFormat: _toFormat,
          onChanged: (format) => setState(() => _toFormat = format),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFormatRow({
    required String label,
    required BookFormat selectedFormat,
    required ValueChanged<BookFormat> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: BookFormat.values.map((format) {
              final isSelected = format == selectedFormat;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(format),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: format != BookFormat.values.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.xBlue
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.xBlue
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        format.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertButton() {
    final canConvert = _selectedFileName != null && _fromFormat != _toFormat;

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: canConvert ? AppColors.xBlue : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(vertical: 16),
        onPressed: canConvert && !_isConverting ? _startConversion : null,
        child: _isConverting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(color: AppColors.textPrimary),
                  const SizedBox(width: 12),
                  Text(
                    'Converting...',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              )
            : Text(
                'Convert',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: canConvert
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: AppColors.xBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Conversion Notes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'PDF',
            description: 'Best for printing and fixed layouts',
          ),
          _InfoRow(
            label: 'EPUB',
            description: 'Most compatible with e-readers',
          ),
          _InfoRow(
            label: 'MOBI',
            description: 'Legacy format for older Kindles',
          ),
          _InfoRow(
            label: 'AZW3',
            description: 'Modern Kindle format with rich features',
            isLast: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub', 'mobi', 'azw3'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFileName = file.name;
      });

      // Auto-detect format
      final extension = file.extension?.toLowerCase();
      if (extension != null) {
        final format = BookFormat.fromExtension(extension);
        if (format != null) {
          setState(() => _fromFormat = format);
        }
      }
    }
  }

  Future<void> _startConversion() async {
    setState(() => _isConverting = true);

    // TODO: Implement actual conversion
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isConverting = false);

    if (mounted) {
      _showConversionResult(context);
    }
  }

  void _showConversionResult(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Conversion Complete'),
        content: Text(
          'Your file has been converted to ${_toFormat.displayName} format.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String description;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
