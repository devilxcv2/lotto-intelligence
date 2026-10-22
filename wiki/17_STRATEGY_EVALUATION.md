# Valutazione delle strategie

Una strategia non viene dichiarata vincitrice. Il confronto utile è fra i suoi centri, la baseline casuale con lo stesso seed e l'atteso del modello equo, sulla finestra scelta dopo il riscaldamento.

Scegliere la strategia perché sulla stessa finestra «ha funzionato» rende quella finestra inutilizzabile come conferma. Per questo il motore separa il riscaldamento dal tratto valutato. Non ottimizza i parametri sulla finestra di test.

## Catalogo dei metodi classici

`lib/features/backtesting/domain/study_strategies.dart` contiene i metodi di studio più diffusi, implementati come `StudyStrategy` che leggono solo `historyBefore`:

| id | Nome | Regola |
| --- | --- | --- |
| `frequency-top` | Più frequenti (tutta la storia) | i 5 numeri con più uscite nell'intero passato |
| `frequency-window` | Più frequenti (finestra) | i 5 più frequenti nelle ultime N estrazioni |
| `delay-top` | Ritardatari | i 5 con il ritardo corrente più lungo |
| `hot-cold-mix` | Caldi e freddi | 3 frequenti della finestra + 2 ritardatari |
| `spy-followers` | Numeri spia | i numeri usciti più spesso nell'estrazione successiva a una che conteneva un numero dell'ultima |
| `pairs-top` | Coppie frequenti | numeri delle coppie più frequenti nella finestra |
| `diametral-of-last` | Diametrali dell'ultima | (n + 45 − 1) mod 90 + 1 dei numeri dell'ultima estrazione |
| `balanced-decades` | Decine bilanciate | un numero per cinque decine diverse |
| `random-baseline` | Baseline casuale | campione uniforme dal seed |

«Confronta tutti i metodi» esegue `compareStrategies` su un isolate e ordina per media di centri. Il report scrive l'avvertenza sui confronti multipli.

## Misura sull'archivio reale (Bari, `tools/strategies_benchmark_test.dart`, 10 ottobre 2026)

Teoria del modello equo: 0,278 centri per estrazione. Errore standard della media su 1.000 estrazioni: circa 0,016.

| Metodo | Media su 100 | Media su 1.000 |
| --- | --- | --- |
| Numeri spia | 0,320 | 0,303 |
| Più frequenti (finestra 100) | 0,320 | 0,298 |
| Coppie frequenti | 0,280 | 0,279 |
| Decine bilanciate | 0,260 | 0,265 |
| Più frequenti (tutta la storia) | 0,260 | 0,264 |
| Baseline casuale | 0,230 | 0,263 |
| Diametrali dell'ultima | 0,250 | 0,258 |
| Caldi e freddi | 0,190 | 0,255 |
| Ritardatari | 0,170 | 0,249 |

Lettura: su 100 estrazioni l'ordine cambia molto e la baseline oscilla di ±0,05; su 1.000 tutte le medie stanno entro 1,6 errori standard dalla teoria, con nove metodi in gara. Nessun metodo mostra un vantaggio distinguibile dal caso. Il risultato è coerente con l'ipotesi di estrazione equa ed è quello che il laboratorio deve far vedere, non nascondere. Tempi: 0,34 s per 100 estrazioni, 2,2 s per 1.000, per tutti i metodi insieme.

Confrontare molte regole sullo stesso storico aumenta la probabilità di vederne una estrema per caso. L'app lo scrive nel limite del report. Non applica una correzione numerica di molteplicità: sta all'utente sapere che il «migliore» di nove è atteso sopra la media anche quando nessuno ha valore predittivo.

## Ricerca trend (0.3.2)

`lib/features/discovery/domain/trend_search.dart` prova dieci regole sulle ultime 2–12 settimane (quattro estrazioni per settimana) e sulle ultime 80 estrazioni in walk-forward. Per ogni numero mostra uscite recenti, pendenza e quota osservata contro 5/90, con l'intervallo di Wilson. La regola con la media più alta propone cinque numeri per il prossimo concorso e un ridotto su 15 numeri (se 3 cadono nel pronostico, una colonna ne ha almeno 2), garanzia verificata. La probabilità mostrata è quella del modello equo, non una affidabilità del trend: scegliendo la migliore di dieci regole sullo stesso archivio la media è spostata verso l'alto.
