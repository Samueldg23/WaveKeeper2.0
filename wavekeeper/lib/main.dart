import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/screens/start/login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://utxoumffgexeferfarbj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0eG91bWZmZ2V4ZWZlcmZhcmJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA2NzUzODMsImV4cCI6MjA0NjI1MTM4M30.H0YMzTkc7gCeqi9S1LFp4F8R3A1y3RRi3_X0lmhnN1c',
  );

  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  String? userId;

  MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white10,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
        ),
      ),
      home: LoginScreen(
        userIdCallback: (id) {
          userId = id;
        },
      ),
    );
  }
}
