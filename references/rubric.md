# CLAUDE.md Scoring Rubric

Score each CLAUDE.md file on a 0–100 scale using the criteria below.
Higher scores = more effective instructions.

---

## Section 1: Size & Focus (25 points)

### 1.1 File length (10 pts)
- 10 pts: ≤ 150 lines
- 7 pts: 151–200 lines
- 4 pts: 201–300 lines
- 0 pts: > 300 lines (severe — rules at the end get dropped by context compression)

### 1.2 Signal-to-noise ratio (10 pts)
For each rule, ask: "Would Claude do the wrong thing without this?" Rules that don't change behavior are noise.

- 10 pts: ≥ 90% of lines are load-bearing (remove them → Claude makes a mistake)
- 7 pts: 75–89%
- 4 pts: 60–74%
- 0 pts: < 60% (file is mostly documentation, not instructions)

### 1.3 No stale facts (5 pts)
Stale facts = API versions, dates, budget numbers, URLs that change — embedded as static text.

- 5 pts: No stale facts (or facts fetched via `@imports`)
- 2 pts: 1–2 potentially stale facts
- 0 pts: 3+ stale facts

---

## Section 2: Rule Quality (30 points)

### 2.1 Specificity (10 pts)
Rules must be verifiable — two people reading the same rule should make the same implementation decision.

Vague: "Use clean code." / "Prefer functional approaches." / "Handle errors properly."
Specific: "Never swallow exceptions silently — always propagate or log with context." / "Use 2-space indentation (project standard since v1)."

- 10 pts: All rules are specific and verifiable
- 7 pts: ≥ 80% specific
- 4 pts: 60–79% specific
- 0 pts: < 60% specific

### 2.2 Rationale presence (10 pts)
Non-obvious rules should explain WHY — this lets Claude generalize to similar situations instead of blindly following the letter of the rule.

Obvious (no rationale needed): "Use TypeScript strict mode."
Non-obvious (needs rationale): "Use `mv` not `git mv` for archiving" → because archive/ is gitignored, git mv would try to track a file that should be untracked.

Count non-obvious rules, then check what fraction have a rationale.

- 10 pts: ≥ 90% of non-obvious rules have rationale
- 7 pts: 70–89%
- 4 pts: 50–69%
- 0 pts: < 50%

### 2.3 No linter's work in CLAUDE.md (10 pts)
Formatting, style enforcement, and syntactic rules belong in linters/hooks, not CLAUDE.md.

Examples of linter's work: indentation, import ordering, semicolons, unused variable warnings, JSDoc enforcement.

- 10 pts: No style/formatting rules (all delegated to linters)
- 7 pts: 1–2 style rules (minor)
- 3 pts: 3–5 style rules
- 0 pts: > 5 style rules or any that could cause inconsistency

---

## Section 3: Structure & Completeness (25 points)

### 3.1 Key commands present and current (5 pts)
The file should document how to run, test, build, and lint the project. Claude shouldn't have to guess.

Commands must also be **current** — a stale command is worse than no command (false confidence). If you can verify one command quickly, do it.

- 5 pts: All relevant commands documented and current (`dev`, `test`, `build`, `lint` or equivalents)
- 3 pts: Most commands present, 1–2 missing or one likely stale
- 1 pt: Only some commands, or commands that look outdated
- 0 pts: No commands (or a static website/docs-only project where N/A)

Score N/A (skip, don't penalize) if the project has no runnable commands.

### 3.2 Gotchas section (5 pts)
Non-obvious behaviors that would trip up someone new: required env vars, migration steps, external service dependencies, known quirks.

- 5 pts: Explicit gotchas section with ≥ 1 non-obvious item
- 2 pts: Gotchas exist but embedded in other sections (harder to find)
- 0 pts: No gotchas (either truly none, or they're missing — ask the user)

### 3.3 Logical organization (5 pts)
Instructions should flow: context → setup → conventions → workflow. Critical instructions should appear early (context compression drops late content first).

- 5 pts: Well-organized, critical items first, sections are coherent
- 3 pts: Mostly organized with minor ordering issues
- 1 pt: Hard to navigate, important rules buried
- 0 pts: No clear organization

### 3.4 Scope correctness (10 pts)
Global CLAUDE.md: user preferences, cross-project tools, personal workflow.
Project CLAUDE.md: project-specific stack, commands, conventions.
Don't mix them — project-specific instructions in global file get applied everywhere incorrectly.

- 10 pts: Everything is in the right place (global vs. project split is clean)
- 7 pts: 1–2 items in the wrong scope
- 4 pts: 3–5 misplaced items
- 0 pts: Significant mixing (project-specific rules in global, or vice versa)

---

## Section 4: Advanced Practices (20 points)

### 4.1 No procedures that should be skills (5 pts)
Multi-step workflows (deploy, release, data migration) belong in skills or scripts — they're deterministic and shouldn't be advisory.

- 5 pts: No multi-step procedures in the file
- 2 pts: 1 procedure (minor)
- 0 pts: 2+ procedures or any critical workflow embedded as prose

### 4.1b Hook alignment (bonus check — not scored, but always report)
This is reported separately from the numeric score because it requires reading settings.json, not just the CLAUDE.md.

For each enforcement rule (contains "always", "never", "must", "before", "after" or Korean equivalents "항상", "반드시", "금지"):
- **Redundant**: rule exists in CLAUDE.md AND a matching hook enforces it → safe to prune from CLAUDE.md
- **Advisory-only**: rule exists in CLAUDE.md but no hook → flag clearly, suggest adding hook or accepting best-effort
- **Hook without mention**: hook exists but CLAUDE.md doesn't reference the constraint → consider adding a note so Claude understands the system

Report these as a separate "Hook Cross-Reference" section, not folded into the score.

### 4.2 Imports used for large reference material (5 pts)
If the file links to or summarizes large documents (API specs, style guides, architecture docs), use `@path/to/file` imports so Claude can load them on demand.

- 5 pts: Imports used where appropriate, OR no large reference material exists
- 2 pts: Some large content inline that should be imported
- 0 pts: Large docs embedded directly (> 50 lines of reference material in-file)

### 4.3 No contradictions with sibling CLAUDE.md files (5 pts)
Rules in this file should not conflict with rules in other CLAUDE.md files in the hierarchy (global, project, subdirectory).

- 5 pts: No contradictions found
- 2 pts: 1 potential conflict (minor or context-dependent)
- 0 pts: Clear contradictions (same behavior, different rules)

### 4.4 Instructions survive the "removal test" (5 pts)
Read 5 random rules. For each: if you removed it, would Claude do something different or worse? If most rules pass this test, the file is tight.

- 5 pts: 5/5 rules pass the removal test
- 3 pts: 4/5 pass
- 1 pt: 3/5 pass
- 0 pts: < 3/5 pass (file has significant dead weight)

---

## Grading Scale

| Score | Grade | Interpretation |
|-------|-------|----------------|
| 90–100 | A | Excellent — Claude will follow these reliably |
| 75–89 | B | Good — minor improvements would help |
| 60–74 | C | Fair — several issues reducing effectiveness |
| 40–59 | D | Needs work — Claude likely ignores significant portions |
| < 40 | F | Major problems — rewrite recommended |

---

## Quick Red Flags (auto-deduct 10 pts each)

These are severe enough to cap the grade regardless of other scores:

- [ ] File > 400 lines (context bloat guarantee)
- [ ] Two rules that directly contradict each other
- [ ] Instructions reference files or tools that don't exist
- [ ] Security-sensitive information (tokens, passwords) in plain text
- [ ] Instructions that could cause data loss if followed literally

---

## Scoring Notes

- If a section is genuinely N/A for the project type (e.g., "Key Commands" for a docs-only repo), redistribute those points to the Rationale section.
- Score based on actual effectiveness, not intent. "We tried to document the stack" doesn't earn points if the documentation is vague.
- When uncertain between two score levels, pick the lower one and note why — it's better to surface issues than hide them.
