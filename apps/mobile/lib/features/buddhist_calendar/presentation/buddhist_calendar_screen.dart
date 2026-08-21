import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/buddhist_calendar_service.dart';

class BuddhistCalendarScreen extends StatefulWidget {
  const BuddhistCalendarScreen({super.key});

  @override
  State<BuddhistCalendarScreen> createState() => _BuddhistCalendarScreenState();
}

class _BuddhistCalendarScreenState extends State<BuddhistCalendarScreen> {
  static const _service = BuddhistCalendarService();
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = _service.monthGrid(_displayedMonth);
    final monthEvents = _service.observancesBetween(days.first, days.last);
    final selectedEvents = _service.onDate(_selectedDate, monthEvents);
    final upcoming = _service.upcoming(today);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.calendarTitle ?? 'Buddhist Calendar'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _displayedMonth = DateTime(today.year, today.month);
              _selectedDate = today;
            }),
            child: Text(l10n?.calendarToday ?? 'Today'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _monthCard(context, l10n, days, monthEvents, today),
          const SizedBox(height: AppSpacing.md),
          _legend(context, l10n),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n?.calendarSelectedDate ?? 'Selected date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            MaterialLocalizations.of(context).formatFullDate(_selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedEvents.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n?.calendarNoObservance ??
                      'No marked observance on this date.',
                ),
              ),
            )
          else
            for (final event in selectedEvents)
              _observanceCard(context, l10n, event),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n?.calendarUpcoming ?? 'Upcoming observances',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < upcoming.length; i++) ...[
                  _upcomingTile(context, l10n, upcoming[i]),
                  if (i < upcoming.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _noticeCard(context, l10n),
        ],
      ),
    );
  }

  Widget _monthCard(
    BuildContext context,
    AppLocalizations? l10n,
    List<DateTime> days,
    List<BuddhistObservance> events,
    DateTime today,
  ) {
    final material = MaterialLocalizations.of(context);
    final sundayFirst = material.narrowWeekdays;
    final weekdays = [...sundayFirst.skip(1), sundayFirst.first];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n?.calendarPreviousMonth ?? 'Previous month',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    material.formatMonthYear(_displayedMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n?.calendarNextMonth ?? 'Next month',
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                for (final weekday in weekdays)
                  Center(
                    child: Text(
                      weekday,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                for (final day in days) _dayCell(context, day, events, today),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    DateTime day,
    List<BuddhistObservance> events,
    DateTime today,
  ) {
    final dayEvents = _service.onDate(day, events);
    final isSelected = BuddhistCalendarService.isSameDate(day, _selectedDate);
    final isToday = BuddhistCalendarService.isSameDate(day, today);
    final isOutside = day.month != _displayedMonth.month;
    final hasFestival = dayEvents.any((event) => event.isFestival);
    final hasUposatha = dayEvents.any((event) => !event.isFestival);
    final selectedColor = Theme.of(context).colorScheme.primary;

    return Semantics(
      selected: isSelected,
      button: true,
      label: MaterialLocalizations.of(context).formatFullDate(day),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => setState(() {
          _selectedDate = day;
          if (isOutside) _displayedMonth = DateTime(day.year, day.month);
        }),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : null,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: isToday && !isSelected
                ? Border.all(color: selectedColor, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isOutside
                              ? AppColors.textSecondary.withValues(alpha: 0.45)
                              : null,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUposatha)
                    _marker(
                      isSelected ? Colors.white : AppColors.primary,
                    ),
                  if (hasUposatha && hasFestival) const SizedBox(width: 2),
                  if (hasFestival)
                    _marker(
                      isSelected ? Colors.white : Colors.amber.shade700,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _marker(Color color) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _legend(BuildContext context, AppLocalizations? l10n) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        _legendItem(
          context,
          AppColors.primary,
          l10n?.calendarUposatha ?? 'Uposatha',
        ),
        _legendItem(
          context,
          Colors.amber.shade700,
          l10n?.calendarFestival ?? 'Festival',
        ),
      ],
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _marker(color),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _observanceCard(
    BuildContext context,
    AppLocalizations? l10n,
    BuddhistObservance event,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              event.isFestival ? Icons.celebration_outlined : Icons.nightlight,
              color:
                  event.isFestival ? Colors.amber.shade700 : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _eventTitle(l10n, event.kind),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_eventDescription(l10n, event.kind)),
                  if (event.isEstimated) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _estimatedBadge(l10n),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingTile(
    BuildContext context,
    AppLocalizations? l10n,
    BuddhistObservance event,
  ) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (event.isFestival ? Colors.amber : AppColors.primary)
              .withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          event.isFestival ? Icons.celebration_outlined : Icons.nightlight,
          color: event.isFestival ? Colors.amber.shade700 : AppColors.primary,
        ),
      ),
      title: Text(_eventTitle(l10n, event.kind)),
      subtitle: Text(
        MaterialLocalizations.of(context).formatFullDate(event.date),
      ),
      trailing: event.isEstimated ? _estimatedBadge(l10n) : null,
      onTap: () => setState(() {
        _selectedDate = event.date;
        _displayedMonth = DateTime(event.date.year, event.date.month);
      }),
    );
  }

  Widget _estimatedBadge(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        l10n?.calendarEstimated ?? 'Estimated',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _noticeCard(BuildContext context, AppLocalizations? l10n) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.calendarNoticeTitle ?? 'About these dates',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n?.calendarEstimateNotice ??
                        'Lunar dates are estimates and may vary by tradition.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _eventTitle(
    AppLocalizations? l10n,
    BuddhistObservanceKind kind,
  ) {
    return switch (kind) {
      BuddhistObservanceKind.uposathaNewMoon =>
        l10n?.calendarNewMoonUposatha ?? 'New Moon Uposatha',
      BuddhistObservanceKind.uposathaFirstQuarter =>
        l10n?.calendarFirstQuarterUposatha ?? 'First Quarter Uposatha',
      BuddhistObservanceKind.uposathaFullMoon =>
        l10n?.calendarFullMoonUposatha ?? 'Full Moon Uposatha',
      BuddhistObservanceKind.uposathaLastQuarter =>
        l10n?.calendarLastQuarterUposatha ?? 'Last Quarter Uposatha',
      BuddhistObservanceKind.maghaPuja =>
        l10n?.calendarMaghaPuja ?? 'Magha Puja (Sangha Day)',
      BuddhistObservanceKind.parinirvanaDay =>
        l10n?.calendarParinirvanaDay ?? 'Parinirvana Day',
      BuddhistObservanceKind.vesak =>
        l10n?.calendarVesak ?? 'Vesak (Buddha Day)',
      BuddhistObservanceKind.asalhaPuja =>
        l10n?.calendarAsalhaPuja ?? 'Asalha Puja (Dhamma Day)',
      BuddhistObservanceKind.pavarana =>
        l10n?.calendarPavarana ?? 'Pavarana Day',
      BuddhistObservanceKind.dhammaChakraPravartanDay =>
        l10n?.calendarDhammaChakraDay ?? 'Dhammachakra Pravartan Day',
      BuddhistObservanceKind.bodhiDay => l10n?.calendarBodhiDay ?? 'Bodhi Day',
    };
  }

  String _eventDescription(
    AppLocalizations? l10n,
    BuddhistObservanceKind kind,
  ) {
    return switch (kind) {
      BuddhistObservanceKind.uposathaNewMoon ||
      BuddhistObservanceKind.uposathaFirstQuarter ||
      BuddhistObservanceKind.uposathaFullMoon ||
      BuddhistObservanceKind.uposathaLastQuarter =>
        l10n?.calendarUposathaDescription ??
            'A day for deeper practice, meditation and observing precepts.',
      BuddhistObservanceKind.maghaPuja => l10n?.calendarMaghaDescription ??
          "Remembers the gathering of the Buddha's disciples.",
      BuddhistObservanceKind.parinirvanaDay =>
        l10n?.calendarParinirvanaDescription ??
            "Commemorates the Buddha's final Nibbana.",
      BuddhistObservanceKind.vesak => l10n?.calendarVesakDescription ??
          "Honours the Buddha's birth, awakening and final Nibbana.",
      BuddhistObservanceKind.asalhaPuja => l10n?.calendarAsalhaDescription ??
          "Remembers the Buddha's first teaching.",
      BuddhistObservanceKind.pavarana => l10n?.calendarPavaranaDescription ??
          'Marks the end of the rains retreat.',
      BuddhistObservanceKind.dhammaChakraPravartanDay =>
        l10n?.calendarDhammaChakraDescription ??
            'Commemorates the Buddhist conversion at Deekshabhoomi.',
      BuddhistObservanceKind.bodhiDay => l10n?.calendarBodhiDescription ??
          "Commemorates the Buddha's awakening.",
    };
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
      );
      _selectedDate = _displayedMonth;
    });
  }
}
