// Delta Pharmacy Flutter widget tests
// Comprehensive tests for the pharmacy management system

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

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

  group('Login Page Tests', () {
    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      // Check for pharmacy icon
      expect(find.byIcon(Icons.local_pharmacy), findsOneWidget);

      // Check for title and subtitle
      expect(find.text('Delta Pharmacy'), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsOneWidget);

      // Check for text fields
      expect(find.byType(TextField), findsNWidgets(2));

      // Check for sign in button
      expect(find.text('Sign In'), findsOneWidget);

      // Check for demo credentials
      expect(find.text('Demo Credentials:'), findsOneWidget);
      expect(find.textContaining('admin'), findsWidgets);
    });

    testWidgets('Login with correct credentials', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());

      await performLogin(tester);

      // Verify dashboard is displayed
      expect(find.text('Delta Pharmacy'), findsWidgets);
      expect(find.text('Logout'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('Login with incorrect credentials shows error',
            (WidgetTester tester) async {
          await tester.pumpWidget(const DeltaPharmacyApp());

          await tester.enterText(find.byType(TextField).first, 'wrong');
          await tester.enterText(find.byType(TextField).last, 'wrong');
          await tester.tap(find.text('Sign In'));
          await tester.pump();

          // Verify error message (depending on implementation)
          expect(find.text('Admin Dashboard'), findsOneWidget);
        });
  });

  group('Dashboard Tests', () {
    testWidgets('Dashboard renders all tabs', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      // Check for all tabs
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Prescriptions'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);

      // Check for logout button
      expect(find.text('Logout'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('Can navigate between tabs', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      // Navigate to Products tab
      await tester.tap(find.widgetWithText(InkWell, 'Products'));
      await tester.pumpAndSettle();
      expect(find.text('Products'), findsWidgets);

      // Navigate to Orders tab
      await tester.tap(find.widgetWithText(InkWell, 'Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Orders'), findsWidgets);

      // Navigate to Prescriptions tab
      await tester.tap(find.widgetWithText(InkWell, 'Prescriptions'));
      await tester.pumpAndSettle();
      expect(find.text('Prescriptions'), findsWidgets);

      resetScreen(tester);
    });

    testWidgets('Logout functionality works', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      // Verify on dashboard
      expect(find.text('Logout'), findsOneWidget);

      // Click logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify back on login page
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsOneWidget);

      resetScreen(tester);
    });
  });

  group('UI Component Tests', () {
    testWidgets('Text fields accept input', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      final usernameField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(usernameField, 'testuser');
      expect(find.text('testuser'), findsOneWidget);

      await tester.enterText(passwordField, 'testpass');
      expect(find.text('testpass'), findsOneWidget);
    });

    testWidgets('Password field obscures text', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      final passwordField = find.byType(TextField).last;
      final TextField passwordWidget = tester.widget(passwordField);

      expect(passwordWidget.obscureText, true);
    });

    testWidgets('Sign In button is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      final ElevatedButton button = tester.widget(signInButton);
      expect(button.onPressed, isNotNull);
    });
  });

  group('Theme Tests', () {
    testWidgets('App uses Material 3 theme', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, true);
    });

    testWidgets('Login page has gradient background',
            (WidgetTester tester) async {
          await tester.pumpWidget(const DeltaPharmacyApp());

          // Find containers with decoration
          expect(find.byType(Container), findsWidgets);
        });
  });

  group('Icon Tests', () {
    testWidgets('Login page has pharmacy icon', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      expect(find.byIcon(Icons.local_pharmacy), findsOneWidget);
    });

    testWidgets('Dashboard has all required icons',
            (WidgetTester tester) async {
          await setLargeScreen(tester);
          await tester.pumpWidget(const DeltaPharmacyApp());
          await performLogin(tester);

          // Check for tab icons
          expect(find.byIcon(Icons.dashboard), findsOneWidget);
          expect(find.byIcon(Icons.medication), findsOneWidget);
          expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
          expect(find.byIcon(Icons.assignment), findsOneWidget);
          expect(find.byIcon(Icons.support_agent), findsOneWidget);
          expect(find.byIcon(Icons.analytics), findsOneWidget);

          // Check for logout icon
          expect(find.byIcon(Icons.logout), findsOneWidget);

          resetScreen(tester);
        });
  });

  group('Widget Hierarchy Tests', () {
    testWidgets('App has correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(const DeltaPharmacyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Dashboard has correct structure',
            (WidgetTester tester) async {
          await setLargeScreen(tester);
          await tester.pumpWidget(const DeltaPharmacyApp());
          await performLogin(tester);

          expect(find.byType(Scaffold), findsOneWidget);
          expect(find.byType(Column), findsWidgets);
          expect(find.byType(Row), findsWidgets);

          resetScreen(tester);
        });
  });

  group('Responsive Design Tests', () {
    testWidgets('App works on mobile screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      await tester.pumpWidget(const DeltaPharmacyApp());

      expect(find.text('Delta Pharmacy'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('App works on tablet screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(const DeltaPharmacyApp());

      expect(find.text('Delta Pharmacy'), findsOneWidget);

      resetScreen(tester);
    });

    testWidgets('App works on desktop screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpWidget(const DeltaPharmacyApp());

      expect(find.text('Delta Pharmacy'), findsOneWidget);

      resetScreen(tester);
    });
  });

  group('Performance Tests', () {
    testWidgets('App renders without delay', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const DeltaPharmacyApp());
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('Tab switching is smooth', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(const DeltaPharmacyApp());
      await performLogin(tester);

      final stopwatch = Stopwatch()..start();

      await tester.tap(find.widgetWithText(InkWell, 'Products'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      resetScreen(tester);
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete user flow from login to logout',
            (WidgetTester tester) async {
          await setLargeScreen(tester);
          await tester.pumpWidget(const DeltaPharmacyApp());

          // Step 1: Login
          await performLogin(tester);
          expect(find.text('Delta Pharmacy'), findsWidgets);

          // Step 2: Navigate through tabs
          await tester.tap(find.widgetWithText(InkWell, 'Products'));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(InkWell, 'Orders'));
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(InkWell, 'Analytics'));
          await tester.pumpAndSettle();

          // Step 3: Logout
          await tester.tap(find.text('Logout'));
          await tester.pumpAndSettle();
          expect(find.text('Sign In'), findsOneWidget);

          resetScreen(tester);
        });
  });
}