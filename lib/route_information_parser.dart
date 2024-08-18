import 'package:flutter/material.dart';

enum PrimeaTabs {
  landing,
  matches,
  dashboard,
}

class PrimeaRoutePath {
  final bool isUnknown;
  final PrimeaTabs tab;

  const PrimeaRoutePath({
    required this.isUnknown,
    required this.tab,
  });

  const PrimeaRoutePath.unknown()
      : isUnknown = true,
        tab = PrimeaTabs.landing;

  const PrimeaRoutePath.matches()
      : isUnknown = false,
        tab = PrimeaTabs.matches;

  const PrimeaRoutePath.dashboard()
      : isUnknown = false,
        tab = PrimeaTabs.dashboard;

  const PrimeaRoutePath.landing()
      : isUnknown = false,
        tab = PrimeaTabs.landing;
}

class PrimeaRouteInformationParser
    extends RouteInformationParser<PrimeaRoutePath> {
  @override
  Future<PrimeaRoutePath> parseRouteInformation(
      RouteInformation routeInformation) {
    print("${routeInformation.uri.toString()}#${routeInformation.uri.query}");
    final path = routeInformation.uri.pathSegments;
    if (path.isEmpty) {
      return Future.value(const PrimeaRoutePath.landing());
    }

    switch (path.first) {
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
    if (configuration.isUnknown) {
      return RouteInformation(uri: Uri.parse('/404'));
    }

    switch (configuration.tab) {
      case PrimeaTabs.matches:
        return RouteInformation(uri: Uri.parse('/matches'));
      case PrimeaTabs.dashboard:
        return RouteInformation(uri: Uri.parse('/dashboard'));
      default:
        return RouteInformation(uri: Uri.parse('/'));
    }
  }
}
