import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/localised_text_field.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../application/pages_providers.dart';

class PageEditorPage extends ConsumerStatefulWidget {
  const PageEditorPage({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<PageEditorPage> createState() => _PageEditorPageState();
}

class _PageEditorPageState extends ConsumerState<PageEditorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _en;
  late final TextEditingController _hi;
  late final TextEditingController _mr;

  var _title = const LocalisedText();
  bool _loaded = false;
  bool _dirty = false;
  bool _saving = false;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _en = TextEditingController();
    _hi = TextEditingController();
    _mr = TextEditingController();
    _en.addListener(_markDirty);
    _hi.addListener(_markDirty);
    _mr.addListener(_markDirty);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _en.dispose();
    _hi.dispose();
    _mr.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_loaded && !_dirty) setState(() => _dirty = true);
  }

  void _hydrate(StaticPage? page) {
    _title = page?.title ?? LocalisedText(en: StaticPageSlugs.label(widget.slug));
    _en.text = page?.body.en ?? '';
    _hi.text = page?.body.hi ?? '';
    _mr.text = page?.body.mr ?? '';
    _updatedAt = page?.updatedAt;
    _loaded = true;
    _dirty = false;
  }

  TextEditingController get _active => switch (_tabs.index) {
    1 => _hi,
    2 => _mr,
    _ => _en,
  };

  void _wrap(String open, String close) {
    final controller = _active;
    final text = controller.text;
    final sel = controller.selection;
    final start = sel.isValid ? sel.start.clamp(0, text.length) : text.length;
    final end = sel.isValid ? sel.end.clamp(0, text.length) : text.length;
    final inner = text.substring(start, end);
    final next = text.replaceRange(start, end, '$open$inner$close');
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: start + open.length + inner.length,
      ),
    );
    _markDirty();
  }

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.pages);
  }

  Future<void> _save() async {
    if (_title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.titleRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(staticPageRepositoryProvider).upsert(
            StaticPage(
              slug: widget.slug,
              title: _title,
              body: LocalisedText(en: _en.text, hi: _hi.text, mr: _mr.text),
            ),
          );
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
        _updatedAt = DateTime.now();
      });
      ref.invalidate(adminStaticPagesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.saved)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.configSaveFailed} $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      final async = ref.watch(adminStaticPageProvider(widget.slug));
      return async.when(
        loading: () => AdminPageFrame(
          title: StaticPageSlugs.label(widget.slug),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => AdminPageFrame(
          title: StaticPageSlugs.label(widget.slug),
          onBack: () => context.go(AdminRoutes.pages),
          child: ErrorState(message: e.toString()),
        ),
        data: (page) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(page));
          });
          return AdminPageFrame(
            title: StaticPageSlugs.label(widget.slug),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final preview = switch (_tabs.index) {
      1 => _hi.text,
      2 => _mr.text,
      _ => _en.text,
    };

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: StaticPageSlugs.label(widget.slug),
        onBack: _back,
        actions: [
          FilledButton(
            onPressed: _saving || !_dirty ? null : _save,
            child: const Text(AdminStrings.save),
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
          children: [
            LocalisedTextField(
              label: AdminStrings.pageTitle,
              value: _title,
              onChanged: (v) {
                _title = v;
                _markDirty();
              },
            ),
            const SizedBox(height: 20),
            Text(
              AdminStrings.pageBody,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(text: AdminStrings.english),
                Tab(text: AdminStrings.hindi),
                Tab(text: AdminStrings.marathi),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _tool('B', () => _wrap('<b>', '</b>')),
                _tool('I', () => _wrap('<i>', '</i>')),
                _tool('H', () => _wrap('<h2>', '</h2>')),
                _tool('•', () => _wrap('<ul><li>', '</li></ul>')),
                _tool('Link', () => _wrap('<a href="">', '</a>')),
                _tool('BR', () => _wrap('<br/>', '')),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: ValueKey(_tabs.index),
              controller: _active,
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: AdminStrings.pageBodyHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AdminStrings.pagePreview,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: preview.trim().isEmpty
                    ? Text(
                        AdminStrings.pagePreviewEmpty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : SimpleHtmlText(html: preview),
              ),
            ),
            if (_updatedAt != null) ...[
              const SizedBox(height: 16),
              Text(
                '${AdminStrings.configUpdatedAt} ${_updatedAt!.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tool(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
