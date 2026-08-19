import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum HtmlBlockKind { paragraph, heading, bullet }

class HtmlInline {
  const HtmlInline({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.href,
  });

  final String text;
  final bool bold;
  final bool italic;
  final String? href;
}

class HtmlBlock {
  const HtmlBlock({required this.kind, required this.inlines});

  final HtmlBlockKind kind;
  final List<HtmlInline> inlines;
}

/// Tiny HTML subset used by static pages: `p`, `h2`/`h3`, `br`, `b`/`strong`,
/// `i`/`em`, `ul`/`li`, `a href`.
List<HtmlBlock> parseSimpleHtml(String raw) {
  final normalized = raw
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll('\r\n', '\n');
  final blocks = <HtmlBlock>[];
  final tag = RegExp(
    r'<h2>([\s\S]*?)</h2>|<h3>([\s\S]*?)</h3>|<ul>([\s\S]*?)</ul>|<p>([\s\S]*?)</p>',
    caseSensitive: false,
  );
  var cursor = 0;
  for (final match in tag.allMatches(normalized)) {
    _flushParagraphs(blocks, normalized.substring(cursor, match.start));
    if (match.group(1) != null || match.group(2) != null) {
      blocks.add(
        HtmlBlock(
          kind: HtmlBlockKind.heading,
          inlines: parseSimpleInlines(match.group(1) ?? match.group(2)!),
        ),
      );
    } else if (match.group(3) != null) {
      final items = RegExp(
        r'<li>([\s\S]*?)</li>',
        caseSensitive: false,
      ).allMatches(match.group(3)!);
      if (items.isEmpty) {
        blocks.add(
          HtmlBlock(
            kind: HtmlBlockKind.bullet,
            inlines: parseSimpleInlines(match.group(3)!),
          ),
        );
      } else {
        for (final item in items) {
          blocks.add(
            HtmlBlock(
              kind: HtmlBlockKind.bullet,
              inlines: parseSimpleInlines(item.group(1)!),
            ),
          );
        }
      }
    } else if (match.group(4) != null) {
      blocks.add(
        HtmlBlock(
          kind: HtmlBlockKind.paragraph,
          inlines: parseSimpleInlines(match.group(4)!),
        ),
      );
    }
    cursor = match.end;
  }
  _flushParagraphs(blocks, normalized.substring(cursor));
  return blocks;
}

void _flushParagraphs(List<HtmlBlock> blocks, String raw) {
  for (final chunk in raw.split(RegExp(r'\n{2,}'))) {
    final trimmed = chunk.trim();
    if (trimmed.isEmpty) continue;
    blocks.add(
      HtmlBlock(
        kind: HtmlBlockKind.paragraph,
        inlines: parseSimpleInlines(trimmed.replaceAll('\n', ' ')),
      ),
    );
  }
}

List<HtmlInline> parseSimpleInlines(String raw) {
  final stripped = raw.replaceAll(RegExp(r'</?(?:span|div)[^>]*>', caseSensitive: false), '');
  final out = <HtmlInline>[];
  final tag = RegExp(
    r'<(b|strong|i|em|a)(?:\s+href="([^"]*)")?>([\s\S]*?)</\1>',
    caseSensitive: false,
  );
  var cursor = 0;
  for (final match in tag.allMatches(stripped)) {
    final before = stripped.substring(cursor, match.start);
    if (before.isNotEmpty) {
      out.add(HtmlInline(text: _decode(before)));
    }
    final name = match.group(1)!.toLowerCase();
    final inner = _decode(match.group(3)!);
    out.add(
      HtmlInline(
        text: inner,
        bold: name == 'b' || name == 'strong',
        italic: name == 'i' || name == 'em',
        href: name == 'a' ? match.group(2) : null,
      ),
    );
    cursor = match.end;
  }
  final tail = stripped.substring(cursor);
  if (tail.isNotEmpty) out.add(HtmlInline(text: _decode(tail)));
  return out;
}

String _decode(String raw) {
  return raw
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'<[^>]+>'), '');
}

class SimpleHtmlText extends StatelessWidget {
  const SimpleHtmlText({
    required this.html,
    this.style,
    this.onLinkTap,
    super.key,
  });

  final String html;
  final TextStyle? style;
  final ValueChanged<String>? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyLarge;
    final blocks = parseSimpleHtml(html);
    if (blocks.isEmpty) {
      return Text('', style: base);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _block(context, blocks[i], base),
        ],
      ],
    );
  }

  Widget _block(BuildContext context, HtmlBlock block, TextStyle? base) {
    final style = switch (block.kind) {
      HtmlBlockKind.heading => Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      HtmlBlockKind.bullet || HtmlBlockKind.paragraph => base,
    };
    final text = Text.rich(
      TextSpan(children: [
        for (final inline in block.inlines) _span(inline, style),
      ]),
    );
    if (block.kind == HtmlBlockKind.bullet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style),
          Expanded(child: text),
        ],
      );
    }
    return text;
  }

  InlineSpan _span(HtmlInline inline, TextStyle? base) {
    var style = base;
    if (inline.bold) style = style?.copyWith(fontWeight: FontWeight.w700);
    if (inline.italic) style = style?.copyWith(fontStyle: FontStyle.italic);
    if (inline.href != null) {
      style = style?.copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      );
      return TextSpan(
        text: inline.text,
        style: style,
        recognizer: onLinkTap == null
            ? null
            : (TapGestureRecognizer()..onTap = () => onLinkTap!(inline.href!)),
      );
    }
    return TextSpan(text: inline.text, style: style);
  }
}
