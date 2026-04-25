-- ─────────────────────────────────────────────────────────────
-- SmartHome.fm → SmartHome.als
-- Act 1  —  satisfiable model (Alloy will find valid products)
-- ─────────────────────────────────────────────────────────────
--
-- Feature model (what we wrote in SmartHome.fm):
--
--   must  Security   ← always selected
--   may   Lights     ← optional
--   must  WiFi       ← always selected
--   Lights requires WiFi
--
-- Valid products (manually computed):
--   Config A : { Security, WiFi }              ← Lights not selected, OK
--   Config B : { Security, WiFi, Lights }      ← Lights selected, WiFi present, OK
--   Config C : { Security, WiFi, Lights } only ← same as B
--
--   INVALID: { Security, Lights }   ← Lights needs WiFi, but WiFi is missing
--   (but this won't happen since WiFi is "must")

module SmartHome

-- ── SIGNATURES ───────────────────────────────────────────────
-- One atom per feature. "abstract" means no bare Feature atoms exist.
abstract sig Feature {}

one sig Security extends Feature {}
one sig Lights   extends Feature {}
one sig WiFi     extends Feature {}

-- ── VALIDITY PREDICATE ───────────────────────────────────────
-- s = the set of selected features in one product configuration
pred valid[s : set Feature] {

  Security in s        -- Security is mandatory
  WiFi in s            -- WiFi is mandatory

  Lights in s implies WiFi in s   -- Lights requires WiFi

}

-- ── RUN COMMAND ──────────────────────────────────────────────
-- Ask Alloy: find a valid configuration (scope: up to 5 atoms)
run valid for 5
