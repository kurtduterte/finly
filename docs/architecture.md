# Architecture

## Feature Structure
Each feature under `lib/features/<name>/` follows:
```
data/         # repositories, data sources, models
presentation/ # screens/, widgets/, providers/
```

## Layers (strict direction: presentation → data)
- **presentation** — UI widgets, Riverpod providers, screen routing
- **data** — repositories, Drift DAOs, external services
- **ai** — Gemma service (standalone, no feature dependency)
- **core** — shared utilities, errors, constants, db schema

## Key Files
| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, `_StartupRouter` |
| `lib/ai/gemma_service.dart` | flutter_gemma wrapper |
| `lib/config/ai_config.dart` | AI constants |
| `lib/core/db/` | Drift database |

## State Management
Riverpod only. No `ChangeNotifier`, no `setState` in business logic.

## Navigation
GoRouter declared in `lib/core/` — screens never push directly.
