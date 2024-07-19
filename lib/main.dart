import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/paragon_picker.dart';
import 'package:parallel_stats/modal/sign_in.dart';
import 'package:parallel_stats/tracker/account.dart';
import 'package:parallel_stats/tracker/game_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
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
  Paragon chosenParagon = Paragon.unknown;

  handleAuthStateChange(AuthState data) {
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
  void initState() {
    chosenParagon = Paragon.values
        .byName(session?.user.userMetadata?["paragon"] ?? "unknown");

    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/favicon.png"),
        actions: [
          if (session != null && !session!.isExpired)
            TextButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () async {
                await supabase.auth.signOut();
              },
            ),
          if (session == null || session!.isExpired)
            TextButton.icon(
              icon: const Icon(Icons.login),
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
        ],
      ),
      body: Account(
        chosenParagon: chosenParagon,
        session: session,
        defaultMatches: (session != null && !session!.isExpired)
            ? []
            : List.generate(
                4,
                (index) {
                  var result =
                      GameResult.values[Random().nextInt(gameResultCount)];
                  var mmrDelta = Random().nextInt(25);
                  if (result == GameResult.disconnect ||
                      result == GameResult.draw) {
                    mmrDelta = 0;
                  } else if (result == GameResult.loss) {
                    mmrDelta = -mmrDelta;
                  }
                  return MatchModel(
                    paragon: Paragon.values[Random().nextInt(paragonsCount)],
                    playerOne: Random().nextBool(),
                    result: result,
                    opponentUsername: 'Sample Opponent #$index',
                    opponentParagon:
                        Paragon.values[Random().nextInt(paragonsCount)],
                    mmrDelta: mmrDelta,
                  );
                },
              ),
      ),
      floatingActionButton: IconButton(
        onPressed: () => showModalBottomSheet(
          showDragHandle: false,
          enableDrag: false,
          context: context,
          builder: (context) {
            return ParagonPicker(
              onParagonSelected: (paragon) {
                setState(() {
                  chosenParagon = paragon;
                });
                if (session != null || !session!.isExpired) {
                  supabase.auth.updateUser(
                    UserAttributes(
                      data: <String, dynamic>{
                        "paragon": paragon.name,
                      },
                    ),
                  );
                }
                Navigator.pop(context);
              },
            );
          },
        ),
        icon: ParagonAvatar(
          paragon: chosenParagon,
          tooltip: "Select your Paragon",
        ),
      ),
    );
  }
}
