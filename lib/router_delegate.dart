import 'package:flutter/material.dart';
import 'package:primea/route_information_parser.dart';

class PrimeaRouterDelegate extends RouterDelegate<PrimeaRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PrimeaRoutePath> {
  PrimeaRouterDelegate();

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  PrimeaPage _selectedTab = const PrimeaLandingPage();

  int? get selectedPageIndex {
    switch (_selectedTab) {
      case PrimeaLandingPage _:
        return 0;
      case PrimeaMatchesPage _:
        return 1;
      case PrimeaDashboardPage _:
        return 2;
      default:
        return null;
    }
  }

  setSelectedPageIndex(int page) {
    switch (page) {
      case 0:
        _selectedTab = const PrimeaLandingPage();
        break;
      case 1:
        _selectedTab = const PrimeaMatchesPage();
        break;
      case 2:
        _selectedTab = const PrimeaDashboardPage();
        break;
      default:
        _selectedTab = const PrimeaUnknownPage();
    }
    notifyListeners();
  }

  @override
  PrimeaRoutePath get currentConfiguration {
    return PrimeaRoutePath(
      page: _selectedTab,
    );
  }

  final List<MaterialPage<dynamic>> pages = [
    MaterialPage(
      key: const ValueKey('HomePage'),
      child: SingleChildScrollView(child: Container()),
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
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
          case 'auth':
            return MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) {
                return Container();
              },
            );
          case 'matches':
            return MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) {
                return Container();
              },
            );
          case 'dashboard':
            return MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) {
                return Container();
              },
            );
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) {
                return Container();
              },
            );
        }
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PrimeaRoutePath configuration) async {
    _selectedTab = configuration.page;
  }
}
