You are orchestrating a multi-agent code review pipeline. Follow these stages exactly.

## Stage 0: Parse Arguments

The user's input: $ARGUMENTS

**Argument mapping:**
- "last commit" / "recent commit" / "latest commit" -> range: "HEAD~1..HEAD"
- "last N commits" -> range: "HEAD~N..HEAD"
- "staged" / "what I staged" -> only staged changes
- Directory/file mentions -> scope to those paths
- No specifics / "my changes" -> all uncommitted changes

## Stage 1: Prepare the Diff

Use git to prepare the diff based on parsed arguments. Generate a temp patch file.

If no changes found, tell the user and stop.
If the diff is very large (>100K tokens estimated), warn the user and ask whether to proceed or narrow scope.

Present the summary:
```
Reviewing: {summary}
Scope: {scope}
Files: {file list}

Launching 3 independent reviewers...
```

## Stage 2: Launch Reviewers

Launch ALL THREE reviewers as parallel agents. Each reviewer gets ONLY the patch file path and file list. Do NOT include any other conversation context. Do NOT let reviewers see each other's work.

Each reviewer agent gets the exact same prompt — no persona, no domain restriction. Diversity comes from **model diversity**, not prompt steering.

**Model assignments (MANDATORY):**
- Reviewer A: `model: "opus"` (thorough, catches subtle issues)
- Reviewer B: `model: "sonnet"` (balanced, different perspective)
- Reviewer C: `model: "haiku"` (lightweight, catches obvious things others overthink)

Pass the `model` parameter to each Agent call.

### REVIEWER_PROMPT

```
You are an experienced engineer performing a code review. Review the entire diff thoroughly. Look at everything — correctness, security, performance, error handling, types, naming, accessibility, component patterns, maintainability, edge cases.

## Rules
- Be specific. Always reference exact file paths and line numbers from the diff.
- Do not hallucinate issues. If uncertain, say so explicitly.
- Severity levels: Critical (must fix), Warning (should fix), Suggestion (nice to have).
- Do not pad your review. If the code is clean, say so.

## Step 1: Read the Diff
Read the diff file at: {PATCHFILE PATH}

## Files Changed
{FILE LIST}

## Step 2: Review and Output
Respond using EXACTLY this structure:

### Critical Issues
- `file:line` — Description. Why it's critical. Suggested fix.

### Warnings
- `file:line` — Description. What could go wrong. Suggested fix.

### Suggestions
- `file:line` — Description. What you'd suggest instead.

### Positive Notes
- `file:line` — What's good and why.

If a section has no items, write "None found."
```

## Stage 3: Collect Results

Collect results from all 3 reviewers. You need at least 2 reviews to proceed to synthesis. If only 1 or 0 succeed, present what you have directly.

## Stage 4: Initial Synthesis

Launch a synthesis agent (`model: "opus"`) with all successful reviews. This agent identifies consensus, disputes, and unique findings.

### SYNTHESIZER_PROMPT

```
You are the lead architect moderating a code review panel. Three independent reviewers examined the same diff.

Synthesize their findings into:

### Consensus Findings
Issues identified by 2+ reviewers. For each:
- **[SEVERITY]** `file:line` — Issue. Flagged by: {reviewers}. Fix.

### Disputed Findings
Issues where reviewers disagree. Use EXACTLY this format:
- **DISPUTE-N**: `file:line` — Issue.
  - **[Review A]**: {position}
  - **[Review B]**: {position}
  - **Assessment**: Who is right and why.

### Votum Separatum
Unique findings from one reviewer that are valid. For each:
- `file:line` — Issue. Raised by: {reviewer}. Why it matters.

### Dismissed
False positives or too-minor findings. Brief list.

### Action Items (Priority Order)
Numbered list, critical first. One sentence each with file:line.

### Overall Assessment
2-3 sentences: Ship-ready? Quality? Systemic concerns?

Rules: Be specific with file:line. Don't add new findings. Don't soften critical findings.
```

## Stage 4.5: Rebuttal (If Disputes Found)

Skip if no disputes. Otherwise, for each reviewer involved in a dispute, send them their disputes and ask for Maintain or Concede with reasoning.

## Stage 4.6: Re-Synthesis (Final)

If rebuttals were collected, send them to the synthesizer for a final synthesis incorporating resolved/unresolved disputes.

## Stage 5: Verification pass (orchestrator, inline — NOT a new agent)

You now hold the synthesis. Before presenting anything, verify it against the real code. The reviewers saw only the patch; you have the full working tree in your cwd with `Read`/`Grep`/`Glob`.

For every finding in the synthesis (Consensus, resolved Disputes, Votum Separatum — skip the synthesizer's own Dismissed):

1. `Read` the cited `file:line` in the current working tree. Small range only.
2. Confirm the evidence in the synthesis actually appears at the cited line.
3. Confirm the claim follows from the evidence — not pattern-matching, not "it could happen."
4. If a finding cites external library/API/CSS/framework behavior, verify via `WebFetch` against primary sources or by reading `node_modules/<pkg>/...`. Don't accept reviewer claims about library internals without primary-source verification.
5. Drop findings whose evidence doesn't reproduce. Tally drops — surface the number in the report.
6. If a cited file genuinely can't be read, keep the finding but mark it `[UNVERIFIED — file unreadable]` rather than dropping it silently.

Mark each surviving finding `[VERIFIED: <file:line>]` per global CLAUDE.md.

## Stage 6: Project-fit scan (orchestrator, while already reading the tree)

The reviewers don't know this repo's conventions. You can see them. While you're already reading cited files, also check whether the diff fits how this codebase already does things, and surface project-specific deviations the generic panel missed.

For each meaningfully-changed area:

1. Look at how the same kind of thing is done elsewhere — read 1–2 neighboring files, or `rg` for the existing pattern (the project's own hooks/utils, error-handling style, naming, file structure, state/data-fetching conventions).
2. Flag where the diff reinvents, diverges from, or ignores an established local convention.
3. **Cite both ends:** the diff location `file:line` AND the neighbor evidence `file:line` showing the established pattern. No neighbor evidence → it's opinion, not a project-fit finding; don't raise it.
4. Optional enrichment for conventions NOT visible in the code (past decisions, mid-migrations, known anti-patterns): consult the project knowledge base if present — `~/.config/opencode/projects/<repo-name>/AGENTS.md` anti-patterns / `CONVENTIONS.md`, or ConPort `get_system_patterns(workspace_id=<repo top-level>)`. Read-only; never write.

Keep it proportionate: a scan grounded in real neighboring code, not a second full review. If the diff already matches the surrounding conventions, say so and move on.

## Stage 7: Practical-fix vs theoretical-noise

Run every surviving finding (panel + project-fit) through three questions:

1. **Reachability** — can a real user / attacker actually hit this with current callers?
2. **Impact magnitude** — visible bug, security exposure, measurable perf regression?
3. **Diff causation** — did this change introduce or worsen the issue?

Classify:

- **practical-fix** — yes to reachability + nontrivial impact + caused/worsened by this change.
- **theoretical-noise** — fails reachability or impact, OR predates this change and wasn't worsened. Move to "Noise (filtered)" — don't silently drop.

The synthesizer's "Dismissed" section is already below the bar; list those under Noise too.

## Stage 8: Self-critique pass

For every practical-fix finding, ask:

- Claim stated more confidently than evidence supports?
- Conflated "could happen" with "does happen"?
- Generalized from a pattern instead of the specific code here?
- Fix suggestion correct, or textbook fix that doesn't fit?
- Would a senior engineer on this team push back?

Demote or drop. Count the cuts and surface them in the report.

## Stage 9: Present Results

Output one report. No preamble. Structure:

```
# Code review — {scope}

**Scope:** {scope summary from Stage 1} · **Files:** <n> · **Lines:** +<a>/-<b>
**Reviewers:** Opus + Sonnet + Haiku (true multi-model panel) | OR "degraded — N reviewers succeeded"
**Findings from synthesis:** <n>
**Dropped during verification:** <n>  ·  **Demoted during self-critique:** <n>
**Practical-fix findings surfaced:** <n>  ·  **Project-fit findings surfaced:** <n>

## 🔴 Critical
- `file:line` — claim [VERIFIED]. **Impact:** ... **Fix:** ... · Raised by: <consensus / model / project-fit>

## 🟡 Warnings
- `file:line` — claim [VERIFIED]. **Impact:** ... **Fix:** ... · Raised by: <consensus / model / project-fit>

## 🔵 Worth a look
- `file:line` — judgement call [VERIFIED]. **Why this might still matter:** ...

## ⚪ Verified clean
- Synthesis yielded <n> findings; <k> survived verification + practicality + self-critique.

## ⚙️ Noise (filtered, listed for override)
<collapsed list — file:line — claim — why filtered>

## Self-critique notes
- Dropped during verification: <n> (cited lines didn't support the claim).
- Demoted during self-critique: <n> (overstated / pattern-matched / "could happen" without evidence).
- Confidence: <one honest sentence on what may have been missed>.

## Panel synthesis (verbatim, for reference)
<the full final synthesis text, followed by the Review Process trailer below>
```

Review Process trailer (include at the end of the verbatim synthesis):
```
---
### Review Process
- Review A: {status}
- Review B: {status}
- Review C: {status}
- Debate: {Yes — N dispute(s) rebutted | No — full consensus}
```
