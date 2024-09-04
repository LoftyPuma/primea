import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:primea/inherited_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Primea extends StatefulWidget {
  final String title;
  final Widget body;

  const Primea({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  State<StatefulWidget> createState() => _PrimeaState();
}

class _PrimeaState extends State<Primea> {
  Session? session = Supabase.instance.client.auth.currentSession;

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: Scaffold(
        drawer: Drawer(
          shape: const LinearBorder(),
          child: ListView(
            padding: const EdgeInsets.only(top: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  style: const ButtonStyle(alignment: Alignment.centerLeft),
                  child: Text(
                    "paragons".toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  onPressed: () {
                    context.go('/');
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  style: const ButtonStyle(alignment: Alignment.centerLeft),
                  child: Text(
                    "matches".toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  onPressed: () {
                    context.go('/matches');
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  style: const ButtonStyle(alignment: Alignment.topLeft),
                  child: Text(
                    "dashboard".toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  onPressed: () {
                    context.go('/dashboard');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              leading: Builder(
                builder: (context) => DrawerButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            widget.body,
          ],
        ),
      ),
    );
  }
}
