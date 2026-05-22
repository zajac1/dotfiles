Review the current UI code using Emil Kowalski's design engineering principles.

Read the skill files at ~/.config/opencode/skills/emil-design-engineering/ for detailed guidance:
- SKILL.md — overview and quick reference
- animations.md — easing, timing, springs, performance
- ui-polish.md — typography, shadows, gradients, scrollbars, dark mode
- forms-controls.md — inputs, buttons, form submission patterns
- touch-accessibility.md — touch devices, keyboard nav, a11y
- component-design.md — compound components, composition, props API
- marketing.md — landing pages, blogs, docs sites
- performance.md — virtualization, preloading, optimization

Apply these core principles when reviewing:

1. **No Layout Shift** — dynamic elements cause no shift. Use hardcoded dimensions, `font-variant-numeric: tabular-nums` for numbers, avoid font weight changes on hover/selected.

2. **Touch-First, Hover-Enhanced** — design for touch first, add hover enhancements. Disable hover on touch devices. 44px minimum tap targets. Never rely on hover for core functionality.

3. **Keyboard Navigation** — tabbing works consistently. Only tab through visible elements. `scrollIntoView()` for keyboard nav.

4. **Accessibility by Default** — every animation needs `prefers-reduced-motion`. Every icon button needs aria label. Every interactive element needs focus states.

5. **Speed Over Delight** — product UI is fast and purposeful. Skip animations for frequent interactions. Marketing pages can be more elaborate.

## Review Checklist
- [ ] No layout shift on dynamic content
- [ ] Animations have reduced motion support
- [ ] Touch targets are 44px minimum
- [ ] Hover effects disabled on touch devices (`@media (hover: hover)`)
- [ ] Keyboard navigation works properly
- [ ] Icon buttons have aria labels
- [ ] Forms submit with Enter/Cmd+Enter
- [ ] Inputs are 16px+ to prevent iOS zoom
- [ ] No `transition: all` — specify exact properties
- [ ] z-index uses fixed scale or `isolation: isolate`

## Common Mistakes to Flag
| Mistake | Fix |
|---------|-----|
| `transition: all` | Specify exact properties |
| Hover effects on touch | Use `@media (hover: hover)` |
| Font weight change on hover | Use consistent weights |
| Animating `height`/`width` | Use `transform` and `opacity` only |
| No reduced motion support | Add `prefers-reduced-motion` query |
| z-index: 9999 | Use fixed scale or `isolation: isolate` |
| Custom page scrollbars | Only customize in small elements |

Read the detailed reference files for the specific areas being reviewed, then check the code and report findings in `file:line` format grouped by severity.

$ARGUMENTS
