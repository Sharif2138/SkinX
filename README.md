# SkinX

**Skin-cancer screening and education for people with albinism in Rwanda, built to work without internet.**

People with albinism are at high risk of skin cancer, and in many parts of Rwanda a specialist or a stable connection is hard to come by. SkinX is a Flutter app that looks at a photo of a skin lesion **right on the phone** (TensorFlow Lite, no internet needed) and says whether it looks suspicious, with a heatmap of what the model focused on. It also has a health-education chatbot in English and Kinyarwanda, learning guides, and optional accounts so individuals and community health workers (CHWs) can keep a screening history.

> **This is a research prototype, not a medical device.** SkinX does not diagnose anything, and "Less suspicious" never means "no cancer". If a spot is growing, bleeding, changing or not healing,  see a health professional.

| Deliverable | Link |
|---|---|
| Walkthrough video | `<ADD VIDEO LINK>` |
| Technical report (PDF, 4 pages) | https://docs.google.com/document/d/1rRtq8FLkG8kfki29Ewr2VCMoVuEwNcr3wviql2OiA7Y/edit?usp=sharing |
| Android APK | `<ADD APK LINK>` or `release/skinx.apk` |

---

## Table of contents

1. [Features](#features)
2. [How it works](#how-it-works)
3. [Technical requirements](#technical-requirements)
4. [Repository structure](#repository-structure)
5. [Installation and running](#installation-and-running)
6. [Testing](#testing)
7. [Model results](#model-results)
8. [Design and code-quality notes](#design-and-code-quality-notes)
9. [Scope status](#scope-status)
10. [Limitations](#limitations)
11. [Data, privacy and ethics](#data-privacy-and-ethics)

---

## Features

| Feature | Description | Works offline |
|---|---|:---:|
| Lesion screening | Camera or gallery photo, returns **Suspicious**, **Less suspicious** or **Cannot infer** with the model score and decision threshold | Yes |
| Explanation heatmap | Class-activation-map overlay showing which regions drove the score (kept in memory, never saved) | Yes |
| Uncertainty abstention | Scores within ±0.05 of the threshold return *Cannot infer* instead of a forced label | Yes |
| Photo validation | JPEG/PNG only, ≤12 MB, ≤20 MP, brightness/contrast gate, EXIF orientation fix | Yes |
| Offline chatbot | 90-entry skin-health FAQ with fuzzy matching, English and Kinyarwanda | Yes |
| Online chatbot | FastAPI service calling a Groq-hosted LLM, tuned for albinism and Rwanda | No |
| Accounts and roles | Individual and CHW accounts (Supabase Auth); CHW records carry a patient name | No |
| Screening history | Offline-first SQLite history that syncs to Supabase when online | Local yes, sync no |
| Learn section | Prevention guides, self-check steps, video links | Guides yes, videos no |
| Privacy and consent | Consent screen; no image is stored or uploaded | Yes |

## How it works

Here is the whole picture, then a few notes on the parts that matter most.

```
                 ┌────────────────────────── Flutter app (mobile/) ──────────────────────────┐
 Camera/Gallery ─►  validate ─► preprocess (isolate) ─► TFLite (IsolateInterpreter)           │
                 │                 EXIF fix, quality gate,        │ score + 7x7 CAM           │
                 │                 224x224 letterbox              ▼                           │
                 │                              ScreeningDecisionPolicy (threshold + margin)  │
                 │                                   │                  │                     │
                 │                       Suspicious / Less suspicious / Cannot infer  heatmap │
                 │                                   ▼                                        │
                 │   SQLite history ◄── save ── ScreeningResultScreen                         │
                 │        │ sync (online only)                                                │
                 │        ▼                                                                   │
                 │   Supabase (Auth + Postgres, Row-Level Security)                           │
                 │                                                                            │
 Question ───────►  ChatbotService ─► OfflineKnowledgeBase (always) ─┐                        │
                 │         └─ if online ─► FastAPI /chat (backend/) ─► Groq LLM ─────────────┘│
                 └────────────────────────────────────────────────────────────────────────────┘
```

* **The model** is an EfficientNetB0 classifier ("target" means a cancerous or pre-cancerous lesion), shrunk to a 7.75 MiB float16 TFLite file. A second version also outputs a 7×7 activation map for the heatmap. The app tries that one first and falls back to the plain model if it can't load.
* **The decision** is simple: a score at or above 0.37495 is Suspicious, below that is Less suspicious, and anything within 0.05 of the threshold is Cannot infer, because the model isn't sure. The threshold and margin live in JSON config files, not in the code.
* **Chat never leaves you empty-handed.** The app works out the offline answer first, so if the internet or the backend fails, you still get that answer plus a short reason.

## Technical requirements

What you need depends on how much of the project you want to run. The app alone is the easiest.

| Component | Requirement |
|---|---|
| Flutter / Dart | Flutter stable that bundles **Dart ≥ 3.11.4** (see `mobile/pubspec.yaml`); check with `flutter --version` |
| Android | **minSdk 26** (Android 8.0+), Java 17, Android SDK + Gradle (via Flutter) |
| iOS / desktop | Project scaffolds exist but are **not tested** |
| Backend | Python **3.10+** (uses `X | None` typing), packages in `backend/requirements.txt` |
| Cloud (optional) | A Supabase project (Auth + Postgres) and a Groq API key |
| ML notebooks (optional) | Google Colab with GPU, TensorFlow 2.21, Google Drive for datasets |
| Hardware | Any Android phone with a camera; no GPU needed (CPU, 2 threads) |

Key Flutter packages: `tflite_flutter`, `image`, `image_picker`, `sqflite`, `supabase_flutter`, `http`, `connectivity_plus`, `url_launcher`, `flutter_svg`. Key Python packages: `fastapi`, `uvicorn`, `httpx`, `pydantic` v2, `python-dotenv`.

## Repository structure

The project is three parts that fit together: the notebooks that made the model, the app, and the optional chat service.

```
SkinX/
├── README.md
├── docs/                       # technical report, screenshots, performance evidence
├── backend/                    # optional online chat service
│   ├── app/
│   │   ├── main.py             # FastAPI app: /health, /chat, rate limiting, schemas
│   │   ├── check_groq.py       # CLI check that the Groq key/model work
│   │   └── skin_health_faq.json
│   ├── sql/
│   │   ├── 001_accounts_and_history.sql      # profiles, screening_records, RLS, triggers
│   │   └── 002_patient_names_for_chw.sql     # CHW patient-name rules
│   ├── tests/test_main.py      # 11 pytest cases
│   ├── env.example             # copy to .env
│   └── requirements.txt
├── ml/                         # model development (Colab notebooks, run in order)
│   ├── 01_data_eda_and_cleaning.ipynb
│   ├── 02_dataset_merging_and_patient_splits.ipynb
│   ├── 03_model_architecture_selection.ipynb
│   ├── 04_final_training_and_evaluation_updated.ipynb
│   ├── 05_pwa_evaluation_and_adaptation.ipynb
│   └── 06_SkinX_offline_mobile_model_CAM.ipynb
└── mobile/                     # Flutter app
    ├── lib/
    │   ├── main.dart, app_shell.dart, splash_screen.dart
    │   ├── *_screen.dart       # screening, result, history, learn, ask, account, auth, privacy
    │   ├── services/           # model, decision policy, chatbot, auth, history, connectivity, language
    │   ├── models/             # ScreeningResult value object
    │   ├── data/               # offline guides (EN / RW)
    │   └── widgets/            # reusable skinx_* UI components
    ├── assets/
    │   ├── models/             # *.tflite, config JSON, SHA-256
    │   ├── knowledge/          # offline FAQ
    │   └── parity_tests/       # synthetic fixture + expected output
    ├── config/dev.example.json # runtime configuration template
    ├── test/                   # unit and widget tests
    └── integration_test/       # on-device model parity test
```

## Installation and running

### 1. Clone

```bash
git clone https://github.com/Sharif2138/SkinX 
cd SkinX
```

### 2. Run the mobile app

Screening and the offline chatbot work straight away, with nothing to configure.

```bash
cd mobile
flutter pub get
flutter run
```

If you also want accounts and online chat, copy `config/dev.example.json` to `config/dev.json`, fill in your values, and run:

```bash
flutter run --dart-define-from-file=config/dev.json
```

| Key | Meaning |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_PUBLISHABLE_KEY` | Supabase publishable (anon) key. Never use a secret/service key in the app |
| `SKINX_API_URL` | Backend URL. Android emulator: `http://10.0.2.2:8000`; physical phone: your computer's LAN IP, e.g. `http://192.168.1.10:8000` |

To build an APK, run `flutter build apk --release`; it lands in `build/app/outputs/flutter-apk/`. Heads up: the release build is still signed with debug keys and uses the placeholder ID `com.example.skinx`, so change both before you publish it anywhere.

### 3. Run the backend (optional)

This is only needed for the online chat.

```bash
cd backend
python -m venv .venv
source .venv/bin/activate         # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp env.example .env               # then edit .env
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

`.env` settings:

| Variable | Purpose |
|---|---|
| `GROQ_API_KEY` | Groq API key (required for `/chat`; without it the API returns 503 `GROQ_KEY_MISSING`) |
| `GROQ_MODEL` | Default `openai/gpt-oss-20b` |
| `CHAT_HOURLY_LIMIT` | Requests per client per hour (default 60) |
| `CORS_ORIGINS` | Comma-separated allowed origins (only needed for browser clients) |
| `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Present in `env.example`; not used by the current `main.py` |

To check it's working, hit `curl http://localhost:8000/health`, and run `python -m app.check_groq` to confirm your key and model are accepted.

### 4. Set up accounts and history (optional)

In the Supabase SQL editor, run `backend/sql/001_accounts_and_history.sql` and then `002_patient_names_for_chw.sql`. Together they create the `profiles` and `screening_records` tables, the row-level security policies, and the triggers that enforce the CHW and individual record rules.

### 5. Reproduce the model (optional)

Open the notebooks in `ml/` in Colab and run them in order. The datasets are **not** in this repo, so download PAD-UFES-20 (Mendeley Data, DOI `10.17632/zr7vgbcyr2.1`) and MILK10k and put them in the Drive folders the notebooks expect. Notebook 06 produces the `.tflite` files, config JSON and test fixture that end up in `mobile/assets/`.

To confirm the bundled model files haven't been changed:

```bash
cd mobile/assets/models
sha256sum skinx_screening.tflite skinx_screening_cam.tflite
# compare with tflite_sha256 in the two *_config.json files
```

## Testing

Everything below runs from the command line. The backend tests mock Groq, so they need no key and no internet.

```bash
# Backend (run from the backend/ folder)
cd backend && pytest -q

# Flutter unit and widget tests
cd mobile && flutter test

# On-device model parity test (needs a connected Android device or emulator)
cd mobile && flutter test integration_test/offline_screening_test.dart -d <device-id>

# Static analysis
cd mobile && flutter analyze
```

| Approach | What it covers | Where |
|---|---|---|
| Unit | Decision policy boundaries and invalid inputs; API validation, rate limit, error mapping, prompt content | `mobile/test/screening_decision_policy_test.dart`, `backend/tests/test_main.py` |
| Widget / functional | Consent and patient-name rules, result display, borderline band, photo confirmation, live language switch | `mobile/test/*_test.dart` |
| Integration / parity | Real TFLite model vs. Colab golden score on a synthetic image, repeatability, empty input | `mobile/integration_test/` |
| Model validation | Patient-grouped splits, sealed test set, PWA source-group-held-out folds | `ml/03`–`ml/06` |

Latest results: `<ADD: pytest X passed; flutter test X/Y passed; device used for the integration test>`.

## Model results

These are the honest numbers, weak spots included.

| Evaluation | Result |
|---|---|
| Validation (n=339), locked threshold 0.375 | Sensitivity 0.941, specificity 0.811, AUROC 0.948 |
| Held-out conventional test (n=333) | Sensitivity 0.928, specificity 0.696, AUROC 0.868; melanoma sensitivity 8/21 |
| PWA pilot (33 images, provisional labels) | Sensitivity 28/28, specificity 2/5, AUROC 0.979. Descriptive only |
| TFLite float16 vs. Keras | Max score difference 0.005, identical validation decisions, 7.75 MiB, median 10.9 ms (Colab CPU) |
| Uncertainty margin 0.05 | Abstains on 2.7% of validation images; specificity among classified 0.851 |

We compared three architectures on validation AUROC: ResNet50 0.954 (90.6 MB), MobileNetV3Large 0.952 (12.1 MB) and EfficientNetB0 0.946 (16.3 MB). We went with EfficientNetB0 because it gave the best balance of accuracy and size for a phone.

On-device performance: `<ADD device table or link to docs/performance.md>`.

## Design notes

A few choices worth knowing about if you're reading the code:

* **Each folder has one job.** Screens, services, models, widgets and data are kept apart, and the decision rule (`ScreeningDecisionPolicy`) is a tiny class that knows nothing about the model or the UI, so it's easy to test.
* **`SkinXModelService` hides the messy parts.** Interpreter setup, config checks, the heatmap fallback and background isolates all sit behind `load()`, `screen()` and `close()`.
* **Config over code.** Threshold, margin, input shape and heatmap layout are read from JSON and validated at load, so a retrained model doesn't need code changes.
* **Screens take callbacks** (`onSave`, `onScreenPhoto`), which lets widget tests run without any platform plugins.
* **Some custom algorithms.** The offline chatbot repairs typos with a one-letter-edit check, scores FAQ matches on coverage and similarity, and refuses to answer when the top two are too close. There's also a heatmap that undoes the image padding, a sliding-window rate limiter, and a sync that can't create duplicates.
* **Secrets stay out of the code.** They live in `.env` or `--dart-define`, every Postgres table uses row-level security, and the backend never passes provider error text on to the app.

## Scope status

| Feature | Status |
|---|---|
| Offline screening, CAM heatmap, uncertainty abstention, photo validation | Completed |
| Offline and online chatbot, bilingual UI | Completed |
| Accounts, CHW role, synced history, consent | Completed |
| Learn guides and videos | Completed (videos need internet) |
| Model adapted to albinism skin | Partial (33 evaluation images, no PWA-trained model) |
| Clinical validation | Not implemented (out of scope) |
| iOS | Partial (scaffold only) |

## Limitations

* The model was trained on lighter-skin lesion datasets. The albinism evidence is just 33 images, and their labels come from the published sources, not from a dermatologist.
* It misses a lot of melanomas (it caught 8 of 21 in the test split), so it must not be used for clinical decisions.
* Benchmarks on real phones and testing on iOS still need to be done.
* The backend's rate limiting is kept in memory, per process.
* Offline Kinyarwanda answers are keyword-based and cover fewer topics than the English ones.

## Privacy and ethics

* Photos are processed on the phone. They are **not** uploaded or added to the SkinX history, and the heatmap only exists in memory. Your phone's camera or gallery may keep its own temporary copy outside SkinX.
* The local history in SQLite is **not encrypted**, so avoid using the app on a shared phone.
* Only the result label, the date and (for CHWs) a patient name are saved, and CHWs must confirm they have permission before saving a name.
* The online chat only sees the question you type and your recent messages, and the model is told to remind users not to share identifying health details.
* The datasets are used under their own licences; the notebooks list the sources.

## Licence and acknowledgements

`<ADD LICENCE, e.g. MIT, and add a LICENSE file>`. Built as a capstone project. Datasets: PAD-UFES-20 and MILK10k. Models: EfficientNetB0 (Keras Applications).
