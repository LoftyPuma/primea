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
    authOptions: const FlutterAuthClientOptions(
      detectSessionInUri: true,
    ),
  );

  runApp(const App());
}

final supabase = Supabase.instance.client;

class App extends StatelessWidget {
  const App({super.key});

  final title = 'Primea';

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFDEF141),
        brightness: Brightness.dark,
      ),
      cardTheme: const CardTheme(
        shape: ContinuousRectangleBorder(),
      ),
      fontFamily: 'Krypton',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        displayMedium: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        displaySmall: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        headlineLarge: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        headlineMedium: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        headlineSmall: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        titleLarge: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        titleMedium: TextStyle(
          fontVariations: [FontVariation('wght', 500)],
        ),
        titleSmall: TextStyle(
          fontVariations: [FontVariation('wght', 500)],
        ),
        bodyLarge: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        bodyMedium: TextStyle(
          fontVariations: [FontVariation('wght', 600)],
        ),
        bodySmall: TextStyle(
          fontVariations: [FontVariation('wght', 400)],
        ),
        labelLarge: TextStyle(
          fontVariations: [FontVariation('wght', 500)],
        ),
        labelMedium: TextStyle(
          fontVariations: [FontVariation('wght', 500)],
        ),
        labelSmall: TextStyle(
          fontVariations: [FontVariation('wght', 500)],
        ),
      ),
    );
    return SafeArea(
      child: MaterialApp(
        title: title,
        theme: theme,
        home: Home(title: title),
      ),
    );
  }
}
