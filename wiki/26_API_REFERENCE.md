# Riferimento

Funzioni e tipi usati dal resto dell'app.

| Simbolo | Ruolo |
| --- | --- |
| `parseOfficialArchiveText` | TSV ufficiale |
| `parseManualCsv` / `parseManualJson` | Import utente |
| `validateDrawNumbers` | 5 numeri distinti, 1–90 |
| `evaluateFreshness` | updated, delayed, unavailable, unverified |
| `StatisticsEngine.summarize` | Statistiche di una ruota |
| `wilsonInterval` | Intervallo sul tasso storico |
| `pearsonPresence` | Correlazione di due presenze |
| `generateIntegral` / `generateParametric` | Sistemi |
| `BacktestEngine.run` | Simulazione cronologica |
| `OfficialArchiveLocations` | Pagina e URL dello ZIP verificati il 2026-10-09 |
| `isAllowedAiEndpoint` | HTTPS oppure HTTP solo locale/privato |
| `WalletRepository.assess` | Blocco dei tetti simulati |
| `WalletRepository.addTicket` / `evaluateOpenTickets` / `summary` | Schedine ipotetiche, valutazione, riepilogo |
| `grossPrizeCents` / `evaluateTicket` / `whatIfBySorte` | Tabella premi e esiti |
| `nextOpenDrawDate` / `resultCheckTime` | Concorso aperto e ora del controllo |
| `ArchiveSyncService.syncOfficial` | Download e import condivisi fra app e task |
| `EveningSync.schedule` / `runOnce` | Task serale WorkManager |
| `NotificationService.showNewDraw` | Notifica locale |
| `compareStrategies` / `studyStrategyCatalog` | Metodi classici a confronto |

Gli URL non sono una API REST del Lotto. L'unico protocollo remoto dell'archivio è il download HTTP dello ZIP.
