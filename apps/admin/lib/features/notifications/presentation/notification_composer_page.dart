import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../../../widgets/upload_field.dart';
import '../../auth/application/admin_session.dart';
import '../../teachers/application/teachers_providers.dart';
import '../application/notifications_providers.dart';

const _modules = <(String, String)>[
  ('home', 'Home'),
  ('wallpaper', 'Wallpapers'),
  ('ringtone', 'Ringtones'),
  ('song', 'Songs'),
  ('meditation', 'Meditations'),
  ('status', 'Statuses'),
  ('prarthana', 'Daily Prarthana'),
  ('profile', 'Profile'),
];

enum _AudienceKind { all, language, teacher, platform, user }

enum _LinkKind { none, module, route, url }

class NotificationComposerPage extends ConsumerStatefulWidget {
  const NotificationComposerPage({this.campaignId, super.key});

  final String? campaignId;

  bool get isNew => campaignId == null || campaignId == 'new';

  @override
  ConsumerState<NotificationComposerPage> createState() =>
      _NotificationComposerPageState();
}

class _NotificationComposerPageState
    extends ConsumerState<NotificationComposerPage> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _route;
  late final TextEditingController _url;
  late final TextEditingController _userId;
  late final TextEditingController _testToken;

  late final String _id;
  String? _imageUrl;
  _AudienceKind _audienceKind = _AudienceKind.all;
  String _language = AppConstants.defaultLanguageCode;
  String? _teacherId;
  String _platform = 'android';
  _LinkKind _linkKind = _LinkKind.none;
  String _module = 'home';
  bool _schedule = false;
  DateTime? _scheduledAt;
  bool _dirty = false;
  bool _loaded = false;
  bool _busy = false;
  String _status = NotificationCampaignStatus.draft;
  int _delivered = 0;
  int _opened = 0;

  bool get _locked =>
      _status == NotificationCampaignStatus.sent ||
      _status == NotificationCampaignStatus.sending;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _body = TextEditingController();
    _route = TextEditingController();
    _url = TextEditingController();
    _userId = TextEditingController();
    _testToken = TextEditingController();
    _id = widget.isNew
        ? ref.read(notificationRepositoryProvider).nextId()
        : widget.campaignId!;
    if (widget.isNew) _loaded = true;
    _title.addListener(_markDirty);
    _body.addListener(_markDirty);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _route.dispose();
    _url.dispose();
    _userId.dispose();
    _testToken.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_loaded || _locked) return;
    if (!_dirty) setState(() => _dirty = true);
  }

  void _hydrate(NotificationCampaign c) {
    _title.text = c.title;
    _body.text = c.body;
    _imageUrl = c.imageUrl;
    _status = c.status;
    _delivered = c.deliveredCount;
    _opened = c.openedCount;
    _scheduledAt = c.scheduledAt;
    _schedule = c.status == NotificationCampaignStatus.scheduled;
    _parseAudience(c.audience);
    _parseLink(c.deepLink);
    _loaded = true;
    _dirty = false;
  }

  void _parseAudience(String raw) {
    if (raw.startsWith('language:')) {
      _audienceKind = _AudienceKind.language;
      _language = raw.substring('language:'.length);
    } else if (raw.startsWith('teacher:')) {
      _audienceKind = _AudienceKind.teacher;
      _teacherId = raw.substring('teacher:'.length);
    } else if (raw.startsWith('platform:')) {
      _audienceKind = _AudienceKind.platform;
      _platform = raw.substring('platform:'.length);
    } else if (raw.startsWith('user:')) {
      _audienceKind = _AudienceKind.user;
      _userId.text = raw.substring('user:'.length);
    } else {
      _audienceKind = _AudienceKind.all;
    }
  }

  void _parseLink(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      _linkKind = _LinkKind.none;
    } else if (value.startsWith('http://') || value.startsWith('https://')) {
      _linkKind = _LinkKind.url;
      _url.text = value;
    } else if (value.startsWith('/')) {
      _linkKind = _LinkKind.route;
      _route.text = value;
    } else {
      _linkKind = _LinkKind.module;
      _module = value;
    }
  }

  String _audience() {
    return switch (_audienceKind) {
      _AudienceKind.all => NotificationAudience.all,
      _AudienceKind.language => NotificationAudience.language(_language),
      _AudienceKind.teacher => NotificationAudience.teacher(_teacherId ?? ''),
      _AudienceKind.platform => NotificationAudience.platform(_platform),
      _AudienceKind.user => NotificationAudience.user(_userId.text.trim()),
    };
  }

  String? _deepLink() {
    return switch (_linkKind) {
      _LinkKind.none => null,
      _LinkKind.module => _module,
      _LinkKind.route => _route.text.trim().isEmpty ? null : _route.text.trim(),
      _LinkKind.url => _url.text.trim().isEmpty ? null : _url.text.trim(),
    };
  }

  String? _validate() {
    if (_title.text.trim().isEmpty) return AdminStrings.notifTitleRequired;
    if (_body.text.trim().isEmpty) return AdminStrings.notifBodyRequired;
    final audience = _audience();
    if (!NotificationAudience.isValid(audience)) {
      return AdminStrings.notifAudienceRequired;
    }
    if (_linkKind == _LinkKind.route && !_route.text.trim().startsWith('/')) {
      return AdminStrings.notifRouteInvalid;
    }
    if (_linkKind == _LinkKind.url) {
      final uri = Uri.tryParse(_url.text.trim());
      if (uri == null ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        return AdminStrings.notifUrlInvalid;
      }
    }
    if (_schedule &&
        (_scheduledAt == null ||
            _scheduledAt!.isBefore(DateTime.now().add(const Duration(minutes: 1))))) {
      return AdminStrings.notifScheduleInvalid;
    }
    return null;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.notifications);
  }

  Future<void> _saveDraft() async {
    final error = _validate();
    if (error != null &&
        error != AdminStrings.notifScheduleInvalid) {
      _snack(error);
      return;
    }
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      _snack(AdminStrings.notifTitleRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      final uid = ref.read(adminAuthUserProvider)?.uid ?? '';
      await ref.read(notificationRepositoryProvider).saveDraft(
            id: _id,
            title: _title.text,
            body: _body.text,
            imageUrl: _imageUrl,
            deepLink: _deepLink(),
            audience: _audience(),
            createdBy: uid,
          );
      _status = NotificationCampaignStatus.draft;
      _dirty = false;
      _snack(AdminStrings.saved);
      if (widget.isNew && mounted) {
        context.go('${AdminRoutes.notifications}/$_id');
      }
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendOrSchedule() async {
    final error = _validate();
    if (error != null) {
      _snack(error);
      return;
    }
    final ok = await ConfirmDialog.show(
      context,
      title: _schedule
          ? AdminStrings.confirmScheduleTitle
          : AdminStrings.confirmSendTitle,
      body: _schedule
          ? AdminStrings.confirmScheduleBody
          : '${AdminStrings.confirmSendBody} ${NotificationAudience.label(_audience())}.',
      confirmLabel: _schedule
          ? AdminStrings.scheduleSend
          : AdminStrings.sendNow,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      final result = await ref.read(adminFunctionsServiceProvider).sendNotification(
            campaignId: _id,
            title: _title.text.trim(),
            body: _body.text.trim(),
            imageUrl: _imageUrl,
            deepLink: _deepLink(),
            audience: _audience(),
            scheduledAt: _schedule ? _scheduledAt : null,
          );
      _status = result.status;
      _delivered = result.deliveredCount;
      _dirty = false;
      ref.invalidate(adminNotificationCampaignsProvider);
      ref.invalidate(adminNotificationCampaignProvider(_id));
      _snack(
        result.status == NotificationCampaignStatus.scheduled
            ? AdminStrings.notifScheduled
            : AdminStrings.notifSent,
      );
      if (widget.isNew && mounted) {
        context.go('${AdminRoutes.notifications}/$_id');
      }
    } on FirebaseFunctionsException catch (e) {
      _snack(e.message ?? e.code);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendTest() async {
    final error = _validate();
    if (error != null && error != AdminStrings.notifScheduleInvalid) {
      _snack(error);
      return;
    }
    if (_testToken.text.trim().isEmpty) {
      _snack(AdminStrings.notifTestTokenRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminFunctionsServiceProvider).sendNotification(
            campaignId: _id,
            title: _title.text.trim(),
            body: _body.text.trim(),
            imageUrl: _imageUrl,
            deepLink: _deepLink(),
            audience: _audience(),
            testToken: _testToken.text.trim(),
          );
      _snack(AdminStrings.notifTestSent);
    } on FirebaseFunctionsException catch (e) {
      _snack(e.message ?? e.code);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelSchedule() async {
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.confirmCancelScheduleTitle,
      body: AdminStrings.confirmCancelScheduleBody,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(notificationRepositoryProvider).cancelSchedule(_id);
      setState(() {
        _status = NotificationCampaignStatus.draft;
        _schedule = false;
        _scheduledAt = null;
      });
      ref.invalidate(adminNotificationCampaignsProvider);
      _snack(AdminStrings.notifScheduleCancelled);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _schedule = true;
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminNotificationCampaignProvider(_id));
      return async.when(
        loading: () => const AdminPageFrame(
          title: AdminStrings.notifications,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => AdminPageFrame(
          title: AdminStrings.notifications,
          onBack: () => context.go(AdminRoutes.notifications),
          child: ErrorState(message: e.toString()),
        ),
        data: (campaign) {
          if (campaign == null) {
            return AdminPageFrame(
              title: AdminStrings.notifications,
              onBack: () => context.go(AdminRoutes.notifications),
              child: const EmptyState(message: AdminStrings.emptyList),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(campaign));
          });
          return const AdminPageFrame(
            title: AdminStrings.notifications,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final teachers = ref.watch(adminTeachersProvider).valueOrNull ?? const [];

    return AdminPageFrame(
      title: widget.isNew
          ? AdminStrings.composeNotification
          : AdminStrings.notifications,
      onBack: _back,
      actions: [
        if (!_locked)
          OutlinedButton(
            onPressed: _busy ? null : _saveDraft,
            child: const Text(AdminStrings.saveDraft),
          ),
        const SizedBox(width: 8),
        if (_status == NotificationCampaignStatus.scheduled)
          OutlinedButton(
            onPressed: _busy ? null : _cancelSchedule,
            child: const Text(AdminStrings.cancelSchedule),
          ),
        if (!_locked) ...[
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _busy ? null : _sendOrSchedule,
            child: Text(
              _schedule ? AdminStrings.scheduleSend : AdminStrings.sendNow,
            ),
          ),
        ],
      ],
      child: AbsorbPointer(
        absorbing: _busy,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final form = _form(teachers);
            final preview = _PhonePreview(
              title: _title.text.trim().isEmpty
                  ? 'Dhamma Path'
                  : _title.text.trim(),
              body: _body.text.trim().isEmpty
                  ? AdminStrings.notifPreviewPlaceholder
                  : _body.text.trim(),
              imageUrl: _imageUrl,
            );
            if (!wide) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                children: [preview, const SizedBox(height: 24), form],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 16, 16, 32),
                    child: form,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 32, 32),
                    child: preview,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _form(List<Teacher> teachers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_locked || _status == NotificationCampaignStatus.failed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _status == NotificationCampaignStatus.sent
                  ? '${AdminStrings.notifStatsSent} · '
                        '${_delivered == 0 ? AdminStrings.topicAccepted : '$_delivered delivered'} · '
                        '$_opened opened'
                  : _status == NotificationCampaignStatus.failed
                      ? AdminStrings.notifFailed
                      : AdminStrings.notifSending,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _status == NotificationCampaignStatus.failed
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ),
        TextField(
          controller: _title,
          enabled: !_locked,
          maxLength: 80,
          decoration: const InputDecoration(labelText: AdminStrings.notifTitle),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _body,
          enabled: !_locked,
          maxLength: 240,
          maxLines: 4,
          decoration: const InputDecoration(labelText: AdminStrings.notifBody),
        ),
        const SizedBox(height: 12),
        if (!_locked)
          UploadField(
            label: AdminStrings.notifImage,
            valueUrl: _imageUrl,
            storagePathBuilder: (ext) => StoragePaths.notificationImage(_id, ext),
            onUploaded: (url) => setState(() {
              _imageUrl = url;
              _dirty = true;
            }),
          )
        else if (_imageUrl != null)
          Image.network(_imageUrl!, height: 120, fit: BoxFit.cover),
        const SizedBox(height: 20),
        Text(AdminStrings.notifAudience, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final kind in _AudienceKind.values)
              ChoiceChip(
                label: Text(_audienceKindLabel(kind)),
                selected: _audienceKind == kind,
                onSelected: _locked
                    ? null
                    : (_) => setState(() {
                          _audienceKind = kind;
                          _dirty = true;
                        }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_audienceKind == _AudienceKind.language)
          DropdownButtonFormField<String>(
            value: _language,
            decoration: const InputDecoration(labelText: AdminStrings.notifLanguage),
            items: [
              for (final code in AppConstants.supportedLanguageCodes)
                DropdownMenuItem(value: code, child: Text(code)),
            ],
            onChanged: _locked
                ? null
                : (v) => setState(() {
                      _language = v ?? _language;
                      _dirty = true;
                    }),
          ),
        if (_audienceKind == _AudienceKind.teacher)
          DropdownButtonFormField<String>(
            value: teachers.any((t) => t.id == _teacherId)
                ? _teacherId
                : (teachers.isEmpty ? null : teachers.first.id),
            decoration: const InputDecoration(labelText: AdminStrings.teachersField),
            items: [
              for (final t in teachers)
                DropdownMenuItem(value: t.id, child: Text(t.name.resolve('en'))),
            ],
            onChanged: _locked
                ? null
                : (v) => setState(() {
                      _teacherId = v;
                      _dirty = true;
                    }),
          ),
        if (_audienceKind == _AudienceKind.platform)
          DropdownButtonFormField<String>(
            value: _platform,
            decoration: const InputDecoration(labelText: AdminStrings.notifPlatform),
            items: const [
              DropdownMenuItem(value: 'android', child: Text('Android')),
              DropdownMenuItem(value: 'ios', child: Text('iOS')),
            ],
            onChanged: _locked
                ? null
                : (v) => setState(() {
                      _platform = v ?? _platform;
                      _dirty = true;
                    }),
          ),
        if (_audienceKind == _AudienceKind.user)
          TextField(
            controller: _userId,
            enabled: !_locked,
            decoration: const InputDecoration(labelText: AdminStrings.notifUserId),
            onChanged: (_) => _markDirty(),
          ),
        const SizedBox(height: 20),
        Text(AdminStrings.notifDeepLink, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final kind in _LinkKind.values)
              ChoiceChip(
                label: Text(_linkKindLabel(kind)),
                selected: _linkKind == kind,
                onSelected: _locked
                    ? null
                    : (_) => setState(() {
                          _linkKind = kind;
                          _dirty = true;
                        }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_linkKind == _LinkKind.module)
          DropdownButtonFormField<String>(
            value: _module,
            decoration: const InputDecoration(labelText: AdminStrings.moduleField),
            items: [
              for (final item in _modules)
                DropdownMenuItem(value: item.$1, child: Text(item.$2)),
            ],
            onChanged: _locked
                ? null
                : (v) => setState(() {
                      _module = v ?? _module;
                      _dirty = true;
                    }),
          ),
        if (_linkKind == _LinkKind.route)
          TextField(
            controller: _route,
            enabled: !_locked,
            decoration: const InputDecoration(
              labelText: AdminStrings.notifRoute,
              hintText: '/wallpapers',
            ),
            onChanged: (_) => _markDirty(),
          ),
        if (_linkKind == _LinkKind.url)
          TextField(
            controller: _url,
            enabled: !_locked,
            decoration: const InputDecoration(
              labelText: AdminStrings.notifUrl,
              hintText: 'https://',
            ),
            onChanged: (_) => _markDirty(),
          ),
        const SizedBox(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(AdminStrings.notifScheduleToggle),
          subtitle: const Text(AdminStrings.notifScheduleHint),
          value: _schedule,
          onChanged: _locked
              ? null
              : (v) => setState(() {
                    _schedule = v;
                    _dirty = true;
                    if (v && _scheduledAt == null) {
                      _scheduledAt = DateTime.now().add(const Duration(hours: 1));
                    }
                  }),
        ),
        if (_schedule)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _locked ? null : _pickSchedule,
              icon: const Icon(Icons.schedule),
              label: Text(
                _scheduledAt == null
                    ? AdminStrings.notifPickTime
                    : _scheduledAt!.toLocal().toString().substring(0, 16),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(AdminStrings.notifTestSend, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _testToken,
          decoration: const InputDecoration(
            labelText: AdminStrings.notifTestToken,
            hintText: AdminStrings.notifTestTokenHint,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _sendTest,
            icon: const Icon(Icons.phonelink_ring_outlined),
            label: const Text(AdminStrings.sendTest),
          ),
        ),
      ],
    );
  }

  String _audienceKindLabel(_AudienceKind kind) => switch (kind) {
    _AudienceKind.all => AdminStrings.notifAudienceAll,
    _AudienceKind.language => AdminStrings.notifAudienceLanguage,
    _AudienceKind.teacher => AdminStrings.notifAudienceTeacher,
    _AudienceKind.platform => AdminStrings.notifAudiencePlatform,
    _AudienceKind.user => AdminStrings.notifAudienceUser,
  };

  String _linkKindLabel(_LinkKind kind) => switch (kind) {
    _LinkKind.none => AdminStrings.notifLinkNone,
    _LinkKind.module => AdminStrings.notifLinkModule,
    _LinkKind.route => AdminStrings.notifLinkRoute,
    _LinkKind.url => AdminStrings.notifLinkUrl,
  };
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview({
    required this.title,
    required this.body,
    this.imageUrl,
  });

  final String title;
  final String body;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AdminStrings.notifPreview,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppColors.divider, width: 8),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.self_improvement,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: ColoredBox(color: AppColors.disabled),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
