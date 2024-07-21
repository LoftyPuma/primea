import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/import.dart';
import 'package:parallel_stats/modal/paragon_picker.dart';
import 'package:parallel_stats/modal/sign_in.dart';
import 'package:parallel_stats/tracker/account.dart';
import 'package:parallel_stats/tracker/dummy_account.dart';
import 'package:parallel_stats/tracker/match_model.dart';
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

class InheritedSession extends InheritedModel<Session> {
  final Session? session;

  const InheritedSession({
    super.key,
    required super.child,
    required this.session,
  });

  static InheritedSession? maybeOf(BuildContext context, [String? aspect]) {
    return InheritedModel.inheritFrom<InheritedSession>(context,
        aspect: aspect);
  }

  static InheritedSession of(BuildContext context, [String? aspect]) {
    final session =
        InheritedModel.inheritFrom<InheritedSession>(context, aspect: aspect);
    assert(session != null, 'No InheritedSession found in context');
    return session!;
  }

  @override
  bool updateShouldNotify(InheritedSession oldWidget) {
    return oldWidget.session != session;
  }

  @override
  bool updateShouldNotifyDependent(
    InheritedSession oldWidget,
    Set<Session> dependencies,
  ) {
    return oldWidget.session != session;
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

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // late final TabController _tabController;

  Session? session = supabase.auth.currentSession;
  Paragon chosenParagon = Paragon.unknown;

  handleAuthStateChange(AuthState data) {
    setState(() {
      session = data.session;
    });
  }

  @override
  void initState() {
    // _tabController = TabController(
    //   length: 2,
    //   vsync: this,
    //   animationDuration: const Duration(milliseconds: 250),
    // );

    chosenParagon = Paragon.values
        .byName(session?.user.userMetadata?["paragon"] ?? "unknown");

    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: const Icon(Icons.menu),
          //   onPressed: () {},
          // ),
          centerTitle: true,
          title: Image.asset("assets/favicon.png"),
          actions: [
            if (session != null && !session!.isExpired)
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Import CSV"),
                onPressed: () async {
                  final importedMatches = await showDialog<List<MatchModel>>(
                    context: context,
                    builder: (context) => const Dialog(
                      child: Import(),
                    ),
                  );
                  if (importedMatches != null) {
                    final importResult = await supabase
                        .from(MatchModel.gamesTableName)
                        .insert(
                          importedMatches
                              .map((match) => match.toJson())
                              .toList(),
                        )
                        .select();
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          showCloseIcon: true,
                          content: Text(
                            "Imported ${importResult.length} matches.",
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const Dialog(
                      child: SignInModal(),
                    ),
                  );
                },
              ),
          ],
        ),
        extendBody: true,
        // bottomNavigationBar: BottomAppBar(
        //   clipBehavior: Clip.antiAlias,
        //   shape: const CircularNotchedRectangle(),
        //   notchMargin: 0,
        //   child: TabBar(
        //     controller: _tabController,
        //     tabAlignment: TabAlignment.fill,
        //     tabs: const [
        //       Tab(
        //         icon: Icon(Icons.games_outlined),
        //         text: "Matches",
        //       ),
        //       Tab(
        //         icon: Icon(Icons.dashboard_sharp),
        //         text: "Dashboard",
        //       ),
        //     ],
        //   ),
        // ),
        body: ListView(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: session == null
                  ? DummyAccount(chosenParagon: chosenParagon)
                  : Account(
                      chosenParagon: chosenParagon,
                    ),
            ),
          ],
        ),
        // body: TabBarView(
        //   controller: _tabController,
        //   children: [
        //     ListView(
        //       children: [
        //         AnimatedSwitcher(
        //           duration: const Duration(milliseconds: 250),
        //           child: session == null
        //               ? DummyAccount(chosenParagon: chosenParagon)
        //               : Account(
        //                   chosenParagon: chosenParagon,
        //                 ),
        //         ),
        //       ],
        //     ),
        //     const Dashboard(),
        //   ],
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
                  if (session != null && !session!.isExpired) {
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
      ),
    );
  }
}
