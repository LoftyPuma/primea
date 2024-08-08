import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/modal/deck_import.dart';
import 'package:parallel_stats/modal/oauth_button.dart';
import 'package:parallel_stats/util/string.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  final Session session;

  const Profile({
    super.key,
    required this.session,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Future<List<UserIdentity>> userIdentities =
      supabase.auth.getUserIdentities();

  _linkIdentity(BuildContext context, OAuthProvider provider) async {
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
                "Connected ${provider.name.toTitleCase()}",
              ),
              content: Text(
                "You have successfully connected your ${provider.name.toTitleCase()} account to Primea.World.",
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
                "Failed to connect ${provider.name.toTitleCase()}",
              ),
              content: Text(
                "There was an error connecting to ${provider.name.toTitleCase()}. ${e.toString()}",
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

  _unlinkIdentity(
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
            title: Text("Disconnect ${provider.name.toTitleCase()}"),
            content: Text(
              "Are you sure you want to disconnect your ${provider.name.toTitleCase()} account? You will not be able to login to Primea.World with ${provider.name.toTitleCase()} unless you reconnect your account.",
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
                  "Connected ${provider.name.toTitleCase()}",
                ),
                content: Text(
                  "You have successfully connected your ${provider.name.toTitleCase()} account to Primea.World.",
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
                "Failed to unlink ${provider.name.toTitleCase()}",
              ),
              content: Text(
                "There was an error unlinking to ${provider.name.toTitleCase()}. ${e.toString()}",
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

  // _getDeck(String name) async {
  //   await supabase.from('decks').select('').inFilter(column, value)
  //   await supabase.from('card_functions').select('').inFilter(column, value)
  // }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minWidth: 450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            // bond(s) the user is a member of
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceAround,
                children: [
                  const Chip(label: Text("ParagonsDAO")),
                  const Chip(label: Text("YGG")),
                  ...[
                    Badge(
                      offset: const Offset(-25, -8),
                      label: const Text("pending"),
                      child: ActionChip(
                        avatar: const Icon(Icons.info),
                        side: const BorderSide(style: BorderStyle.none),
                        label: const Text(
                          "EXILE",
                        ),
                        onPressed: () {
                          print("examine bond");
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
                          icon: Image.asset(data.icon, width: 24, height: 24),
                          label: Text(provider.name.toTitleCase()),
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
                          final identityIndex = snapshot.data!
                              .indexWhere((id) => id.provider == provider.name);

                          if (identityIndex == -1) {
                            return OutlinedButton.icon(
                              icon:
                                  Image.asset(data.icon, width: 24, height: 24),
                              label: Text(
                                  "Connect ${provider.name.toTitleCase()}"),
                              onPressed: () async {
                                await _linkIdentity(context, provider);
                              },
                            );
                          } else {
                            final identity = snapshot.data![identityIndex];
                            return FilledButton.icon(
                              label: Text(
                                identity.identityData?['name'] ??
                                    identity.identityData?['email'] ??
                                    provider.name.toTitleCase(),
                              ),
                              icon:
                                  Image.asset(data.icon, width: 24, height: 24),
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
                            icon: Image.asset(data.icon, width: 24, height: 24),
                            label: Text(provider.name.toTitleCase()),
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
            // user's saved decks
            Center(
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 150,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: DeckImportModal(onImport: () {}),
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: 1,
                                  child: Text(
                                    "New Deck",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                const Icon(Icons.add, size: 48),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 1,
                                left: 1,
                                child: Text(
                                  "22 units\n10 effects\n2 relics\n1 upgrade",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Positioned(
                                bottom: 1,
                                left: 1,
                                child: Text(
                                  "BURN BABY BURN\nCatherine LaPointe",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 1,
                                left: 1,
                                child: Text(
                                  "22 units\n10 effects\n2 relics\n1 upgrade",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Positioned(
                                bottom: 1,
                                left: 1,
                                child: Text(
                                  "BURN BABY BURN\nCatherine LaPointe",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 380,214,621,611,713,385,653,237,236,218,232,691,602,82,204,613,386,213,616