/// Semver-ish compare for `x.y.z` app versions (FR-1.3). Extra segments
/// and non-numeric tails are ignored; missing segments count as 0.
int compareAppVersions(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  final n = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < n; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l.compareTo(r);
  }
  return 0;
}

/// Admin `forceUpdate` blocks only installs below [minSupportedVersion].
bool needsForceUpdate({
  required bool forceUpdate,
  required String minSupportedVersion,
  required String installedVersion,
}) {
  if (!forceUpdate) return false;
  return compareAppVersions(installedVersion, minSupportedVersion) < 0;
}

List<int> _parts(String raw) {
  return raw
      .split('+')
      .first
      .split('-')
      .first
      .split('.')
      .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();
}
