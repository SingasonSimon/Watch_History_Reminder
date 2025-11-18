import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/video_provider.dart';
import '../../models/video_entry.dart';
import '../../core/utils/date_utils.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          final videos = provider.videos;
          
          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No statistics yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add videos to see your statistics',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, videos),
                const SizedBox(height: 24),
                _buildStatusChart(context, videos),
                const SizedBox(height: 24),
                _buildGenreChart(context, videos),
                const SizedBox(height: 24),
                _buildWatchTimeStats(context, videos),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, List<VideoEntry> videos) {
    final totalVideos = videos.length;
    final completed = videos.where((v) => v.status == WatchStatus.completed).length;
    final inProgress = videos.where((v) => v.status == WatchStatus.inProgress).length;
    final totalWatchTime = videos
        .where((v) => v.timeWatched != null)
        .fold<Duration>(
          Duration.zero,
          (sum, v) => sum + v.timeWatched!,
        );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Videos',
            totalVideos.toString(),
            Icons.video_library,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            completed.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'In Progress',
            inProgress.toString(),
            Icons.play_circle,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Watch Time',
            AppDateUtils.formatTime(totalWatchTime),
            Icons.access_time,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart(BuildContext context, List<VideoEntry> videos) {
    final statusCounts = <WatchStatus, int>{
      WatchStatus.notStarted: 0,
      WatchStatus.inProgress: 0,
      WatchStatus.completed: 0,
      WatchStatus.dropped: 0,
    };

    for (var video in videos) {
      statusCounts[video.status] = (statusCounts[video.status] ?? 0) + 1;
    }

    final colors = [
      Colors.grey,
      Theme.of(context).colorScheme.primary,
      Colors.green,
      Colors.red,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: statusCounts.entries
                      .where((e) => e.value > 0)
                      .map((entry) {
                    final index = WatchStatus.values.indexOf(entry.key);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[index],
                      radius: 80,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: statusCounts.entries
                  .where((e) => e.value > 0)
                  .map((entry) {
                final index = WatchStatus.values.indexOf(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: colors[index],
                    ),
                    const SizedBox(width: 4),
                    Text(entry.key.name),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChart(BuildContext context, List<VideoEntry> videos) {
    final genreCounts = <String, int>{};
    
    for (var video in videos) {
      for (var genre in video.genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    if (genreCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Genres',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topGenres.first.value.toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < topGenres.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                topGenres[index].key,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: topGenres.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchTimeStats(BuildContext context, List<VideoEntry> videos) {
    final totalWatchTime = videos
        .where((v) => v.timeWatched != null)
        .fold<Duration>(
          Duration.zero,
          (sum, v) => sum + v.timeWatched!,
        );

    final totalDuration = videos
        .where((v) => v.duration != null)
        .fold<Duration>(
          Duration.zero,
          (sum, v) => sum + v.duration!,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watch Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              'Total Watched',
              AppDateUtils.formatDuration(totalWatchTime),
            ),
            _buildStatRow(
              context,
              'Total Duration',
              AppDateUtils.formatDuration(totalDuration),
            ),
            if (totalDuration.inSeconds > 0)
              _buildStatRow(
                context,
                'Completion Rate',
                '${((totalWatchTime.inSeconds / totalDuration.inSeconds) * 100).toStringAsFixed(1)}%',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

