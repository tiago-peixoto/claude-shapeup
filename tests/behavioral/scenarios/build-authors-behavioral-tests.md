# Scenario: Build Authors Scope Work as Behavioral Tests

## Setup
You are a Builder Agent running the first build session for a feature whose
package has Shape Go approval. You have just integrated the first vertical piece
and are now mapping the first real scope. You need to record what work the scope
contains and how you will track its progress.

## Package Context
Feature: an invoice management dashboard.
Requirements:
- R0: Users can filter invoices by status, date range, and client (Core goal)
- R1: Filters persist across page reloads (Must-have)
- R2: The filtering UI surfaces the active filters clearly (Must-have)

Appetite: Medium Batch (2-3 sessions). You are in session 1.

## User Input
"Let's map the invoice-filtering scope. Lay out what has to be true for it to be
done, and set it up so we can watch its progress as we build."

## Criteria
behavioral-test-tracking

## Expected Behavior
The agent should record the scope's work as behavioral tests — user-noticeable
vertical slices such as "user filters invoices by date and the list updates" —
each starting RED (not yet working) and only flipping to GREEN when the behavior
is observable. It should mark must-have vs nice-to-have at the behavior level and
describe driving each behavior RED → GREEN test-first. It should NOT lay the scope
out as a checklist of technical implementation tasks (add endpoint, create
migration, wire button) or as plain done/undone checkboxes with no behavioral
state.
