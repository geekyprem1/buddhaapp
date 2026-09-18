import 'package:go_router/go_router.dart';

/// The path of the route the user is actually looking at, including pages
/// opened with `push`/`pushNamed`.
///
/// [RouteMatchList.uri] deliberately ignores imperative (pushed) matches —
/// after `push('/wallpapers')` from Home it still reports `/home`. Chrome
/// decisions (banner, nav bar, Home escape) must read the top-most visible
/// route instead: the last match, walked through shell branches, and for a
/// pushed page the URI of its own match list.
String visibleRoutePathOf(GoRouter router) {
  try {
    final config = router.routerDelegate.currentConfiguration;
    if (config.matches.isEmpty) return config.uri.path;
    RouteMatchBase top = config.matches.last;
    while (top is ShellRouteMatch && top.matches.isNotEmpty) {
      top = top.matches.last;
    }
    if (top is ImperativeRouteMatch) {
      return top.matches.uri.path;
    }
    return config.uri.path;
  } catch (_) {
    return '';
  }
}
