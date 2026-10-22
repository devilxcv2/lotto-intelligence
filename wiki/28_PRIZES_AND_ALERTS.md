# Premi, schedine ipotetiche e avvisi serali

Dalla 0.3.0 il laboratorio valuta le giocate di studio in euro simulati e avvisa quando una nuova estrazione entra in archivio. Niente di tutto questo compra una giocata o tocca denaro.

## Tabella premi

`lib/core/lotto/prize_table.dart`. Fonti verificate il 10 ottobre 2026:

- ADM, «Gioco del Lotto – Come si gioca» (`adm.gov.it/portale/monopoli/giochi/gioco-del-lotto/lotto_g/lotto_gioca`): la posta viene moltiplicata per 11,233 (estratto), 250 (ambo), 4.500 (terno), 120.000 (quaterna), 6.000.000 (cinquina); giocata minima 1 €, incrementi di 0,50 €, massima 200 €; vincita massima 6.000.000 € per scontrino; ritenuta dell'8% sulle vincite.
- ADM, «Come riscuotere»: la ritenuta dell'8% deriva dall'art. 6 c. 2 del d.l. 50/2017, convertito dalla l. 96/2017.
- lotto-italia.it, «Premi del Lotto»: con più numeri il premio si divide per le combinazioni della sorte (ambo su 5 numeri 25,00 €, terno su 5 numeri 450,00 €); la ruota TUTTE esclude la Nazionale e divide i premi per 10.

Formula implementata, in centesimi:

```text
lordo = posta × coefficiente × C(centri, sorte) / C(numeri giocati, sorte) / ruote coperte
```

arrotondato al centesimo sul totale, non combinazione per combinazione. Dove la tabella pubblicata mostra un valore arrotondato per euro (3,74 per l'estratto su 3 numeri, 83,33 per l'ambo su 3), il motore lo riproduce; sul totale può differire di un centesimo dallo scontrino reale, come scritto nella nota dell'esito. Il netto è il lordo meno l'8%. Il tetto di 6.000.000 € si applica alla schedina.

Non modellati: estratto determinato, ambetto, Numero Oro, Doppio Oro, 10eLotto. Le sorti disponibili sono le cinque classiche.

Il test `tabella premi ufficiale` in `test/wallet_test.dart` fissa i valori della tabella pubblicata: estratto 11,23, ambo 250, terno 4.500, quaterna 120.000, cinquina 6.000.000 per 1 € con i soli numeri della sorte; 3,74 / 83,33 su 3 numeri; 2,25 / 25 / 450 / 24.000 su 5 numeri.

## Schedina ipotetica

`TicketDraft`: ruota (una delle undici oppure `TUTTE`), da 1 a 10 numeri, una posta per ciascuna sorte. Regole verificate da `TicketDraft.problem()`: almeno una posta, passi di 0,50 €, totale fra 1 e 200 €, numeri sufficienti per la sorte (ambo ≥ 2 numeri, terno ≥ 3…).

Alla registrazione la schedina riceve `target_draw_date`, calcolata da `nextOpenDrawDate`: il giorno stesso se è un giorno di estrazione e la raccolta non è chiusa (19:30 locali, ADM), altrimenti il prossimo fra martedì, giovedì, venerdì e sabato. I tetti del portafoglio simulato (per concorso, mensile, capitale) bloccano la registrazione come prima.

Le pagine Laboratorio → Backtest («Registra come schedina ipotetica») e Sistemi («Schedina») non registrano più direttamente: aprono la pagina «Nuova schedina» con numeri e ruota precompilati, dove si scelgono le poste.

## Valutazione automatica

`WalletRepository.evaluateOpenTickets()` cerca, per ogni schedina `open`, l'estrazione di `target_draw_date` sulla ruota giocata (tutte le dieci per `TUTTE`; finché una manca, la schedina resta in attesa). Scrive una riga in `ticket_results` con centri, lordo, netto e `detail_json` (centri per ruota, lordo per sorte, data) e porta la schedina a `evaluated`. Non valuta due volte.

La valutazione parte:

- al termine di ogni importazione riuscita (`ArchiveSyncService.run`), in primo piano o in background;
- quando l'app torna in primo piano (`LiveSyncHost`);
- all'apertura dell'elenco schedine.

Le schedine create con lo schema 1 non hanno poste per sorte: restano `legacy`, mostrano solo i centri e non entrano nel saldo.

## «E se avessi puntato…»

Nel dettaglio di una schedina valutata, `whatIfBySorte` ricalcola lo stesso esito con una posta a scelta su una sola sorte. È un conto a posteriori sull'estrazione già uscita; la pagina lo dice. Nella pagina «Nuova schedina» compare invece il ritorno atteso: somma su k dei P(k centri) ipergeometrici per il premio, meno l'8%. Per le sorti classiche è sempre sotto la posta.

## Portafoglio

`WalletSummary`: schedine in attesa e valutate, giocato, lordo, netto, saldo, schedine vincenti, miglior netto, serie del saldo cumulato per il grafico. Il capitale residuo mostrato è capitale simulato + saldo − poste in attesa. Il testo di accompagnamento ricorda che la perdita è l'esito atteso: nessun invito a recuperare.

## Aggiornamento serale a app chiusa

`lib/core/background/evening_sync.dart`, plugin `workmanager` 0.10.10.

- Quando l'opzione «Aggiornamento serale automatico» è attiva, `EveningSync.schedule()` registra un task one-off alle 20:15 locali del prossimo giorno di estrazione (`ExistingWorkPolicy.replace`, rete richiesta). Spegnendo l'opzione il task viene cancellato.
- Il task apre il database, controlla che l'opzione sia ancora attiva, esegue lo stesso `ArchiveSyncService.syncOfficial()` dell'app, valuta le schedine, e se la data più recente è cambiata invia la notifica. Se l'archivio pubblicato è ancora «in ritardo» e sono meno delle 23, programma un nuovo tentativo dopo 20 minuti (massimo 8). In ogni caso riprogramma il prossimo giorno di estrazione.
- Android può posticipare il task in Doze o con il risparmio energetico: l'ora è indicativa. Il timer da 15 minuti a app aperta resta come prima.
- Il database è aperto con `busy_timeout = 8000` perché il task può girare mentre l'app è in primo piano.

`EveningSync.runOnce` è separato dal dispatcher e viene testato con un adapter Dio che restituisce uno ZIP costruito nel test.

## Notifiche

`lib/core/notifications/notification_service.dart`, plugin `flutter_local_notifications` 22.3.1. Notifica locale, canale `draw_results`, nessun server e nessun token. Il corpo riporta la data, il numero di schedine confrontate e il netto simulato; il tocco apre `/more/tickets` (payload). Su Android 13+ il permesso `POST_NOTIFICATIONS` viene chiesto quando si attiva l'opzione o si registra una schedina con gli avvisi attivi. L'interruttore «Notifica a nuova estrazione» è separato e dipende da quello serale.

Requisiti di build aggiunti: `isCoreLibraryDesugaringEnabled = true` e `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` in `android/app/build.gradle.kts`.
