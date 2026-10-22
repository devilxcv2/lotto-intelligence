# AI remota

Provider `openai` e `openai_compatible` usano:

- `GET {endpoint}/models` per la prova;
- `POST {endpoint}/chat/completions` con `response_format` json_object.

L'endpoint deve essere HTTPS, salvo i casi LAN descritti per Ollama. La chiave, se inserita, va nel secure storage e nell'header `Authorization`. Non viene scritta nel database, nel riepilogo del log né nel messaggio di errore mostrato: in caso di fallimento si vede solo il codice HTTP o «connessione non riuscita».

Timeout configurabile da 5 a 120 secondi.

Nessuna chiave è nel repository.
