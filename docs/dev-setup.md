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

## Web Gemma setup
Web cannot run `flutter_gemma` locally. Configure a server-side endpoint
that accepts `POST` JSON in this shape:

```json
{
  "messages": [
    {"role": "user", "content": "Hello"}
  ],
  "stream": false
}
```

Then set these in `.env.json`:

```json
{
  "GEMMA_WEB_API_URL": "https://your-api.example.com/gemma/chat",
  "GEMMA_WEB_API_KEY": "optional",
  "GOOGLE_WEB_CLIENT_ID": "1234567890-xxxxx.apps.googleusercontent.com"
}
```

`GOOGLE_WEB_CLIENT_ID` is required for Google sign-in on web.

Run web:

```bash
make run-web
```

If you run web from an IDE launch profile, include:

```bash
--dart-define-from-file=.env.json
```

Otherwise Firebase env values will be empty at compile time and web auth fails
with `auth/invalid-api-key`.

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
