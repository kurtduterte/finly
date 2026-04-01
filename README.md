# Finly

Finly is an offline-first personal finance tracker that makes expense logging effortless. Most people know they're spending money but have no clear picture of where it actually goes — manually entering every purchase is tedious, so it never happens consistently.

Finly solves this by letting you photograph a receipt and having an on-device AI (Gemma 3) extract the expense automatically. No cloud, no subscription, no data leaving your phone.

## Main Features

- **Receipt scanning** — point your camera at a receipt and Finly creates the expense entry for you using a local LLM
- **Expense management** — organize spending by account and category
- **AI chat** — ask questions about your finances in a persistent, multi-conversation chat powered by the same on-device model
- **Optional sync** — back up and restore data via Firestore when you want cross-device access

## Docs

- [Architecture](docs/architecture.md)
- [Developer Setup](docs/dev-setup.md)
