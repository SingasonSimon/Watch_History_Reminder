import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_provider.dart';
import '../../models/video_entry.dart';
import '../../widgets/video/video_card.dart';
import '../../widgets/video/video_list_item.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../routes/app_router.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isGridView = true;
  String _searchQuery = '';
  WatchStatus? _filterStatus;
  String? _sortBy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _filterStatus = null;
                } else {
                  _filterStatus = WatchStatus.values.firstWhere(
                    (e) => e.name == value,
                  );
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'notStarted', child: Text('Not Started')),
              const PopupMenuItem(value: 'inProgress', child: Text('In Progress')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'dropped', child: Text('Dropped')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search videos...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Video List
          Expanded(
            child: Consumer<VideoProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator();
                }

                var videos = provider.videos;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  videos = videos
                      .where((v) => v.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Apply status filter
                if (_filterStatus != null) {
                  videos = videos
                      .where((v) => v.status == _filterStatus)
                      .toList();
                }

                // Apply sort
                if (_sortBy == 'title') {
                  videos.sort((a, b) => a.title.compareTo(b.title));
                } else if (_sortBy == 'date') {
                  videos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                }

                if (videos.isEmpty) {
                  return EmptyState(
                    icon: Icons.video_library_outlined,
                    title: _searchQuery.isNotEmpty
                        ? 'No videos found'
                        : 'No videos yet',
                    message: _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Add your first video to get started!',
                  );
                }

                return _isGridView
                    ? _buildGridView(videos, provider)
                    : _buildListView(videos, provider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.add);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridView(List<VideoEntry> videos, VideoProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoCard(
          video: video,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.detail,
              arguments: {'videoId': video.id},
            );
          },
          onLongPress: () {
            _showDeleteDialog(context, video, provider);
          },
        );
      },
    );
  }

  Widget _buildListView(List<VideoEntry> videos, VideoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: VideoListItem(
            video: video,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.detail,
                arguments: {'videoId': video.id},
              );
            },
            onDelete: () {
              provider.deleteVideo(video.id);
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    VideoEntry video,
    VideoProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Are you sure you want to delete "${video.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteVideo(video.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

