# Feature Model PoC — Explanation

> 

## The Big Picture (one paragraph)

We write a feature model in a simple text file (`.fm`).
A tool called **Xtext** reads that file and builds an object in memory
(called an **EMF model**). Our **Xtend generator** then reads that object
and writes an **Alloy file** (`.als`). Finally, the **Alloy Analyzer** reads
that file and tells us whether a valid product configuration exists.

```
SmartHome.fm  →  [Xtext]  →  objects in memory  →  [Generator]  →  SmartHome.als  →  [Alloy]  →  ✓ or ✗
```

That's the entire pipeline. Every file in this project serves one of those steps.

---

## Step 1 — The Grammar (`FeatureModel.xtext`)

### What is a grammar?

A grammar is a set of rules that tell the parser "what text is allowed and what it means."
Think of it like a recipe: "a feature model starts with the word `model`, then a name, then `{`, then features, then `}`."

### Our grammar has exactly 5 rules

**Rule 1 — FeatureModel** (the whole file)

```
model SmartHome {
    ...features go here...
}
constraints {
    ...constraints go here...
}
```

→ Creates a `FeatureModel` object with a `name` and two lists.

---

**Rule 2 — Feature** (one line per feature)

```
must Security
may  Lights
must WiFi
```

→ Creates a `Feature` object with a `kind` (must or may) and a `name`.

---

**Rule 3 — Constraint** (relationships between features)

```
Lights requires WiFi
Security excludes Debug
```

→ Creates a `Constraint` object with a `source`, an `op` (requires/excludes), and a `target`.
The `[Feature]` notation means "look up this name in the file and link to that Feature object."

---

**Rule 4 — Kind** (enum: what does `must`/`may` mean?)

```
must  →  MANDATORY  (always in every product)
may   →  OPTIONAL   (included or not, your choice)
```

---

**Rule 5 — ConstraintType** (enum: what does the relationship mean?)

```
requires  →  if A is selected, B must also be selected
excludes  →  A and B cannot both be selected
```

---

### What Xtext does with the grammar

After you run the MWE2 workflow once, Xtext reads the grammar and generates:

- A **parser** — reads `.fm` text → builds objects in memory
- **Java classes** — one class per rule (e.g. `FeatureModel.java`, `Feature.java`)
- An **Eclipse editor** — syntax highlighting + error markers for free

You never write these yourself. They are generated from the grammar.

---

## Step 2 — Objects in Memory (the EMF Model)

After Xtext parses `SmartHome.fm`, the following objects exist in memory:

```
FeatureModel
  name = "SmartHome"
  features = [
    Feature { kind=MANDATORY, name="Security" }
    Feature { kind=OPTIONAL,  name="Lights"   }
    Feature { kind=MANDATORY, name="WiFi"     }
  ]
  constraints = [
    Constraint { source=→Security, op=REQUIRES, target=→WiFi }
  ]
```

The arrows (`→`) are cross-references — they point to the actual Feature objects, not copies.
This is the input the generator will read.

---

## Step 3 — The Generator (`FeatureModelGenerator.xtend`)

### What is the generator?

A class that reads the EMF model objects and writes text.
It is called automatically by Eclipse whenever you save a `.fm` file.

### Our generator has 4 methods

**Method 1 — `doGenerate()`** (entry point, called by Eclipse)

```xtend
val model = resource.contents.head as FeatureModel
fsa.generateFile(model.name + ".als", toAlloy(model))
```

Gets the root object. Writes the output file. That's all.

---

**Method 2 — `toAlloy(model)`** (assembles the full .als text)

Uses Xtend template syntax (`''' ... '''`). Loops over features and constraints.
Calls methods 3 and 4 for each element.

---

**Method 3 — `toSignature(f)`** (one line per feature)

```
Feature.name = "Security"  →  one sig Security extends Feature {}
```

"one sig" = exactly one atom of this type. "extends Feature" = it IS a Feature.

---

**Method 4a — `toConstraintLine(feature)`** (variability → Alloy)

```
must Security  →  Security in s        (must be in the selected set)
may  Lights    →  (nothing)            (no rule needed for optional)
```

**Method 4b — `toConstraintLine(constraint)`** (relationship → Alloy)

```
Lights requires WiFi  →  Lights in s implies WiFi in s
Security excludes X   →  not (Security in s and X in s)
```

---

## Step 4 — The Generated Alloy (`SmartHome.als`)

```alloy
module SmartHome

abstract sig Feature {}
one sig Security extends Feature {}
one sig Lights   extends Feature {}
one sig WiFi     extends Feature {}

pred valid[s : set Feature] {
  Security in s
  WiFi in s
  Lights in s implies WiFi in s
}

run valid for 5
```

### Reading this in plain English

| Line                                  | Plain English                                                                         |
| ------------------------------------- | ------------------------------------------------------------------------------------- |
| `abstract sig Feature {}`             | "Feature" is a category. Nothing is directly a Feature — only its subtypes are.       |
| `one sig Security extends Feature {}` | There is exactly one thing called Security. It is a Feature.                          |
| `pred valid[s : set Feature]`         | "valid" is a named rule that checks whether a set of features `s` is a legal product. |
| `Security in s`                       | Security must always be in the product.                                               |
| `WiFi in s`                           | WiFi must always be in the product.                                                   |
| `Lights in s implies WiFi in s`       | If Lights is in the product, WiFi must also be.                                       |
| `run valid for 5`                     | "Find me a set `s` that satisfies all the rules above."                               |

---

## Step 5 — Alloy Verification

### Act 1 — SmartHome.als (satisfiable)

Alloy finds: `s = { Security, WiFi }` ✓
Or: `s = { Security, WiFi, Lights }` ✓

**What to say:** "The analyzer found a valid product — the model is satisfiable. These are real products you could build."

---

### Act 2 — SmartHomeError.als (void)

The extra constraint `Security excludes Security` generates:

```alloy
not (Security in s and Security in s)
```

Which simplifies to: `Security NOT in s`.

But we also have: `Security in s` (mandatory).

Both cannot be true → **No instance found**.

**What to say:** "The tool automatically detected that no valid product exists. The constraints contradict each other. This is the whole point — formal verification catches errors that are invisible to the naked eye."

---

## The One-Slide Summary

```
┌──────────────────────────────────────────────────────────────────┐
│  YOU WRITE           XTEXT DOES          YOU WRITE    ALLOY DOES │
│                                                                  │
│  Grammar    →    Parser + Editor    →    Generator  →  Verify    │
│  (5 rules)       (generated auto)       (4 methods)  (✓ or ✗)   │
│                                                                  │
│  Feature.xtext → FeatureModel.java → SmartHome.als → Instance?  │
└──────────────────────────────────────────────────────────────────┘
```

The professor sees:

- You know what a grammar is and what it produces
- You know what a generator is and what it produces
- You know what Alloy verification means (satisfiable vs void)

That is the proof of concept. ✓

---

## Setup (before the presentation)

1. Open Eclipse → **File → Import → Existing Projects into Workspace** → select `org.example.poc/`
2. Right-click `GenerateFeatureModel.mwe2` → **Run As → MWE2 Workflow** (generates parser + Java classes)
3. **Run As → Eclipse Application** (launches a second Eclipse window)
4. In the second Eclipse: create a General Project, drag in `SmartHome.fm`
5. Save `SmartHome.fm` → `SmartHome.als` appears automatically in `src-gen/`
6. Open `SmartHome.als` in Alloy Analyzer → **Execute** → show instance
7. Repeat with `SmartHomeError.fm` → show "No instance found"
