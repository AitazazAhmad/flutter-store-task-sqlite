import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth with SQLite',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f0c29),
        cardColor: const Color(0xFF1e1e2e),
        primaryColor: Colors.deepPurple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white70,
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white70),
        ),
      ),
      initialRoute: '/auth',
      routes: {'/auth': (context) => const AuthScreen()},
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments;
          if (args is String) {
            return MaterialPageRoute(
              builder: (context) => HomeScreen(email: args),
            );
          } else {
            return _errorRoute("Invalid argument for HomeScreen");
          }
        }
        return _errorRoute("Route not found");
      },
    );
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
