// test/superenalotto_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/database/app_database.dart';
import 'package:lotto_intelligence/features/superenalotto/data/superenalotto_parser.dart';
import 'package:lotto_intelligence/features/superenalotto/data/superenalotto_repository.dart';

void main() {
  const row = '''
<tr class="superenalotto-extraction-archive__details__table__row  ">
  <td>Concorso <strong>Nº 168</strong> del <strong>20 Ottobre 2026</strong></td>
  <td><div class="superenalotto-extraction-archive__details__table__combination"><span class="superenalotto-extraction-archive__details__table__combination__text">13</span></div>
      <div class="superenalotto-extraction-archive__details__table__combination"><span class="superenalotto-extraction-archive__details__table__combination__text">25</span></div>
      <div class="superenalotto-extraction-archive__details__table__combination"><span class="superenalotto-extraction-archive__details__table__combination__text">37</span></div>
      <div class="superenalotto-extraction-archive__details__table__combination"><span class="superenalotto-extraction-archive__details__table__combination__text">45</span></div>
      <div class="superenalotto-extraction-archive__details__table__combination"><span class="superenalotto-extraction-archive__details__table__combination__text">50</span></div>
      <div class="superenalotto-extraction-archive__details__table__combination"><span class="superenalotto-extraction-archive__details__table__combination__text">70</span></div>
  </td>
  <td><div class="superenalotto-extraction-archive__details__table__jolly"><span class="superenalotto-extraction-archive__details__table__jolly__text">8</span></div></td>
  <td><div class="superenalotto-extraction-archive__details__table__superstar"><span class="superenalotto-extraction-archive__details__table__superstar__text">49</span></div></td>
</tr>
''';

  test('legge la tabella ufficiale', () {
    final parsed = parseSuperenalottoArchiveHtml(row);
    expect(parsed, hasLength(1));
    expect(parsed.single.isValid, isTrue);
    expect(parsed.single.contestNumber, 168);
    expect(parsed.single.date, DateTime.utc(2026, 10, 20));
    expect(parsed.single.numbers, [13, 25, 37, 45, 50, 70]);
    expect(parsed.single.jolly, 8);
    expect(parsed.single.superstar, 49);
  });

  test('rifiuta una sestina con il Jolly ripetuto', () {
    final broken = row.replaceAll('jolly__text">8', 'jolly__text">13');
    final parsed = parseSuperenalottoArchiveHtml(broken);
    expect(parsed.single.isValid, isFalse);
  });

  test('importa il concorso una sola volta e non sovrascrive un conflitto', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = SuperenalottoRepository(db);
    final parsed = parseSuperenalottoArchiveHtml(row);
    final first = await repository.importParsed(draws: parsed, provenance: 'test');
    final second = await repository.importParsed(draws: parsed, provenance: 'test');
    expect(first.inserted, 1);
    expect(second.duplicates, 1);
    final changed = parseSuperenalottoArchiveHtml(row.replaceAll('superstar__text">49', 'superstar__text">1'));
    final third = await repository.importParsed(draws: changed, provenance: 'test');
    expect(third.conflicts, 1);
    final stored = await repository.latest();
    expect(stored.single.superstar, 49);
    expect(stored.single.officiallyVerified, isFalse);
  });
}
