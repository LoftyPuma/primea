import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PrimeaPage {
  const PrimeaPage();
}

class PrimeaUnknownPage extends PrimeaPage {
  const PrimeaUnknownPage();
}

class PrimeaLandingPage extends PrimeaPage {
  const PrimeaLandingPage();
}

class PrimeaMatchesPage extends PrimeaPage {
  const PrimeaMatchesPage();
}

class PrimeaDashboardPage extends PrimeaPage {
  const PrimeaDashboardPage();
}

class PrimeaRoutePath {
  final PrimeaPage page;

  const PrimeaRoutePath({
    required this.page,
  });

  const PrimeaRoutePath.unknown() : page = const PrimeaUnknownPage();

  const PrimeaRoutePath.landing() : page = const PrimeaLandingPage();

  const PrimeaRoutePath.matches() : page = const PrimeaMatchesPage();

  const PrimeaRoutePath.dashboard() : page = const PrimeaDashboardPage();
}

class PrimeaRouteInformationParser
    extends RouteInformationParser<PrimeaRoutePath> {
  @override
  Future<PrimeaRoutePath> parseRouteInformation(
      RouteInformation routeInformation) {
    if (kDebugMode) {
      print("${routeInformation.uri.toString()}#${routeInformation.uri.query}");
    }
    final path = routeInformation.uri.pathSegments;
    if (path.isEmpty) {
      return Future.value(const PrimeaRoutePath.landing());
    }

    switch (path.first) {
      case '/':
      case 'auth':
        return Future.value(const PrimeaRoutePath.landing());
      case 'matches':
        return Future.value(const PrimeaRoutePath.matches());
      case 'dashboard':
        return Future.value(const PrimeaRoutePath.dashboard());
      default:
        return Future.value(const PrimeaRoutePath.unknown());
    }
  }

  @override
  RouteInformation? restoreRouteInformation(PrimeaRoutePath configuration) {
    switch (configuration.page) {
      case PrimeaLandingPage _:
        return RouteInformation(uri: Uri.parse('/'));
      case PrimeaMatchesPage _:
        return RouteInformation(uri: Uri.parse('/matches'));
      case PrimeaDashboardPage _:
        return RouteInformation(uri: Uri.parse('/dashboard'));
      case PrimeaUnknownPage _:
      default:
        return RouteInformation(uri: Uri.parse('/404'));
    }
  }
}
