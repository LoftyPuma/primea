import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/sign_in.dart';
import 'package:parallel_stats/tracker/account.dart';
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

  final title = 'Parallel Portal';

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
      // darkTheme: ThemeData.dark(useMaterial3: true),
      home: SafeArea(
        child: Home(title: title),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Session? session = supabase.auth.currentSession;

  late final StreamSubscription<AuthState> authSubscription;

  init() {
    authSubscription =
        supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
  }

  handleAuthStateChange(AuthState data) {
    if (kDebugMode) {
      print('event: ${data.event}, session: ${data.session}');
    }

    // switch (data.event) {
    //   case AuthChangeEvent.initialSession:
    //   // handle initial session
    //   case AuthChangeEvent.signedIn:
    //   // handle signed in
    //   case AuthChangeEvent.signedOut:
    //   // handle signed out
    //   case AuthChangeEvent.passwordRecovery:
    //   // handle password recovery
    //   case AuthChangeEvent.tokenRefreshed:
    //   // handle token refreshed
    //   case AuthChangeEvent.userUpdated:
    //   // handle user updated
    //   case AuthChangeEvent.userDeleted:
    //   // handle user deleted
    //   case AuthChangeEvent.mfaChallengeVerified:
    //   // handle mfa challenge verified
    //   default:
    // }
    setState(() {
      session = data.session;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (session != null) {
      actions.add(
        TextButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          onPressed: () async {
            await supabase.auth.signOut();
          },
        ),
      );
    } else {
      actions.add(
        TextButton.icon(
          icon: const Icon(Icons.add_box_outlined),
          label: const Text('Sign In'),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return const Dialog(
                  child: SignInModal(),
                );
              },
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/favicon.ico"),
        actions: actions,
      ),
      body: const Account(),
    );
  }
}
