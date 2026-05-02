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
→ Run Steps 1–4 only (Step 4 lightweight: P0 issues + top 3 P1s). Skip Steps 6–8.

**Full Audit** — "Do a thorough review" (5–10 min)
→ Run all steps. Include hook cross-reference, optional external audit offer, and spot-check.

Default to **Quick Check** if the user gives no signal either way. Offer to go deeper after showing initial findings.

**Always announce the chosen mode before Step 1** — say "Running Quick Check" or "Running Full Audit" so the user knows what to expect.

**Output language** — match the conversation language. Default to Korean if mixed.

If no root or global CLAUDE.md is found → skip to **[No File Found](#no-file-found)** at the bottom. (Quick Check does not scan subdirectories — a subdirectory-only repo will appear empty in this mode. Tell the user: "No root-level CLAUDE.md found. Run Full Audit to check subdirectories.")

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
- Use Glob pattern `<root>/**/CLAUDE.md`, skip `.git/`. Exclude files already found in the project-level check above (root, `.claude/`) — don't double-score them.
- For each subdirectory file found, answer before scoring: **"Should this be a `.claude/rules/` file instead?"**
  - Rules apply only to files in that directory → yes, `.claude/rules/` + `paths:` is cleaner (centrally managed, visible in one place)
  - Content is directory-specific context Claude needs when *entering* that directory → keep as subdirectory CLAUDE.md
  - Flag candidates for migration. Don't auto-migrate — confirm with user first.

Tell the user which files you found and what scope each covers (global / project / subdirectory / personal-only).

### Step 2: Load the Scoring Rubric

**Read `references/rubric.md` now**, before scoring anything. The rubric file is in the same directory as this skill. If you skip this step, the scores will be inconsistent.

### Step 3: Score Each File

Apply the rubric from Step 2 to each CLAUDE.md.

Lead with a **checklist**, not a number — the findings are more actionable than the aggregate score.

Use this exact format — one item per line, never concatenate:

```
### ~/CLAUDE.md — Grade B (80/100 ±5–10 pts)

Objective checks:
  ✓  98 lines — within budget (≤150)
  ✗  multi-step procedure — L34 → move to scripts/deploy.sh
  ✓  @imports: 2/2 resolve

Subjective checks:
  ~  rationale coverage ~50% — L12, L24, L45 missing WHY
  ~  2 vague rules — L8 "handle errors properly", L31 "use clean code"
  ✓  organization — critical rules appear early
```

Score line at the bottom: `Score: 80/100 (B) — treat as rough quartile, not exact`

**@import validation:** For every `@path/to/file` found in the CLAUDE.md:
1. Attempt to Read the target path. Resolve relative paths from the directory containing the CLAUDE.md file. Flag failures as broken imports — they silently do nothing at runtime.
2. For each resolved import, perform a lightweight audit of the imported file: slot count (does it blow the budget?), any obvious stale facts, any contradictions with the parent file's rules. If you skip this, mark the parent file's score as **provisional** and note: "Import content not audited — score may be optimistic."

Present scorecards for all files before moving to recommendations.

### Step 4: Prioritized Recommendations

Order by impact × effort:

Use this exact table format — one row per issue, sorted P0 → P1 → P2:

```
PRI  LINE   ISSUE                              FIX
───  ─────  ─────────────────────────────────  ──────────────────────────────────
P0   L34    multi-step deploy procedure        move to scripts/deploy.sh
P0   L67    contradicts global rule (L12)      remove — global wins
P1   L24    "자동 트리거 금지" no rationale       add: "billing + rollback risk"
P1   L45    "never push" no hook               add PreToolUse on git push
P1   L88    stale API version (v3→v5)          remove or use @api-docs.md
P2   L2-3   HTML comments waste tokens         delete
P2   —      no Gotchas section                 add env vars, known quirks
```

P0 = hurts effectiveness today (contradictions, 200+ lines, rules too vague to follow)
P1 = meaningfully improves adherence (missing rationale, unhooked rules, procedures, stale facts)
P2 = polish (reorder, @imports, missing sections, global/project split)

### Step 5: Apply Changes

Ask which fixes to apply:
- "Apply all P0" → edit immediately
- "Walk me through P1" → discuss each
- "Rewrite the whole thing" → draft a clean version from the template in this skill

Edit in place. Don't rewrite unless asked — surgical edits preserve intent.

After edits: **sanity check** — "Did any change make the file longer without making it clearer? If yes, those edits went too far — revert them."

Show a brief summary: what was removed, added, reorganized.

**Tip to share after edits:** During any Claude Code session, press `#` to have Claude auto-incorporate session learnings back into CLAUDE.md. For personal preferences that shouldn't be shared with the team, use `CLAUDE.local.md` (add to `.gitignore`).

#### If the file is still over 200 lines after edits — offer the Migration Wizard

Only trigger this if the post-edit file length is still > 200 lines. Do not run it by default.

Say: *"The file is still [N] lines. Want me to propose a modular split? I'll map rules to `.claude/rules/` files with path scoping so CLAUDE.md becomes the lightweight anchor."*

If the user agrees, do the following:

1. **Group rules by scope** — scan each rule and classify:
   - Applies only to specific file types (`.py`, `.ts`, `*.test.*`) → `.claude/rules/` with `paths:` scoping
   - Applies only in specific directories (`src/`, `scripts/`) → `.claude/rules/` with `paths:` scoping (preferred over subdirectory CLAUDE.md — easier to manage centrally)
   - Applies everywhere, always → stays in root CLAUDE.md

2. **Propose the split** (don't apply yet):
   ```
   CLAUDE.md (~60 lines)        → tech stack, key commands, gotchas, cross-cutting rules
   .claude/rules/python.md      paths: ['**/*.py', 'tests/**']         → 18 rules
   .claude/rules/frontend.md    paths: ['src/components/**', '**/*.tsx'] → 12 rules
   scripts/deploy.sh            → 6-step procedure from lines 134–145
   ```

3. Ask: "Apply this split?" — only edit files on explicit confirmation. Create the `.claude/rules/` files with this exact frontmatter format at the top, then trim root CLAUDE.md to the anchor content:

   ```markdown
   ---
   paths:
     - "**/*.py"
     - "tests/**"
   ---

   # Python Rules
   - (rules go here)
   ```

   The `---` block is the frontmatter — Claude Code reads it to decide when to load this file. Without it, the file loads on every session (same as CLAUDE.md). With `paths:`, it only loads when Claude is working with matching files.

---

## Full Audit Only: Steps 6–8

Only run these steps in Full Audit mode, or if the user explicitly asks for them.

### Step 6: Config System Audit

CLAUDE.md is only one layer of the Claude Code config system. The other layers — hooks, permissions, model selection — interact with CLAUDE.md rules and often make them redundant or reveal gaps. Audit all three together.

Read these files with the Read tool (do NOT use shell commands):
- `~/.claude/settings.json` (global config)
- `.claude/settings.json` (project config, if present)

If no settings.json found at either path: note this and skip the cross-reference sections below. Suggest creating `.claude/settings.json` to unlock deterministic enforcement.

#### 6a: Hook Cross-Reference

**What are hooks?** Shell commands that run automatically on Claude Code events (e.g., before every Bash call, after every file write). Unlike CLAUDE.md rules — which Claude may miss under context pressure — hooks are deterministic.

Extract hooks from the `"hooks"` key. Then identify **enforcement rules** in the CLAUDE.md files — rules containing "always", "never", "must", "before", "after", or Korean equivalents "항상", "반드시", "금지", "절대".

Use this table format:

```
Hook Cross-Reference

HOOKS FOUND
  PreToolUse  / Bash  → scripts/run_tests.sh
  PostToolUse / Write → scripts/lint.sh

ENFORCEMENT RULES vs HOOKS
  STATUS       LINE  RULE                      HOOK MATCH
  ──────────── ───── ──────────────────────── ──────────────────────
  ✓ redundant  L23   "run tests before commit" PreToolUse/Bash ← safe to remove from CLAUDE.md
  ✓ redundant  L31   "lint after edits"        PostToolUse/Write ← safe to remove
  ✗ advisory   L45   "never push to main"      none → add hook or accept best-effort
```

Don't auto-decide the mapping. Surface it and let the user confirm.

For each advisory-only rule, include a ready-to-paste JSON snippet so the user doesn't need to look up the settings.json schema:

```json
// Add to .claude/settings.json → "hooks"
"PreToolUse": [{
  "matcher": "Bash",
  "hooks": [{"type": "command", "command": "echo 'Blocked: never force push' && exit 1"}]
}]
```

Tailor the `matcher` (tool name: `Bash`, `Write`, `Edit`, …) and `command` to the specific rule. For rules that should block rather than warn, use `exit 1`. For audit-only, use `exit 0` with a log message.

#### 6b: Permissions Audit

Extract the `"permissions"` key (or `"allow"` / `"deny"` depending on settings version). Check:

- **Overly broad allow-lists** — `Bash(*)` or `*` means no guardrails. Flag if the CLAUDE.md has safety rules that a broad permission silently overrides.
- **Overly restrictive deny-lists** — blocks that contradict documented workflows in CLAUDE.md (e.g., `git push` blocked but CLAUDE.md documents a deploy flow that requires it).
- **Missing permissions** — CLAUDE.md mentions tools or commands but no permission entry exists; Claude will prompt on every use, defeating automation.

Report as:
```
Allow: Bash(git *), Read(*), Write(src/**)   Deny: Bash(rm -rf *)
Gap: `npm publish` in CLAUDE.md deploy workflow — not in allow-list (will prompt every run)
Gap: no deny on `git push --force` — "never force push" rule has no enforcement
```

#### 6c: Model Setting

Check if a model is pinned in settings.json (`"model"` key). If yes:
- Is the pinned model still current? (Flag if it's a retired or legacy model ID.)
- Does CLAUDE.md reference model-specific behavior that assumes a different model?

If no model is pinned: note that Claude will use the default, which changes over time — acceptable for most projects, worth pinning if behavior consistency matters.

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

### Step 8: Default Behavior Test (Optional)

More reliable than introspection. For 3–5 enforcement rules, construct a concrete scenario and predict behavior without the rule:

> "If a user asks me to [specific action], and this rule didn't exist, I would [predicted behavior]."

- **Prediction matches rule** → rule is documenting a default. Candidate for pruning (or keep as onboarding docs — mark explicitly).
- **Prediction differs from rule** → rule is load-bearing. Keep.

Example:
> Rule: "Never use `console.log` in production — use the logger module."
> Without rule: I'd use `console.log` (natural choice for quick debug output).
> Verdict: load-bearing — keep.

Share results: "X/5 rules appear to match my defaults and may not be changing behavior."

---

## No File Found

If Step 1 finds no CLAUDE.md anywhere:

Ask the user:
- Are you starting a new project?
- Do you want a project-level file, a global file, or both?

Then offer to create one using this template:

```markdown
# [Project Name] — one-line summary

## Tech Stack
- Language, runtime, key frameworks (versions), database, external services

## Key Commands
- `cmd` — what it does  (dev / test / build / lint)

## Code Conventions
- Specific, verifiable rules only — each non-obvious rule gets a one-line "why"

## Workflow
- Branch naming, PR requirements, commit style

## Gotchas
- Non-obvious behaviors, required env vars, known quirks
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
