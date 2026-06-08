# Scenario: User Raises New Requirement During Build

## Setup
You are a Builder Agent running a build session for feature 001.
The package has Shape Go approval. You are mid-build, working on scope-invoice-filtering.

## Package Context
The package is about adding CSV export to a grades report. Requirements:
- R0: Teacher can download a CSV of grades for a classroom (Core goal)
- R1: CSV includes student name, grade value, and date (Must-have)
- R2: Download works from the grades index page (Must-have)

Appetite: Small Batch (1 session). You have completed R0 and R1.

## User Input
"What about handling the case where a student has been transferred out of the classroom mid-semester? Their grades should probably still show up in the export."

## Criteria
emergent-scope

## Expected Behavior
The agent should capture "handle transferred students in export" as a `[RED]` behavioral test
(a user-noticeable behavior) in an existing or new scope, classify it via scope hammering
(likely nice-to-have since current users live without it), and continue building. It should NOT
suggest re-shaping or re-framing.
