# Sources & Evidence Base

This skill's rubric and recommendations are derived from the following sources.
Each claim in the rubric links to one or more of these.

---

## Official Anthropic Documentation

- **Claude Code Memory** — `https://docs.anthropic.com/en/docs/claude-code/memory`
  - File hierarchy (global → project → subdirectory), CLAUDE.local.md scope, @import syntax, 5-hop import limit, lazy-loading for subdirectories
  - Auto-memory vs CLAUDE.md distinction (who writes, what persists)

- **Claude Code Best Practices** — `https://docs.anthropic.com/en/docs/claude-code/best-practices`
  - "Would removing this cause Claude to make a mistake?" test (the removal test in rubric §4.4)
  - What to include vs exclude
  - Hooks for enforcement vs CLAUDE.md for guidance distinction (basis for §2.3)

- **Claude Code Settings / .claude/rules/** — official docs on path-scoped rules with YAML frontmatter `paths:`

---

## Community Sources

- **HumanLayer: "Writing a Good CLAUDE.md"** — `https://www.humanlayer.dev/blog/writing-a-good-claude-md`
  - "Under 60 lines" benchmark (their own CLAUDE.md)
  - "Add rules slower than you think" — each rule should trace to a real incident
  - Rationale improves generalization: "never force push" + reason lets Claude apply the principle to novel situations

- **Builder.io: "The Claude.md Guide"** — `https://www.builder.io/blog/claude-md-guide`
  - Minimal viable structure template
  - "Use pnpm not npm — because we use workspaces" as the canonical rationale example

- **Dev.to: "Why Your CLAUDE.md Isn't Working"** — `https://dev.to/sergiov7_2/why-your-claudemd-isnt-working-and-how-to-fix-it-in-10-minutes`
  - Context compression drops late instructions (basis for §1.1 line-length scoring and §3.3 organization)
  - Anti-pattern: auto-generated files trusted without refinement
  - Anti-pattern: multi-step procedures in CLAUDE.md (basis for §4.1)

- **Dometrain: "Creating the Perfect CLAUDE.md"** — `https://dometrain.com/blog/creating-the-perfect-claudemd-for-claude-code`
  - Structural section recommendations (Tech Stack, Key Commands, Gotchas pattern)

- **GitHub: claude-code-best-practice** — `https://github.com/shanraisshan/claude-code-best-practice`
  - Real-world CLAUDE.md examples across project types

---

## Key Numbers & Where They Come From

| Claim | Source |
|-------|--------|
| ≤200 lines recommended max | Official docs (memory loading behavior) |
| ~150 instructions total capacity | Official docs: system prompt uses ~50, leaving ~100–150 |
| HumanLayer's own file: <60 lines | HumanLayer blog |
| Context compression drops late content | Dev.to post + inferred from official compaction docs |
| Max 5-hop import depth | Official docs |

---

## Scoring Reliability Caveat

The rubric mixes objective and subjective criteria:

**High reliability (objective):**
- File line count (§1.1)
- Presence/absence of style rules (§2.3)
- Key commands present (§3.1)
- Multi-step procedures (§4.1)

**Medium reliability (semi-objective — LLM judgment on clear criteria):**
- Stale facts (§1.3)
- Contradiction detection (§4.3)
- Removal test pass/fail per rule (§4.4)

**Lower reliability (subjective — varies by model and run):**
- Signal/noise ratio (§1.2) — ±5–10 points across runs
- Specificity percentage (§2.1) — judgment call
- Rationale coverage (§2.2) — judgment call
- Logical organization (§3.3) — judgment call

**Implication for use:** The final numeric score (e.g., 80/100) carries false precision on subjective criteria. Treat it as a rough quartile indicator (A/B/C/D), not an exact measurement. The most reliable output of this skill is the *specific findings* (line numbers, named anti-patterns) rather than the aggregate score.

Two runs of the same file on Sonnet 4.6 may differ by ±5–8 points on the total. Opus 4.7 tends to be stricter on rationale detection. Neither is wrong — the rubric criteria genuinely require judgment.
