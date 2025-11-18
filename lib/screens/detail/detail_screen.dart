import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_provider.dart';
import '../../models/video_entry.dart';
import '../../routes/app_router.dart';
import '../../core/utils/date_utils.dart';

class DetailScreen extends StatefulWidget {
  final String videoId;

  const DetailScreen({super.key, required this.videoId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  VideoEntry? _video;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() {
    final provider = context.read<VideoProvider>();
    _video = provider.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => throw Exception('Video not found'),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_video == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_video!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.add,
                arguments: widget.videoId,
              ).then((_) => _loadVideo());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (_video!.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _video!.thumbnailUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Status and Progress
            _buildStatusCard(),
            
            const SizedBox(height: 16),
            
            // Info Section
            _buildInfoSection(),
            
            const SizedBox(height: 16),
            
            // Rating
            if (_video!.rating != null) _buildRatingSection(),
            
            const SizedBox(height: 16),
            
            // Tags and Genres
            if (_video!.tags.isNotEmpty || _video!.genres.isNotEmpty)
              _buildTagsSection(),
            
            const SizedBox(height: 16),
            
            // Notes
            if (_video!.notes.isNotEmpty) _buildNotesSection(),
            
            const SizedBox(height: 16),
            
            // Watch Sessions
            if (_video!.watchSessions.isNotEmpty) _buildWatchSessionsSection(),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateProgress,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Update Progress'),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${_video!.status.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 12),
            Text('Progress: ${(_video!.progress * 100).toStringAsFixed(0)}%'),
            LinearProgressIndicator(
              value: _video!.progress,
              minHeight: 8,
            ),
            if (_video!.duration != null) ...[
              const SizedBox(height: 8),
              Text(
                'Watched: ${AppDateUtils.formatDuration(_video!.timeWatched)} / ${AppDateUtils.formatDuration(_video!.duration)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (_video!.status) {
      case WatchStatus.completed:
        color = Colors.green;
        break;
      case WatchStatus.inProgress:
        color = Theme.of(context).colorScheme.primary;
        break;
      case WatchStatus.dropped:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(_video!.status.name),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_video!.filePath != null)
              _buildInfoRow('File Path', _video!.filePath!),
            if (_video!.duration != null)
              _buildInfoRow('Duration', AppDateUtils.formatDuration(_video!.duration)),
            if (_video!.fileSize != null)
              _buildInfoRow('File Size', AppDateUtils.formatFileSize(_video!.fileSize!)),
            if (_video!.format != null)
              _buildInfoRow('Format', _video!.format!),
            if (_video!.startedDate != null)
              _buildInfoRow('Started', AppDateUtils.formatDate(_video!.startedDate!)),
            if (_video!.lastWatchedDate != null)
              _buildInfoRow('Last Watched', AppDateUtils.formatDate(_video!.lastWatchedDate!)),
            if (_video!.completedDate != null)
              _buildInfoRow('Completed', AppDateUtils.formatDate(_video!.completedDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              _video!.rating!.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Text('/ 10'),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_video!.genres.isNotEmpty) ...[
              Text(
                'Genres',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _video!.genres
                    .map((genre) => Chip(label: Text(genre)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (_video!.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _video!.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._video!.notes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(note),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchSessionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watch Sessions (${_video!.watchSessions.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._video!.watchSessions.map((session) => ListTile(
                  title: Text(AppDateUtils.formatDateTime(session.startTime)),
                  trailing: session.duration != null
                      ? Text(AppDateUtils.formatDuration(session.duration!))
                      : null,
                )),
          ],
        ),
      ),
    );
  }

  void _updateProgress() {
    showDialog(
      context: context,
      builder: (context) => _ProgressDialog(
        currentProgress: _video!.progress,
        onSave: (progress) async {
          final provider = context.read<VideoProvider>();
          await provider.updateProgress(widget.videoId, progress);
          _loadVideo();
        },
      ),
    );
  }
}

class _ProgressDialog extends StatefulWidget {
  final double currentProgress;
  final Function(double) onSave;

  const _ProgressDialog({
    required this.currentProgress,
    required this.onSave,
  });

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.currentProgress;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${(_progress * 100).toStringAsFixed(0)}%'),
          Slider(
            value: _progress,
            onChanged: (value) {
              setState(() {
                _progress = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_progress);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

