# Fonti dati

Il 9 ottobre 2026 la pagina `https://www.lotto-italia.it/lotto/estratti-ruote` contiene, nel markup, questi archivi ZIP pubblici:

- `https://www.brightstarlottery.it/content/dam/rebranding/documents/zip/storico39-70.zip`
- `https://www.brightstarlottery.it/content/dam/rebranding/documents/zip/storico71-00.zip`
- `https://www.brightstarlottery.it/STORICO_ESTRAZIONI_LOTTO/storico01-oggi.zip`
- `https://www.brightstarlottery.it/STORICO_ESTRAZIONI_LOTTO/storico.zip`

Non è un'API documentata. Sono i file che la pagina invita a scaricare. L'app usa solo `storico.zip`, che al controllo del 9 ottobre 2026 conteneva `storico.txt` dal 1939-01-07 al 2026-10-08. Header osservato: HTTP 200, `Content-Type: application/zip`, circa 688 KB.

Formato di ogni riga, separatore tabulazione:

```text
YYYY/MM/DD  RUOTA  n1  n2  n3  n4  n5
```

Codici ruota nel file: BA, CA, FI, GE, MI, NA, PA, RM, TO, VE, RN. RN è la Nazionale. Le ruote non presenti nei primi decenni non vengono inventate.

L'import manuale accetta lo stesso testo, un CSV `date,wheel,n1..n5` e il JSON:

```json
{
  "schema": "lotto-intelligence.draws/v1",
  "draws": [
    {"date": "1939-01-07", "wheel": "BA", "numbers": [58, 22, 47, 49, 69]}
  ]
}
```

`officiallyVerified` resta falso. L'integrità strutturale controlla cinque numeri distinti fra 1 e 90 e una ruota nota. Non è un bollettino firmato né un confronto con una seconda fonte.

Lo stato di freschezza usa il calendario pubblicato sul sito: martedì, giovedì, venerdì e sabato. Dopo le 21:00 locali di un giorno di estrazione ci si aspetta la data odierna nel file. Se manca, lo stato è «in ritardo»: può essere il ritardo di pubblicazione dello ZIP, non la prova che l'estrazione non sia avvenuta.

L'aggiornamento serale, se attivato nelle impostazioni, ricontrolla al massimo ogni 15 minuti fra le 20 e le 23 dei giorni di estrazione a app aperta, e dalla 0.3.0 anche a app chiusa con un task WorkManager alle 20:15 e tentativi ogni 20 minuti fino alle 23. Stessa URL, stesso parser, stessi limiti. Vedi [28_PRIZES_AND_ALERTS](28_PRIZES_AND_ALERTS.md).

## SuperEnalotto

Il 22 ottobre 2026 `https://www.superenalotto.it/archivio-estrazioni` pubblica una tabella HTML, non uno ZIP. Ogni riga ha concorso, data in italiano, sei numeri, Jolly e SuperStar. Le pagine mensili stanno su `/archivio-estrazioni/{anno}/{mese}` (esempio `/2026/ottobre`). L'anno da solo risponde 404. L'app legge la pagina corrente a ogni controllo serale e, su richiesta, i mesi dal 2023. `officiallyVerified` resta falso: è una sola fonte e il parser può saltare una riga malformata.
