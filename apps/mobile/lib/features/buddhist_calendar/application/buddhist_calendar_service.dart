// Buddhist calendar data — Uposath dates and important observances.
//
// Source of truth: docs/Notes_260904_204424.pdf (BuddhaRashmi 2026 Uposath list)
// + docs/important_buddhist_uposath_dates_2026_2030.md (2027–2030 astronomical).
//
// All 2026 titles and descriptions are transcribed EXACTLY from the PDF.
// Do NOT rename the events or add Poya/month names — PDF uses only
// "पूर्णिमा", "कृष्ण अष्टमी", "अमावस्या", "शुक्ल अष्टमी".

/// Moon phase category for an Uposath day.
enum UposathPhase {
  fullMoon, // पूर्णिमा
  lastQuarter, // कृष्ण अष्टमी
  newMoon, // अमावस्या
  firstQuarter, // शुक्ल अष्टमी
}

class BuddhistObservance {
  const BuddhistObservance({
    required this.date,
    required this.phase,
    this.specialEvents,
    this.isEstimated = false,
  });

  final DateTime date;
  final UposathPhase phase;

  /// Numbered special events for a full-moon day (e.g. the January poornima
  /// has 3 events from the PDF). Null for plain uposath days.
  final List<String>? specialEvents;

  /// True for projected (non-2026) dates that may vary by ~1 day.
  final bool isEstimated;

  bool get hasSpecialEvents =>
      specialEvents != null && specialEvents!.isNotEmpty;

  /// Display title — exactly as the PDF names each phase.
  String get title => switch (phase) {
        UposathPhase.fullMoon => 'पूर्णिमा',
        UposathPhase.lastQuarter => 'कृष्ण अष्टमी',
        UposathPhase.newMoon => 'अमावस्या',
        UposathPhase.firstQuarter => 'शुक्ल अष्टमी',
      };

  /// The common uposath paragraph from the PDF, phrased per-phase.
  String get uposathDescription {
    final phase = switch (this.phase) {
      UposathPhase.fullMoon => 'पूर्णिमा',
      UposathPhase.lastQuarter => 'अष्टमी',
      UposathPhase.newMoon => 'अमावस्या',
      UposathPhase.firstQuarter => 'अष्टमी',
    };
    return 'भगवान बुद्ध के समय में उनके मार्ग पर चलने वाले $phase के दिन '
        'अष्टांग उपोसथ शील धारण करते थे एवं अपने जीवन में अप्रमाण पुण्य जमा करते '
        'थे। यह उपोसथ शील अत्यंत उत्तम एवं निर्मल है। इसे पालन करने से मन में '
        'प्रसन्नता जागती है एवं शोक दूर होता है। अरहन्त मुनि लोगों का अनुसरण करते '
        'हुए यह उपोसथ शील पालन किया जाता है।';
  }
}

class BuddhistCalendarService {
  const BuddhistCalendarService();

  List<BuddhistObservance> observancesBetween(DateTime start, DateTime end) {
    final from = _dateOnly(start);
    final through = _dateOnly(end);
    return _allObservances
        .where((e) => !e.date.isBefore(from) && !e.date.isAfter(through))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Observances in the displayed month only (for "This month" section).
  List<BuddhistObservance> thisMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    return observancesBetween(first, last);
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

  // ─── Data ───

  static final List<BuddhistObservance> _allObservances = _build();

  static List<BuddhistObservance> _build() {
    final out = <BuddhistObservance>[];
    // 2026 events replace plain entries on the same date.
    final eventDates = <String>{
      for (final e in _events2026) '${e.date.year}-${e.date.month}-${e.date.day}',
    };
    _uposath.forEach((year, months) {
      final estimated = year != 2026;
      months.forEach((month, entries) {
        for (final entry in entries) {
          final key = '$year-$month-${entry.$1}';
          if (eventDates.contains(key)) continue;
          out.add(BuddhistObservance(
            date: DateTime(year, month, entry.$1),
            phase: entry.$2,
            isEstimated: estimated,
          ));
        }
      });
    });
    out.addAll(_events2026);
    return out;
  }

  // Phase shorthands.
  static const _nm = UposathPhase.newMoon;
  static const _fq = UposathPhase.firstQuarter;
  static const _fm = UposathPhase.fullMoon;
  static const _lq = UposathPhase.lastQuarter;

  /// year -> month -> list of (day, phase).
  static const Map<int, Map<int, List<(int, UposathPhase)>>> _uposath = {
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

  /// 2026 full-moon days with special events from the PDF.
  static final List<BuddhistObservance> _events2026 = [
    BuddhistObservance(
      date: DateTime(2026, 1, 3),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'बुद्धत्व प्राप्ति के आठ महीने पश्चात् मह्यंगन नामक स्थान पर भगवान बुद्ध का पहली बार श्रीलंका में आगमन, जहाँ आज एक पूजनीय स्तूप है।',
        'भगवान बुद्ध द्वारा सुमनसमन नामक देवता को केश धातु का परित्याग।',
        'भगवान बुद्ध का ज्ञान सुनकर श्रीलंका के सुमनसमन देवता का स्रोतापन्न होना।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 2, 1),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'भगवान बुद्ध द्वारा 1250 भिक्षुओं का प्रथम संघ सम्मेलन।',
        'अरहन्त सारिपुत्र की अग्र शिष्य पद की प्राप्ति।',
        'भगवान बुद्ध द्वारा महापरिनिर्वाण से तीन माह पूर्व जीवित रहने की आयु का त्याग करना।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 3, 3),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'बुद्धत्व प्राप्ति के पश्चात् 20,000 अरहन्त भिक्षुओं के साथ राजगीर से कपिलवस्तु के लिए यात्रा का आरंभ।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 4, 2),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'बुद्धत्व प्राप्ति के 5 वर्ष पश्चात् भगवान बुद्ध का श्रीलंका में दूसरी बार आगमन, चूलोदर एवं महोदर नामक दिव्य नागों के मध्य मणि से निर्मित सिंहासन को लेकर हुए कलह में युद्ध को शांत करने हेतु।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 5, 1),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'सिद्धार्थ बोधिसत्त्व का मनुष्य लोक में आगमन (जन्म)।',
        'सिद्धार्थ बोधिसत्त्व की बुद्धत्व प्राप्ति (सम्बुद्धत्व)।',
        'भगवान बुद्ध का महापरिनिर्वाण।',
        'बुद्धत्व के पश्चात् कपिलवस्तु में आगमन एवं शाक्यों के अहंकार को खंडित करने हेतु यमक महाप्रातिहार्य का प्रदर्शन।',
        'बुद्धत्व के 8 वर्ष पश्चात् भगवान बुद्ध का तीसरी बार श्रीलंका में आगमन।',
        'श्रीलंका के श्रीपाद पर्वत के शिखर पर भगवान बुद्ध द्वारा श्रीचरण के पदचिह्न स्थापित करना।',
        'अरहन्त आनन्द भन्ते जी का परिनिर्वाण।',
        'राजकुमार विजय का श्रीलंका द्वीप में आगमन एवं सिंहली जाति की शुरुआत।',
      ],
    ),
    // May 31 — second poornima, no special event per PDF.
    BuddhistObservance(
      date: DateTime(2026, 5, 31),
      phase: UposathPhase.fullMoon,
    ),
    BuddhistObservance(
      date: DateTime(2026, 6, 29),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'श्रीलंका में भगवान बुद्ध के धर्म को स्थापित करने हेतु अरहन्त महेन्द्र भन्ते जी का श्रीलंका के अनुराधपुर में मिहिन्तले स्थान पर आगमन।',
        'श्रीलंका के राजा देवानंपियतिस्स सहित 40,000 लोगों को अरहन्त महेन्द्र भन्ते जी द्वारा चुल्लहत्थिपदोपम सूत्र का धर्म प्रवचन।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 7, 29),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'सिद्धार्थ बोधिसत्त्व का तुषित देवलोक से देवी महामाया के गर्भ में प्रवेश।',
        'सिद्धार्थ बोधिसत्त्व का मुक्ति हेतु गृहत्याग।',
        'भगवान बुद्ध द्वारा वाराणसी में पंच भिक्षुओं को प्रथम उपदेश — धम्मचक्कप्पवत्तन सूत्र — का प्रवचन।',
        'राहुल कुमार का जन्म।',
        'भगवान बुद्ध सहित पंच भिक्षुओं का प्रथम वर्षावास वाराणसी के ऋषिपतन मृगदाय (वर्तमान सारनाथ) में।',
        'भिक्षुओं के वर्षावास का आरंभ दिवस।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 8, 28),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'प्रथम धम्म संगीति का आरंभ अगस्त महीने की पूर्णिमा से हुआ था।',
        'भगवान बुद्ध के अग्र सेवक आनन्द भन्ते जी का अर्हत्व पाना।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 9, 26),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'भिक्षुणी संघ का आरंभ।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 10, 25),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'वर्षावास का पवारण दिवस।',
        'भगवान बुद्ध का तावतिंस देवलोक से धरती पर संकिस्सा नामक स्थान पर पधारना।',
        'अरहन्त सारिपुत्र भन्ते जी को प्रज्ञावान भिक्षुओं में अग्र पद की प्राप्ति।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 11, 24),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'भगवान बुद्ध द्वारा साठ अरहन्त भिक्षुओं को धर्मदूत के रूप में लोकजन के कल्याण हेतु धर्म प्रचार के लिए आदेश देना।',
        'अरहन्त सारिपुत्र भन्ते जी का परिनिर्वाण।',
        'उरुवेला (बोधगया) के तीन जटिलों को दमन करने के लिए भगवान बुद्ध का उरुवेला में आगमन।',
      ],
    ),
    BuddhistObservance(
      date: DateTime(2026, 12, 23),
      phase: UposathPhase.fullMoon,
      specialEvents: [
        'सम्राट अशोक की पुत्री अरहन्त संघमित्रा भिक्षुणी द्वारा बोधिवृक्ष को श्रीलंका में लाना।',
      ],
    ),
  ];
}
