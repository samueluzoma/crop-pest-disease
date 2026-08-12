# Crop pest insect detection API

Backend used by the Flutter **web** build only (native Android/iOS/desktop keep running the TFLite model on-device — see `lib/prediction/prediction_service_io.dart`). It loads the same `model_unquant.tflite` used by the app and exposes it over HTTP.

## Run locally

```
python3 -m pip install -r requirements.txt
python3 -m uvicorn main:app --reload
```

Serves on `http://localhost:8000`. The Flutter web build defaults to this address in dev (see `lib/prediction/prediction_service_web.dart`); override it at build time with `--dart-define=API_BASE_URL=https://your-backend-url`.

## Endpoints

- `GET /health` — returns `{"status": "ok", "labels": [...]}`
- `POST /predict` — multipart form field `file` (image); returns `{"label": ..., "confidence": ...}`

## Deploying to Render

`render.yaml` at the repo root is a Blueprint that provisions both services from this one repo:
- `crop-pest-disease-api` — this backend, Python web service.
- `crop-pest-disease-web` — the Flutter web build, static site, built with `--dart-define=API_BASE_URL=https://crop-pest-disease-api.onrender.com` so it points at the API above.

In the Render dashboard: New → Blueprint → select this GitHub repo → Apply.

**Free-tier note:** `tensorflow` is a large dependency and free-tier services have 512MB RAM and spin down when idle (slow cold start + the model has to reload each time). If the build times out or the service gets OOM-killed on first request, switching to a paid instance type (or swapping `tensorflow` for the lighter `tflite-runtime` package, if a compatible wheel exists for Render's Python version) are the two ways out.
