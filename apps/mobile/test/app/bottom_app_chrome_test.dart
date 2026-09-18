import 'package:core/core.dart';
import 'package:dhamma_path/app/app_chrome_layout.dart';
import 'package:dhamma_path/app/app_visible_route.dart';
import 'package:dhamma_path/app/donate_support_banner.dart';
import 'package:dhamma_path/app/home_app_bar_button.dart';
import 'package:dhamma_path/app/persistent_bottom_nav.dart';
import 'package:dhamma_path/app/router.dart';
import 'package:dhamma_path/features/home/presentation/module_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _router({required String initialLocation, bool homeButton = false}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const Scaffold(body: Text('Home page')),
      ),
      GoRoute(
        path: AppRoutes.videos,
        builder: (_, __) => Scaffold(
          appBar: homeButton ? AppBar(leading: const HomeAppBarButton()) : null,
          body: const Text('Videos page'),
        ),
      ),
      GoRoute(
        path: AppRoutes.wallpapers,
        builder: (_, __) => const Scaffold(body: Text('Wallpapers page')),
      ),
      GoRoute(
        path: AppRoutes.askBuddha,
        builder: (_, __) => const Scaffold(body: Text('Buddha page')),
      ),
      GoRoute(
        path: AppRoutes.dana,
        builder: (_, __) => const Scaffold(body: Text('Daan page')),
      ),
    ],
  );
}

Widget _chromeHost(GoRouter router, {required bool bodhiAiEnabled}) {
  return MaterialApp.router(
    routerConfig: router,
    builder: (context, child) => AppChromeLayout(
      router: router,
      body: child ?? const SizedBox.shrink(),
      topBanner: const SizedBox.shrink(),
      miniPlayer: const SizedBox.shrink(),
      chromeEnabled: true,
      bodhiAiEnabled: bodhiAiEnabled,
    ),
  );
}

void main() {
  test('every Home module card resolves away from the Home route', () {
    for (final moduleId in HomeModuleIds.all) {
      expect(
        moduleRoute(moduleId),
        isNot(AppRoutes.home),
        reason: '$moduleId must activate non-home chrome',
      );
    }
  });

  testWidgets('Home keeps donation banner and full navigation', (tester) async {
    final router = _router(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_chromeHost(router, bodhiAiEnabled: true));

    expect(find.byType(DonateSupportBanner), findsOneWidget);
    expect(find.byType(PersistentBottomNav), findsOneWidget);
    expect(find.byType(DaanAskBuddhaBar), findsNothing);
  });

  testWidgets('opening Wallpaper from Home replaces the full navigation',
      (tester) async {
    final router = _router(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_chromeHost(router, bodhiAiEnabled: true));
    expect(find.byType(PersistentBottomNav), findsOneWidget);

    router.push(AppRoutes.wallpapers);
    await tester.pumpAndSettle();

    // RouteMatchList.uri ignores pushed pages, so the assertion must use the
    // top-most visible route — the same source the chrome decisions use.
    expect(visibleRoutePathOf(router), AppRoutes.wallpapers);
    expect(find.text('Wallpapers page'), findsOneWidget);
    expect(find.byType(PersistentBottomNav), findsNothing);
    expect(find.byType(DaanAskBuddhaBar), findsOneWidget);
  });

  testWidgets('non-home route shows only split Daan and Buddha bar',
      (tester) async {
    final router = _router(initialLocation: AppRoutes.videos);
    addTearDown(router.dispose);

    await tester.pumpWidget(_chromeHost(router, bodhiAiEnabled: true));

    expect(find.byType(PersistentBottomNav), findsNothing);
    expect(find.byType(DonateSupportBanner), findsNothing);
    expect(find.byType(DaanAskBuddhaBar), findsOneWidget);
    expect(find.text('Daan'), findsOneWidget);
    expect(find.text('Support this app'), findsOneWidget);
    expect(find.text('Ask Buddha'), findsOneWidget);
    expect(find.text('Powered by Bodhi AI'), findsOneWidget);

    await tester.tap(find.text('Ask Buddha'));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.askBuddha);
  });

  testWidgets('non-home route uses full Daan banner when AI is disabled',
      (tester) async {
    final router = _router(initialLocation: AppRoutes.videos);
    addTearDown(router.dispose);

    await tester.pumpWidget(_chromeHost(router, bodhiAiEnabled: false));

    expect(find.byType(PersistentBottomNav), findsNothing);
    expect(find.byType(DonateSupportBanner), findsOneWidget);
    expect(find.text('Ask Buddha'), findsNothing);
  });

  testWidgets('non-home AppBar Home button returns to Home', (tester) async {
    final router = _router(
      initialLocation: AppRoutes.videos,
      homeButton: true,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, AppRoutes.home);
  });
}
