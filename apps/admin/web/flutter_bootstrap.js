// Custom Flutter web bootstrap for the admin desk.
//
// IMPORTANT: do not write the double-brace placeholder tokens anywhere except
// the two lines below where they are intended. flutter build substitutes them
// literally (even inside comments), which would break this file.
//
// Purpose:
//   - Serve CanvasKit from our own hosting (canvaskit/) instead of
//     gstatic.com. gstatic is slow/blocked on some networks, which left the
//     engine unable to paint -> a blank white admin panel in prod.
//   - The build config injection is required by FlutterLoader.load(); without
//     it the loader throws that buildConfig must be set.
//   - Unregister any service worker cached from an earlier deploy and do not
//     register a new one (an internal desk needs no offline cache).

{{flutter_js}}
{{flutter_build_config}}

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations()
    .then(function (regs) { regs.forEach(function (r) { r.unregister(); }); })
    .catch(function () {});
}
if (window.caches && caches.keys) {
  caches.keys()
    .then(function (keys) { keys.forEach(function (k) { caches.delete(k); }); })
    .catch(function () {});
}

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/'
  }
});
