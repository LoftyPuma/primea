import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parallel_stats/dashboard/dashboard.dart';
import 'package:parallel_stats/inherited_session.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/modal/import.dart';
import 'package:parallel_stats/modal/paragon_picker.dart';
import 'package:parallel_stats/modal/sign_in.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_list.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/tracker/account.dart';
import 'package:parallel_stats/tracker/dummy_account.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vector_graphics/vector_graphics.dart';

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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final TabController _tabController;

  MatchResults matchResults = MatchResults();
  late MatchList matchList;

  Session? session = supabase.auth.currentSession;
  Paragon chosenParagon = Paragon.unknown;

  handleAuthStateChange(AuthState data) async {
    setState(() {
      session = data.session;
    });
    if (session != null && !session!.isExpired) {
      if (matchResults.isEmpty) {
        await matchResults.init();
      }
      if (matchList.isEmpty) {
        await matchList.init();
      }
    }
  }

  @override
  void initState() {
    matchList = MatchList(_listKey, matchResults);
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 250),
    );

    chosenParagon = Paragon.values
        .byName(session?.user.userMetadata?["paragon"] ?? "unknown");

    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: InheritedMatchList(
        matchList: matchList,
        child: InheritedMatchResults(
          matchResults: matchResults,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const SvgPicture(
                AssetBytesLoader(
                  "assets/parallel_logos/vec/parallel_pills.svg.vec",
                ),
              ),
              actions: [
                if (session != null && !session!.isExpired)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Import CSV"),
                    onPressed: () async {
                      final importedMatches =
                          await showDialog<List<MatchModel>>(
                        context: context,
                        builder: (context) => const Dialog(
                          child: Import(),
                        ),
                      );
                      if (importedMatches != null) {
                        await matchList.addAll(importedMatches);
                        for (var match in importedMatches) {
                          matchResults.recordMatch(match);
                        }
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              showCloseIcon: true,
                              content: Text(
                                "Imported ${importedMatches.length} matches.",
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
            bottomNavigationBar: BottomAppBar(
              clipBehavior: Clip.antiAlias,
              shape: const CircularNotchedRectangle(),
              notchMargin: 0,
              child: TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.fill,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.games_outlined),
                    text: "Matches",
                  ),
                  Tab(
                    icon: Icon(Icons.dashboard_sharp),
                    text: "Dashboard",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  children: [
                    AnimatedSwitcher(
                      // key: const PageStorageKey('account'),
                      duration: const Duration(milliseconds: 250),
                      child: session == null
                          ? DummyAccount(chosenParagon: chosenParagon)
                          : Account(
                              listKey: _listKey,
                              chosenParagon: chosenParagon,
                            ),
                    ),
                  ],
                ),
                const Dashboard(),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
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
        ),
      ),
    );
  }
}
