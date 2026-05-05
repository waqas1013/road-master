# B-license theory import (PDF extract)

**For another AI or teammate:** reading **this whole file** is enough to integrate the data (coverage, file roles, JSON fields, images, answers, and Flutter paths). You do not need a separate pasted prompt.

This folder holds **driving theory (B)** content extracted from a PDF. It is intended for **local development** (often untracked in Git). Flutter loads assets listed in `pubspec.yaml` under `assets/b_license_import/…`.

## What we have (coverage)

| Item | Count / note |
|------|----------------|
| **Question entries in JSON** | **900** (one row per PDF occurrence) |
| **With at least one image** | **360** (`has_image: true` and/or non-empty `image_files`) |
| **Without image** | **540** (`has_image: false`, `image_files: []`) |
| **With an inferred correct answer** | **493** — see `correct_option` + `correct_option_method` |
| **Missing inferred correct answer** | **407** — no reliable bold-based detection; **do not assume** an answer |

Correct answers were **inferred** from the PDF (bold option: font metadata first, then a visual “darkness” fallback). This is **not** the same as an official answer key; use `correct_option_confidence` and plan for **manual review** before high-stakes scoring.

## Files

| File | Purpose |
|------|---------|
| `b_questions_extracted.json` | **Canonical** structured data for the app / code generation |
| `question_image_map.json` | **Derived:** `by_question_id` → list of Flutter-ready asset paths (`assets/b_license_import/question_images/…`). Only questions **with** images appear (~360). Multi-image questions have several paths in **order**. Easiest file for another AI to resolve “which PNGs for this `id`?” without parsing absolute paths in the main JSON. |
| `b_questions_extracted.md` | Human-readable dump for spot-checking |
| `summary.txt` | Extraction stats (counts above) |
| `question_images/` | PNG snippets; filenames tie to question `id` |

## JSON shape (per question)

- **`id`**: Stable unique key, e.g. `q005_occ001` (`q` + display number + `_occ` + occurrence). **Use this as the primary key.**
- **`display_number` / `occurrence`**: The same “display” number can appear more than once; **`id` is unique.**
- **`question`**: Stem text.
- **`options[]`**: `key` (`a`, `b`, …), `text`, plus `font_bold_ratio` / `visual_darkness` (for QA of extraction only).
- **`correct_option`**: Option key when detection ran, e.g. `"b"`. **May be absent** for many rows.
- **`correct_option_method`**: `font_bold` or `visual_darkness` when `correct_option` is set.
- **`correct_option_confidence`**: 0–1 when present.
- **`has_image`**: Boolean.
- **`image_files`**: List of paths from the machine that ran extraction — often **absolute paths**. **Do not use paths as-is in the app.**

## Mapping question → image (for an AI or engineer)

**Already linked in data:** each question row in `b_questions_extracted.json` carries **`has_image`** and **`image_files`** for that question only — no separate join table is required.

**Easiest path for tooling:** open **`question_image_map.json`** and look up **`by_question_id["q005_occ001"]`** → ordered list of asset paths ready for `Image.asset(...)` / `rootBundle`.

From the main JSON only:

1. Read **`has_image`**. If `false` (and `image_files` empty), the question is **text-only** for this extract.
2. If `true`, use **`image_files`**: take only the **filename** (e.g. `q005_occ001_img1.png`).
3. Flutter **asset** path: `assets/b_license_import/question_images/<filename>` (must match `pubspec.yaml` `assets:` entries).
4. Filenames align with **`id`**: e.g. `q005_occ001` → `q005_occ001_img1.png`, possibly `_img2.png`, etc.

**Regenerating `question_image_map.json`** (if you edit the main JSON): strip any bytes before the first `{` in `b_questions_extracted.json`, parse JSON, then for each question build basename paths under `assets/b_license_import/question_images/` from `image_files`.

## Mapping question → answer

1. If **`correct_option`** is present, treat it as the **model’s best guess** from PDF bold styling; check **`correct_option_confidence`** and **`correct_option_method`**.
2. If **`correct_option`** is **missing**, the extract **does not** provide an answer — the app should not score those as “known correct” until curated or re-processed.

## One-line integration rules (duplicate of sections above)

- Primary key: question **`id`**. Load stems/options from **`b_questions_extracted.json`** (parse JSON; if needed, skip any garbage before the first `{`).
- Images: prefer **`question_image_map.json`** → `by_question_id[id]`; absent key ⇒ no images.
- Answers: use **`correct_option`** only when present; many rows have no inferred answer.

## Re-generating paths

If `image_files` still contain old absolute prefixes from another machine, **only the filename** matters for the app; paths in JSON are not authoritative for runtime.
