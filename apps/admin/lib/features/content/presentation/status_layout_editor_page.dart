import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/responsive_layout.dart';
import '../../auth/application/admin_session.dart';
import '../application/content_providers.dart';
import '../application/content_type_config.dart';

/// Visual status layout editor (T1.19, FR-12.2). Drag/resize the circular
/// photo frame and the name text over the base image; everything is stored as
/// **normalised 0–1 coordinates** so the mobile composer (T2.28) renders the
/// exact same composition at any resolution. The preview here uses the same
/// math as `apps/mobile/.../status_layout.dart`:
///   - photo frame: circle of diameter `min(w·W, h·H)` with top-left `(x·W, y·H)`
///   - name text:   top-left `(x·W, y·H)`, width `w·W`, font `size·H`
class StatusLayoutEditorPage extends ConsumerStatefulWidget {
  const StatusLayoutEditorPage({
    required this.config,
    required this.itemId,
    super.key,
  });

  final ContentTypeConfig config;
  final String itemId;

  @override
  ConsumerState<StatusLayoutEditorPage> createState() =>
      _StatusLayoutEditorPageState();
}

class _StatusLayoutEditorPageState
    extends ConsumerState<StatusLayoutEditorPage> {
  LayoutRect _frame = const LayoutRect(x: 0.62, y: 0.70, w: 0.22, h: 0.22);
  StatusTextStyle _name = const StatusTextStyle(x: 0.06, y: 0.90, w: 0.6);
  bool _watermark = true;
  DateTime? _festivalDate;

  String _sampleName = 'Your Name';
  Uint8List? _samplePhoto;

  bool _loaded = false;
  bool _saving = false;
  bool _dirty = false;

  void _hydrate(ContentItem item) {
    final meta = item.statusMeta ?? const StatusMeta();
    _frame = meta.photoFrame;
    _name = meta.nameText;
    _watermark = meta.watermark;
    _festivalDate = meta.festivalDate;
    _loaded = true;
  }

  Future<void> _pickSamplePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes != null) setState(() => _samplePhoto = bytes);
  }

  Future<void> _save(ContentItem item) async {
    setState(() => _saving = true);
    final updated = item.copyWith(
      statusMeta: StatusMeta(
        photoFrame: _frame,
        nameText: _name,
        watermark: _watermark,
        festivalDate: _festivalDate,
      ),
    );
    try {
      await ref
          .read(contentRepositoryProvider(widget.config.collection))
          .update(updated);
      ref.invalidate(adminContentListProvider(widget.config.collection));
      ref.invalidate(
        adminContentItemProvider((widget.config.collection, widget.itemId)),
      );
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AdminStrings.saved)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save. $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      adminContentItemProvider((widget.config.collection, widget.itemId)),
    );
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (item) {
        if (item == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        if (!_loaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(item));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final canEdit = AdminRole.canEditContent(
          ref.watch(adminRoleProvider).valueOrNull,
        );
        return AdminPageFrame(
          title:
              '${AdminStrings.statusLayoutTitle} — ${item.title.resolve('en')}',
          onBack: () => context.go(
            '${widget.config.route}/${widget.itemId}',
          ),
          actions: [
            FilledButton(
              onPressed:
                  _saving || !canEdit || !_dirty ? null : () => _save(item),
              child: const Text(AdminStrings.save),
            ),
          ],
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final preview = _PreviewCanvas(
                baseUrl: item.mediaUrl,
                frame: _frame,
                name: _name,
                sampleName: _sampleName,
                samplePhoto: _samplePhoto,
                watermark: _watermark,
                enabled: canEdit,
                onFrame: (r) => setState(() {
                  _frame = r;
                  _dirty = true;
                }),
                onName: (s) => setState(() {
                  _name = s;
                  _dirty = true;
                }),
              );
              final controls = _Controls(
                frame: _frame,
                name: _name,
                sampleName: _sampleName,
                watermark: _watermark,
                festivalDate: _festivalDate,
                enabled: canEdit,
                onSampleName: (v) => setState(() => _sampleName = v),
                onPickPhoto: _pickSamplePhoto,
                onSize: (v) => setState(() {
                  _name = _name.copyWith(size: v);
                  _dirty = true;
                }),
                onAlign: (v) => setState(() {
                  _name = _name.copyWith(align: v);
                  _dirty = true;
                }),
                onWatermark: (v) => setState(() {
                  _watermark = v;
                  _dirty = true;
                }),
                onFestivalDate: (d) => setState(() {
                  _festivalDate = d;
                  _dirty = true;
                }),
              );
              return SingleChildScrollView(
                padding: AdminResponsive.pagePadding(
                  context,
                  top: 24,
                  bottom: 48,
                ),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 360, child: preview),
                          const SizedBox(width: 32),
                          Expanded(child: controls),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: preview,
                            ),
                          ),
                          const SizedBox(height: 24),
                          controls,
                        ],
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

/// The interactive image canvas with the draggable frame + name overlays.
class _PreviewCanvas extends StatefulWidget {
  const _PreviewCanvas({
    required this.baseUrl,
    required this.frame,
    required this.name,
    required this.sampleName,
    required this.samplePhoto,
    required this.watermark,
    required this.enabled,
    required this.onFrame,
    required this.onName,
  });

  final String? baseUrl;
  final LayoutRect frame;
  final StatusTextStyle name;
  final String sampleName;
  final Uint8List? samplePhoto;
  final bool watermark;
  final bool enabled;
  final ValueChanged<LayoutRect> onFrame;
  final ValueChanged<StatusTextStyle> onName;

  @override
  State<_PreviewCanvas> createState() => _PreviewCanvasState();
}

class _PreviewCanvasState extends State<_PreviewCanvas> {
  Size? _imageSize;

  // Transient values while a gesture is active. Committing to the parent only
  // on gesture end keeps the whole page (Controls panel) from rebuilding on
  // every pointer move, which is what made dragging feel slow.
  LayoutRect? _liveFrame;
  StatusTextStyle? _liveName;

  LayoutRect get _frame => _liveFrame ?? widget.frame;
  StatusTextStyle get _name => _liveName ?? widget.name;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(_PreviewCanvas old) {
    super.didUpdateWidget(old);
    if (old.baseUrl != widget.baseUrl) _resolve();
  }

  void _resolve() {
    final url = widget.baseUrl;
    if (url == null || url.isEmpty) return;
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (mounted) {
          setState(() => _imageSize = Size(
                info.image.width.toDouble(),
                info.image.height.toDouble(),
              ));
        }
        stream.removeListener(listener);
      },
      onError: (_, __) => stream.removeListener(listener),
    );
    stream.addListener(listener);
  }

  double _clamp01(double v) => v.clamp(0.0, 1.0);

  void _commitFrame() {
    if (_liveFrame != null) {
      widget.onFrame(_liveFrame!);
      setState(() => _liveFrame = null);
    }
  }

  void _commitName() {
    if (_liveName != null) {
      widget.onName(_liveName!);
      setState(() => _liveName = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.baseUrl == null || widget.baseUrl!.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Center(child: Text(AdminStrings.statusNoBase)),
        ),
      );
    }
    // Match the base image's aspect so preview == mobile composite in proportion.
    final aspect =
        _imageSize == null ? 4 / 5 : _imageSize!.width / _imageSize!.height;

    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, c) {
            final cw = c.maxWidth;
            final ch = c.maxHeight;
            final f = _frame;
            final n = _name;
            final diameter = (f.w * cw) < (f.h * ch) ? (f.w * cw) : (f.h * ch);
            final fontSize = n.size * ch;

            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Image.network(widget.baseUrl!, fit: BoxFit.cover),
                  ),
                ),
                if (widget.watermark)
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: Text(
                      AdminStrings.appName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: ch * 0.02,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // --- Photo frame (circle) ---
                Positioned(
                  left: f.x * cw,
                  top: f.y * ch,
                  width: diameter,
                  height: diameter,
                  child: GestureDetector(
                    onPanUpdate: widget.enabled
                        ? (d) {
                            setState(() {
                              _liveFrame = f.copyWith(
                                x: _clamp01(f.x + d.delta.dx / cw),
                                y: _clamp01(f.y + d.delta.dy / ch),
                              );
                            });
                          }
                        : null,
                    onPanEnd: widget.enabled ? (_) => _commitFrame() : null,
                    child: _FrameOverlay(
                      diameter: diameter,
                      photo: widget.samplePhoto,
                      enabled: widget.enabled,
                      onResize: widget.enabled
                          ? (delta) {
                              final newD = (diameter + delta).clamp(
                                cw * 0.06,
                                cw * 0.9,
                              );
                              setState(() {
                                _liveFrame = f.copyWith(
                                  w: newD / cw,
                                  h: newD / ch,
                                );
                              });
                            }
                          : null,
                      onResizeEnd: widget.enabled ? _commitFrame : null,
                    ),
                  ),
                ),

                // --- Name text box ---
                Positioned(
                  left: n.x * cw,
                  top: n.y * ch,
                  width: n.w * cw,
                  child: GestureDetector(
                    onPanUpdate: widget.enabled
                        ? (d) {
                            setState(() {
                              _liveName = n.copyWith(
                                x: _clamp01(n.x + d.delta.dx / cw),
                                y: _clamp01(n.y + d.delta.dy / ch),
                              );
                            });
                          }
                        : null,
                    onPanEnd: widget.enabled ? (_) => _commitName() : null,
                    child: _NameOverlay(
                      text: widget.sampleName,
                      fontSize: fontSize,
                      align: textAlignOf(n.align),
                      color: _colorOf(n.color),
                      weight: _weightOf(n.weight),
                      enabled: widget.enabled,
                      onResize: widget.enabled
                          ? (delta) {
                              setState(() {
                                _liveName = n.copyWith(
                                  w: _clamp01(n.w + delta / cw),
                                );
                              });
                            }
                          : null,
                      onResizeEnd: widget.enabled ? _commitName : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FrameOverlay extends StatelessWidget {
  const _FrameOverlay({
    required this.diameter,
    required this.photo,
    required this.enabled,
    required this.onResize,
    required this.onResizeEnd,
  });

  final double diameter;
  final Uint8List? photo;
  final bool enabled;
  final ValueChanged<double>? onResize;
  final VoidCallback? onResizeEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.25),
            border: Border.all(color: Colors.white, width: 2),
            image: photo != null
                ? DecorationImage(image: MemoryImage(photo!), fit: BoxFit.cover)
                : null,
          ),
          child: photo == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        if (enabled)
          Positioned(
            right: -8,
            bottom: -8,
            child: GestureDetector(
              onPanUpdate: (d) => onResize?.call(d.delta.dx),
              onPanEnd: (_) => onResizeEnd?.call(),
              child: const _ResizeHandle(),
            ),
          ),
      ],
    );
  }
}

class _NameOverlay extends StatelessWidget {
  const _NameOverlay({
    required this.text,
    required this.fontSize,
    required this.align,
    required this.color,
    required this.weight,
    required this.enabled,
    required this.onResize,
    required this.onResizeEnd,
  });

  final String text;
  final double fontSize;
  final TextAlign align;
  final Color color;
  final FontWeight weight;
  final bool enabled;
  final ValueChanged<double>? onResize;
  final VoidCallback? onResizeEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? Colors.white70 : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Text(
            text.isEmpty ? 'Your Name' : text,
            textAlign: align,
            style: TextStyle(
              fontSize: fontSize <= 0 ? 12 : fontSize,
              color: color,
              fontWeight: weight,
              height: 1.1,
            ),
          ),
        ),
        if (enabled)
          Positioned(
            right: -8,
            bottom: -8,
            child: GestureDetector(
              onPanUpdate: (d) => onResize?.call(d.delta.dx),
              onPanEnd: (_) => onResizeEnd?.call(),
              child: const _ResizeHandle(),
            ),
          ),
      ],
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.open_in_full, size: 10, color: Colors.white),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.frame,
    required this.name,
    required this.sampleName,
    required this.watermark,
    required this.festivalDate,
    required this.enabled,
    required this.onSampleName,
    required this.onPickPhoto,
    required this.onSize,
    required this.onAlign,
    required this.onWatermark,
    required this.onFestivalDate,
  });

  final LayoutRect frame;
  final StatusTextStyle name;
  final String sampleName;
  final bool watermark;
  final DateTime? festivalDate;
  final bool enabled;
  final ValueChanged<String> onSampleName;
  final VoidCallback onPickPhoto;
  final ValueChanged<double> onSize;
  final ValueChanged<String> onAlign;
  final ValueChanged<bool> onWatermark;
  final ValueChanged<DateTime?> onFestivalDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AdminStrings.statusLayoutHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Text(AdminStrings.statusSampleName, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: sampleName,
          enabled: enabled,
          decoration: const InputDecoration(hintText: 'Your Name'),
          onChanged: onSampleName,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: enabled ? onPickPhoto : null,
          icon: const Icon(Icons.person_outline, size: 18),
          label: const Text(AdminStrings.statusSamplePhoto),
        ),
        const Divider(height: 32),
        Text(AdminStrings.statusNameSize, style: theme.textTheme.labelLarge),
        Slider(
          value: name.size.clamp(0.02, 0.10),
          min: 0.02,
          max: 0.10,
          divisions: 16,
          label: '${(name.size * 100).toStringAsFixed(1)}%',
          onChanged: enabled ? onSize : null,
        ),
        const SizedBox(height: 8),
        Text(AdminStrings.statusNameAlign, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final a in const ['left', 'center', 'right'])
              ChoiceChip(
                label: Text(a),
                selected: name.align == a,
                onSelected: enabled ? (_) => onAlign(a) : null,
              ),
          ],
        ),
        const Divider(height: 32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(AdminStrings.statusWatermark),
          value: watermark,
          onChanged: enabled ? onWatermark : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(AdminStrings.statusFestivalDate),
          subtitle: Text(
            festivalDate == null
                ? AdminStrings.statusFestivalNone
                : '${festivalDate!.year}-${festivalDate!.month.toString().padLeft(2, '0')}-${festivalDate!.day.toString().padLeft(2, '0')}',
          ),
          trailing: Wrap(
            children: [
              if (festivalDate != null)
                IconButton(
                  onPressed: enabled ? () => onFestivalDate(null) : null,
                  icon: const Icon(Icons.clear),
                ),
              IconButton(
                onPressed: enabled
                    ? () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: festivalDate ?? now,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 3),
                        );
                        if (picked != null) onFestivalDate(picked);
                      }
                    : null,
                icon: const Icon(Icons.calendar_today, size: 18),
              ),
            ],
          ),
        ),
        const Divider(height: 32),
        Text(
          'Frame  x:${frame.x.toStringAsFixed(2)}  y:${frame.y.toStringAsFixed(2)}  '
          'size:${frame.w.toStringAsFixed(2)}\n'
          'Name   x:${name.x.toStringAsFixed(2)}  y:${name.y.toStringAsFixed(2)}  '
          'w:${name.w.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

TextAlign textAlignOf(String align) {
  switch (align) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    default:
      return TextAlign.left;
  }
}

Color _colorOf(String hex) {
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? const Color(0xFF1F1F1F) : Color(parsed);
}

FontWeight _weightOf(int weight) {
  if (weight >= 800) return FontWeight.w800;
  if (weight >= 700) return FontWeight.w700;
  if (weight >= 600) return FontWeight.w600;
  if (weight >= 500) return FontWeight.w500;
  return FontWeight.w400;
}
