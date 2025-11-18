// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watch_history_tracker/core/theme/app_theme.dart';
import 'package:watch_history_tracker/widgets/common/bottom_nav_bar.dart';
import 'package:watch_history_tracker/widgets/common/loading_indicator.dart';
import 'package:watch_history_tracker/widgets/common/empty_state.dart';

void main() {
  testWidgets('Bottom navigation bar renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: const Center(child: Text('Test')),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            onTap: (index) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify bottom navigation bar exists
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verify navigation destinations are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Loading indicator displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(message: 'Loading...'),
        ),
      ),
    );

    await tester.pump(); // Use pump instead of pumpAndSettle for loading indicators

    // Verify loading indicator exists
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('Empty state displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.movie_outlined,
            title: 'No videos',
            message: 'Add your first video',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state elements exist
    expect(find.text('No videos'), findsOneWidget);
    expect(find.text('Add your first video'), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });
}
