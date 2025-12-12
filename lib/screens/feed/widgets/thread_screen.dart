import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../providers/feed_provider.dart';

/// Thread detail screen showing OP and all replies with reference linking
class ThreadScreen extends ConsumerStatefulWidget {
  final Thread thread;

  const ThreadScreen({super.key, required this.thread});

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
  final _scrollController = ScrollController();
  final _replyController = TextEditingController();
  final Set<String> _highlightedPosts = {};
  bool _showReplyBar = false;
  final List<String> _replyingTo = [];

  @override
  void dispose() {
    _scrollController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    final allPosts = [thread.op, ...thread.replies];

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        middle: Text(
          'Thread ${thread.op.displayId}',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => _showReplyBar = !_showReplyBar),
          child: Icon(CupertinoIcons.reply, color: AppColors.primary),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return _PostItem(
                  post: post,
                  allPosts: allPosts,
                  isHighlighted: _highlightedPosts.contains(post.id),
                  onQuote: () => _addQuote(post),
                  onReferenceClick: (refId) => _scrollToPost(refId, allPosts),
                  onReferenceHover: (refId) => _highlightPost(refId),
                  onReferenceHoverEnd: (refId) => _unhighlightPost(refId),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 30 * index),
                );
              },
            ),
          ),

          // Reply bar
          if (_showReplyBar) _buildReplyBar(),
        ],
      ),
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply references
            if (_replyingTo.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _replyingTo.map((id) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '>>${id.substring(0, 8)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _replyingTo.remove(id)),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (_replyingTo.isNotEmpty) const SizedBox(height: 8),

            // Input row
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _replyController,
                    placeholder: 'Write a reply...',
                    placeholderStyle: TextStyle(color: AppColors.textTertiary),
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: _submitReply,
                  child: Icon(
                    CupertinoIcons.arrow_up,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addQuote(Post post) {
    if (!_replyingTo.contains(post.id)) {
      setState(() {
        _replyingTo.add(post.id);
        _showReplyBar = true;
      });
    }
  }

  void _scrollToPost(String postId, List<Post> allPosts) {
    final index = allPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _scrollController.animateTo(
        index * 200.0, // Approximate height
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _highlightPost(postId);
      Future.delayed(const Duration(seconds: 2), () => _unhighlightPost(postId));
    }
  }

  void _highlightPost(String postId) {
    setState(() => _highlightedPosts.add(postId));
  }

  void _unhighlightPost(String postId) {
    setState(() => _highlightedPosts.remove(postId));
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;

    ref.read(feedProvider.notifier).replyToThread(
      threadId: widget.thread.id,
      content: _replyController.text.trim(),
      replyToIds: _replyingTo,
    );

    setState(() {
      _replyController.clear();
      _replyingTo.clear();
      _showReplyBar = false;
    });
  }
}

/// Individual post item with reply reference rendering
class _PostItem extends StatelessWidget {
  final Post post;
  final List<Post> allPosts;
  final bool isHighlighted;
  final VoidCallback onQuote;
  final Function(String) onReferenceClick;
  final Function(String) onReferenceHover;
  final Function(String) onReferenceHoverEnd;

  const _PostItem({
    required this.post,
    required this.allPosts,
    required this.isHighlighted,
    required this.onQuote,
    required this.onReferenceClick,
    required this.onReferenceHover,
    required this.onReferenceHoverEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : AppColors.border,
          width: isHighlighted ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // OP badge
              if (post.isOp)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OP',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Author
              Text(
                post.displayName,
                style: TextStyle(
                  color: post.authorName != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (post.tripcode != null) ...[
                const SizedBox(width: 4),
                Text(
                  post.tripcode!,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              // Post ID
              Text(
                post.displayId,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
              Text(
                ' · ${post.timeAgo}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Reply references (>>postId)
          if (post.replyToIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: post.replyToIds.map((refId) {
                return GestureDetector(
                  onTap: () => onReferenceClick(refId),
                  onLongPress: () => onReferenceHover(refId),
                  onLongPressEnd: (_) => onReferenceHoverEnd(refId),
                  child: Text(
                    '>>${refId.substring(0, 8)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 8),

          // Content with greentext support
          _buildContentWithGreentext(post.content),

          // Attachment
          if (post.hasImage) ...[
            const SizedBox(height: 8),
            _ImageAttachment(attachment: post.primaryImage!),
          ] else if (post.hasFile) ...[
            const SizedBox(height: 8),
            _FileAttachment(attachment: post.attachments.first),
          ],

          // Action bar
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onQuote,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.reply,
                      color: AppColors.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Quote',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithGreentext(String content) {
    // Parse greentext (lines starting with >)
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final isGreentext = line.trim().startsWith('>') && 
            !line.trim().startsWith('>>');
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            line,
            style: TextStyle(
              color: isGreentext ? AppColors.success : AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ImageAttachment extends StatelessWidget {
  final dynamic attachment;

  const _ImageAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 200,
        color: AppColors.surfaceVariant,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.photo,
                color: AppColors.textTertiary,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                attachment.fileName,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileAttachment extends StatelessWidget {
  final dynamic attachment;

  const _FileAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                attachment.extension,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.sizeDisplay,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.cloud_download,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
