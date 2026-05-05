# B-license import (`assets/b_license_import/`)

**Scope:** This README describes **only** this folder — questions, images, and how to use them in code.

**Flutter clone / machine setup:** read the **repository root** `README.md` first (`firebase_options.dart`, `flutter pub get`, etc.).

---

## Why this is in Git

So **`git clone`** always restores the full extract (JSON + PNGs). No extra USB step; the repo is the backup.

---

## Files (short)

| File / folder | Role |
|---------------|------|
| `b_questions_extracted.json` | Main data: stems, options, flags, optional inferred answers |
| `question_image_map.json` | `by_question_id` → ordered Flutter asset paths for PNGs (easiest lookup) |
| `question_images/*.png` | Images tied to question `id` in filenames |
| `b_questions_extracted.md`, `summary.txt` | Human / stats review |

All relevant paths must stay listed under **`pubspec.yaml`** → `flutter: assets:`.

---

## Coverage (important)

| | Count |
|--|--------|
| Question rows | **900** |
| With ≥1 image | **360** |
| Text-only | **540** |
| Has inferred **`correct_option`** | **493** |
| No inferred answer | **407** — **do not assume** correct |

Inferred answers came from PDF bold styling (not an official key). Use confidence fields when you score.

---

## IDs and images

- **Primary key:** `id` (e.g. `q005_occ001`). **`display_number`** can repeat; **`id`** does not.
- **Has image?** Use **`question_image_map.json`** → if `by_question_id[id]` is missing, **no images** for that row.
- **Or** from JSON: `has_image` + **`image_files`** → use **basename only** → `assets/b_license_import/question_images/<basename>`.
- **`image_files`** may contain old absolute paths from another PC — **ignore directory; basename only.**

---

## Answers

- If **`correct_option`** is set → best-effort guess; check **`correct_option_confidence`** / **`correct_option_method`**.
- If missing → treat as **unknown** until curated.

---

## How to integrate (same idea as taxi)

Taxi today: **`assets/taxi/bank/questions.json`** + **`TaxiQuestionBank`** (`rootBundle.loadString`) + optional **`TaxiBankImage`** / Storage URLs in JSON.

For B-license, unless you redesign on purpose:

1. **Keep** this folder layout and filenames (JSON + `question_images/` + map).
2. **Load JSON** with **`rootBundle.loadString`** (`b_questions_extracted.json`; parse JSON — if parse fails, strip bytes **before the first `{`**).
3. **Resolve images** from **`question_image_map.json`** or basenames from JSON as above.
4. **Reuse** taxi-style widgets (**`TaxiBankImage`**, lightbox) where it fits, or add B-specific wrappers.
5. **Later:** optional Firebase Storage + HTTPS URLs (same pattern as taxi bank scripts) with **`Image.asset`** fallback.

**Avoid:** moving PNGs/JSON without updating **`pubspec.yaml`** and **`question_image_map.json`**; assuming every row has **`correct_option`**; removing this folder from Git without another backup.

---

## Regenerate `question_image_map.json`

After a **new** `b_questions_extracted.json` (e.g. re-export from PDF): parse the JSON (start at first `{`), for each question with non-empty **`image_files`**, map **`id`** → list of `assets/b_license_import/question_images/<basename>` in order.
