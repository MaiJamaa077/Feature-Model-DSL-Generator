module PoC

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

}

-- ============================================================
-- VOID MODEL CHECK
-- "run" asks the Alloy Analyzer to find a satisfying instance.
--
--   Found an instance  =>  the feature model is SATISFIABLE
--                          (at least one valid product exists)
--
--   No instance found  =>  the constraints are CONTRADICTORY
--                          (no valid product can be built)
--
-- "for 5" sets the scope: search within worlds of up to 5 atoms.
-- ============================================================
run validConfiguration for 5
