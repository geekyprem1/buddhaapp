// Buddhist calendar data — Uposath dates and important observances.
//
// Source of truth: docs/important_buddhist_uposath_dates_2026_2030.md
// (2026 BuddhaRashmi Uposath list + full-moon events; 2027–2030 uposath
// dates from astronomical lunar-phase projection). All dates below are
// transcribed directly from that file — do NOT recompute them from lunar
// maths, because the whole point is to match the published list exactly.

/// Moon phase / observance category for an Uposath day.
enum BuddhistObservanceKind {
  uposathaNewMoon, // अमावस्या
  uposathaFirstQuarter, // शुक्ल अष्टमी
  uposathaFullMoon, // पूर्णिमा
  uposathaLastQuarter, // कृष्ण अष्टमी
  fullMoonEvent, // A full-moon Poya day carrying a named event (2026).
}

class BuddhistObservance {
  const BuddhistObservance({
    required this.date,
    required this.kind,
    this.title,
    this.description,
    this.isEstimated = false,
  });

  final DateTime date;
  final BuddhistObservanceKind kind;

  /// Event name for a named full-moon Poya (e.g. "वैशाख / वेसाक पूर्णिमा").
  /// Null for a plain Uposath day.
  final String? title;

  /// Event description for a named full-moon Poya. Null for plain Uposath.
  final String? description;

  /// True for projected (non-2026) dates that may vary by ~1 day.
  final bool isEstimated;

  bool get isFestival => kind == BuddhistObservanceKind.fullMoonEvent;
  bool get isFullMoon =>
      kind == BuddhistObservanceKind.uposathaFullMoon ||
      kind == BuddhistObservanceKind.fullMoonEvent;
}

class BuddhistCalendarService {
  const BuddhistCalendarService();

  List<BuddhistObservance> observancesBetween(DateTime start, DateTime end) {
    final from = _dateOnly(start);
    final through = _dateOnly(end);
    final events = _allObservances
        .where((e) => !e.date.isBefore(from) && !e.date.isAfter(through))
        .toList();
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  /// Upcoming observances to highlight: named full-moon events first, and (so
  /// the list is never empty once 2026's named events pass) any full-moon day.
  List<BuddhistObservance> upcoming(DateTime from, {int count = 8}) {
    final today = _dateOnly(from);
    final future = _allObservances
        .where((e) => e.isFullMoon && !e.date.isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return future.take(count).toList();
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

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // --- Data (transcribed from the MD file) ---

  /// Built once. Combines the plain uposath days for 2026–2030 with the 2026
  /// named full-moon events (which replace the plain full-moon entry on the
  /// same date).
  static final List<BuddhistObservance> _allObservances = _build();

  static List<BuddhistObservance> _build() {
    final out = <BuddhistObservance>[];
    // Dates that carry a named 2026 event — skip the plain uposath entry so we
    // don't duplicate the day.
    final eventDates = {
      for (final e in _events2026) DateTime(e.date.year, e.date.month, e.date.day),
    };
    _uposath.forEach((year, months) {
      final estimated = year != 2026;
      months.forEach((month, entries) {
        for (final entry in entries) {
          final date = DateTime(year, month, entry.$1);
          if (eventDates.contains(date)) continue;
          out.add(
            BuddhistObservance(
              date: date,
              kind: entry.$2,
              isEstimated: estimated,
            ),
          );
        }
      });
    });
    out.addAll(_events2026);
    return out;
  }

  // Phase shorthands.
  static const _nm = BuddhistObservanceKind.uposathaNewMoon; // अमावस्या
  static const _fq = BuddhistObservanceKind.uposathaFirstQuarter; // शुक्ल अष्टमी
  static const _fm = BuddhistObservanceKind.uposathaFullMoon; // पूर्णिमा
  static const _lq = BuddhistObservanceKind.uposathaLastQuarter; // कृष्ण अष्टमी

  /// year -> month -> list of (day, phase). Transcribed from §3–§5 of the MD.
  static const Map<int, Map<int, List<(int, BuddhistObservanceKind)>>>
      _uposath = {
    2026: {
      1: [(3, _fm), (10, _lq), (18, _nm), (26, _fq)],
      2: [(1, _fm), (9, _lq), (17, _nm), (24, _fq)],
      3: [(3, _fm), (11, _lq), (19, _nm), (26, _fq)],
      4: [(2, _fm), (10, _lq), (17, _nm), (24, _fq)],
      5: [(1, _fm), (9, _lq), (16, _nm), (23, _fq), (31, _fm)],
      6: [(8, _lq), (15, _nm), (22, _fq), (29, _fm)],
      7: [(7, _lq), (14, _nm), (21, _fq), (29, _fm)],
      8: [(6, _lq), (12, _nm), (20, _fq), (28, _fm)],
      9: [(4, _lq), (11, _nm), (19, _fq), (26, _fm)],
      10: [(3, _lq), (10, _nm), (18, _fq), (25, _fm)],
      11: [(2, _lq), (9, _nm), (17, _fq), (24, _fm)],
      12: [(1, _lq), (9, _nm), (16, _fq), (23, _fm), (31, _lq)],
    },
    2027: {
      1: [(7, _nm), (15, _fq), (22, _fm), (29, _lq)],
      2: [(6, _nm), (14, _fq), (20, _fm), (28, _lq)],
      3: [(8, _nm), (15, _fq), (22, _fm), (30, _lq)],
      4: [(6, _nm), (13, _fq), (20, _fm), (28, _lq)],
      5: [(6, _nm), (13, _fq), (20, _fm), (28, _lq)],
      6: [(4, _nm), (11, _fq), (19, _fm), (27, _lq)],
      7: [(4, _nm), (10, _fq), (18, _fm), (26, _lq)],
      8: [(2, _nm), (9, _fq), (17, _fm), (25, _lq), (31, _nm)],
      9: [(7, _fq), (15, _fm), (23, _lq), (30, _nm)],
      10: [(7, _fq), (15, _fm), (22, _lq), (29, _nm)],
      11: [(6, _fq), (14, _fm), (21, _lq), (28, _nm)],
      12: [(6, _fq), (13, _fm), (20, _lq), (27, _nm)],
    },
    2028: {
      1: [(5, _fq), (12, _fm), (18, _lq), (26, _nm)],
      2: [(3, _fq), (10, _fm), (17, _lq), (25, _nm)],
      3: [(4, _fq), (11, _fm), (17, _lq), (26, _nm)],
      4: [(2, _fq), (9, _fm), (16, _lq), (24, _nm)],
      5: [(2, _fq), (8, _fm), (16, _lq), (24, _nm), (31, _fq)],
      6: [(7, _fm), (15, _lq), (22, _nm), (29, _fq)],
      7: [(6, _fm), (14, _lq), (22, _nm), (28, _fq)],
      8: [(5, _fm), (13, _lq), (20, _nm), (27, _fq)],
      9: [(3, _fm), (12, _lq), (18, _nm), (25, _fq)],
      10: [(3, _fm), (11, _lq), (18, _nm), (25, _fq)],
      11: [(2, _fm), (9, _lq), (16, _nm), (24, _fq)],
      12: [(2, _fm), (9, _lq), (16, _nm), (23, _fq), (31, _fm)],
    },
    2029: {
      1: [(7, _lq), (14, _nm), (22, _fq), (30, _fm)],
      2: [(5, _lq), (13, _nm), (21, _fq), (28, _fm)],
      3: [(7, _lq), (15, _nm), (23, _fq), (30, _fm)],
      4: [(5, _lq), (13, _nm), (21, _fq), (28, _fm)],
      5: [(5, _lq), (13, _nm), (21, _fq), (27, _fm)],
      6: [(4, _lq), (12, _nm), (19, _fq), (26, _fm)],
      7: [(3, _lq), (11, _nm), (18, _fq), (25, _fm)],
      8: [(2, _lq), (10, _nm), (16, _fq), (24, _fm)],
      9: [(1, _lq), (8, _nm), (15, _fq), (22, _fm), (30, _lq)],
      10: [(7, _nm), (14, _fq), (22, _fm), (30, _lq)],
      11: [(6, _nm), (13, _fq), (21, _fm), (28, _lq)],
      12: [(5, _nm), (12, _fq), (20, _fm), (28, _lq)],
    },
    2030: {
      1: [(4, _nm), (11, _fq), (19, _fm), (26, _lq)],
      2: [(2, _nm), (10, _fq), (18, _fm), (25, _lq)],
      3: [(4, _nm), (12, _fq), (19, _fm), (26, _lq)],
      4: [(2, _nm), (11, _fq), (18, _fm), (24, _lq)],
      5: [(2, _nm), (10, _fq), (17, _fm), (24, _lq)],
      6: [(1, _nm), (9, _fq), (15, _fm), (22, _lq), (30, _nm)],
      7: [(8, _fq), (15, _fm), (22, _lq), (30, _nm)],
      8: [(6, _fq), (13, _fm), (21, _lq), (28, _nm)],
      9: [(4, _fq), (11, _fm), (19, _lq), (27, _nm)],
      10: [(4, _fq), (11, _fm), (19, _lq), (26, _nm)],
      11: [(2, _fq), (10, _fm), (18, _lq), (25, _nm)],
      12: [(1, _fq), (9, _fm), (18, _lq), (24, _nm), (31, _fq)],
    },
  };

  /// 2026 named full-moon events (§2 of the MD), replacing the plain full-moon
  /// entry on the same date.
  static final List<BuddhistObservance> _events2026 = [
    BuddhistObservance(
      date: DateTime(2026, 1, 3),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'दुरुत्थु पूर्णिमा',
      description:
          'भगवान बुद्ध का श्रीलंका में पहली बार आगमन; सुमनसमन देवता को केश धातु का '
          'परित्याग; सुमनसमन देवता का स्रोत सुनकर स्रोतापन्न होना।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 2, 1),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'नवम पूर्णिमा',
      description:
          '1250 भिक्षुओं का प्रथम संघ सम्मेलन; अरहंत सारिपुत्र की अग्र शिष्य पद की '
          'प्राप्ति; महापरिनिर्वाण से तीन माह पूर्व जीवित रहने की आयु का त्याग।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 3, 3),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'मदिन पूर्णिमा',
      description:
          'बुद्धत्व प्राप्ति के पश्चात् 20,000 अरहंत भिक्षुओं के साथ राजगीर से '
          'कपिलवस्तु की यात्रा का आरंभ।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 4, 2),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'बक पूर्णिमा',
      description:
          'बुद्ध का श्रीलंका में दूसरी बार आगमन; चूलोदर और महोदर नागों के विवाद को '
          'शांत करना।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 5, 1),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'वैशाख / वेसाक पूर्णिमा',
      description:
          'सिद्धार्थ बोधिसत्त्व का जन्म; बुद्धत्व की प्राप्ति; महापरिनिर्वाण; '
          'कपिलवस्तु आगमन और यमक महाप्रातिहार्य; श्रीलंका में तीसरी यात्रा; श्रीपाद '
          'पर श्रीचरण पदचिह्न की स्थापना; अरहंत आनंद का परिनिर्वाण; राजकुमार विजय '
          'का श्रीलंका आगमन।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 5, 31),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'वैशाख / वेसाक पूर्णिमा',
      description: 'स्रोत में विशेष बौद्ध घटना नहीं; केवल Uposath Day.',
    ),
    BuddhistObservance(
      date: DateTime(2026, 6, 29),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'पोसोन पूर्णिमा',
      description:
          'अरहंत महेंद्र भंतेजी का अनुराधपुर के मिहिंतले आगमन; राजा देवानंपियतिस्स '
          'सहित लगभग 40,000 लोगों को धम्म-प्रवचन।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 7, 29),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'एसला पूर्णिमा',
      description:
          'सिद्धार्थ बोधिसत्त्व का तुषित देवलोक से महामाया के गर्भ में प्रवेश; '
          'गृहत्याग; प्रथम उपदेश—धम्मचक्कप्पवत्तन सुत्त; राहुल का जन्म; प्रथम '
          'वर्षावास का आरंभ।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 8, 28),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'निकिनी पूर्णिमा',
      description: 'प्रथम धम्म संगीति का आरंभ; आनंद भंतेजी का अरहत्व प्राप्त करना।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 9, 26),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'बिनारा पूर्णिमा',
      description: 'भिक्षुणी संघ का आरंभ।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 10, 25),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'वप पूर्णिमा',
      description:
          'वर्षावास का पवारण दिवस; बुद्ध का तावतिंस देवलोक से संकिसा आगमन; सारिपुत्र '
          'भंतेजी को प्रज्ञावान भिक्षुओं में अग्र पद।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 11, 24),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'इल पूर्णिमा',
      description:
          'बुद्ध द्वारा 60 अरहंत भिक्षुओं को धम्मदूत के रूप में भेजना; सारिपुत्र '
          'भंतेजी का परिनिर्वाण; उरुवेला के तीन जटिलों को दमन करने हेतु बुद्ध का आगमन।',
    ),
    BuddhistObservance(
      date: DateTime(2026, 12, 23),
      kind: BuddhistObservanceKind.fullMoonEvent,
      title: 'उन्दुवप पूर्णिमा',
      description:
          'सम्राट अशोक की पुत्री अरहंत संघमित्रा भिक्षुणी द्वारा बोधिवृक्ष को '
          'श्रीलंका लाना।',
    ),
  ];
}
