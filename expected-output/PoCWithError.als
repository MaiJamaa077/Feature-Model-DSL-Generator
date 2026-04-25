module PoCWithError

-- ============================================================
-- FEATURE SIGNATURES
-- Each feature becomes a singleton Alloy signature.
-- "one sig" means: exactly one atom of this type exists.
-- "extends Feature" places it in the Feature type hierarchy.
-- ============================================================
abstract sig Feature {}

one sig Security extends Feature {}
one sig Lighting extends Feature {}
one sig Connectivity extends Feature {}
one sig WiFi extends Feature {}
one sig Bluetooth extends Feature {}

-- ============================================================
-- VALIDITY PREDICATE
-- A predicate is a named constraint block.
-- "selected : set Feature" is the parameter representing which
-- features are chosen in a particular product configuration.
-- ============================================================
pred validConfiguration[selected : set Feature] {

    -- Security is mandatory: must always be selected
    Security in selected

    -- Lighting is optional: no forced constraint

    -- Connectivity is mandatory: must always be selected
    Connectivity in selected

    -- XOR group under Connectivity: exactly one of {WiFi, Bluetooth}
    Connectivity in selected implies (one f : WiFi + Bluetooth | f in selected)
    (WiFi + Bluetooth) & selected != none implies Connectivity in selected

    -- Lighting requires WiFi
    Lighting in selected implies WiFi in selected

    -- CONTRADICTION: Security excludes Security
    -- This says Security and Security cannot both be selected.
    -- But "mandatory Security" forces Security into every configuration.
    -- These two constraints are mutually exclusive → no valid config exists.
    not (Security in selected and Security in selected)

}

-- ============================================================
-- VOID MODEL CHECK
-- Expected result: "No instance found"
-- Explanation: The excludes constraint on Security conflicts
-- with the mandatory constraint on Security. No configuration
-- can satisfy both simultaneously.
-- ============================================================
run validConfiguration for 5
