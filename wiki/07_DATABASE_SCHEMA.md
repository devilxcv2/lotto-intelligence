# Schema

`AppDatabase.schemaVersion` è 4. Alla creazione vengono inserite le undici ruote e le fonti `lotto_italia_archive`, `manual_import` e `superenalotto_archive`. Non vengono inserite estrazioni.

Tabelle: `wheels`, `data_sources`, `draws`, `draw_numbers`, `sync_logs`, `strategies`, `strategy_parameters`, `ai_models`, `predictions`, `prediction_numbers`, `ai_execution_logs`, `backtest_runs`, `backtest_results`, `virtual_tickets`, `ticket_numbers`, `ticket_results`, `user_settings`.

`draws` è unica su data e ruota. `officially_verified` nasce falso. `content_hash` è SHA-256 di `yyyy-MM-dd|RUOTA|n1,n2,n3,n4,n5` nell'ordine pubblicato. Le date sono salvate come secondi Unix a mezzanotte UTC; Drift le rilegge come `DateTime` locali, quindi i confronti passano da `toUtc()` o da `dateOnlyUtc`.

## Schedine (schema 2)

`virtual_tickets`: `wheel_code` è una ruota oppure `TUTTE`; `stake_cents` è la posta totale; `stake_estratto_cents`, `stake_ambo_cents`, `stake_terno_cents`, `stake_quaterna_cents`, `stake_cinquina_cents` la scompongono; `target_draw_date` è il concorso a cui partecipa; `status` vale `open`, `evaluated` o `legacy`.

`ticket_numbers`: da 1 a 10 numeri per schedina, `CHECK` sulla posizione fra 1 e 10 e sul numero fra 1 e 90.

`ticket_results`: una riga per valutazione con `draw_id` (solo per ruota singola), `hits`, `gross_cents`, `net_cents`, `outcome_note` e `detail_json` con centri per ruota, lordo per sorte e data.

## SuperEnalotto (schema 3)

`superenalotto_draws`: data, numero di concorso unico, sei numeri, Jolly, SuperStar, hash, `officially_verified` falso, provenienza e data di import. La migrazione 2 → 3 crea la tabella e la fonte. I premi a montepremi non hanno colonne.

## Schedine SuperEnalotto (schema 4)

`superenalotto_tickets`: sei numeri, SuperStar facoltativa, data del concorso, stato `open` o `evaluated`, origine (`manuale`, `suggerimento`, `sistemone`). `superenalotto_ticket_results`: centri sui sei numeri, Jolly, SuperStar e categoria. Nessuna colonna in euro. La migrazione 3 → 4 crea le due tabelle.

## Migrazione 1 → 2

`onUpgrade` aggiunge le colonne con i default, marca `legacy` le schedine esistenti (non hanno poste per sorte), ricrea `ticket_numbers` con `TableMigration` per allargare il `CHECK`, aggiunge `detail_json`. I vincoli esterni sono spenti durante la migrazione e riaccesi in `beforeOpen`, dove viene impostato anche `busy_timeout = 8000`.

La migrazione è coperta dal test `migrazione dallo schema 1` su `test/fixtures/schema_v1.sqlite`, un file creato con il codice della 0.2.0 (due estrazioni, una schedina con esito a due centri). Quando lo schema cambierà di nuovo, va aggiunta una fixture della versione precedente con lo stesso metodo: aprire un `NativeDatabase(File)` con il codice della versione da congelare, inserire poche righe, chiudere.

Le chiavi API non stanno in queste tabelle. Stanno nel secure storage, chiave `ai_model_<id>_api_key`.

Il file dell'app è `lotto_intelligence.sqlite` nella directory documenti, aperto con `NativeDatabase.createInBackground`. I test usano `NativeDatabase.memory()`.
