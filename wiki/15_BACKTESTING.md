# Backtesting

`BacktestEngine.run` scorre le estrazioni in ordine. Alla posizione `i` la strategia riceve solo `draws.sublist(0, i)`. Il punteggio usa `draws[i]`. Le estrazioni prima di `scoreFromIndex` scaldano la storia e non entrano negli istogrammi: è il tratto fuori dal periodo che si vuole misurare. `runBacktestInBackground` esegue lo stesso motore su un isolate.

Strategie incluse:

- il catalogo dei metodi classici descritto in [17_STRATEGY_EVALUATION](17_STRATEGY_EVALUATION.md);
- `FixedNumbersStrategy`: la cinquina scritta dall'utente;
- `RandomBaselineStrategy`: campione uniforme con `Random(seed + indice * 9973)`, senza leggere i numeri estratti.

Il report mette accanto, per 0–5 centri, il conteggio della strategia, quello della baseline e l'atteso ipergeometrico. La media teorica dei centri è 5 * 5/90.

Accanto al report compare «Cosa proporrebbe oggi questo metodo»: la stessa funzione applicata a tutta la storia, con il confronto fra la sua media storica e la teoria. Il pulsante «Registra come schedina ipotetica» apre la pagina della nuova schedina con quei numeri; le poste e la verifica in euro simulati sono descritte in [28_PRIZES_AND_ALERTS](28_PRIZES_AND_ALERTS.md).

Il JSON del report ha ancora `monetary.available = false`: il backtest confronta centri, non euro. La tabella premi esiste dalla 0.3.0 ma non è stata collegata al backtest: farlo richiede scegliere un profilo di posta per ogni estrazione simulata, ed è in roadmap.

I risultati per estrazione stanno in `backtest_results`. Il riepilogo sta in `backtest_runs.summary_json`.
