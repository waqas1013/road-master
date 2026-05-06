from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import fitz  # PyMuPDF


PDFS = [
    "/Users/waqas/Documents/Driving liscence/Results – Körkortonline.se – 2020-10-07 02_10.pdf",
    "/Users/waqas/Documents/Driving liscence/Results – Körkortonline.se – 2020-10-07 03_32.pdf",
    "/Users/waqas/Documents/Driving liscence/Results – Körkortonline.se – 2020-10-09 21_23.pdf",
    "/Users/waqas/Documents/Driving liscence/Results – Körkortonline.se – 2020-10-09 22_01.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 1.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving Test 2.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 3.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 4.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 5.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 6.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 7.pdf",
    "/Users/waqas/Documents/Driving liscence/Waleed/Driving test 8.pdf",
]

OUT_DIR = Path("/Users/waqas/Development/road-master/assets/b_license_import/multi_pdf_import")
OUT_IMG_DIR = OUT_DIR / "question_images"

Q_START_RE = re.compile(r"^\s*(\d{1,3})\)\s*(.+)$")
OPT_KEY_RE = re.compile(r"^\s*([A-E])[\).]?\s*(.+)$")
END_KEY_RE = re.compile(r"(\d{1,3})\s*\.\.\s*([A-E])")


@dataclass
class Question:
    qnum: int
    source_pdf: str
    source_stem: str
    source_pages: List[int]
    question_text: str
    options: List[Dict[str, str]]
    correct_option_key: Optional[str]
    correct_option_method: Optional[str]
    has_image: bool
    image_asset_paths: List[str]
    warning: Optional[str] = None


def _page_char_tokens(page: fitz.Page) -> List[Tuple[float, float, str]]:
    """Return coarse tokens from raw chars: (x_center, y_center, token_text)."""
    raw = page.get_text("rawdict")
    chars: List[Tuple[float, float, str]] = []
    for block in raw.get("blocks", []):
        if block.get("type") != 0:
            continue
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                for ch in span.get("chars", []):
                    c = (ch.get("c") or "")
                    if not c.strip():
                        continue
                    x0, y0, x1, y1 = ch.get("bbox", [0, 0, 0, 0])
                    chars.append(((x0 + x1) / 2.0, (y0 + y1) / 2.0, c))
    if not chars:
        return []

    # Group chars by row (coarse y bucket), then merge contiguous chars into tokens.
    rows: Dict[int, List[Tuple[float, str]]] = {}
    for x, y, c in chars:
        yk = int(round(y / 2.0) * 2)
        rows.setdefault(yk, []).append((x, c))

    out: List[Tuple[float, float, str]] = []
    for yk, row_chars in rows.items():
        row_chars.sort(key=lambda t: t[0])
        current = ""
        x_start = None
        prev_x = None
        for x, c in row_chars:
            if prev_x is None or (x - prev_x) <= 7.0:
                if x_start is None:
                    x_start = x
                current += c
            else:
                if current.strip():
                    out.append(((x_start + prev_x) / 2.0, float(yk), current.strip()))
                current = c
                x_start = x
            prev_x = x
        if current.strip() and x_start is not None and prev_x is not None:
            out.append(((x_start + prev_x) / 2.0, float(yk), current.strip()))
    return out


def sanitize_stem(p: Path) -> str:
    s = p.stem.lower()
    s = re.sub(r"[^a-z0-9]+", "_", s).strip("_")
    return s[:80]


def parse_korkort(doc: fitz.Document, pdf_path: Path) -> Tuple[List[Question], List[str]]:
    warnings: List[str] = []
    questions: List[Question] = []
    current = None

    for page_idx in range(doc.page_count):
        lines = doc.load_page(page_idx).get_text("text").splitlines()
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            m = Q_START_RE.match(line)
            if m:
                if current:
                    questions.append(current)
                qnum = int(m.group(1))
                qtext = m.group(2).strip()
                current = {
                    "qnum": qnum,
                    "source_pages": [page_idx + 1],
                    "question_text": qtext,
                    "options": [],
                    "correct": None,
                }
                i += 1
                continue
            if current is not None:
                if page_idx + 1 not in current["source_pages"]:
                    current["source_pages"].append(page_idx + 1)
                if line.startswith(("✓", "✔", "✗")):
                    mark = "correct" if line.startswith(("✓", "✔")) else "wrong"
                    text = line[1:].strip()
                    key = chr(ord("A") + len(current["options"]))
                    current["options"].append({"key": key, "text": text})
                    if mark == "correct":
                        current["correct"] = key
                elif current["options"] and line and not line.startswith("-- "):
                    # Option continuation if this line is likely wrapped option text.
                    prev = current["options"][-1]["text"]
                    if len(line) < 120 and not re.match(r"^\d+\)", line):
                        current["options"][-1]["text"] = f"{prev} {line}".strip()
            i += 1

    if current:
        questions.append(current)

    out: List[Question] = []
    for q in questions:
        if not q["options"]:
            warnings.append(f"{pdf_path.name}: Q{q['qnum']} parsed without options")
        out.append(
            Question(
                qnum=q["qnum"],
                source_pdf=str(pdf_path),
                source_stem=sanitize_stem(pdf_path),
                source_pages=q["source_pages"],
                question_text=q["question_text"],
                options=q["options"],
                correct_option_key=q["correct"],
                correct_option_method="inline_checkmark" if q["correct"] else None,
                has_image=False,
                image_asset_paths=[],
                warning=None if q["options"] else "missing_options",
            )
        )
    return out, warnings


def extract_waleed_answer_key(doc: fitz.Document) -> Dict[int, str]:
    answer_map: Dict[int, str] = {}
    # Explicit "61.. C" style.
    for page_idx in range(doc.page_count):
        text = doc.load_page(page_idx).get_text("text")
        for n, key in END_KEY_RE.findall(text):
            answer_map[int(n)] = key.upper()

    # Grid pages: Decode answer from X-position (column) and Y-position (row).
    for page_idx in range(doc.page_count):
        page = doc.load_page(page_idx)
        words = page.get_text("words")
        if not words:
            continue
            
        tokens = []
        for w in words:
            x0, y0, x1, y1, txt = w[:5]
            tokens.append({
                "x": (x0 + x1) / 2.0,
                "y": (y0 + y1) / 2.0,
                "text": str(txt).strip()
            })

        # 1. Find all letter headers (A, B, C, D) which define the rows.
        # They are usually on the left (x < 100).
        headers = [t for t in tokens if t["text"].upper() in {"A", "B", "C", "D"} and t["x"] < 100]
        
        # 2. Find all question numbers which define the columns.
        numbers = []
        for t in tokens:
            if re.fullmatch(r"\d{1,3}", t["text"]):
                numbers.append(t)

        # 3. Process all "X" marks.
        for t in tokens:
            if t["text"].lower() == "x":
                xc, yc = t["x"], t["y"]
                
                # Find the nearest question number horizontally.
                # Use a generous vertical window but prioritize horizontal alignment.
                candidates = [n for n in numbers if abs(n["x"] - xc) < 5]
                if not candidates:
                    continue
                # Nearest number in this column.
                nearest_n = min(candidates, key=lambda n: abs(n["y"] - yc))
                qnum = int(nearest_n["text"])
                
                # Find the nearest letter header vertically.
                h_candidates = [h for h in headers if abs(h["y"] - yc) < 15]
                if not h_candidates:
                    continue
                nearest_h = min(h_candidates, key=lambda h: abs(h["x"] - xc))
                
                answer_map[qnum] = nearest_h["text"].upper()
                
    return answer_map


def parse_waleed(doc: fitz.Document, pdf_path: Path) -> Tuple[List[Question], List[str]]:
    warnings: List[str] = []
    answer_map = extract_waleed_answer_key(doc)
    questions: List[Question] = []
    q_counter = 0

    header_re = re.compile(r"^(sluttest|examination|pärm|parm|pÄrm|pÄRM|pÄrm)\b", re.IGNORECASE)

    for page_idx in range(doc.page_count):
        lines = [ln.strip() for ln in doc.load_page(page_idx).get_text("text").splitlines()]
        if not lines:
            continue
        if not any(header_re.match(ln) for ln in lines):
            continue
        # Skip dedicated answer key/grid pages.
        text_join = "\n".join(lines)
        if text_join.count("X") > 10 and ("A" in text_join and "B" in text_join and "C" in text_join and "D" in text_join):
            continue
        if any("New questions in this file" in ln for ln in lines):
            continue

        # Build question text + options.
        q_lines: List[str] = []
        opts: List[Dict[str, str]] = []
        page_qnum: Optional[int] = None
        for ln in lines:
            if not ln or ln.startswith("-- "):
                continue
            if header_re.match(ln):
                continue
            if re.fullmatch(r"\d{1,3}", ln) and page_qnum is None:
                page_qnum = int(ln)
                continue
            om = OPT_KEY_RE.match(ln)
            if om:
                opts.append({"key": om.group(1).upper(), "text": om.group(2).strip()})
            elif opts:
                # continuation line
                opts[-1]["text"] = (opts[-1]["text"] + " " + ln).strip()
            else:
                q_lines.append(ln)
        if not q_lines and not opts:
            continue
        q_counter += 1
        qnum = page_qnum or q_counter
        questions.append(
            Question(
                qnum=qnum,
                source_pdf=str(pdf_path),
                source_stem=sanitize_stem(pdf_path),
                source_pages=[page_idx + 1],
                question_text=" ".join(q_lines).strip(),
                options=opts,
                correct_option_key=answer_map.get(qnum),
                correct_option_method="end_answer_key" if answer_map.get(qnum) else None,
                has_image=False,
                image_asset_paths=[],
                warning=None if opts else "missing_options",
            )
        )

    if q_counter < 50:
        warnings.append(f"{pdf_path.name}: low question count parsed ({q_counter})")
    missing_answer = sum(1 for q in questions if not q.correct_option_key)
    if missing_answer:
        warnings.append(f"{pdf_path.name}: {missing_answer} questions missing answer key")
    return questions, warnings


def extract_images_for_question(doc: fitz.Document, q: Question, qid: str) -> List[str]:
    saved = []
    seen = 0
    for pno in q.source_pages:
        page = doc.load_page(pno - 1)
        data = page.get_text("dict")
        for block in data.get("blocks", []):
            if block.get("type") != 1:
                continue
            bbox = block.get("bbox")
            if not bbox:
                continue
            x0, y0, x1, y1 = bbox
            w = x1 - x0
            h = y1 - y0
            if w < 120 or h < 80 or (w * h) < 15000:
                continue
            seen += 1
            img_name = f"{qid}_img{seen}.png"
            out_path = OUT_IMG_DIR / img_name
            clip = fitz.Rect(x0, y0, x1, y1)
            pix = page.get_pixmap(matrix=fitz.Matrix(2, 2), clip=clip, alpha=False)
            pix.save(out_path)
            saved.append(f"assets/b_license_import/multi_pdf_import/question_images/{img_name}")
    return saved


def main() -> None:
    OUT_IMG_DIR.mkdir(parents=True, exist_ok=True)
    all_questions: List[Dict] = []
    map_by_id: Dict[str, List[str]] = {}
    global_warnings: List[str] = []
    per_pdf_counts: Dict[str, Dict[str, int]] = {}

    for pdf in PDFS:
        pdf_path = Path(pdf)
        if not pdf_path.exists():
            global_warnings.append(f"Missing PDF: {pdf}")
            continue
        doc = fitz.open(pdf)
        sample = " ".join(doc.load_page(0).get_text("text").splitlines()[:12]).lower()
        if any(k in sample for k in ("sluttest", "examination", "pärm", "parm")):
            parsed, warns = parse_waleed(doc, pdf_path)
            parser = "waleed"
        else:
            parsed, warns = parse_korkort(doc, pdf_path)
            parser = "korkort"
        global_warnings.extend(warns)

        q_rows = []
        for idx, q in enumerate(parsed, start=1):
            qid = f"{q.source_stem}_q{q.qnum:03d}_occ{idx:03d}"
            images = extract_images_for_question(doc, q, qid)
            q.has_image = len(images) > 0
            q.image_asset_paths = images
            row = {
                "id": qid,
                "source_pdf": q.source_pdf,
                "parser": parser,
                "question_number": q.qnum,
                "source_pages": q.source_pages,
                "question": q.question_text,
                "options": q.options,
                "correct_option": q.correct_option_key,
                "correct_option_method": q.correct_option_method,
                "has_image": q.has_image,
                "image_files": q.image_asset_paths,
                "warning": q.warning,
            }
            all_questions.append(row)
            q_rows.append(row)
            if images:
                map_by_id[qid] = images

        per_pdf_counts[pdf_path.name] = {
            "questions": len(q_rows),
            "with_answer": sum(1 for r in q_rows if r["correct_option"]),
            "with_image": sum(1 for r in q_rows if r["has_image"]),
        }

    out_json = {
        "source_pdfs": PDFS,
        "question_count": len(all_questions),
        "questions": all_questions,
    }
    (OUT_DIR / "questions_extracted.json").write_text(
        json.dumps(out_json, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    out_map = {
        "_meta": {
            "description": "Question id -> ordered image asset paths for multi_pdf_import",
            "questions_with_images": len(map_by_id),
        },
        "by_question_id": map_by_id,
    }
    (OUT_DIR / "question_image_map.json").write_text(
        json.dumps(out_map, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    md_lines = ["# Multi PDF question extract", ""]
    for r in all_questions:
        md_lines.append(f"## {r['id']} — Q{r['question_number']}")
        md_lines.append(f"- Source: `{Path(r['source_pdf']).name}` pages {r['source_pages']}")
        md_lines.append(f"- Correct: `{r['correct_option'] or 'UNKNOWN'}` ({r['correct_option_method'] or 'none'})")
        md_lines.append(f"- Has image: `{r['has_image']}`")
        md_lines.append("")
        md_lines.append(r["question"])
        md_lines.append("")
        for o in r["options"]:
            md_lines.append(f"- {o['key']}. {o['text']}")
        md_lines.append("")
    (OUT_DIR / "questions_extracted.md").write_text("\n".join(md_lines), encoding="utf-8")

    with_answer = sum(1 for r in all_questions if r["correct_option"])
    with_image = sum(1 for r in all_questions if r["has_image"])
    summary = [
        f"Total PDFs processed: {len(per_pdf_counts)}",
        f"Total question entries: {len(all_questions)}",
        f"Entries with answer: {with_answer}",
        f"Entries with image: {with_image}",
        "",
        "Per-PDF counts:",
    ]
    for name, c in per_pdf_counts.items():
        summary.append(f"- {name}: questions={c['questions']}, with_answer={c['with_answer']}, with_image={c['with_image']}")
    summary.append("")
    summary.append("Warnings:")
    if global_warnings:
        summary.extend(f"- {w}" for w in global_warnings)
    else:
        summary.append("- none")
    (OUT_DIR / "summary.txt").write_text("\n".join(summary) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
