// test/se_studio_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/database/app_database.dart';
import 'package:lotto_intelligence/features/superenalotto/data/se_ticket_repository.dart';
import 'package:lotto_intelligence/features/superenalotto/data/superenalotto_parser.dart';
import 'package:lotto_intelligence/features/superenalotto/data/superenalotto_repository.dart';
import 'package:lotto_intelligence/features/superenalotto/domain/superenalotto_studio.dart';

void main() {
  SuperenalottoDraw draw({
    required int contest,
    required List<int> numbers,
    int jolly = 7,
    int superstar = 8,
  }) {
    return SuperenalottoDraw(
      date: DateTime.utc(2026, 1, contest),
      contestNumber: contest,
      numbers: numbers,
      jolly: jolly,
      superstar: superstar,
      officiallyVerified: false,
    );
  }

  test('cinque + Jolly quando il sesto numero è il Jolly', () {
    final match = matchSuperenalotto(
      played: const [1, 2, 3, 4, 5, 9],
      superstar: 7,
      drawn: const [1, 2, 3, 4, 5, 8],
      jolly: 9,
      drawnSuperstar: 7,
    );
    expect(match.category, 'cinque_jolly');
    expect(match.hits, 5);
    expect(match.jollyMatched, isTrue);
    expect(match.superstarMatched, isTrue);
    expect(match.label, 'Cinque + Jolly');
  });

  test('cinque senza Jolly non sale di categoria', () {
    final match = matchSuperenalotto(
      played: const [1, 2, 3, 4, 5, 9],
      drawn: const [1, 2, 3, 4, 5, 8],
      jolly: 10,
      drawnSuperstar: 1,
    );
    expect(match.category, 'cinque');
    expect(match.superstarMatched, isFalse);
  });

  test('lo Zoppe da sei propone anche Jolly e SuperStar', () {
    final draws = [
      for (var contest = 1; contest <= 90; contest++)
        draw(
          contest: contest,
          numbers: [
            ((contest) % 90) + 1,
            ((contest + 7) % 90) + 1,
            ((contest + 19) % 90) + 1,
            ((contest + 31) % 90) + 1,
            ((contest + 47) % 90) + 1,
            ((contest + 61) % 90) + 1,
          ],
          jolly: contest.isEven ? 77 : 88,
          superstar: contest % 3 == 0 ? 12 : 34,
        ),
    ];
    final suggestions = suggestSuperenalotto(draws, seed: 5);
    expect(suggestions.any((item) => item.name.contains('Zoppe')), isTrue);
    final zoppe = suggestions.firstWhere((item) => item.name.contains('Zoppe'));
    expect(zoppe.numbers, hasLength(6));
    expect(zoppe.jolly, isNotNull);
    expect(zoppe.numbers.contains(zoppe.jolly), isFalse);
    expect(zoppe.superstar, isNotNull);
    expect(zoppe.jollyHow, contains('Jolly'));
    expect(zoppe.superstarHow, contains('SuperStar'));
  });

  test('il ritardo guarda solo i sei numeri', () {
    final draws = [
      draw(contest: 1, numbers: const [1, 2, 3, 4, 5, 6], jolly: 1),
      draw(contest: 2, numbers: const [2, 3, 4, 5, 6, 7]),
      draw(contest: 3, numbers: const [2, 3, 4, 5, 6, 8]),
    ];
    final stats = superenalottoStats(draws);
    expect(stats[0].delay, 2);
    expect(stats[1].delay, 0);
    expect(stats[8].delay, 3);
    expect(stats[8].neverSeen, isTrue);
    final suggestions = suggestSuperenalotto(draws);
    expect(suggestions, isEmpty);
  });

  test('la schedina si chiude sulla categoria del concorso, senza importi', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const row = '''
<tr class="superenalotto-extraction-archive__details__table__row">
  <td>Concorso <strong>Nº 10</strong> del <strong>10 Ottobre 2026</strong></td>
  <td>
    <span class="combination__text">1</span>
    <span class="combination__text">2</span>
    <span class="combination__text">3</span>
    <span class="combination__text">4</span>
    <span class="combination__text">5</span>
    <span class="combination__text">6</span>
  </td>
  <td><span class="jolly__text">9</span></td>
  <td><span class="superstar__text">8</span></td>
</tr>
''';
    await SuperenalottoRepository(db).importParsed(draws: parseSuperenalottoArchiveHtml(row), provenance: 'test');
    final tickets = SeTicketRepository(db);
    await tickets.add(
      numbers: const [1, 2, 3, 4, 5, 9],
      superstar: 8,
      origin: 'test',
      now: DateTime(2026, 10, 10, 9),
    );
    expect(await tickets.evaluateOpen(), 1);
    final stored = await tickets.list();
    expect(stored.single.isOpen, isFalse);
    expect(stored.single.match!.category, 'cinque_jolly');
    expect(stored.single.match!.superstarMatched, isTrue);
    expect(stored.single.contestNumber, 10);
    expect(await tickets.evaluateOpen(), 0);
  });
}
