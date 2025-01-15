import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindmap_assessment/consts/const.dart';
import 'package:mindmap_assessment/database/prefs.dart';
import 'package:mindmap_assessment/main.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;
import 'package:mockito/mockito.dart';

http.Client theHttpClient = http.Client();

@GenerateMocks([http.Client, Prefs])
main(){

  testWidgets('Login Page Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text("MindMap Assessment - Shesha Prasad"), findsOneWidget);

    final textField = find.byType(TextField);
    // Simulate user input

    await tester.tap(textField.at(0));
    await tester.enterText(textField.at(0), 'username');
    // Verify the entered text
    expect(find.text('username'), findsOneWidget);

    await tester.tap(textField.at(1));
    await tester.enterText(textField.at(1), 'password');
    // Verify the entered text
    expect(find.text('password'), findsOneWidget);


  });


  testWidgets('LoginScreen - successful login', (WidgetTester tester) async {

    // Wrap your MyApp widget with providers for the mock dependencies
    await tester.pumpWidget(
      MyApp(),
    );

    // Find the username and password text fields and enter valid credentials
    final usernameField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;
    await tester.enterText(usernameField, 'Tester');
    await tester.enterText(passwordField, 'password');

    // Tap the login button
    final loginButton = find.byType(OutlinedButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

  });
}

Future<http.Response> makeApiCall(http.Client client) async {
  final url = Uri.parse('https://api.example.com/data');
  return await client.get(url);
}

class MockClient extends Mock implements http.Client {}
class MockPrefs extends Mock implements Prefs {}