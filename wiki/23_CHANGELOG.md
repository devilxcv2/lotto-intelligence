# Changelog

## 0.5.17 — 2026-10-28

Maschera Sisal G5/G4/G3.

- Lab → **Maschera Sisal**: griglia colonne sviluppate, garanzia G5/G4/G3, footer con Comb e totale come Sisal.
- SuperEnalotto hub → **Sistemi G5/G4/G3**.
- Scheda «Quanto spendi»: confronto con l’integrale, tabella di riferimento Sisal SE, avviso budget.

## 0.5.16 — 2026-10-25

Pagina Condividi.

- In **Più → Condividi**: link da inviare, copia messaggio, foglio di condivisione di sistema.
- Pagina pubblica `dist/download.html` con pulsante Scarica APK (legge sempre `update.json`).

## 0.5.15 — 2026-10-25

Scheda Soldi in barra.

- Nuova voce **Soldi**: credito simulato, budget, vincite.
- Per metodo (Zoppe, Auto, mirate…): saldo e centri medi.
- Lettura didattica delle schedine chiuse: cosa ha centrato e perché il sistemone non “sbaglia” la probabilità.
- Trend Auto SuperEnalotto nella stessa scheda.

## 0.5.14 — 2026-10-24

Schedine mirate Lotto e algoritmi SE personalizzati.

- Nuova schedina: modalità Ambo / Terno / Quaterna / Cinquina su una ruota, con suggerimenti della giusta lunghezza.
- SuperEnalotto: algoritmi sull’archivio (mix, pari/dispari, somma, giorno, decadi, coppie) + trend delle Auto; puoi registrarle tutte insieme.
- Include anche poste auto Lotto e auto SE a tre strategie (0.5.13).

## 0.5.13 — 2026-10-24

Poste auto configurabili e SuperEnalotto automatico.

- In Impostazioni: poste di default per estratto/ambo/terno/quaterna/cinquina sulle schedine Lotto automatiche, con «Applica suggerite».
- Opzione SuperEnalotto automatico: crea Zoppe + ritardi + frequenti per confrontare i trend (categorie, non euro).
- Catalogo SE: filtro Auto.

## 0.5.12 — 2026-10-24

Menu più giovane, disclaimer fuori dalla Home.

- Barra sotto flottante a pillola: Home · Extra · Ticket · Lab · Più, con icona piena quando sei lì.
- Il testo sul caso non sta più in cima alla Home: sta in Più → Informazioni.
- Hub «Più» con intestazione più vivace.

## 0.5.11 — 2026-10-24

Area SuperEnalotto dedicata.

- Hub verde/oro separato dal Lotto: ultimo concorso, azioni, conteggi.
- Catalogo schedine SE con filtri (in attesa, categorie, nessuna), distinto dalle schedine Lotto in euro.
- Studio e nuova giocata dentro l’area; da Estrazioni e Altro si entra dall’hub.

## 0.5.10 — 2026-10-23

Avviso aggiornamento più affidabile.

- Controlla di nuovo al ritorno in app (non solo al primo avvio).
- Riprova se la rete non è pronta; non silenzia più la versione se tocchi Scarica (solo «Più tardi»).
- Intestazioni no-cache sul file di versione.

## 0.5.9 — 2026-10-23

APK più leggero e menu meno dispersivi.

- Release arm64-only con minify e shrink resources; rimossi `cupertino_icons` e `url_launcher`; in app solo le voci wiki davvero usate.
- Home: azioni essenziali (nuova schedina, elenco, Zoppe) e un solo ingresso al Lab; Lab e Altro raggruppati per sezioni con icone.
- Splash e tema leggermente più nitidi (fondo, navigation bar, tile).

## 0.5.8 — 2026-10-23

Schedine che si arrangiano da sole.

- Elenco a catalogo per concorso, filtri Vincite/Auto, palline colpite evidenziate.
- Popup a schermo sempre quando ci sono nuovi esiti (anche aprendo Schedine o tornando in app).
- Opzione «Schedine automatiche»: l’app crea Zoppe/ritardi/frequenti per il prossimo concorso, valuta con lo ZIP e notifica.

## 0.5.7 — 2026-10-23

Serata di estrazione più chiara.

- Popup in app quando sta per estrarre (18:30–19:30) e dopo la chiusura se lo ZIP non c’è ancora.
- Notifica alle 19:00 (imminente) e alle 20:15 (scarico archivio); poi quando la nuova estrazione è in archivio.
- Timeline esplicita: 19:30 chiusura · risultati tipici verso 20:30 (non subito) · ZIP dalle 20:15 con riprove fino alle 23.
- Aggiornamento serale automatico acceso di default.

## 0.5.6 — 2026-10-22

Più semplice da usare.

- In Impostazioni (e Portafoglio) il budget simulato può essere a limiti, spento o infinito, così le prove non restano bloccate.
- Navigazione: Home · Estrazioni · Schedine · Lab · Altro. Le statistiche stanno in Altro.
- Nuova schedina: prima la ruota, poi i suggerimenti (Zoppe, ritardatari, frequenti) e le poste.
- Estrazioni con palline per ruota e tocco sullo storico; Zoppe con scelta ruota e guida d'uso.

## 0.5.5 — 2026-10-22

Scarico aggiornamenti in app.

- Se sei indietro di più versioni puoi scegliere quale scaricare; l'ultima è consigliata.
- Lo scarico mostra barra, megabyte, velocità e tempo restante. A fine file si apre l'installazione Android. «Più tardi» resta disponibile.

## 0.5.4 — 2026-10-22

Schedina più chiara e Zoppe dalla nuova giocata.

- Nuova schedina in quattro passi (numeri, ruota, poste, registra), con i numeri scelti in evidenza.
- Da lì partono Ritardatari, Frequenti e Sistemone Zoppe: lo Zoppe riempie cinque numeri e «Altra colonna Zoppe» passa alla successiva. Nulla di quanto c'era prima è stato tolto.

## 0.5.3 — 2026-10-22

Indirizzo di aggiornamento già impostato.

- Se in Impostazioni il campo del file di versione è vuoto, l'app legge da sola `dist/update.json` sul repository pubblico GitHub. Non serve più copiare l'indirizzo a mano.

## 0.5.2 — 2026-10-22

Zoppe a gambe e SuperEnalotto.

- Il Sistemone Zoppe prende un gettonato a caso, un ritardatario e un numero dalle fasce 30–45, 50–65 e 70–85. La legenda in pagina spiega ogni gamba. Sul SuperEnalotto la stessa costruzione ha sei numeri (più la fascia 15–30) e suggerisce Jolly e SuperStar dalle loro storie, senza inventare importi.

## 0.5.1 — 2026-10-22

Richiesta di aggiornamento, non obbligatoria.

- In Impostazioni si indica l'indirizzo di `update.json`. Se il `versionCode` pubblicato è più alto, all'apertura l'app chiede se scaricare. «Più tardi» continua con la versione installata e non ripete quella stessa richiesta. «Scarica» apre l'APK nel browser.

## 0.5.0 — 2026-10-22

Studio SuperEnalotto.

- Da Altro, da Estrazioni e dalle schedine del Lotto si apre uno studio dedicato: ultime combinazioni, dieci ritardatari, tre suggerimenti (ritardo, frequenza, Zoppe da sei) e una griglia per la schedina.
- La schedina ha sei numeri e una SuperStar facoltativa. Il sistemone riusa il ridotto già verificato, con colonne da 6: dal system builder, una colonna da 6 si porta nello studio.
- Dopo lo scarico le schedine del concorso si chiudono sulla categoria (sei, cinque + Jolly, cinque, quattro, tre, due). Non c'è un importo: il premio è a montepremi. Le schedine del Lotto restano nel portafoglio, con le poste in euro.

## 0.4.1 — 2026-10-22

Sistemone Zoppe.

- Nel Laboratorio, e dal pronostico del system builder, si apre lo Zoppe: maschera positiva scelta a mano, maschera negativa come complemento dei 90.
- Dalla negativa entra la fascia di frequenza fra il 30° e il 45° posto delle ultime 100 estrazioni. Dalla positiva entra il 10–15% con più uscite. Le colonne mescolano le due gambe, con meno numeri dalla positiva.
- In pagina resta la probabilità equa, 5 su 90. La fascia non è una previsione.

## 0.4.0 — 2026-10-22

SuperEnalotto e avviso a schermo.

- In Estrazioni si passa da Lotto a SuperEnalotto. Le combinazioni (sei numeri, Jolly, SuperStar) si scaricano dalle pagine dell'archivio ufficiale: il sito non pubblica uno ZIP unico. «Ultimi concorsi» legge la pagina corrente, «Dal 2023» le pagine mensili. Lo ZIP del Lotto resta quello di lotto-italia.it.
- A scarico finito compare un avviso a tutto schermo con l'esito del controllo delle schedine ipotetiche. La notifica di sistema, la sera, cita anche i concorsi SuperEnalotto nuovi.
- I premi in euro del SuperEnalotto non sono calcolati: sono a montepremi e non stanno nella tabella scaricata.

## 0.3.2 — 2026-10-10

Ricerca trend.

- Laboratorio → Ricerca trend: legge le ultime 2–12 settimane della ruota e prova dieci regole (frequenza, pendenza, giorno della settimana, eco, laterali, ritmo proprio, decine, cifre finali, ripetizione breve, coppie).
- Accanto a ogni numero mette la quota osservata e la probabilità equa 5/90. La regola in testa propone 5 numeri e un ridotto da 15, con la garanzia verificata. Il testo dice che la scelta della regola migliore sullo stesso archivio non è una previsione.

## 0.3.1 — 2026-10-10

Bacheca estrazioni.

- Tema chiaro di default nello stile della bacheca classica: titolo blu, fascia arancione, ruote arancioni, numeri blu, palline blu con cifra gialla. Il tema scuro tiene gli stessi colori su fondo blu notte.
- Pagina Estrazioni e giorno di estrazione a tabella, come l'elenco delle undici ruote. Ritardi e frequenze con intestazione arancione e righe alternate.
- Chi aveva il tema scuro predefinito delle versioni precedenti passa una volta al chiaro. Si può tornare a Scuro dalle impostazioni.

## 0.3.0 — 2026-10-10

Studio in tempo reale.

- Tabella premi del Lotto con fonti ADM e lotto-italia.it verificate il 10 ottobre 2026: coefficienti per sorte, divisione per le combinazioni, TUTTE ÷10, ritenuta 8%, tetto 6.000.000 €, posta 1–200 € a passi di 0,50.
- Schedine ipotetiche da 1 a 10 numeri, poste per sorte, ruota singola o TUTTE, concorso di riferimento calcolato con la chiusura delle 19:30. Le pagine Backtest e Sistemi aprono la nuova schedina precompilata.
- Valutazione automatica dopo ogni importazione, al ritorno in primo piano e all'apertura dell'elenco: centri, lordo, netto, dettaglio per ruota e per sorte. Analisi «e se avessi puntato…» e ritorno atteso.
- Portafoglio con saldo, giocato, lordo, netto, ritorno, capitale residuo, grafico del saldo e limiti. Home con scheda «Studio in tempo reale».
- Aggiornamento serale a app chiusa con WorkManager (20:15, tentativi ogni 20 minuti fino alle 23) e notifica locale con apertura dell'elenco schedine. Interruttore separato per le notifiche, permesso chiesto a runtime.
- `ArchiveSyncService` condiviso fra app e task; `busy_timeout` sul database.
- Schema 2 con migrazione da 1 testata su fixture; `ticket_numbers` fino a 10 posizioni.
- Metodi classici misurati su Bari (`tools/strategies_benchmark_test.dart`): nessuno distinguibile dal caso su 1.000 estrazioni.
- Nuovi test: 29 verdi. Gradle con desugaring. APK debug arm64 ricompilato.

## 0.2.0 — 2026-10-09

Fluidità e sistemi grandi.

- SQLite su isolate di background. Unzip, parsing e hash dell'archivio su `Isolate.run`. Deduplica e conflitti in SQL tramite tabella temporanea. Banner di avanzamento con «Annulla» su ogni scheda.
- Statistiche e backtest fuori dal thread UI, statistiche in cache per ruota e finestra.
- Lettura di una ruota compattata: blocco UI da 73 a 19 ms sull'archivio reale.
- System builder: colonne da 2 a 10, integrali fino a 200.000 colonne, ridotto (v, k, m, t) con verifica esaustiva, generazione annullabile con avanzamento reale, filtri regolabili, riempimento da frequenti, ritardatari, casuali o testo, lista completa scorrevole, export JSON.
- Nuovi test: ridotto verificato e rifiutato, colonne da 2 e 10, job annullabile, conflitti e duplicati nello stesso file.
- Strumenti di misura in `tools/`.

## 0.1.0 — 2026-10-09

Prima versione eseguibile.

- Progetto Flutter 3.41.6, Riverpod, GoRouter, Drift 2.31.
- Import dell'archivio ZIP collegato da lotto-italia.it e import CSV/JSON.
- Statistiche, sistemi, backtest senza vincite inventate, portafoglio con tetti, wiki offline.
- Le estrazioni importate restano non marcate come ufficialmente verificate.
- APK debug arm64 compilato. Non installato su dispositivo.
