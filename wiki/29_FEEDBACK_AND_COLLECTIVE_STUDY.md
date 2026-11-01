# Feedback e studio collettivo

## Segnalazioni (ora)

Dall’app: **Più → Segnala bug o richiesta**.

- Tipi: bug, richiesta, idea.
- Invio: apre una Issue su GitHub del repository pubblico, con titolo e testo già compilati.
- Copia locale: `feedback_outbox.json` nei documenti dell’app (fino a 100 voci), per uno smistamento futuro su database senza perdere lo storico del telefono.

## Smistamento (dopo)

Database lato progetto per classificare Issues / outbox: priorità, area (Lotto, SE, Soldi, sync…), stato. L’app continuerà a usare GitHub o un endpoint dedicato.

## Modellino AI sulle schedine di studio (roadmap)

Idea: con **consenso esplicito**, raccogliere schedine di studio anonimizzate (numeri, ruota/gioco, esito simulato) e allinearle allo ZIP ufficiale delle estrazioni.

- Obiettivo: descrizione e cluster (cosa giocano le persone in studio, quali pattern ricorrono **dopo** le uscite), non previsione del prossimo concorso.
- Vincoli: niente soldi reali, opt-in, niente dati personali nelle colonne di gioco, disclaimer scientifico invariato.
- Ingressi previsti: outbox/export schedine + archivio ZIP già usato in app.

Finché non c’è opt-in e backend, questa parte resta solo documentazione.
