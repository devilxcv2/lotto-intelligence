# Architettura

L'app è Flutter, feature-first. Il dominio statistico e combinatorio non importa Flutter. Il database Drift sta sotto i repository. L'interfaccia legge provider Riverpod.

```mermaid
flowchart LR
  UI[Schermate] --> Providers
  Providers --> Repo[Repository]
  Repo --> DB[(SQLite)]
  Repo --> Motori[Statistiche Sistemi Backtest]
  Sync[ArchiveSync] --> HTTP[Dio ZIP]
  Sync --> Parser[Parser TSV CSV JSON]
  Sync --> Repo
  AI[AiRepository] --> Secrets[Secure storage]
  AI --> HTTP
```

Dipendenze verso il basso: le schermate non scrivono SQL. I motori non aprono la rete. Il parser non decide se una riga è «ufficiale»: imposta solo l'integrità strutturale.

```mermaid
flowchart TD
  Splash --> Onboarding
  Onboarding --> Dashboard
  Dashboard --> Estrazioni
  Dashboard --> Statistiche
  Dashboard --> Laboratorio
  Dashboard --> Altro
```

Le cinque destinazioni della barra sono Home, Estrazioni, Statistiche, Laboratorio e Altro. Le schermate secondarie stanno nelle route figlie di quel ramo.
