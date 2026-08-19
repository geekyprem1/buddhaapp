String slugify(String input) {
  final lower = input.trim().toLowerCase();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return replaced.replaceAll(RegExp(r'^_+|_+$'), '');
}
