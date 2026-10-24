import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/features/superenalotto/data/superenalotto_repository.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/superenalotto_studio.dart';

SuperenalottoDraw _draw(int day, List<int> numbers, {int jolly = 90, int star = 1}) {
  return SuperenalottoDraw(
    date: DateTime.utc(2024, 1, day),
    contestNumber: day,
    numbers: numbers,
    jolly: jolly,
    superstar: star,
    officiallyVerified: false,
  );
}

void main() {
  test('gli algoritmi personalizzati propongono sestina valide dall\'archivio', () {
    final draws = <SuperenalottoDraw>[
      for (var i = 1; i <= 40; i++)
        _draw(
          i,
          [
            1 + (i % 10),
            11 + (i % 10),
            21 + (i % 10),
            31 + (i % 10),
            41 + (i % 10),
            51 + (i % 10),
          ],
          jolly: 70 + (i % 5),
          star: 3 + (i % 7),
        ),
    ];
    final personal = personalizedSuperenalotto(draws, forDrawDay: DateTime.utc(2024, 2, 1));
    expect(personal, isNotEmpty);
    for (final suggestion in personal) {
      expect(suggestion.numbers.length, 6);
      expect(suggestion.numbers.toSet().length, 6);
      expect(seTicketProblem(suggestion.numbers, superstar: suggestion.superstar), isNull);
    }
  });

  test('il riepilogo trend Auto elenca le strategie valutate', () {
    final lines = seAutoTrendLines([
      (origin: 'Auto · Zoppe', match: const SeMatch(hits: 2, jollyMatched: false, superstarMatched: false, category: 'due')),
      (origin: 'Auto · Zoppe', match: const SeMatch(hits: 0, jollyMatched: false, superstarMatched: false, category: 'nessuna')),
      (origin: 'Auto · Ritardi', match: const SeMatch(hits: 3, jollyMatched: false, superstarMatched: false, category: 'tre')),
    ]);
    expect(lines.length, 2);
    expect(lines.first, contains('Auto · Ritardi'));
  });
}
