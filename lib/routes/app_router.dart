import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/add/add_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/detail/detail_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String library = '/library';
  static const String add = '/add';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String detail = '/detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (routeName == library) {
      return MaterialPageRoute(builder: (_) => const LibraryScreen());
    } else if (routeName == add) {
      final args = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => AddScreen(videoId: args is String ? args : null),
      );
    } else if (routeName == statistics) {
      return MaterialPageRoute(builder: (_) => const StatisticsScreen());
    } else if (routeName == AppRouter.settings) {
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    } else if (routeName == detail) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => DetailScreen(videoId: args!['videoId'] as String),
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
    }
  }
}

