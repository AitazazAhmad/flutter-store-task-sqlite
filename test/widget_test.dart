import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_login_form/login_page.dart';

void main() {
  testWidgets('Login form UI elements are present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Check for presence of Username and Password fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Check for login button
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Validation error appears on empty form submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Tap the login button without entering any data
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // Expect validation errors
    expect(find.text('Enter username'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
  });

  testWidgets('Snackbar appears on incorrect login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Enter invalid credentials
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'wronguser',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrongpass',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump(); // start async call
    await tester.pump(const Duration(seconds: 1)); // wait for snackbar

    // Check for invalid credentials snackbar
    expect(find.text('Invalid credentials!'), findsOneWidget);
  });
}
