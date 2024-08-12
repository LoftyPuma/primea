import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/deck_import.dart';
import 'package:primea/modal/deck_preview.dart';
import 'package:primea/modal/oauth_button.dart';
import 'package:primea/model/deck/deck_model.dart';
import 'package:primea/model/deck/sliver_deck_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  final Session session;
  final ScrollController scrollController;
  final GlobalKey<SliverAnimatedGridState> gridKey;

  final SliverDeckList decks;

  const Profile({
    super.key,
    required this.session,
    required this.scrollController,
    required this.gridKey,
    required this.decks,
  });

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  // Future<Iterable<Bond>> bonds = Bond.fetchAll();

  bool settingsExpanded = false;

  final Future<List<UserIdentity>> userIdentities =
      supabase.auth.getUserIdentities();

  Future<void> _linkIdentity(
      BuildContext context, OAuthProvider provider) async {
    try {
      await supabase.auth.linkIdentity(
        provider,
        redirectTo: kIsWeb ? "/auth/callback" : "world.primea://auth/callback",
      );
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Connected ${provider.name}",
              ),
              content: Text(
                "You have successfully connected your ${provider.name} account to Primea.World.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Failed to connect ${provider.name}",
              ),
              content: Text(
                "There was an error connecting to ${provider.name}. ${e.toString()}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _unlinkIdentity(
    BuildContext context,
    OAuthProvider provider,
    UserIdentity identity,
  ) async {
    try {
      final unlinkIdentity = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.warning,
              color: Colors.red,
            ),
            title: Text("Disconnect ${provider.name}"),
            content: Text(
              "Are you sure you want to disconnect your ${provider.name} account? You will not be able to login to Primea.World with ${provider.name} unless you reconnect your account.",
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              OutlinedButton.icon(
                label: const Text("Cancel"),
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FilledButton.icon(
                label: const Text("Disconnect"),
                icon: const Icon(Icons.delete),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (unlinkIdentity != null && unlinkIdentity) {
        await supabase.auth.unlinkIdentity(
          identity,
        );
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Disconnected ${provider.name}",
                ),
                content: Text(
                  "You have successfully disconnected your ${provider.name} account from Primea.World.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Failed to unlink ${provider.name}",
              ),
              content: Text(
                "There was an error unlinking to ${provider.name}. ${e.toString()}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // decks = widget.decks;
    // deckList = SliverDeckList(
    //   listKey: _gridKey,
    //   removedItemBuilder: (item, context, animation) {
    //     return ScaleTransition(
    //       scale: animation,
    //       child: DeckPreview(
    //         key: ValueKey(item.name),
    //         deck: item,
    //         onUpdate: (_) {},
    //         onDelete: () {},
    //       ),
    //     );
    //   },
    // );
    // decks.then((futureDecks) {
    //   setState(() {
    //     deckList.insertAll(0, futureDecks);
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: CustomScrollView(
        controller: widget.scrollController,
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            // greeting
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Hello, ${currentUser?.userMetadata?['nickname'] ?? currentUser?.email}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await supabase.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),

          // bonds the user is a part of or was invited to
          // SliverToBoxAdapter(
          //   child: FutureBuilder(
          //     future: bonds,
          //     builder: (context, snapshot) {
          //       Widget child;
          //       if (snapshot.hasError ||
          //           (snapshot.connectionState == ConnectionState.done &&
          //               !snapshot.hasData)) {
          //         child = InkWell(
          //           key: const ValueKey("retry"),
          //           borderRadius: BorderRadius.circular(20),
          //           onTap: () {
          //             setState(() {
          //               decks = _fetchDecks();
          //             });
          //           },
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.spaceAround,
          //             children: [
          //               const Icon(Icons.error),
          //               const Text("Retry"),
          //               Text(
          //                 snapshot.error?.toString() ?? "Failed to load decks",
          //                 style: Theme.of(context).textTheme.bodySmall,
          //               ),
          //             ],
          //           ),
          //         );
          //       } else if (snapshot.connectionState != ConnectionState.done) {
          //         child = const Column(
          //           key: ValueKey("loading"),
          //           mainAxisAlignment: MainAxisAlignment.spaceAround,
          //           children: [
          //             CircularProgressIndicator(),
          //             Text("Loading decks..."),
          //           ],
          //         );
          //       }

          //       if (!snapshot.hasData) {
          //         child = Container();
          //       } else {
          //         child = const Wrap(
          //           spacing: 8,
          //           runSpacing: 8,
          //           alignment: WrapAlignment.spaceAround,

          //           // children: [
          //           //   const Chip(label: Text("ParagonsDAO")),
          //           //   const Chip(label: Text("YGG")),
          //           //   ...[
          //           //     Badge(
          //           //       offset: const Offset(-25, -8),
          //           //       label: const Text("pending"),
          //           //       child: ActionChip(
          //           //         avatar: const Icon(Icons.info),
          //           //         side: const BorderSide(style: BorderStyle.none),
          //           //         label: const Text(
          //           //           "EXILE",
          //           //         ),
          //           //         onPressed: () {
          //           //           print("examine bond");
          //           //         },
          //           //       ),
          //           //     ),
          //           //   ],
          //           // ],
          //         );
          //       }

          //       return AnimatedScale(
          //         scale: snapshot.hasData && snapshot.data!.isNotEmpty ? 1 : 0,
          //         duration: const Duration(milliseconds: 250),
          //         child: Padding(
          //           padding: const EdgeInsets.only(bottom: 16),
          //           child: child,
          //         ),
          //       );
          //     },
          //   ),
          // ),

          // user settings
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OutlinedButton.icon(
                  //   icon: const Icon(Icons.upload_file),
                  //   label: const Text("Import CSV"),
                  //   onPressed: () async {
                  //     final importedMatches =
                  //         await showDialog<List<MatchModel>>(
                  //       context: context,
                  //       builder: (context) => const Dialog(
                  //         child: Import(),
                  //       ),
                  //     );
                  //     if (importedMatches != null) {
                  //       await matchList.addAll(importedMatches);
                  //       if (mounted) {
                  //         // ignore: use_build_context_synchronously
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //             showCloseIcon: true,
                  //             content: Text(
                  //               "Imported ${importedMatches.length} matches.",
                  //             ),
                  //           ),
                  //         );
                  //       }
                  //     }
                  //   },
                  // ),
                  FutureBuilder(
                    future: userIdentities,
                    builder: (context, snapshot) {
                      List<Widget> children;
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          children = OAuthButton.providers.entries.map(
                            (entry) {
                              final provider = entry.key;
                              final data = entry.value;
                              return OutlinedButton.icon(
                                icon: Image.asset(data.icon,
                                    width: 24, height: 24),
                                label: Text(provider.name),
                                onPressed: null,
                              );
                            },
                          ).toList();
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            children = const [
                              Text(
                                'Error loading identities. Please refresh the page.',
                              )
                            ];
                          } else if (snapshot.hasData) {
                            children = List.generate(
                              OAuthButton.providers.length,
                              (index) {
                                final provider =
                                    OAuthButton.providers.keys.elementAt(index);
                                final data = OAuthButton.providers[provider]!;
                                final identityIndex = snapshot.data!.indexWhere(
                                    (id) => id.provider == provider.name);

                                if (identityIndex == -1) {
                                  return OutlinedButton.icon(
                                    icon: Image.asset(data.icon,
                                        width: 24, height: 24),
                                    label: Text("Connect ${provider.name}"),
                                    onPressed: () async {
                                      await _linkIdentity(context, provider);
                                    },
                                  );
                                } else {
                                  final identity =
                                      snapshot.data![identityIndex];
                                  return FilledButton.icon(
                                    label: Text(
                                      identity.identityData?['name'] ??
                                          identity.identityData?['email'] ??
                                          provider.name,
                                    ),
                                    icon: Image.asset(data.icon,
                                        width: 24, height: 24),
                                    onPressed: snapshot.data!.length <= 1
                                        ? null
                                        : () async {
                                            await _unlinkIdentity(
                                              context,
                                              provider,
                                              snapshot.data![identityIndex],
                                            );
                                          },
                                  );
                                }
                              },
                              growable: false,
                            );
                          } else {
                            children = OAuthButton.providers.entries.map(
                              (entry) {
                                final provider = entry.key;
                                final data = entry.value;
                                return OutlinedButton.icon(
                                  icon: Image.asset(data.icon,
                                      width: 24, height: 24),
                                  label: Text(provider.name),
                                  onPressed: () async {
                                    await _linkIdentity(context, provider);
                                  },
                                );
                              },
                            ).toList();
                          }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: children,
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Streamer Mode"),
                      ),
                      Switch(
                        value: currentUser?.userMetadata?['streamer_mode'] ??
                            false,
                        onChanged: (value) async {
                          await supabase.auth.updateUser(UserAttributes(
                            data: {
                              "streamer_mode": value,
                            },
                          ));
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // user's saved decks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("New Deck"),
                onPressed: () async {
                  final newDeckModel = await showDialog<DeckModel>(
                    context: context,
                    builder: (context) {
                      return const Dialog(
                        child: DeckImportModal(),
                      );
                    },
                  );
                  if (newDeckModel != null) {
                    final newDeck = await newDeckModel.toDeck();
                    setState(() {
                      widget.decks.insert(0, newDeck);
                    });
                  }
                },
              ),
            ),
          ),
          ListenableBuilder(
            listenable: widget.decks,
            builder: (context, child) {
              return SliverAnimatedGrid(
                key: widget.gridKey,
                initialItemCount: widget.decks.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index, animation) {
                  if (index > (widget.decks.length)) {
                    return Container();
                  }
                  final deck = widget.decks[index];
                  return ScaleTransition(
                    scale: animation,
                    child: DeckPreview(
                      key: ValueKey(deck.name),
                      deck: deck,
                      onUpdate: (updatedDeck) async {
                        widget.decks.removeAt(index);
                        Future.delayed(const Duration(milliseconds: 250), () {
                          widget.decks.insert(0, updatedDeck);
                        });
                      },
                      onDelete: () {
                        widget.decks.removeAt(index);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
