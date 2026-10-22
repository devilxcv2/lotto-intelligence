# Motore statistico

`StatisticsEngine.summarize` riceve cinquine già in ordine cronologico di una sola ruota. Non legge il database e non guarda altre ruote.

Per ogni numero da 1 a 90 calcola:

- frequenza assoluta e relativa sulla finestra;
- ritardo corrente: estrazioni trascorse dall'ultima uscita, 0 se è nell'ultima;
- ritardo massimo osservato lungo la finestra, compreso il ritardo ancora aperto;
- intervallo medio fra indici di uscita successiva, solo se le uscite sono almeno due;
- intervallo di Wilson al 95% sul tasso storico.

La probabilità di riferimento mostrata accanto è sempre 5/90. Se il Wilson contiene 5/90, l'interfaccia dice che la frequenza della finestra è compatibile con un'estrazione equa. È un commento sul passato.

La somma attesa di cinque numeri distinti uniformi fra 1 e 90 è 227,5, per linearità. L'istogramma dei pari è confrontato con l'ipergeometrica di 45 pari su 90.

Le coppie in cima all'elenco sono scelte dopo aver visto i dati. La pagina lo dice: fra tutte le coppie, qualcuna risulta alta per caso. L'attesa di una coppia specifica è `estrazioni * C(88,3) / C(90,5)`.

`pearsonPresence` correla le serie 0/1 di due numeri. Con tante coppie confrontate, un valore estremo non è una scoperta. L'interfaccia calcola una sola coppia scelta dall'utente.

Le finestre in UI sono 10, 30, 50, 100, 500, 1000 o tutte. Il taglio prende le ultime N estrazioni della ruota.

Il calcolo non gira nel `build` dei widget. `wheelStatisticsProvider` (`lib/features/statistics/data/statistics_providers.dart`) lo esegue con `summarizeInBackground` su un isolate e lo tiene in cache per ruota e finestra. Si ricalcola quando l'import invalida `wheelDrawsProvider`. Dashboard, statistiche, heatmap, coppie e riempimento rapido del system builder leggono la stessa cache.
