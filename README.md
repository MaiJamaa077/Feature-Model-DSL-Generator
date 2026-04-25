# Feature Model DSL Generator

A Domain-Specific Language (DSL) and code generator for Feature Modeling in Software Product Lines.

## Overview
This repository contains a proof-of-concept Generative Software Engineering project. It defines a custom Domain-Specific Language (DSL) using **Xtext** for declaring Feature Models (`.fm`), and includes a code generator written in **Xtend** that automatically translates these abstract models into Alloy (`.als`) specifications for formal verification.

## The Engineering Problem
In complex software architectures and Digital Twin implementations, managing variability (different features for different configurations) is notoriously error-prone. By creating a custom DSL and automating the generation of formal logic models, we can mathematically verify that a given software product line configuration is valid, constraint-free, and logically sound before a single line of application code is written.

## Key Features
* **Custom DSL (Xtext)**: Provides a clean, human-readable syntax for defining features, relationships (mandatory, optional), and constraints (requires, excludes).
* **Automated Code Generation (Xtend)**: Parses the custom `.fm` files and generates syntactically correct Alloy specification files (`.als`).
* **Formal Verification (Alloy)**: The output files can be executed in the Alloy Analyzer to find logical contradictions or dead features in the software architecture.
* **Eclipse Plugin Architecture**: Built as an Eclipse plugin, demonstrating knowledge of standard enterprise IDE extension models.

## Project Structure
- `org.example.poc/`: The core Eclipse plugin project containing the Xtext grammar (`FeatureModel.xtext`) and Xtend generator (`FeatureModelGenerator.xtend`).
- `models/`: Example Feature Models written in the custom DSL (e.g., `SmartHome.fm`).
- `expected-output/`: The generated Alloy models (`.als`) used for formal logic verification.

---
*Project Context: Developed as an advanced proof-of-concept for Generative Software Engineering and Model-Driven Architecture.*
