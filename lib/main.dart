import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parallel_stats/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fdrysfgctvdtvrxpldxb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkcnlzZmdjdHZkdHZyeHBsZHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyNDMyMjgsImV4cCI6MjAzNjgxOTIyOH0.7wcpER7Kch2A9zm5MiTKowd7IQ3Q2jSVkDytGzdTZHU',
  );

  runApp(const App());
}

final supabase = Supabase.instance.client;

class App extends StatelessWidget {
  const App({super.key});

  final title = 'Parallel Stats';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 222, 241, 65),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardTheme(
          shape: ContinuousRectangleBorder(),
        ),
      ),
      home: SafeArea(
        child: Home(title: title),
      ),
    );
  }
}
