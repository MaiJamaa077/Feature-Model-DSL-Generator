-- ─────────────────────────────────────────────────────────────
-- SmartHomeError.fm → SmartHomeError.als
-- Act 2  —  void model (Alloy reports "No instance found")
-- ─────────────────────────────────────────────────────────────
--
-- Same as SmartHome but adds one contradictory constraint:
--   Security excludes Security
--
-- WHY THIS IS A CONTRADICTION:
--   "must Security"         →  Security must ALWAYS be selected
--   "Security excludes Security" →  Security and Security cannot BOTH be selected
--                                   = Security can NEVER be selected
--
--   Must be selected  +  Can never be selected  =  impossible
--   → No configuration can exist → Alloy says "No instance found"

module SmartHomeError

abstract sig Feature {}

one sig Security extends Feature {}
one sig Lights   extends Feature {}
one sig WiFi     extends Feature {}

pred valid[s : set Feature] {

  Security in s        -- Security is mandatory
  WiFi in s            -- WiFi is mandatory

  Lights in s implies WiFi in s          -- Lights requires WiFi

  not (Security in s and Security in s)  -- Security excludes Security (CONTRADICTION)

}

run valid for 5
