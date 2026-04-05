---
name: gliner2
description: Extracts entities, classifies text, and extracts relationships from text using  GLiNER2. Use when the user needs named entity recognition (NER), text classification, zero-shot labeling, or relation extraction on arbitrary text with custom labels — no training required. Triggers: entity extraction, NER, classify text, sentiment, relationship extraction, zero-shot classification, label text.
---

# GLiNER2 Inference

Zero-shot entity extraction, text classification, and relationship extraction using GLiNER2. Runs locally — no API key needed.

## Quick Start

```python
from gliner2 import GLiNER2

model = GLiNER2.from_pretrained("fastino/gliner2-base-v1")
result = model.extract_entities(
    "Apple CEO Tim Cook announced iPhone 15 in Cupertino.",
    ["company", "person", "product", "location"],
    include_confidence=True,
)
print(result)
```

## Environment Setup

1. Install the package:
   ```bash
   uv add gliner2
   ```
2. The first call to `GLiNER2.from_pretrained(...)` downloads the model to the HuggingFace cache. This is a one-time cost.
3. Available models:

   | Model | Params | Notes |
   |---|---:|---|
   | `fastino/gliner2-base-v1` | 205M | Default — good balance of speed and quality |
   | `fastino/gliner2-large-v1` | 340M | Higher accuracy, slower |


## Procedure

Determine which task(s) the user needs, build a Python script, execute it, and summarize the results.

### Step 1 — Identify the Task

| User wants… | Method |
|---|---|
| Extract entities / NER | `extract_entities()` |
| Classify text | `classify_text()` |
| Find relationships between entities | `extract_relations()` |
| Multiple tasks on the same text | Combined schema via `create_schema()` |

### Step 2 — Build the Script

Write a complete Python script to a temporary file at `.search/gliner2_task.py`. For short one-liners, `uv run python -c "..."` is acceptable, but for multi-line text always write to a file to avoid shell escaping issues.

Use the recipes below based on the task.

### Step 3 — Execute

```bash
uv run python .search/gliner2_task.py
```

Read the output and summarize results to the user. Delete the temp file after.

---

## Entity Extraction (NER)

### Basic extraction

```python
from gliner2 import GLiNER2

model = GLiNER2.from_pretrained("fastino/gliner2-base-v1")
result = model.extract_entities(
    "Apple CEO Tim Cook announced iPhone 15 in Cupertino yesterday.",
    ["company", "person", "product", "location"],
    include_confidence=True,
)
print(result)
```

### With descriptions (improves accuracy for ambiguous or domain-specific types)

Pass entity types as a dict mapping label → description:

```python
result = model.extract_entities(
    text,
    {
        "medication": "Names of drugs or pharmaceutical substances",
        "dosage": "Specific amounts like '400mg' or '2 tablets'",
        "symptom": "Medical symptoms or patient complaints",
    },
    include_confidence=True,
)
```

### Batch extraction (multiple texts)

```python
results = model.batch_extract_entities(texts, labels, batch_size=32)
```

**When choosing entity types:** Ask the user what to extract. If vague, suggest common types (person, organization, location, date, product). For domain-specific text (legal, medical, financial), always use descriptions.

---

## Text Classification

### Single-task classification

```python
from gliner2 import GLiNER2

model = GLiNER2.from_pretrained("fastino/gliner2-base-v1")
result = model.classify_text(
    "This product exceeded my expectations! Absolutely love it.",
    {"sentiment": ["positive", "negative", "neutral"]},
)
print(result)
```

### Multi-task classification (classify on multiple dimensions at once)

```python
result = model.classify_text(
    text,
    {
        "sentiment": ["positive", "negative", "neutral"],
        "urgency": ["high", "medium", "low"],
        "category": {
            "labels": ["tech", "finance", "politics", "sports"],
            "multi_label": False,
        },
    },
)
```

### Multi-label classification (text can have multiple labels)

```python
schema = model.create_schema().classification(
    "topics",
    ["technology", "business", "health", "politics", "sports"],
    multi_label=True,
    cls_threshold=0.3,
)
result = model.extract(text, schema)
print(result)
```

**Defaults:** Use single-label unless the user asks for multi-label. For multi-label, start with `cls_threshold=0.3`. Multiple classification dimensions can run in one call.

---

## Relationship Extraction

### Basic relation extraction

```python
from gliner2 import GLiNER2

model = GLiNER2.from_pretrained("fastino/gliner2-base-v1")
result = model.extract_relations(
    "John works for Apple Inc. and lives in San Francisco.",
    ["works_for", "lives_in"],
    include_confidence=True,
)
print(result)
# {'relation_extraction': {'works_for': [('John', 'Apple Inc.')], ...}}
```

### With descriptions

```python
result = model.extract_relations(
    text,
    {
        "works_for": "Employment relationship between person and organization",
        "located_in": "Physical location of an entity",
    },
    include_confidence=True,
)
```

**Relation types** are directional tuples `(head, tail)`. Define them using verb phrases (e.g., `works_for`, `founded_by`, `located_in`). Use descriptions for domain-specific relations.

---

## Combined Extraction (Multiple Tasks in One Pass)

When the user wants multiple extraction types from the same text, combine into one schema:

```python
from gliner2 import GLiNER2

model = GLiNER2.from_pretrained("fastino/gliner2-base-v1")
schema = (
    model.create_schema()
    .classification("sentiment", ["positive", "negative", "neutral"])
    .entities(["company", "product", "person", "location"])
    .relations(["works_for", "located_in", "manufactures"])
)
result = model.extract(text, schema)
print(result)
```

Always prefer combined schema over separate calls for efficiency.

---

## Practical Guidance

| Topic | Guidance |
|---|---|
| **Model choice** | Use `gliner2-base-v1` by default. Only suggest `large` if user reports poor quality or has a GPU. |
| **Threshold tuning** | Default thresholds work well. Lower for recall-heavy tasks, raise for precision-heavy. |
| **Entity descriptions** | Always use descriptions for domain-specific extraction (legal, medical, financial). |
| **Long text** | GLiNER2 has a token limit from its encoder. For long documents, split into paragraphs and use `batch_extract_entities`. |
| **Max span width** | Default `max_width=8` limits entity span to ~8 tokens. Increase if extracting long entity names. |
| **Output format** | Default to `include_confidence=True` so the user can judge extraction quality. |
| **Caching** | Model loading takes a few seconds. For many texts, write one script that loads the model once and loops over all inputs. |

## Error Handling

| Error | Fix |
|---|---|
| `ModuleNotFoundError: No module named 'gliner2'` | Run `uv add gliner2`. |
| CUDA out of memory | Use `gliner2-base-v1` instead of `large`, or ensure no other GPU processes are running. |
| Empty results | Add entity/relation descriptions, lower thresholds, or use more general type names. |
| Slow first run | Model download is one-time; subsequent runs use the HuggingFace cache. |

## Out of Scope

This skill covers **inference only**. It does not cover: training, fine-tuning, LoRA adapters, API mode (`from_api()`), structured JSON extraction (`extract_json`), regex validators, or model publishing.
