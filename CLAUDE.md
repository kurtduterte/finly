# Finly — Claude Guidelines

Offline-first personal finance tracker. Photo receipt → local Gemma LLM → expense entry. No internet required at runtime.

## Docs
- [Architecture](docs/architecture.md)
- [Dev Setup](docs/dev-setup.md)

## Code Rules

### Imports
Use `package:finly/` — never relative imports from `lib/`.

### File size
**Max ~150 lines per file.** Split by responsibility when approaching the limit:
- Extract widgets to `widgets/`
- Extract logic to a provider or repository
- Extract constants to `core/constants/`

### Separation of concerns
- Screens own **layout only** — no business logic, no direct API calls
- Providers own **state + logic** — no `BuildContext` dependency
- Repositories own **data access** — no UI imports
- Never import a `presentation/` file from `data/`

### Readable code
- Name things for what they **do**, not what they are (`fetchReceipt` not `receiptData`)
- One public export per file
- No multi-responsibility classes — if a class does two things, split it
- Prefer `final` everywhere; avoid `late` unless init order requires it

### Dart style
- Named params: required before optional — `{required this.x, super.key}`
- Fire-and-forget: `unawaited(someFuture())` in `initState`
- Error handling: `on SomeException catch` — never bare `catch`
- Private State classes: `_MyWidgetState`

### State (Riverpod)
- No `setState` for business logic
- No `ChangeNotifier`
- Providers live in `presentation/providers/` within their feature

### AI / Gemma
See `lib/ai/gemma_service.dart` for the correct flutter_gemma 0.12.6 API.
Do **not** use `FlutterGemma.instance` — use static methods directly.

## Tooling
- Linter: `very_good_analysis` — no doc comment requirement (`public_member_api_docs: false`)
- Code gen: `make gen` after modifying freezed/drift/json classes
- Hooks: Lefthook runs lint + format on pre-commit
