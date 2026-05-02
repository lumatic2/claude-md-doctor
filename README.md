# claude-md-doctor

A Claude Code skill that audits your `CLAUDE.md` files and tells you exactly what to fix — and whether your rules are actually changing Claude's behavior.

Most `CLAUDE.md` files fall into one of three failure modes: too long (context compression drops the end), too vague (two people would implement the rule differently), or full of rules Claude would follow anyway. This skill diagnoses all three and helps you cut to instructions that genuinely work.

---

## Install

**macOS / Linux / Windows (PowerShell or WSL):**
```bash
git clone https://github.com/lumatic2/claude-md-doctor ~/.claude/skills/claude-md-doctor
```

**Windows (Command Prompt)** — `~` is not expanded in CMD, use the full path:
```cmd
git clone https://github.com/lumatic2/claude-md-doctor %USERPROFILE%\.claude\skills\claude-md-doctor
```

No setup script needed.

---

## Use

In any Claude Code session:

```
/claude-md-doctor
```

Point it at a specific project:

```
/claude-md-doctor ~/projects/my-project/
```

Claude defaults to **Quick Check** (top 3 issues, ~3 min). Say "full audit" for the complete 10-minute review.

---

## What it checks

### Quick Check (Steps 1–3)
| Check | What it catches |
|-------|----------------|
| File length | Rules dropped by context compression (>200 lines) |
| Signal-to-noise | Rules Claude would follow anyway — dead weight |
| Rule specificity | Vague rules two people would implement differently |
| Rationale coverage | Non-obvious rules missing a one-line "why" |
| Linter's work | Style/formatting rules that belong in `.eslintrc`, not here |
| Key commands (currency) | Missing or stale commands — stale is worse than missing |
| Gotchas | Non-obvious behaviors buried or absent |
| Scope correctness | Project-specific rules leaking into global file, or vice versa |

### Full Audit (Steps 1–8, adds:)
| Check | What it catches |
|-------|----------------|
| Hook cross-reference | Enforcement rules with no hook → advisory-only, not enforced |
| Redundant rules | Rules already covered by a hook → safe to prune |
| `@import` validation | Broken import paths that silently fail |
| **Removal test** | For each rule: would removing it cause Claude to make a mistake? |
| **Behavioral spot-check** | Rules Claude would follow by default — documenting defaults, not changing behavior |
| External agent review | Independent audit from a fresh Claude instance with no context |

Scoring is on a 0–100 rubric across four sections: Size & Focus, Rule Quality, Structure & Completeness, Advanced Practices. See [`references/rubric.md`](references/rubric.md) for the full criteria.

---

## How this compares to `claude-md-improver`

Anthropic ships an official [`claude-md-improver`](https://github.com/anthropics/claude-plugins-official) plugin. It's good at checking whether your file is practically useful — are the commands right, is the architecture described, are gotchas captured?

`claude-md-doctor` asks a different question: **are your rules actually changing Claude's behavior?**

| | claude-md-improver | claude-md-doctor |
|--|--|--|
| Content accuracy (commands, architecture) | ✓ | — |
| Behavioral verification (removal test) | — | ✓ |
| Hook cross-reference | — | ✓ |
| External independent review | — | ✓ |
| Rationale coverage analysis | — | ✓ |
| Linter's job detection | — | ✓ |
| Cross-platform (no `find`/`bash`) | — | ✓ |
| Scoring reliability notes | — | ✓ |

They complement each other. Run `claude-md-improver` to check if your content is correct, run `claude-md-doctor` to check if your rules are load-bearing.

---

## What good looks like

- Under 150 lines (< 200 for complex projects)
- Every rule passes: *"if I removed this, would Claude make a mistake?"*
- Non-obvious rules have a one-line rationale
- Enforcement rules either have a hook backing them or are explicitly marked advisory-only
- No stale facts, no stale commands, no multi-step procedures, no linter's work
- Critical instructions appear early

**Tip:** Press `#` during any Claude Code session to have Claude auto-incorporate session learnings back into your `CLAUDE.md`. Use `CLAUDE.local.md` for personal preferences you don't want to share with your team.

---

## Rubric sources

Scoring criteria are grounded in the [official Anthropic memory documentation](https://docs.anthropic.com/en/docs/claude-code/memory) and community best-practice patterns. See [`references/sources.md`](references/sources.md) for the full evidence base and notes on scoring reliability across model versions (Opus vs. Sonnet scores can vary ±5–10 pts on subjective criteria).
