# Project Strategy: (X1) Feature Models to Alloy

This document outlines the complete strategy for developing your Generative Software Engineering project, specifically tailored to hit every requirement in the grading rubric to secure a top mark.

## 1. Core Technical Architecture (The "Dual DSL")
As explicitly required, the project cannot just model features; it must also model specific products (configurations). 

*   **DSL 1: Feature Model DSL (`.fm`):** A language to define the domain. It will support:
    *   Root features and sub-features (Tree structure)
    *   Feature types: Mandatory, Optional, `OR` groups, `XOR` groups (Alternatives)
    *   Cross-tree constraints (e.g., `requires`, `excludes`)
*   **DSL 2: Product Configuration DSL (`.config`):** A language for the user to select specific features to build a "Product". The generator will check if this configuration is valid according to the `.fm` model.

## 2. Code Generation & Tooling (Tutorial Style)
To comply with the requirement to follow the course's "structure and style," we will strictly adhere to the standard Eclipse Xtext tooling:
*   **MWE2 Workflow:** We will use the standard MWE2 workflow to generate the language infrastructure.
*   **Xtend Dispatch Methods:** The code generator (`.xtend`) will heavily utilize `dispatch` methods to cleanly separate the translation logic for different AST nodes (e.g., dispatching differently for an `OptionalFeature` vs an `XorGroup`). 
*   **Target Language (Alloy):** The generator will output `.als` files. Alloy's relational logic is perfectly suited for checking tree constraints and configurations.

## 3. Maximizing "Technical Achievement" (50% of Grade)
To score beyond a basic pass, our generator will implement "Advanced Checks" by automatically generating Alloy `run` and `check` commands to verify:
1.  **Product Validity:** "Is the user's specific `.config` valid under this feature model?"
2.  **Void Feature Models:** "Is it mathematically impossible to build *any* product from this model due to conflicting constraints?"
3.  **Dead Features:** "Are there specific features in this model that can never be selected in any valid product?"

## 4. Evaluation and Generalizability (15% of Grade)
To prove the tool works for a "class of problems" and not just one hardcoded example, we will build and test models across **three distinct domains**:
1.  **Smart Home System** (Sensors, Cameras, Alarms)
2.  **E-Commerce Platform** (Payment gateways, Search functionality, User reviews)
3.  **Mobile Phone Lineup** (Screen types, Storage sizes, 5G capabilities)

## 5. The "Explainability" Guarantee (Avoiding the 0)
Because you must explain the submitted work during your presentation, we will:
*   Comment every block of Xtend code to explain exactly *why* a specific Alloy string is being generated.
*   Ensure the generated Alloy logic is readable and maps directly to the concepts you present, so you can confidently walk the instructor through the entire pipeline.

---

## Next Milestone: Intermediate Presentation (July 10th)
**Goal:** Deliver a working "Proof of Concept".
Instead of just slides, you will present a live demo in the Eclipse IDE demonstrating:
1.  A basic `.fm` file being successfully parsed (e.g., Mandatory/Optional features).
2.  The MWE2/Xtend pipeline automatically generating a small, mathematically sound `.als` file in real-time.

> [!IMPORTANT]
> **User Review Required**
> Please review this strategy. If this roadmap looks solid to you, let's proceed to writing the initial Xtext Grammar for the Feature Model DSL to hit our July 10th deadline!
