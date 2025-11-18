import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_provider.dart';
import '../../widgets/video/video_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/animated_fade_in.dart';
import '../../routes/app_router.dart';
import '../../core/utils/date_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.add);
            },
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading your videos...');
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadVideos(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  AnimatedFadeIn(
                    child: _buildQuickStats(provider),
                  ),
                  
                  // Continue Watching
                  if (provider.continueWatching.isNotEmpty) ...[
                    AnimatedFadeIn(
                      child: _buildSectionHeader('Continue Watching', () {}),
                    ),
                    _buildContinueWatching(provider),
                  ],
                  
                  // Recent Watches
                  if (provider.recentVideos.isNotEmpty) ...[
                    AnimatedFadeIn(
                      child: _buildSectionHeader('Recent Watches', () {
                        Navigator.pushNamed(context, AppRouter.library);
                      }),
                    ),
                    _buildRecentWatches(provider),
                  ],
                  
                  // Empty State
                  if (provider.videos.isEmpty)
                    const EmptyState(
                      icon: Icons.movie_outlined,
                      title: 'No videos yet',
                      message: 'Add your first video to get started!',
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.add);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickStats(VideoProvider provider) {
    final totalVideos = provider.videos.length;
    final completed = provider.completedVideos.length;
    final inProgress = provider.continueWatching.length;
    final totalWatchTime = provider.videos
        .where((v) => v.timeWatched != null)
        .fold<Duration>(
          Duration.zero,
          (sum, v) => sum + v.timeWatched!,
        );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalVideos.toString(), Icons.video_library),
          _buildStatItem('Watching', inProgress.toString(), Icons.play_circle),
          _buildStatItem('Completed', completed.toString(), Icons.check_circle),
          _buildStatItem('Watch Time', AppDateUtils.formatTime(totalWatchTime), Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatching(VideoProvider provider) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.continueWatching.length,
        itemBuilder: (context, index) {
          final video = provider.continueWatching[index];
          return SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: VideoCard(
                video: video,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.detail,
                    arguments: {'videoId': video.id},
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentWatches(VideoProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.recentVideos.take(5).length,
      itemBuilder: (context, index) {
        final video = provider.recentVideos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VideoCard(
            video: video,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.detail,
                arguments: {'videoId': video.id},
              );
            },
          ),
        );
      },
    );
  }
}

