# AI locale

I motori A, B e C girano in Dart, anche senza rete e senza un modello scaricato.

Ollama è opzionale. In Modelli AI si imposta un endpoint. HTTP è accettato solo per localhost e per gli indirizzi privati 10.0.0.0/8, 192.168.0.0/16 e 172.16.0.0/12, così un server in LAN può essere raggiunto senza aprire il cleartext verso Internet. HTTPS è ammesso verso l'host indicato.

La prova di connessione per Ollama è `GET /api/tags`. La generazione è `POST /api/chat` con `format: json` e `stream: false`.

Se Ollama non risponde, il resto dell'app continua a funzionare.
