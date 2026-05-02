---
name: claude-md-doctor
description: Audit and optimize CLAUDE.md files against official Anthropic guidelines and community best practices. Use this skill whenever the user wants to review, improve, diagnose, or refactor their CLAUDE.md (memory file) — whether they say "check my CLAUDE.md", "is my CLAUDE.md good", "optimize my memory file", "audit claude instructions", or similar. Also trigger proactively after helping someone set up a new project or write their first CLAUDE.md.
---

# CLAUDE.md Doctor

A skill for auditing CLAUDE.md files and improving them to production quality.

The goal is to make CLAUDE.md files that are concise, actionable, and actually change Claude's behavior — not documentation for humans.

## What is CLAUDE.md?

CLAUDE.md is a persistent memory file that Claude Code reads at every session start. It lives in your project or home directory and contains instructions, conventions, and context that don't change frequently. Think of it as the standing brief you'd give a new team member who already knows how to code.

**Key properties:**
- Loaded in full at session start (consumes tokens)
- Survives `/compact` if in project root
- Hierarchical: global (`~/.claude/CLAUDE.md`) → project root (`./CLAUDE.md`) → subdirectories (lazy-loaded)
- Personal sandbox: `CLAUDE.local.md` (gitignored, not shared with team)
- Imports: use `@path/to/file` to pull in external docs

---

## Start Here: Choose a Mode

Before diving in, ask the user (or infer from context):

**Quick Check** — "Just tell me the biggest problems" (2–3 min)
→ Run Steps 1–3 only. Surface top 3 issues, skip hook analysis and optional steps.

**Full Audit** — "Do a thorough review" (5–10 min)
→ Run all steps. Include hook cross-reference, optional external audit offer, and spot-check.

Default to **Quick Check** if the user gives no signal either way. Offer to go deeper after showing initial findings.

**Always announce the chosen mode before Step 1** — say "Running Quick Check" or "Running Full Audit" so the user knows what to expect.

If no CLAUDE.md is found at all → skip to **[No File Found](#no-file-found)** at the bottom.

---

## Audit Workflow

### Step 1: Discover Files

Use the Read and Glob tools — do NOT use shell commands like `find`, `ls`, or `cat`. These are unreliable across platforms (Windows/Mac/Linux).

**Resolve the project root:**
- If the user provided a path (absolute or relative), use that — do not ignore it in favor of the current working directory.
- If no path was provided, use the current working directory as the project root.

**Tell the user the resolved root immediately:** "Scanning project root: `{resolved path}`"

Resolve the project root, then check these paths with the Read tool. Note which exist:

**Project-level (check all, substituting the resolved root):**
- `<root>/CLAUDE.md` — shared with team (checked into git)
- `<root>/CLAUDE.local.md` — personal overrides (gitignored, not shared)
- `<root>/.claude/CLAUDE.md`
- `<root>/.claude/rules/` (use Glob: `<root>/.claude/rules/*.md`)

**Global (user-level — always check regardless of root):**
- `~/.claude/CLAUDE.md`

**Subdirectories (Full Audit only):**
- Use Glob pattern `<root>/**/CLAUDE.md`, skip `.git/`

Tell the user which files you found and what scope each covers (global / project / subdirectory / personal-only).

### Step 2: Load the Scoring Rubric

**Read `references/rubric.md` now**, before scoring anything. The rubric file is in the same directory as this skill. If you skip this step, the scores will be inconsistent.

### Step 3: Score Each File

Apply the rubric from Step 2 to each CLAUDE.md.

Lead with a **checklist**, not a number — the findings are more actionable than the aggregate score:

```
### ~/.claude/CLAUDE.md — Grade B

Objective checks (reliable):
[✓] File length: 95 lines (under 200 limit)
[✓] No style/formatting rules present
[✓] Key commands documented
[✗] Multi-step procedure found (line 34) → move to a skill or script
[✓] @imports: all 2 import paths resolve (verified with Read tool)

Subjective checks (±5–10 pts depending on model):
[~] Rationale coverage: ~50% of non-obvious rules have a WHY
[~] Specificity: 2 rules too vague to verify independently
[✓] Organization: critical rules appear early

Score: 80/100 (B) — treat as rough quartile, not precise measurement
Note: subjective criteria (rationale, specificity) vary ±5–10 pts across model versions.

Top 3 issues: [with line numbers]
Top 3 strengths: [with line numbers]
```

**@import validation:** For every `@path/to/file` found in the CLAUDE.md, attempt to Read the target path. Resolve relative paths from the directory containing the CLAUDE.md file (not the skill's directory). Flag any that fail as broken imports — they silently do nothing at runtime.

Present scorecards for all files before moving to recommendations.

### Step 4: Prioritized Recommendations

Order by impact × effort:

**P0 — Fix now** (hurts Claude's effectiveness today):
- File over 200 lines → rules at the end get dropped by context compression
- Rules that contradict each other across files
- Rules so vague two people would implement them differently

**P1 — High value** (meaningfully improve adherence):
- Non-obvious rules without a one-line "why"
- Enforcement rules with no hook backing them (advisory-only → flag clearly)
- Multi-step procedures → skills or scripts
- Stale facts embedded as static text

**P2 — Polish:**
- Reorder sections (critical rules first)
- Extract large content to `@imports`
- Add missing sections (key commands, gotchas)
- Split global vs project concerns

For each item: specific line/section, what to change, expected improvement.

### Step 5: Apply Changes

Ask which fixes to apply:
- "Apply all P0" → edit immediately
- "Walk me through P1" → discuss each
- "Rewrite the whole thing" → draft a clean version from the template in this skill

Edit in place. Don't rewrite unless asked — surgical edits preserve intent.

After edits: **sanity check** — "Did any change make the file longer without making it clearer? If yes, those edits went too far — revert them."

Show a brief summary: what was removed, added, reorganized.

**Tip to share after edits:** During any Claude Code session, press `#` to have Claude auto-incorporate session learnings back into CLAUDE.md. For personal preferences that shouldn't be shared with the team, use `CLAUDE.local.md` (add to `.gitignore`).

---

## Full Audit Only: Steps 6–8

Only run these steps in Full Audit mode, or if the user explicitly asks for them.

### Step 6: Hook Cross-Reference

**What are hooks?** Claude Code hooks are shell commands that run automatically on events (e.g., before every Bash tool call, after every file write). Unlike CLAUDE.md rules — which Claude tries to follow but may miss under context pressure — hooks are deterministic. If a hook exists for a behavior, the CLAUDE.md rule is redundant and can be safely pruned.

Read these files with the Read tool (do NOT use shell commands):
- `~/.claude/settings.json` (global hooks)
- `.claude/settings.json` (project hooks, if present)

Extract hooks from the `"hooks"` key. List them: event type, matcher, and what command runs.

Then identify **enforcement rules** in the CLAUDE.md files — rules containing words like "always", "never", "must", "before", "after", "항상", "반드시", "금지", "절대".

Present the cross-reference clearly and ask the user to confirm the mapping:

```
Hooks found:
- PreToolUse / Bash → scripts/run_tests.sh
- PostToolUse / Write → scripts/lint.sh

Enforcement rules in CLAUDE.md:
- "Run tests before every commit" (line 23)
- "Lint after file edits" (line 31)
- "Never push directly to main" (line 45)

Likely redundant (hook probably covers it):
- Line 23 ↔ PreToolUse hook — confirm and remove from CLAUDE.md?
- Line 31 ↔ PostToolUse hook — confirm and remove from CLAUDE.md?

Advisory-only (no hook backing it):
- Line 45: no hook found. Add a PreToolUse hook on `git push`, or accept best-effort.
```

Don't auto-decide the mapping. Surface it and let the user confirm.

If no settings.json found: note this and skip the cross-reference.

### Step 7: External Audit (Optional)

The core limitation of this skill: the same Claude instance that follows your CLAUDE.md is also evaluating it. An independent agent without this context will catch things the internal audit misses — rules Claude already follows naturally (making them redundant), or constraints that only look specific but actually aren't.

Offer: *"Want an independent second opinion? I can hand your CLAUDE.md to a separate agent that isn't operating under these instructions."*

If the user agrees, pass the content with this prompt to any available external agent (a fresh Claude session, another LLM, or `/codex` if set up):

```
Review this CLAUDE.md. For each rule, assess:
1. Would Claude handle this correctly by default without the rule?
2. Is this rule specific enough for two people to implement it the same way?
3. For non-obvious rules: is the rationale sufficient?
Report as line-level observations, not a score.
```

If no external agent is available: say so explicitly ("No external agent configured — skipping independent review"), then note which findings from the internal audit are most likely to be blind spots (rules Claude already follows by default). The user can always paste the CLAUDE.md into a fresh Claude session manually and run the prompt above.

### Step 8: Spot-Check Compliance (Optional)

To partially bridge the gap between "rule looks good" and "rule is actually followed":

For 3–5 enforcement rules, ask yourself (honestly): *"In a realistic scenario where this rule applies, would I have followed it anyway — even without CLAUDE.md?"*

Rules where the honest answer is "yes, probably" are candidates for pruning. They document Claude's defaults, not behavioral changes.

Share findings with the user: "These rules appear to match my defaults — they may not be changing my behavior. Worth keeping for documentation, or safe to remove?"

---

## No File Found

If Step 1 finds no CLAUDE.md anywhere:

Ask the user:
- Are you starting a new project?
- Do you want a project-level file, a global file, or both?

Then offer to create one using this template:

```markdown
# [Project Name]
One-line summary.

## Tech Stack
- Language, runtime, key frameworks (with versions)
- Database, external services

## Key Commands
- `cmd` — what it does

## Code Conventions
- Specific, verifiable rules only
- Each non-obvious rule gets a one-line "why"

## Workflow
- Branch naming, PR requirements, commit style

## Gotchas
- Non-obvious behaviors, required env vars, known quirks

## External Resources
@path/to/detailed-docs.md
```

Start minimal. Add rules only when Claude makes a mistake that a rule would have prevented — not speculatively.

---

## Diagnosis Patterns

**The Bloat Problem** — File is long but Claude ignores rules or asks questions the file already answers.
Fix: cut to < 200 lines. Move details to `@imports` or `.claude/rules/` with `paths:` scoping.

**The Vague Rule** — "Use proper error handling." Claude does something; user says that's not what they meant.
Fix: make it concrete and verifiable. Add why.

**The Linter's Job** — "Always use 2-space indentation." Claude sometimes ignores it.
Fix: formatting belongs in `.eslintrc`/`.prettierrc`/hooks. Remove from CLAUDE.md.

**The Redundant Hook Rule** — CLAUDE.md says "run tests before committing" AND a PreToolUse hook does it.
Fix: remove from CLAUDE.md. The hook is authoritative.

**The Unenforced Critical Rule** — "Never push to main." No hook enforces it.
Fix: add a PreToolUse hook on `git push`, or explicitly accept advisory-only status.

**The Stale Fact** — "API version is v3." It's now v5.
Fix: remove or replace with `@path/to/api-docs.md`.

**The Contradiction** — Global: "prefer async/await." Project: "use callbacks for legacy compat."
Fix: audit files together, resolve explicitly.

**The Procedure That Belongs in a Skill** — "To deploy: 1) build 2) test 3) changelog 4) tag 5) push."
Fix: create a `/deploy` skill or `scripts/deploy.sh`.

---

## Scoring Reliability

Lead with the checklist and specific findings — not the number.

**Reliable (objective):** file line count, style rules, key commands, multi-step procedures, hook presence

**Model-dependent (±5–10 pts):** signal/noise ratio, specificity %, rationale coverage, organization

Opus 4.7 tends to be stricter on rationale than Sonnet 4.6. Trust line-level findings over the aggregate score.

## What Good Looks Like

- Under 150 lines (< 200 for complex projects)
- Every rule passes: "would removing this cause Claude to make a mistake?"
- Non-obvious rules have a one-line rationale
- Enforcement rules either have a hook or are explicitly marked advisory-only
- No stale facts, no multi-step procedures, no linter's work
- Critical instructions appear early

**North star:** a new team member understands exactly what to do, and why, in 5 minutes.

## References

Rubric and recommendations are grounded in official Anthropic docs and community patterns.
See `references/sources.md` for the full evidence base and scoring reliability notes.
