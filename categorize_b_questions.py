import json
import os
import random
from collections import defaultdict

def categorize(question_text, options_text):
    text = (question_text + " " + options_text).lower()
    
    # Keyword definitions
    keywords = {
        'Signs & Signals': ['sign', 'signal', 'traffic light', 'yellow light', 'red light', 'marking', 'lines', 'painted', 'road signs'],
        'The Human Factor': ['alcohol', 'drug', 'medicine', 'tired', 'fatigue', 'stress', 'reaction time', 'peer pressure', 'drunk', 'vision', 'blind', 'driver'],
        'Environment & Tech': ['eco', 'fuel', 'emission', 'catalytic', 'carbon', 'co2', 'environment', 'wash', 'heater', 'tire pressure', 'exhaust'],
        'Vehicle & Documents': ['registration', 'inspection', 'mot', 'insurance', 'liability', 'steering', 'brakes', 'tread depth', 'load', 'weight', 'towing', 'trailer', 'cargo', 'tyre', 'tire'],
        'Safety & Pedestrians': ['pedestrian', 'child', 'cyclist', 'safety', 'distance', 'blind spot', 'accident', 'collision', 'dark', 'visibility', 'icy', 'slippery', 'snow', 'winter', 'fog'],
        # Default fallback is usually Traffic Rules or general
        'Traffic Rules': ['right of way', 'give way', 'priority', 'speed', 'limit', 'overtake', 'parking', 'stopping', 'roundabout', 'intersection', 'crossing', 'motorway', 'highway', 'lane', 'turn', 'driving']
    }
    
    scores = defaultdict(int)
    for cat, words in keywords.items():
        for w in words:
            if w in text:
                scores[cat] += text.count(w)
                
    if not scores:
        return 'Traffic Rules' # fallback
    
    return max(scores.items(), key=lambda x: x[1])[0]

all_questions = []

# Load b_questions_extracted.json
with open("assets/b_license_import/b_questions_extracted.json", "r") as f:
    text = f.read()
    first_brace = text.find("{")
    data1 = json.loads(text[first_brace:])
    for q in data1["questions"]:
        opt_text = " ".join([o.get("text", "") for o in q.get("options", [])])
        q["assigned_category"] = categorize(q.get("question", ""), opt_text)
        all_questions.append(q)

# Load multi_pdf_import/questions_extracted.json
with open("assets/b_license_import/multi_pdf_import/questions_extracted.json", "r") as f:
    data2 = json.load(f)
    for q in data2["questions"]:
        opt_text = " ".join([o.get("text", "") for o in q.get("options", [])])
        q["assigned_category"] = categorize(q.get("question", ""), opt_text)
        all_questions.append(q)

# Analyze
stats = defaultdict(list)
for q in all_questions:
    stats[q["assigned_category"]].append(q)

print(f"Total questions analyzed: {len(all_questions)}")
print("-" * 30)
for cat, qs in stats.items():
    print(f"{cat}: {len(qs)} questions")
    
    # Calculate how many sets if we divide by ~50 questions per set
    num_sets = max(1, len(qs) // 50)
    print(f"  -> Can be divided into ~{num_sets} sets")

