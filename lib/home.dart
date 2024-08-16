import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primea/dashboard/dashboard.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/deck_preview.dart';
import 'package:primea/modal/import.dart';
import 'package:primea/modal/paragon_picker.dart';
import 'package:primea/modal/profile.dart';
import 'package:primea/modal/sign_in.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/deck_model.dart';
import 'package:primea/model/deck/mini_deck.dart';
import 'package:primea/model/deck/sliver_deck_list.dart';
import 'package:primea/model/match/inherited_match_list.dart';
import 'package:primea/model/match/inherited_match_results.dart';
import 'package:primea/model/match/match_list.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_results.dart';
import 'package:primea/tracker/account.dart';
import 'package:primea/tracker/dummy_account.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/tracker/paragon_avatar.dart';
import 'package:primea/util/analytics.dart';
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
  final GlobalKey<SliverAnimatedGridState> _profileDeckGridKey =
      GlobalKey<SliverAnimatedGridState>();

  final DraggableScrollableController _profileScrollController =
      DraggableScrollableController();
  late final TabController _tabController;

  MatchResults matchResults = MatchResults();
  late MatchList matchList;

  Future<Iterable<Deck>> _fetchDecks() async => DeckModel.toDeckList(
        await DeckModel.fetchAll(),
      );
  late final SliverDeckList<Deck> deckList;

  Session? session = supabase.auth.currentSession;
  Paragon chosenParagon = Paragon.unknown;
  Deck? selectedDeck;
  int deckCount = 0;

  handleAuthStateChange(AuthState data) async {
    Analytics.instance.trackEvent(
      "authStateChanged",
      {"event": data.event.name},
    );

    setState(() {
      session = data.session;
      switch (data.event) {
        case AuthChangeEvent.signedOut:
          chosenParagon = Paragon.unknown;
          selectedDeck = null;
          deckCount = 0;
          deckList.clear();
          matchList.clear();
          matchResults.clear();
          break;
        case AuthChangeEvent.signedIn:
          _init();
        default:
      }
    });
    if (session != null && !session!.isExpired) {
      try {
        if (matchResults.isEmpty) {
          Future(() async {
            final matchStart = DateTime.now();
            await matchResults.init();
            Analytics.instance.trackEvent("initializeMatchResults", {
              "duration": DateTime.now().difference(matchStart).inMilliseconds,
            });
          });
        }
        if (matchList.isEmpty) {
          Future(() async {
            final resultsStart = DateTime.now();
            await matchList.init();
            Analytics.instance.trackEvent("initializeMatchList", {
              "duration":
                  DateTime.now().difference(resultsStart).inMilliseconds,
            });
          });
        }
      } catch (e) {
        Analytics.instance.trackEvent("homeInitError", {
          "error": e.toString(),
        });
      } finally {}
    }
  }

  void _init() {
    _fetchDecks().then((futureDecks) {
      deckList.insertAll(0, futureDecks);
      setState(() {
        try {
          selectedDeck = futureDecks.singleWhere(
              (deck) => deck.name == session?.user.userMetadata?["deck"]);
        } on StateError catch (_) {}
      });
    });

    chosenParagon = Paragon.values
        .byName(session?.user.userMetadata?["paragon"] ?? "unknown");
  }

  @override
  void initState() {
    deckList = SliverDeckList<Deck>(
      listKey: _profileDeckGridKey,
      removedItemBuilder: (item, context, animation) {
        return ScaleTransition(
          scale: animation,
          child: DeckPreview(
            key: ValueKey(item.name),
            deck: item,
            onUpdate: (_) {},
            onDelete: () {},
          ),
        );
      },
    );

    matchList = MatchList(_listKey, matchResults);
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 250),
    );

    _init();
    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Analytics.instance.trackEvent("load", {"page": "home"});

    return InheritedSession(
      session: session,
      child: InheritedMatchList(
        matchList: matchList,
        child: InheritedMatchResults(
          matchResults: matchResults,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: const Padding(
                padding: EdgeInsets.all(8),
                child: SvgPicture(
                  AssetBytesLoader(
                    "assets/parallel_logos/vec/universal.svg.vec",
                  ),
                ),
              ),
              title: Text(widget.title),
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
                if (session != null && !session!.isExpired)
                  Builder(builder: (builderContext) {
                    return TextButton.icon(
                      label: Text(
                        session?.user.userMetadata?["nickname"] ??
                            session?.user.email,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Icon(
                        Icons.account_circle_rounded,
                        color: chosenParagon.parallel.color,
                      ),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: builderContext,
                          isScrollControlled: true,
                          useSafeArea: true,
                          showDragHandle: true,
                          builder: (context) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.5,
                              maxChildSize: 0.75,
                              minChildSize: 0.25,
                              expand: false,
                              snap: true,
                              snapSizes: const [0.26, 0.75],
                              controller: _profileScrollController,
                              builder: (context, scrollController) => Profile(
                                session: session!,
                                scrollController: scrollController,
                                gridKey: _profileDeckGridKey,
                                decks: deckList,
                              ),
                            );
                          },
                        );
                      },
                    );
                  })
              ],
            ),
            extendBody: true,
            bottomNavigationBar: BottomAppBar(
              clipBehavior: Clip.antiAlias,
              shape: const AutomaticNotchedShape(
                RoundedRectangleBorder(),
                StadiumBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
              ),
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
                SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: session == null
                        ? DummyAccount(chosenParagon: chosenParagon)
                        : Account(
                            listKey: _listKey,
                            chosenParagon: chosenParagon,
                            chosenDeck: selectedDeck,
                            decks: deckList.items,
                          ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: supabase.auth.currentUser
                                ?.userMetadata?['streamer_mode'] ??
                            false
                        ? const Color(0xFF0047BB)
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: const Dashboard(),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: IconButton(
              onPressed: () => showModalBottomSheet(
                showDragHandle: false,
                enableDrag: true,
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.26,
                    maxChildSize: 0.75,
                    minChildSize: 0.25,
                    expand: false,
                    snap: true,
                    snapSizes: const [0.26, 0.75],
                    controller: _profileScrollController,
                    builder: (context, scrollController) => ParagonPicker(
                      scrollController: scrollController,
                      deckList: deckList.items,
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
                      onDeckSelected: (chosenDeck) {
                        setState(() {
                          chosenParagon =
                              Paragon.fromCardID(chosenDeck.paragon.id);
                          selectedDeck = chosenDeck;
                        });
                        if (session != null && !session!.isExpired) {
                          supabase.auth.updateUser(
                            UserAttributes(
                              data: <String, dynamic>{
                                "paragon": chosenParagon.name,
                                "deck": chosenDeck.name,
                              },
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              icon: selectedDeck == null
                  ? ParagonAvatar(
                      paragon: chosenParagon,
                      tooltip: "Select your Paragon",
                    )
                  : MiniDeck(deck: selectedDeck!),
            ),
          ),
        ),
      ),
    );
  }
}
