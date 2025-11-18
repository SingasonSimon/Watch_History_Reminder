import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/video_entry.dart';
import '../../core/utils/date_utils.dart';

class VideoCard extends StatelessWidget {
  final VideoEntry video;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  video.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: video.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildPlaceholder(theme),
                        )
                      : _buildPlaceholder(theme),
                  // Progress indicator
                  if (video.progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: video.progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildStatusBadge(theme),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (video.duration != null)
                    Text(
                      AppDateUtils.formatDuration(video.duration),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  if (video.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.rating!.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceVariant,
      child: Icon(
        Icons.movie,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color color;
    IconData icon;
    
    switch (video.status) {
      case WatchStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case WatchStatus.inProgress:
        color = theme.colorScheme.primary;
        icon = Icons.play_circle;
        break;
      case WatchStatus.dropped:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

