import 'package:flutter/material.dart';
import 'package:primea/inherited_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Primea extends StatefulWidget {
  final String title;
  final Widget body;
  final int? selectedPageIndex;
  final Function(int) setSelectedPage;

  const Primea({
    super.key,
    required this.title,
    required this.body,
    required this.selectedPageIndex,
    required this.setSelectedPage,
  });

  @override
  State<StatefulWidget> createState() => _PrimeaState();
}

class _PrimeaState extends State<Primea> {
  Session? session = Supabase.instance.client.auth.currentSession;

  int? selectedPageIndex;

  @override
  void initState() {
    super.initState();
    selectedPageIndex = widget.selectedPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedPageIndex,
              elevation: 4,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              labelType: NavigationRailLabelType.all,
              groupAlignment: 0,
              onDestinationSelected: (index) {
                setState(() {
                  widget.setSelectedPage(index);
                  selectedPageIndex = index;
                });
              },
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.data_array),
                  selectedIcon: Icon(
                    Icons.data_array,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    "Home",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.games),
                  selectedIcon: Icon(
                    Icons.games,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    "Matches",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard),
                  selectedIcon: Icon(
                    Icons.dashboard,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    "Dashboard",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }
}
