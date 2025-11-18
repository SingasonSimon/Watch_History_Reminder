import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/video_entry.dart';
import '../../core/utils/date_utils.dart';

class VideoListItem extends StatelessWidget {
  final VideoEntry video;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const VideoListItem({
    super.key,
    required this.video,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(video.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 60,
            child: video.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: video.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.movie,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.movie,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
          ),
        ),
        title: Text(
          video.title,
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video.duration != null)
              Text(
                AppDateUtils.formatDuration(video.duration),
                style: theme.textTheme.bodySmall,
              ),
            if (video.progress > 0)
              LinearProgressIndicator(
                value: video.progress,
                backgroundColor: theme.colorScheme.surfaceVariant,
                minHeight: 2,
              ),
          ],
        ),
        trailing: _buildStatusIcon(theme),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    IconData icon;
    Color color;
    
    switch (video.status) {
      case WatchStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case WatchStatus.inProgress:
        icon = Icons.play_circle;
        color = theme.colorScheme.primary;
        break;
      case WatchStatus.dropped:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.circle_outlined;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 24);
  }
}

