# claude-md-doctor

A Claude Code skill that audits your `CLAUDE.md` files and tells you exactly what to fix.

Most `CLAUDE.md` files are either too long, too vague, or full of rules that Claude would follow anyway. This skill scores your file against a structured rubric, finds the dead weight, and helps you cut it down to instructions that actually change Claude's behavior.

---

## Install

```bash
git clone https://github.com/MOD-yo/claude-md-doctor ~/.claude/skills/claude-md-doctor
```

That's it. No setup script needed.

---

## Use

In any Claude Code session:

```
/claude-md-doctor
```

Or point it at a specific project:

```
/claude-md-doctor ~/projects/my-project/
```

Claude will ask whether you want a **Quick Check** (top 3 issues, ~3 min) or a **Full Audit** (scored report + hook cross-reference + optional external review, ~10 min).

---

## What it checks

| Check | Quick | Full |
|-------|-------|------|
| File length & signal-to-noise | ✓ | ✓ |
| Rule specificity & rationale coverage | ✓ | ✓ |
| Key commands, gotchas, organization | ✓ | ✓ |
| Hook cross-reference (redundant vs advisory-only rules) | — | ✓ |
| Independent external agent review | — | ✓ (optional) |
| Spot-check: does removing a rule change Claude's behavior? | — | ✓ |

Scoring is on a 0–100 rubric across four sections: Size & Focus, Rule Quality, Structure, and Advanced Practices. See [`references/rubric.md`](references/rubric.md) for the full criteria.

---

## What good looks like

- Under 150 lines
- Every rule passes: *"if I removed this, would Claude make a mistake?"*
- Non-obvious rules have a one-line rationale
- Enforcement rules either have a hook backing them or are explicitly marked advisory-only
- No stale facts, no multi-step procedures, no linter's work

---

## Rubric sources

Scoring criteria are grounded in the [official Anthropic memory documentation](https://docs.anthropic.com/en/docs/claude-code/memory) and community best-practice patterns. See [`references/sources.md`](references/sources.md) for the full evidence base and notes on scoring reliability across model versions.

---

## Works on

- macOS, Linux, Windows (WSL or PowerShell)
- Claude Code CLI, desktop app, IDE extensions
- Any project with a `CLAUDE.md` — global, project-level, or subdirectory
