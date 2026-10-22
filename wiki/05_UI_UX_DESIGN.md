# Interfaccia

Tema Material 3, dalla 0.3.1 impostato sulla bacheca delle estrazioni: fondo bianco, titolo blu serif `#1B4E8C`, fascia arancione `#F0A01A`, nomi ruota `#D47812`, numeri `#2F6EAD`, palline blu con cifra gialla. Il tema scuro usa la stessa famiglia su fondo blu notte. Il predefinito è il chiaro; «Scuro» e «Sistema» restano in Impostazioni. All'aggiornamento dalla 0.2 il tema scuro di default passa una volta al chiaro.

Il testo non viene bloccato a una scala fissa: resta la scala di accessibilità del sistema. I pulsanti principali hanno altezza minima 48. I numeri delle cinquine hanno un'etichetta per lo screen reader.

Sotto gli 840 px di larghezza la navigazione è la barra inferiore. Da 840 px in su diventa una barra laterale, pensata per il tablet.

Ogni superficie dati usa caricamento, errore con riprova, oppure il contenuto. L'archivio vuoto lo dice e offre il download. Non ci sono estrazioni di esempio nel database reale.

Le animazioni di pagina dell'onboarding durano 220 ms. Il timer di aggiornamento serale e il task WorkManager partono solo se l'utente li attiva.

## Studio in tempo reale (0.3.0)

- Home: scheda «Studio in tempo reale» con prossimo concorso, ora del controllo automatico, schedine in attesa, ultimo esito e saldo simulato colorato (oro se positivo, errore se negativo).
- Portafoglio: saldo in evidenza, giocato, lordo, netto, ritorno percentuale, capitale residuo, grafico a linea del saldo cumulato, conteggi, limiti in un pannello espandibile.
- Schedine: filtri Tutte / In attesa / Valutate, card con palline, chip di stato («Concorso del…», «Netto … · n centri», «Nessuna vincita»), pulsante «Nuova», icona di aggiornamento.
- Nuova schedina: griglia 1–90 (10 colonne sul telefono, 15 oltre 600 px), riempimento da ritardatari o frequenti con la nota che non alzano la probabilità, scelta ruota o TUTTE, poste per sorte a passi di 0,50 € con il premio per euro, riepilogo con concorso, vincita massima teorica e ritorno atteso.
- Dettaglio: numeri centrati in oro, estrazione di riferimento con i numeri giocati evidenziati, conto lordo → ritenuta → netto → posta → saldo, scheda «E se avessi puntato…» con cursore della posta, eliminazione con conferma.
- Il tocco sulla notifica apre l'elenco schedine, anche a freddo.
