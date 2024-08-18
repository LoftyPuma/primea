import 'package:flutter/material.dart';
import 'package:primea/home.dart';
import 'package:primea/route_information_parser.dart';

class PrimeaRouterDelegate extends RouterDelegate<PrimeaRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PrimeaRoutePath> {
  PrimeaRouterDelegate(this.title) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  final String title;

  bool _show404 = false;
  PrimeaTabs _selectedTab = PrimeaTabs.landing;

  @override
  PrimeaRoutePath get currentConfiguration {
    return PrimeaRoutePath(
      isUnknown: _show404,
      tab: _selectedTab,
    );
  }

  final List<MaterialPage<dynamic>> pages = [
    const MaterialPage(
      key: ValueKey('HomePage'),
      child: Home(
        title: "Primea",
        initialTab: PrimeaTabs.landing,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (page) {
        pages.remove(page);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PrimeaRoutePath path) async {
    _show404 = path.isUnknown;
    _selectedTab = path.tab;
  }
}
