# Developer Setup

## Prerequisites
- Flutter SDK (stable)
- Android SDK (minSdk 24) or iOS 16+ simulator

## First-time model download
```bash
mkdir -p assets/models
curl -L -H "Authorization: Bearer hf_YOUR_TOKEN" \
  "https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task" \
  -o assets/models/gemma3-1b-it-int4.task
```
Model is gitignored. Required to run the app.

## Common commands
```bash
make run        # flutter run
make gen        # build_runner (freezed, drift, json_serializable)
make lint       # dart analyze + format check
make test       # flutter test
```

## Code generation
Run `make gen` after modifying any `@freezed`, `@JsonSerializable`, or Drift table class.
Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis.
