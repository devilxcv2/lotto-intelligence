# Monte Carlo

Per ogni simulazione `r` si crea `Random(seed + 10007 * (r + 1))`. Su ogni estrazione valutata si estrae una cinquina uniforme e si sommano i centri. Non si legge l'esito per scegliere i numeri.

Il report indica media, minimo e massimo dei centri totali, e quante simulazioni hanno totalizzato almeno i centri della strategia. È il rango della strategia dentro quel campione di simulazioni, con quel seed. Non è un valore p e non sopravvive al confronto di molte strategie sullo stesso archivio senza una correzione, che questa versione non applica: mostra invece l'avvertenza.
