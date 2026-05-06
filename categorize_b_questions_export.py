import json
import os
import re
from collections import defaultdict

def categorize(question_text, options_text):
    text = (question_text + " " + options_text).lower()
    
    keywords = {
        'Signs & Signals': ['sign', 'signal', 'traffic light', 'yellow light', 'red light', 'marking', 'lines', 'painted', 'road signs'],
        'The Human Factor': ['alcohol', 'drug', 'medicine', 'tired', 'fatigue', 'stress', 'reaction time', 'peer pressure', 'drunk', 'vision', 'blind', 'driver'],
        'Environment & Tech': ['eco', 'fuel', 'emission', 'catalytic', 'carbon', 'co2', 'environment', 'wash', 'heater', 'tire pressure', 'exhaust'],
        'Vehicle & Documents': ['registration', 'inspection', 'mot', 'insurance', 'liability', 'steering', 'brakes', 'tread depth', 'load', 'weight', 'towing', 'trailer', 'cargo', 'tyre', 'tire'],
        'Safety & Pedestrians': ['pedestrian', 'child', 'cyclist', 'safety', 'distance', 'blind spot', 'accident', 'collision', 'dark', 'visibility', 'icy', 'slippery', 'snow', 'winter', 'fog'],
        'Traffic Rules': ['right of way', 'give way', 'priority', 'speed', 'limit', 'overtake', 'parking', 'stopping', 'roundabout', 'intersection', 'crossing', 'motorway', 'highway', 'lane', 'turn', 'driving']
    }
    
    scores = defaultdict(int)
    for cat, words in keywords.items():
        for w in words:
            if w in text:
                scores[cat] += text.count(w)
                
    if not scores:
        return 'Traffic Rules'
    return max(scores.items(), key=lambda x: x[1])[0]

def normalize_text(text):
    if not text: return ""
    # Remove extra whitespace, convert to lower
    text = re.sub(r'\s+', ' ', text).strip().lower()
    return text

all_entries = []

# 1. Load Local Extracted PDF
try:
    with open("assets/b_license_import/b_questions_extracted.json", "r") as f:
        text = f.read()
        first_brace = text.find("{")
        data1 = json.loads(text[first_brace:])
        for q in data1["questions"]:
            q["source_file"] = "b_questions_extracted.json"
            all_entries.append(q)
except Exception as e:
    print(f"Warning loading local json: {e}")

# 2. Load Multi PDF Import
try:
    with open("assets/b_license_import/multi_pdf_import/questions_extracted.json", "r") as f:
        data2 = json.load(f)
        for q in data2["questions"]:
            q["source_file"] = "multi_pdf_import.json"
            all_entries.append(q)
except Exception as e:
    print(f"Warning loading multi-pdf json: {e}")

# 3. Deduplicate
grouped = defaultdict(list)
for q in all_entries:
    key = normalize_text(q.get("question", ""))
    grouped[key].append(q)

final_questions = []
for key, entries in grouped.items():
    if not key: continue
    
    # Selection Strategy:
    # 1. Prefer entries with a correct_option
    # 2. Prefer entries with an image
    # 3. Prefer entries with more options
    
    # Sort entries by "quality"
    def quality_score(e):
        score = 0
        if e.get("correct_option"): score += 100
        if e.get("has_image"): score += 50
        score += len(e.get("options", []))
        return score
    
    best = max(entries, key=quality_score)
    
    # Mark for review if no answer is found
    if not best.get("correct_option"):
        best["needs_review"] = True
    else:
        best["needs_review"] = False
    
    # Assign category if not already present
    if not best.get("category"):
        opt_text = " ".join([o.get("text", "") for o in best.get("options", [])])
        best["category"] = categorize(best.get("question", ""), opt_text)
    
    final_questions.append(best)

# Sort by category then original id to keep some order
final_questions.sort(key=lambda x: (x.get("category", ""), x.get("id", "")))

# Split into Ready and Needs Review
ready_questions = [q for q in final_questions if not q.get("needs_review")]
needs_review_questions = [q for q in final_questions if q.get("needs_review")]

# 1. Save Ready Questions (for the app)
output_ready = {
    "total_count": len(ready_questions),
    "unique_questions": len(ready_questions),
    "original_total_count": len(final_questions),
    "questions": ready_questions
}

with open("assets/b_license_import/b_license_categorized.json", "w") as f:
    json.dump(output_ready, f, indent=2)

# 2. Save Needs Review Questions (separately)
output_review = {
    "total_count": len(needs_review_questions),
    "questions": needs_review_questions
}

with open("assets/b_license_import/b_license_needs_review.json", "w") as f:
    json.dump(output_review, f, indent=2)

print(f"Deduplication & Splitting Complete!")
print(f"Original entries: {len(all_entries)}")
print(f"Final unique questions: {len(final_questions)}")
print(f"Ready for App: {len(ready_questions)}")
print(f"Needs Review (Stored Separately): {len(needs_review_questions)}")


