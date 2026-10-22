# Architettura AI

I motori locali implementano una proposta di studio, non un addestramento.

- A, `UniformEngine`: campione uniforme, baseline.
- B, `DescriptiveWeightEngine`: peso = frequenza oppure ritardo, più uno, poi campionamento pesato senza reinserimento. Il peso non è la probabilità di uscita.
- C, `HeuristicFilterEngine`: filtro esplicito e, se restano almeno 5 numeri, campione uniforme. Se il filtro ne lascia meno, si ferma e lo dice.

Il modello classico di machine learning in un servizio separato non c'è. Il runtime on-device oltre a Ollama in rete non è stato verificato su questo hardware come dipendenza dell'app, quindi non è obbligatorio e non è incluso.

`AiRepository.generateRemote` chiede JSON con `numbers`, `method` e `rationale`. Valida la cinquina. Ignora eventuali probabilità nel testo e aggiunge il vincolo scientifico dell'app. La spiegazione del modello non è trattata come accuratezza.

Ogni proposta locale o remota accettata finisce in `predictions` e `prediction_numbers`.
