Review the current code for React and Next.js performance optimization.

Read the skill file at ~/.agents/skills/vercel-react-best-practices/SKILL.md for the rule index, then read the specific rule files under ~/.agents/skills/vercel-react-best-practices/rules/ as needed.

For the full compiled guide, read ~/.agents/skills/vercel-react-best-practices/AGENTS.md

Apply these guidelines when writing, reviewing, or refactoring React/Next.js code. Focus on:
1. Eliminating waterfalls (CRITICAL) - parallel fetching, Suspense boundaries
2. Bundle size optimization (CRITICAL) - direct imports, dynamic imports, deferred third-party
3. Server-side performance (HIGH) - caching, dedup, parallel fetching
4. Client-side data fetching (MEDIUM-HIGH) - SWR dedup, event listeners
5. Re-render optimization (MEDIUM) - memo, derived state, functional setState
6. Rendering performance (MEDIUM) - content-visibility, hydration
7. JavaScript performance (LOW-MEDIUM) - Set/Map lookups, early exits
8. Advanced patterns (LOW) - event handler refs, stable callbacks

Check the code against these rules and report any violations or optimization opportunities.
