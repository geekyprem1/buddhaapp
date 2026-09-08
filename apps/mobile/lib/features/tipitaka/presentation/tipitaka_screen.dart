import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Tipitaka — the Pali canon, embedded from https://tipitaka.app inside an
/// in-app WebView so the user never leaves the app. Shows a loading bar while
/// the page loads and an error state (with retry) if it can't be reached.
class TipitakaScreen extends StatefulWidget {
  const TipitakaScreen({super.key});

  static const _url = 'https://tipitaka.app/';

  @override
  State<TipitakaScreen> createState() => _TipitakaScreenState();
}

class _TipitakaScreenState extends State<TipitakaScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _error = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _error = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Only surface a full error for the main frame failing.
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() {
                _loading = false;
                _error = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(TipitakaScreen._url));
  }

  void _reload() {
    setState(() {
      _loading = true;
      _error = false;
    });
    _controller.loadRequest(Uri.parse(TipitakaScreen._url));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.homeTipitaka ?? 'Tipitaka'),
        actions: [
          IconButton(
            tooltip: l10n?.retryButton ?? 'Reload',
            onPressed: () {
              AppHaptics.tap();
              _reload();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _error
          ? ErrorState(
              message: l10n?.errorLoadFailed ?? 'Could not load content.',
              onRetry: _reload,
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  const LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.disabled,
                  ),
              ],
            ),
    );
  }
}
