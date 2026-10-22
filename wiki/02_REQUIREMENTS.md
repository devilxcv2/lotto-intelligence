# Requisiti coperti dalla 0.1.0

Funzionano sul codice attuale:

- Avvio con onboarding persistito e tema scuro, chiaro o di sistema.
- Download dello ZIP `storico.zip` collegato dalla pagina ufficiale delle estrazioni, oppure import di TXT/CSV/JSON/ZIP scelto dall'utente.
- Archivio SQLite con undici ruote, deduplica, conflitti non sovrascritti, righe mai marcate `officiallyVerified`.
- Selezione ruota, frequenze, ritardi, heatmap, coppie, parità, somme, decine, cifre finali, correlazione fra due numeri.
- Generatore integrale completo solo sotto il limite di 5000 combinazioni, generatore parametrico senza copertura garantita, salvataggio strategia, export CSV.
- Backtest walk-forward contro una baseline casuale con seed, Monte Carlo, report JSON/CSV/PDF salvato in locale.
- Portafoglio virtuale con tetti che bloccano la registrazione. Dalla 0.3.0: schedine da 1 a 10 numeri con poste per sorte, valutazione automatica contro l'estrazione del concorso, vincite lorde e nette con la tabella premi citata, analisi «e se avessi puntato», aggiornamento serale a app chiusa e notifica locale ([28_PRIZES_AND_ALERTS](28_PRIZES_AND_ALERTS.md)).
- AI Lab con tre motori locali. Provider remoto opzionale, chiave nel secure storage.
- Wiki in app. Analisi offline sui dati già importati.

Non sono in questa versione: ROI in valuta nel backtest, estratto determinato e ambetto, modello di machine learning classico, runtime on-device diverso da Ollama in rete.
