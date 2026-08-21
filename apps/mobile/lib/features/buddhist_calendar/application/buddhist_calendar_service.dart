enum BuddhistObservanceKind {
  uposathaNewMoon,
  uposathaFirstQuarter,
  uposathaFullMoon,
  uposathaLastQuarter,
  maghaPuja,
  parinirvanaDay,
  vesak,
  asalhaPuja,
  pavarana,
  dhammaChakraPravartanDay,
  bodhiDay,
}

class BuddhistObservance {
  const BuddhistObservance({
    required this.date,
    required this.kind,
    required this.isFestival,
    required this.isEstimated,
  });

  final DateTime date;
  final BuddhistObservanceKind kind;
  final bool isFestival;
  final bool isEstimated;
}

class BuddhistCalendarService {
  const BuddhistCalendarService();

  static final DateTime _newMoonEpoch = DateTime.utc(2000, 1, 6, 18, 14);
  static const double _synodicMonthDays = 29.530588853;
  static const double _quarterMilliseconds = _synodicMonthDays * 86400000 / 4;

  List<BuddhistObservance> observancesBetween(
    DateTime start,
    DateTime end,
  ) {
    final from = _dateOnly(start);
    final through = _dateOnly(end);
    final events = <BuddhistObservance>[
      ..._lunarObservances(from, through),
      ..._festivalObservances(from, through),
    ];
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  List<BuddhistObservance> upcoming(
    DateTime from, {
    int count = 8,
  }) {
    final today = _dateOnly(from);
    return observancesBetween(today, today.add(const Duration(days: 400)))
        .take(count)
        .toList();
  }

  List<BuddhistObservance> onDate(
    DateTime date,
    Iterable<BuddhistObservance> events,
  ) {
    return events.where((event) => isSameDate(event.date, date)).toList();
  }

  List<DateTime> monthGrid(DateTime month) {
    final first = DateTime(month.year, month.month);
    final leadingDays = first.weekday - DateTime.monday;
    final gridStart = first.subtract(Duration(days: leadingDays));
    return List.generate(42, (index) => gridStart.add(Duration(days: index)));
  }

  List<BuddhistObservance> _lunarObservances(
    DateTime start,
    DateTime end,
  ) {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final delta = startUtc.difference(_newMoonEpoch).inMilliseconds;
    var index = (delta / _quarterMilliseconds).floor() - 2;
    final events = <BuddhistObservance>[];

    while (true) {
      final instant = _newMoonEpoch.add(
        Duration(milliseconds: (index * _quarterMilliseconds).round()),
      );
      final local = instant.toLocal();
      final date = DateTime(local.year, local.month, local.day);
      if (date.isAfter(end)) break;
      if (!date.isBefore(start)) {
        events.add(
          BuddhistObservance(
            date: date,
            kind: _phaseKind(index),
            isFestival: false,
            isEstimated: true,
          ),
        );
      }
      index++;
    }
    return events;
  }

  BuddhistObservanceKind _phaseKind(int index) {
    final phase = ((index % 4) + 4) % 4;
    return switch (phase) {
      0 => BuddhistObservanceKind.uposathaNewMoon,
      1 => BuddhistObservanceKind.uposathaFirstQuarter,
      2 => BuddhistObservanceKind.uposathaFullMoon,
      _ => BuddhistObservanceKind.uposathaLastQuarter,
    };
  }

  List<BuddhistObservance> _festivalObservances(
    DateTime start,
    DateTime end,
  ) {
    final events = <BuddhistObservance>[];
    for (var year = start.year - 1; year <= end.year + 1; year++) {
      events.addAll([
        _lunarFestival(year, 2, BuddhistObservanceKind.maghaPuja),
        BuddhistObservance(
          date: DateTime(year, 2, 15),
          kind: BuddhistObservanceKind.parinirvanaDay,
          isFestival: true,
          isEstimated: false,
        ),
        _lunarFestival(year, 5, BuddhistObservanceKind.vesak),
        _lunarFestival(year, 7, BuddhistObservanceKind.asalhaPuja),
        _lunarFestival(year, 10, BuddhistObservanceKind.pavarana),
        BuddhistObservance(
          date: DateTime(year, 10, 14),
          kind: BuddhistObservanceKind.dhammaChakraPravartanDay,
          isFestival: true,
          isEstimated: false,
        ),
        BuddhistObservance(
          date: DateTime(year, 12, 8),
          kind: BuddhistObservanceKind.bodhiDay,
          isFestival: true,
          isEstimated: false,
        ),
      ]);
    }
    return events
        .where(
            (event) => !event.date.isBefore(start) && !event.date.isAfter(end))
        .toList();
  }

  BuddhistObservance _lunarFestival(
    int year,
    int month,
    BuddhistObservanceKind kind,
  ) {
    final first = DateTime(year, month);
    final last = DateTime(year, month + 1, 0);
    final fullMoon = _lunarObservances(first, last).firstWhere(
      (event) => event.kind == BuddhistObservanceKind.uposathaFullMoon,
      orElse: () => BuddhistObservance(
        date: DateTime(year, month, 15),
        kind: BuddhistObservanceKind.uposathaFullMoon,
        isFestival: false,
        isEstimated: true,
      ),
    );
    return BuddhistObservance(
      date: fullMoon.date,
      kind: kind,
      isFestival: true,
      isEstimated: true,
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
