import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../main.dart';

void main() {
  // Helper function to set large screen size
  Future<void> setLargeScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
  }

  // Helper function to perform login
  Future<void> performLogin(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'admin');
    await tester.enterText(find.byType(TextField).last, 'admin123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
  }

  // Cleanup helper
  void resetScreen(WidgetTester tester) {
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('Full Application Integration Tests', () {
    testWidgets('Complete login to logout flow', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());

      // Verify login page
      expect(find.text('Delta Pharmacy'), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));

      // Perform login
      await performLogin(tester);

      // Verify dashboard loaded
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify back to login
      expect(find.text('Sign In'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('Navigate through all dashboard tabs',
            (WidgetTester tester) async {
          await setLargeScreen(tester);
          await tester.pumpWidget(const DeltaPharmacyApp());
          await performLogin(tester);

          // Dashboard tab (default)
          expect(find.text('Dashboard'), findsOneWidget);

          // Products tab
          await tester.tap(find.widgetWithText(InkWell, 'Products'));
          await tester.pumpAndSettle();
          expect(find.text('Products'), findsWidgets);

          // Orders tab
          await tester.tap(find.widgetWithText(InkWell, 'Orders'));
          await tester.pumpAndSettle();
          expect(find.text('Orders'), findsWidgets);

          // Prescriptions tab
          await tester.tap(find.widgetWithText(InkWell, 'Prescriptions'));
          await tester.pumpAndSettle();
          expect(find.text('Prescriptions'), findsWidgets);

          // Support tab
          await tester.tap(find.widgetWithText(InkWell, 'Support'));
          await tester.pumpAndSettle();
          expect(find.text('Support'), findsWidgets);

          // Analytics tab
          await tester.tap(find.widgetWithText(InkWell, 'Analytics'));
          await tester.pumpAndSettle();
          expect(find.text('Analytics'), findsWidgets);

          resetScreen(tester);
        });

    testWidgets('Multiple login/logout cycles', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());

      // First cycle
      await performLogin(tester);
      expect(find.text('Logout'), findsOneWidget);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);

      // Second cycle
      await performLogin(tester);
      expect(find.text('Logout'), findsOneWidget);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);

      // Third cycle
      await performLogin(tester);
      expect(find.text('Logout'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('Session persistence check', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      // Navigate between tabs
      await tester.tap(find.widgetWithText(InkWell, 'Products'));
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Analytics'));
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsOneWidget);

      // Still logged in
      await tester.tap(find.widgetWithText(InkWell, 'Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('Failed login does not navigate', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      await tester.enterText(find.byType(TextField).first, 'wronguser');
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should still be on login page
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    testWidgets('App handles rapid tab switching', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      // Rapid switching
      await tester.tap(find.widgetWithText(InkWell, 'Products'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Orders'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Support'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Dashboard'));
      await tester.pumpAndSettle();

      // Should still be functional
      expect(find.text('Logout'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('UI elements remain consistent across tabs',
            (WidgetTester tester) async {
          await setLargeScreen(tester);
          await tester.pumpWidget(const DeltaPharmacyApp());
          await performLogin(tester);

          final tabs = ['Products', 'Orders', 'Prescriptions', 'Support', 'Analytics'];

          for (final tab in tabs) {
            await tester.tap(find.widgetWithText(InkWell, tab));
            await tester.pumpAndSettle();

            // Header should always be present
            expect(find.text('Delta Pharmacy'), findsWidgets);
            expect(find.text('Logout'), findsOneWidget);

            // All tabs should still be visible
            expect(find.text('Dashboard'), findsOneWidget);
            expect(find.text('Products'), findsOneWidget);
          }

          resetScreen(tester);
        });
  });

  group('Error Handling Tests', () {
    testWidgets('Empty credentials validation', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should remain on login page
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Special characters in credentials', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      await tester.enterText(find.byType(TextField).first, 'admin@#%');
      await tester.enterText(find.byType(TextField).last, 'pass<>{}');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));
    });
  });

  group('Performance Tests', () {
    testWidgets('App initialization performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const DeltaPharmacyApp());
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'App should initialize within 3 seconds');
    });

    testWidgets('Login performance', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());

      final stopwatch = Stopwatch()..start();

      await performLogin(tester);

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Login should complete within 2 seconds');

      resetScreen(tester);
    });

    testWidgets('Tab navigation performance', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      final stopwatch = Stopwatch()..start();

      await tester.tap(find.widgetWithText(InkWell, 'Analytics'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Tab navigation should be instant');

      resetScreen(tester);
    });
  });
}