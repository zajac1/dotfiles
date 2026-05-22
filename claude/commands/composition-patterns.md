Review the current code for React composition pattern compliance.

Read the skill file at ~/.agents/skills/vercel-composition-patterns/SKILL.md for the rule index, then read the specific rule files under ~/.agents/skills/vercel-composition-patterns/rules/ as needed.

For the full compiled guide, read ~/.agents/skills/vercel-composition-patterns/AGENTS.md

Apply these patterns when refactoring components with boolean prop proliferation, building flexible component libraries, or designing reusable APIs:

1. Component Architecture (HIGH)
   - Avoid boolean props to customize behavior; use composition
   - Structure complex components with shared context (compound components)

2. State Management (MEDIUM)
   - Provider is the only place that knows how state is managed
   - Define generic interface with state, actions, meta for dependency injection
   - Move state into provider components for sibling access

3. Implementation Patterns (MEDIUM)
   - Create explicit variant components instead of boolean modes
   - Use children for composition instead of renderX props

4. React 19 APIs (MEDIUM) - only if using React 19+
   - Don't use forwardRef; use use() instead of useContext()

Check the code against these patterns and report any violations or improvement opportunities.
