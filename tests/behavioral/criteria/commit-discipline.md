# Criterion: Commit Discipline at Scope Completion

When a scope's last must-have finishes — optionally alongside a discovery that
reshapes remaining work — the agent bundles the scope's code, its tracking-doc
updates, and any new/updated discovery scope files into a SINGLE commit. The
handover (if any) is a separate commit at session end.

## Pass Conditions (ALL must be true)

1. The agent describes committing the scope-closing work as ONE commit that
   bundles: code + the scope file (with must-have behaviors GREEN ([GREEN]) and
   Hill Position `✓ Done`) + `hillchart.md`.
2. If a discovery emerged during the work, the agent describes including the
   new/updated discovery scope file(s) in the SAME commit as the scope-closing
   work — not split across multiple commits.
3. Any new scope file the agent mentions is named after a business capability,
   not a technical layer (no `scope-backend-*`, `scope-api-*`, `scope-frontend-*`,
   `scope-database-*`, `scope-migrations-*`, `scope-ui-*`, etc.).
4. If the agent mentions a handover document, it is described as a SEPARATE
   commit at session end — not bundled with the scope-closing commit.
5. The agent sequences the tracking updates (scope file behavior states
   ([RED]/[GREEN]), Hill Position, hillchart) BEFORE the commit — not after.

## Fail Conditions (ANY triggers failure)

1. The agent proposes two or more commits for the scope closure (e.g. one for
   code, one for tracking docs, or one for "done" and one for "discovery").
2. The agent splits a discovery scope file into its own separate commit.
3. The agent names a new discovery scope by technical layer.
4. The agent commits without updating `hillchart.md` or the scope file first.
5. The agent writes a handover document and bundles it with the scope-closing
   commit.
6. The agent skips the commit entirely ("I'll commit at the end of the session"
   / "I'll batch the commits later").
