/*
 * FeatureModelGenerator.xtend  —  SIMPLIFIED PoC Generator
 *
 * 4 methods only. One job each. Fits on one screen.
 * ─────────────────────────────────────────────────────────
 *
 * WHAT THIS CLASS DOES IN ONE SENTENCE:
 *   It reads the EMF model that Xtext built from the .fm file,
 *   and writes an Alloy .als file that Alloy Analyzer can verify.
 *
 * FLOW:
 *   Save .fm
 *     → Xtext calls doGenerate()
 *       → toAlloy() assembles the file text
 *         → toSignature() handles each feature's "one sig" line
 *         → toConstraintLine() handles each mandatory/requires/excludes line
 *           → fsa.generateFile() writes the .als file to disk
 */
package org.example.poc.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.example.poc.featureModel.FeatureModel
import org.example.poc.featureModel.Feature
import org.example.poc.featureModel.Constraint
import org.example.poc.featureModel.Kind

class FeatureModelGenerator extends AbstractGenerator {

    // ── Method 1 ─────────────────────────────────────────────
    // ENTRY POINT — Xtext calls this automatically when you save a .fm file.
    //
    // It does two things:
    //   1. Gets the model object (the root FeatureModel) from the resource
    //   2. Writes the generated text to a .als file in src-gen/
    //
    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
        val model = resource.contents.head as FeatureModel
        fsa.generateFile(model.name + ".als", toAlloy(model))
    }


    // ── Method 2 ─────────────────────────────────────────────
    // ASSEMBLER — builds the complete Alloy text.
    //
    // The ''' ... ''' syntax is an Xtend template (multi-line string).
    // «expression» inserts a value.  «FOR x : list» ... «ENDFOR» is a loop.
    //
    // Three sections are produced:
    //   (a) one sig per feature     ← signatures
    //   (b) mandatory constraints   ← from Feature.kind
    //   (c) cross-tree constraints  ← from Constraint objects
    //
    def String toAlloy(FeatureModel model) '''
        module «model.name»

        -- Every feature is a singleton type that extends the abstract Feature type.
        abstract sig Feature {}
        «FOR f : model.features»
        «toSignature(f)»«ENDFOR»

        -- A configuration = a set of selected features.
        -- This predicate lists the rules a valid configuration must obey.
        pred valid[s : set Feature] {
        «FOR f : model.features»«toConstraintLine(f)»«ENDFOR»
        «FOR c : model.constraints»«toConstraintLine(c)»«ENDFOR»
        }

        -- Ask Alloy: "find a valid configuration within scope 5"
        -- Found an instance  →  the model is satisfiable (valid products exist)
        -- No instance found  →  the constraints contradict each other (void model)
        run valid for 5
    '''


    // ── Method 3 ─────────────────────────────────────────────
    // SIGNATURE — turns one Feature into one Alloy signature line.
    //
    //   Feature.name = "Security"
    //   →  one sig Security extends Feature {}
    //
    // "one sig" = exactly one atom of this type exists in every world.
    // "extends Feature" = Security IS-A Feature (subtype).
    //
    def String toSignature(Feature f) {
        '''one sig «f.name» extends Feature {}'''
    }


    // ── Method 4a ────────────────────────────────────────────
    // CONSTRAINT LINE (Feature) — turns a feature's variability into Alloy.
    //
    //   must Security  →  Security in s    (always selected)
    //   may  Lights    →  (nothing)        (no rule needed for optional)
    //
    def String toConstraintLine(Feature f) {
        if (f.kind == Kind.MANDATORY)
            '''  «f.name» in s        -- «f.name» is mandatory
'''
        else
            ""   // optional features need no constraint
    }


    // ── Method 4b ────────────────────────────────────────────
    // CONSTRAINT LINE (Constraint) — turns a cross-tree constraint into Alloy.
    //
    //   Lights requires WiFi
    //     →  Lights in s implies WiFi in s
    //
    //   Security excludes Debug
    //     →  not (Security in s and Debug in s)
    //
    // c.source and c.target are resolved by Xtext cross-references —
    // we just use .name to get back the feature's identifier string.
    //
    def String toConstraintLine(Constraint c) {
        switch c.op {
            case REQUIRES:
                '''  «c.source.name» in s implies «c.target.name» in s
'''
            case EXCLUDES:
                '''  not («c.source.name» in s and «c.target.name» in s)
'''
            default: ""
        }
    }
}
