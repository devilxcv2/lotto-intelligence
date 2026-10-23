// test/wallet_test.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_intelligence/core/background/evening_sync.dart';
import 'package:lotto_intelligence/core/database/app_database.dart';
import 'package:lotto_intelligence/core/lotto/archive_parser.dart';
import 'package:lotto_intelligence/core/lotto/freshness.dart';
import 'package:lotto_intelligence/core/lotto/prize_table.dart';
import 'package:lotto_intelligence/core/settings/app_settings.dart';
import 'package:lotto_intelligence/core/settings/settings_repository.dart';
import 'package:lotto_intelligence/features/draws/data/draw_repository.dart';
import 'package:lotto_intelligence/features/virtual_wallet/data/wallet_repository.dart';

void main() {
  group('tabella premi ufficiale', () {
    test('coefficienti per 1 euro con i soli numeri della sorte', () {
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.estratto, numbersPlayed: 1), 1123);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.ambo, numbersPlayed: 2), 25000);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.terno, numbersPlayed: 3), 450000);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.quaterna, numbersPlayed: 4), 12000000);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.cinquina, numbersPlayed: 5), 600000000);
    });

    test('con più numeri il premio si divide per le combinazioni (tabella lotto-italia.it)', () {
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.estratto, numbersPlayed: 3), 374);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.ambo, numbersPlayed: 3), 8333);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.estratto, numbersPlayed: 5), 225);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.ambo, numbersPlayed: 5), 2500);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.terno, numbersPlayed: 5), 45000);
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.quaterna, numbersPlayed: 5), 2400000);
      // 250 / 45 = 5,5556 → arrotondato al centesimo.
      expect(tablePrizeCentsPerEuro(sorte: LottoSorte.ambo, numbersPlayed: 10), 556);
    });

    test('più centri pagano più combinazioni, TUTTE divide per 10, ritenuta 8%', () {
      // Terno con 5 numeri e 4 centri: 4 terni vincenti su 10 possibili.
      expect(grossPrizeCents(sorte: LottoSorte.terno, numbersPlayed: 5, hits: 4, stakeCents: 100), 180000);
      // Ambo con 2 centri su 2 numeri giocati su tutte le ruote: 25 €.
      expect(grossPrizeCents(sorte: LottoSorte.ambo, numbersPlayed: 2, hits: 2, stakeCents: 100, wheelsCovered: 10), 2500);
      expect(grossPrizeCents(sorte: LottoSorte.ambo, numbersPlayed: 5, hits: 1, stakeCents: 100), 0);
      expect(netFromGrossCents(25000), 23000);
      expect(applyTicketCap(700000000), maxTicketWinCents);
      expect(stakeProblem(50), isNotNull);
      expect(stakeProblem(20050), isNotNull);
      expect(stakeProblem(125), isNotNull);
      expect(stakeProblem(150), isNull);
    });

    test('valutazione di una schedina su una ruota e su tutte', () {
      final single = evaluateTicket(
        played: [5, 17, 42, 61, 88],
        stakes: {LottoSorte.ambo: 100, LottoSorte.terno: 100},
        drawnByWheel: {
          'BA': [5, 17, 42, 1, 2],
        },
      );
      expect(single.bestHits, 3);
      // Ambo su 5 numeri con 3 centri: 3 ambi × 25 € = 75 €. Terno: 450 €.
      expect(single.grossCents, 7500 + 45000);
      expect(single.netCents, ((7500 + 45000) * 0.92).round());
      expect(single.stakeCents, 200);

      final all = evaluateTicket(
        played: [5, 17],
        stakes: {LottoSorte.ambo: 100},
        drawnByWheel: {
          for (var i = 0; i < 10; i++) 'W$i': i == 3 ? [5, 17, 20, 30, 40] : [50, 60, 70, 80, 90],
        },
      );
      expect(all.bestHits, 2);
      expect(all.grossCents, 2500);
    });

    test('what-if elenca solo le sorti giocabili con quei numeri', () {
      final rows = whatIfBySorte(numbersPlayed: 3, hitsByWheel: {'BA': 2}, stakeCents: 100);
      expect(rows.map((r) => r.sorte), [LottoSorte.estratto, LottoSorte.ambo, LottoSorte.terno]);
      // 11,233 × 2 / 3 = 7,4887 → arrotondato sul totale, non per combinazione.
      expect(rows[0].grossCents, 749);
      expect(rows[1].grossCents, 8333);
      expect(rows[2].grossCents, 0);
    });
  });

  group('calendario delle giocate', () {
    test('prossimo concorso aperto rispetta la chiusura delle 19:30', () {
      // Sabato 10 ottobre 2026 alle 10:00 locali → stesso giorno.
      final saturdayMorning = DateTime(2026, 10, 10, 10);
      expect(nextOpenDrawDate(saturdayMorning), DateTime.utc(2026, 10, 10));
      // Sabato alle 19:45 → martedì 13.
      expect(nextOpenDrawDate(DateTime(2026, 10, 10, 19, 45)), DateTime.utc(2026, 10, 13));
      // Domenica → martedì.
      expect(nextOpenDrawDate(DateTime(2026, 10, 11, 12)), DateTime.utc(2026, 10, 13));
      // Mercoledì → giovedì.
      expect(nextOpenDrawDate(DateTime(2026, 10, 14, 12)), DateTime.utc(2026, 10, 15));
    });

    test('il controllo serale cade alle 20:15 del prossimo giorno di estrazione', () {
      expect(EveningSync.nextCheckTime(DateTime(2026, 10, 10, 10)), DateTime(2026, 10, 10, 20, 15));
      expect(EveningSync.nextCheckTime(DateTime(2026, 10, 10, 21)), DateTime(2026, 10, 13, 20, 15));
      expect(EveningSync.nextCheckTime(DateTime(2026, 10, 11, 8)), DateTime(2026, 10, 13, 20, 15));
    });

    test('il promemoria pre-estrazione cade alle 19:00 del giorno di estrazione', () {
      expect(EveningSync.nextPreDrawTime(DateTime(2026, 10, 10, 10)), DateTime(2026, 10, 10, 19));
      expect(EveningSync.nextPreDrawTime(DateTime(2026, 10, 10, 19, 1)), DateTime(2026, 10, 13, 19));
      expect(drawEveningPhase(DateTime(2026, 10, 10, 19, 0)), DrawEveningPhase.closingSoon);
      expect(drawEveningPhase(DateTime(2026, 10, 10, 20, 0)), DrawEveningPhase.waitingResults);
      expect(drawEveningPhase(DateTime(2026, 10, 10, 12)), DrawEveningPhase.none);
    });
  });

  group('schedine ipotetiche', () {
    test('registrazione, valutazione automatica e riepilogo', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final wallet = WalletRepository(db);
      final draws = DrawRepository(db);
      final created = DateTime(2026, 10, 8, 10); // giovedì mattina → concorso dell'8/10
      final id = await wallet.addTicket(
        TicketDraft(wheelCode: 'BA', numbers: [5, 17, 42, 61, 88], stakes: {LottoSorte.ambo: 100, LottoSorte.terno: 50}),
        now: created,
      );
      final allWheels = await wallet.addTicket(
        TicketDraft(wheelCode: allWheelsCode, numbers: [5, 17], stakes: {LottoSorte.ambo: 100}),
        now: created,
      );
      expect(await wallet.evaluateOpenTickets(), isEmpty, reason: 'estrazione non ancora in archivio');

      await draws.importParsed(
        draws: parseOfficialArchiveText('2026/10/08\tBA\t5\t17\t42\t1\t2\n').draws,
        sourceCode: 'lotto_italia_archive',
        provenance: 'fixture',
      );
      final evaluated = await wallet.evaluateOpenTickets();
      expect(evaluated.map((t) => t.id), [id], reason: 'TUTTE aspetta le dieci ruote');
      final ticket = evaluated.single;
      expect(ticket.evaluation!.hits, 3);
      expect(ticket.evaluation!.grossCents, 7500 + 22500);
      expect(ticket.evaluation!.drawDate, DateTime.utc(2026, 10, 8));
      expect(ticket.status, 'evaluated');

      // Seconda chiamata: niente doppia valutazione.
      expect(await wallet.evaluateOpenTickets(), isEmpty);

      final summary = await wallet.summary();
      expect(summary.openCount, 1);
      expect(summary.evaluatedCount, 1);
      expect(summary.stakedCents, 150);
      expect(summary.netCents, (30000 * 0.92).round());
      expect(summary.timeline, hasLength(1));

      final rows = StringBuffer();
      for (final wheel in ['BA', 'CA', 'FI', 'GE', 'MI', 'NA', 'PA', 'RM', 'TO', 'VE']) {
        rows.writeln('2026/10/08\t$wheel\t${wheel == 'MI' ? '5\t17' : '3\t4'}\t50\t60\t70');
      }
      await draws.importParsed(
        draws: parseOfficialArchiveText(rows.toString()).draws,
        sourceCode: 'lotto_italia_archive',
        provenance: 'fixture',
      );
      final second = await wallet.evaluateOpenTickets();
      expect(second.map((t) => t.id), [allWheels]);
      // Bari conserva la cinquina già archiviata (5, 17, …): due ambi su due
      // ruote, ciascuno pagato un decimo di 250 €.
      expect(second.single.evaluation!.hitsByWheel['MI'], 2);
      expect(second.single.evaluation!.hitsByWheel['BA'], 2);
      expect(second.single.evaluation!.grossCents, 5000, reason: 'ambo su TUTTE paga un decimo per ruota');
    });

    test('la bozza rifiuta poste e numeri fuori regola', () {
      expect(const TicketDraft(wheelCode: 'BA', numbers: [], stakes: {LottoSorte.ambo: 100}).problem(), isNotNull);
      expect(const TicketDraft(wheelCode: 'BA', numbers: [1], stakes: {LottoSorte.ambo: 100}).problem(), contains('ambo'));
      expect(const TicketDraft(wheelCode: 'BA', numbers: [1, 2], stakes: {LottoSorte.ambo: 75}).problem(), contains('0,50'));
      expect(const TicketDraft(wheelCode: 'BA', numbers: [1, 2], stakes: {LottoSorte.ambo: 50}).problem(), contains('minima'));
      expect(const TicketDraft(wheelCode: 'XX', numbers: [1, 2], stakes: {LottoSorte.ambo: 100}).problem(), contains('Ruota'));
      expect(const TicketDraft(wheelCode: 'BA', numbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], stakes: {LottoSorte.ambo: 100}).problem(), contains('massimo'));
      expect(const TicketDraft(wheelCode: 'TUTTE', numbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], stakes: {LottoSorte.cinquina: 100}).problem(), isNull);
    });

    test('migrazione dallo schema 1: le schedine vecchie restano leggibili', () async {
      final fixture = File('test/fixtures/schema_v1.sqlite');
      expect(fixture.existsSync(), isTrue);
      final copy = File('${Directory.systemTemp.path}/lotto_schema_v1_${DateTime.now().microsecondsSinceEpoch}.sqlite');
      fixture.copySync(copy.path);
      addTearDown(() => copy.deleteSync());
      final db = AppDatabase(NativeDatabase(copy));
      addTearDown(db.close);
      final wallet = WalletRepository(db);
      final tickets = await wallet.list();
      expect(tickets, hasLength(1));
      expect(tickets.single.isLegacy, isTrue);
      expect(tickets.single.numbers, [5, 17, 20, 30, 40]);
      expect(tickets.single.evaluation!.hits, 2);
      expect(tickets.single.balanceCents, isNull);
      // Lo schema 4 accetta 10 numeri, le poste per sorte, i concorsi e le schedine SuperEnalotto.
      final id = await wallet.addTicket(
        TicketDraft(wheelCode: 'RM', numbers: List.generate(10, (i) => i + 1), stakes: {LottoSorte.estratto: 100}),
      );
      final stored = (await wallet.list()).firstWhere((t) => t.id == id);
      expect(stored.numbers, hasLength(10));
      expect(stored.stakes[LottoSorte.estratto], 100);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 4);
      final summary = await wallet.summary();
      expect(summary.legacyCount, 1);
    });
  });

  group('aggiornamento serale', () {
    test('scarica, importa, valuta le schedine e segnala la nuova estrazione', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await SettingsRepository(db).save(AppSettings.initial.copyWith(liveSyncEnabled: true, onboardingCompleted: true));
      final wallet = WalletRepository(db);
      final created = DateTime(2026, 10, 10, 9); // sabato mattina → concorso del 10/10
      await wallet.addTicket(
        TicketDraft(wheelCode: 'BA', numbers: [11, 22, 33], stakes: {LottoSorte.ambo: 200}),
        now: created,
      );
      final dio = Dio()..httpClientAdapter = _ZipAdapter('2026/10/10\tBA\t11\t22\t70\t80\t90\n2026/10/10\tRM\t1\t2\t3\t4\t5\n');
      final result = await EveningSync.runOnce(db: db, dio: dio, now: DateTime(2026, 10, 10, 20, 15), notifications: null);
      expect(result.newDrawDate, DateTime.utc(2026, 10, 10));
      expect(result.evaluatedTickets, 1);
      expect(result.retry, isFalse);
      final tickets = await wallet.list();
      expect(tickets.single.evaluation!.hits, 2);
      // Ambo su 3 numeri con 2 €: 2 × 250 / 3 = 166,67 €.
      expect(tickets.single.evaluation!.grossCents, 16667);

      // Stessa sera, nessuna novità: niente nuova estrazione, nessun retry dopo le 23.
      final again = await EveningSync.runOnce(db: db, dio: dio, now: DateTime(2026, 10, 10, 23, 10), notifications: null);
      expect(again.newDrawDate, isNull);
      expect(again.retry, isFalse);
    });

    test('resta in attesa se l\'archivio pubblicato è ancora vecchio', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await SettingsRepository(db).save(AppSettings.initial.copyWith(liveSyncEnabled: true));
      final dio = Dio()..httpClientAdapter = _ZipAdapter('2026/10/08\tBA\t11\t22\t70\t80\t90\n');
      final result = await EveningSync.runOnce(db: db, dio: dio, now: DateTime(2026, 10, 10, 20, 15), notifications: null);
      expect(result.newDrawDate, DateTime.utc(2026, 10, 8), reason: 'la prima importazione porta comunque una data nuova');
      final second = await EveningSync.runOnce(db: db, dio: dio, now: DateTime(2026, 10, 10, 21, 0), notifications: null);
      expect(second.newDrawDate, isNull);
      expect(second.retry, isTrue);
    });

    test('non fa nulla se l\'aggiornamento serale è spento', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await SettingsRepository(db).save(AppSettings.initial.copyWith(liveSyncEnabled: false));
      final result = await EveningSync.runOnce(db: db, dio: Dio(), now: DateTime(2026, 10, 10, 20, 15), notifications: null);
      expect(result.reason, contains('disattivato'));
    });
  });
}

/// Risponde a qualsiasi GET con uno ZIP che contiene il testo indicato.
class _ZipAdapter implements HttpClientAdapter {
  _ZipAdapter(this.text);

  final String text;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final archive = Archive()..addFile(ArchiveFile('storico.txt', utf8.encode(text).length, utf8.encode(text)));
    final bytes = ZipEncoder().encode(archive);
    return ResponseBody.fromBytes(bytes, 200, headers: {
      'content-type': ['application/zip'],
      'last-modified': ['Sat, 10 Oct 2026 18:40:00 GMT'],
    });
  }

  @override
  void close({bool force = false}) {}
}
