import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/video_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/file_scanner_service.dart';
import '../../models/video_entry.dart';
import '../../core/utils/date_utils.dart';

class AddScreen extends StatefulWidget {
  final String? videoId;

  const AddScreen({super.key, this.videoId});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _filePathController = TextEditingController();
  final _notesController = TextEditingController();
  
  final FileScannerService _fileScanner = FileScannerService();
  
  WatchStatus _status = WatchStatus.notStarted;
  double _progress = 0.0;
  double? _rating;
  List<String> _tags = [];
  List<String> _genres = [];
  String? _selectedFormat;
  Duration? _duration;
  int? _fileSize;
  String? _thumbnailUrl;
  
  bool _isLoading = false;
  VideoEntry? _existingVideo;

  @override
  void initState() {
    super.initState();
    if (widget.videoId != null) {
      _loadExistingVideo();
    }
  }

  Future<void> _loadExistingVideo() async {
    final provider = context.read<VideoProvider>();
    _existingVideo = provider.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => throw Exception('Video not found'),
    );
    
    _titleController.text = _existingVideo!.title;
    _filePathController.text = _existingVideo!.filePath ?? '';
    _notesController.text = _existingVideo!.notes.join('\n');
    _status = _existingVideo!.status;
    _progress = _existingVideo!.progress;
    _rating = _existingVideo!.rating;
    _tags = List.from(_existingVideo!.tags);
    _genres = List.from(_existingVideo!.genres);
    _selectedFormat = _existingVideo!.format;
    _duration = _existingVideo!.duration;
    _fileSize = _existingVideo!.fileSize;
    _thumbnailUrl = _existingVideo!.thumbnailUrl;
    
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _filePathController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final filePath = await _fileScanner.pickVideoFile();
    if (filePath != null) {
      setState(() {
        _filePathController.text = filePath;
        if (_titleController.text.isEmpty) {
          _titleController.text = _fileScanner.extractTitleFromPath(filePath);
        }
      });
      
      // Get metadata
      final metadata = await _fileScanner.getVideoMetadata(filePath);
      if (metadata != null) {
        setState(() {
          _duration = metadata['duration'] as Duration?;
          _fileSize = metadata['fileSize'] as int?;
          _selectedFormat = metadata['format'] as String?;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<VideoProvider>();
      final firebaseService = FirebaseService();
      final userId = firebaseService.currentUser?.uid ?? 'local';
      final now = DateTime.now();

      final notes = _notesController.text
          .split('\n')
          .where((n) => n.trim().isNotEmpty)
          .toList();

      final video = VideoEntry(
        id: _existingVideo?.id ?? const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        filePath: _filePathController.text.trim().isEmpty
            ? null
            : _filePathController.text.trim(),
        duration: _duration,
        fileSize: _fileSize,
        format: _selectedFormat,
        thumbnailUrl: _thumbnailUrl,
        status: _status,
        progress: _progress,
        rating: _rating,
        notes: notes,
        tags: _tags,
        genres: _genres,
        createdAt: _existingVideo?.createdAt ?? now,
        updatedAt: now,
        startedDate: _status != WatchStatus.notStarted
            ? (_existingVideo?.startedDate ?? now)
            : null,
        lastWatchedDate: _status != WatchStatus.notStarted ? now : null,
        completedDate: _status == WatchStatus.completed
            ? (_existingVideo?.completedDate ?? now)
            : null,
      );

      if (_existingVideo != null) {
        await provider.updateVideo(video);
      } else {
        await provider.addVideo(video);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingVideo != null ? 'Edit Video' : 'Add Video'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter video title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _filePathController,
                    decoration: const InputDecoration(
                      labelText: 'File Path',
                      hintText: 'Select or enter file path',
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.folder),
                  onPressed: _pickFile,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WatchStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: WatchStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Progress: ${(_progress * 100).toStringAsFixed(0)}%'),
            Slider(
              value: _progress,
              onChanged: (value) {
                setState(() {
                  _progress = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_duration != null)
              Text('Duration: ${AppDateUtils.formatDuration(_duration)}'),
            if (_fileSize != null)
              Text('File Size: ${AppDateUtils.formatFileSize(_fileSize!)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add your notes...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Text('Rating: ${_rating?.toStringAsFixed(1) ?? 'Not rated'}'),
            Slider(
              value: _rating ?? 5.0,
              min: 1.0,
              max: 10.0,
              divisions: 18,
              label: _rating?.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

