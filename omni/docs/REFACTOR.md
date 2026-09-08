# Plan: table-driven menu levels

Status: proposed, not started. Read `GOTCHAS.md` first.

## The problem

Adding one menu item touches three files that nothing keeps in sync:

| file | what you add |
|---|---|
| `bin/omni-menu-query` | a `printf 'kind\tglyph  Label\tpayload\n'` inside a 243-line `case "$lvl"` |
| `bin/omni-exec` | a `payload) command ;;` branch inside a 30-branch `case` |
| `config/sections.example` | the id, if it is a root section |

Forget one and the row renders but does nothing, or the action exists with no way
to reach it. Neither failure is loud. The same three-way split is why the
`update)` block got duplicated unnoticed (fixed in `omni-menu-query`, 2026-09-07).

## The shape after

One directory, one file per level, row and action together:

```
~/.config/omni/levels/          (user-editable, wins)
~/.local/share/omni/levels/     (shipped defaults)
    root.tsv
    style.tsv
    setup.tsv
    utilities.tsv
    system.tsv
    confirm.tsv
```

A level file is the row protocol plus one column — still tab-separated, still
`kind` first, so every existing consumer keeps working unchanged:

```
# kind   display              payload    action
run      󰒓  System Settings   settings   open -a "System Settings"
run      󰖩  Wifi              wifi       open "x-apple.systempreferences:com.apple.wifi-settings-extension"
menu     󰏘  Theme             theme
act      󰅶  Caffeinate        caffeinate omni-caffeinate toggle
```

- `omni-menu-query <level>` becomes: read the level file, drop comments, print
  columns 1–3. Dynamic levels (`theme`, `font`, `weather`, `cpu`, `passwords`)
  stay as they are — a level file may instead be an executable that emits rows,
  exactly like today's `omni-sysinfo` and `omni-pass-rows`.
- `omni-exec` becomes: look up the selected row's `payload` in its level file
  and run column 4 with `bash -c`. The 30-branch `case` disappears.
- `sections` keeps its job (which root ids, in which order) — it already is the
  table for the root level; this makes every other level work the same way.

Favourites already store `kind<TAB>payload` and resolve the display at render
time; they need no change and gain the ability to pin anything in any level.

## Security boundary

Column 4 is executed. Today the equivalent strings live inside `omni-exec`,
which is `0755` and owned by the user; a level file must be held to the same
standard or it becomes a new way to run code by writing to `~/.config`:

- refuse a level file that is group- or world-writable (`stat -f %Lp`)
- refuse a level file not owned by the current user
- the `payload` column is matched with `awk -F'\t' '$3 == p'`, never
  interpolated into a pattern
- `theme` and `font` stay special-cased in `omni-enter` — they edit
  `config.sh` and must keep the validation `omni-osc` relies on

## Migration, in order

1. `omni-levels` (new, ~40 lines): resolve a level name to a file, with the
   user directory overriding the shipped one; emit rows; validate permissions.
2. Move the static levels out of `omni-menu-query` into `.tsv` files. Root
   first, since `sections` already drives it. Run the pty harness before and
   after each level: identical row output, byte for byte.
3. Move the matching `omni-exec` branches into column 4 of each file. Delete
   each branch as it moves; the `case` should be empty when done except
   `app|project|file|calc|web|pass`, which are search results, not menu rows.
4. `install.sh` copies `levels/` to `~/.local/share/omni/levels/`. It must NOT
   copy into `~/.config/omni/levels/` — that is the user's, like `config.sh`.
5. Delete the static branches from `omni-menu-query`. It should end up ~120
   lines: favourites, the search flattening, the calculator gate.

Each step is a commit that leaves the launcher working.

## Tests, which do not exist yet

`tests/` with the pty + pyte harness that has been living in scratch, and three
checks that would have caught every protocol bug so far:

- **row protocol**: every emitted row has exactly two tabs, `kind` is one of the
  known literals, `display` has no leading whitespace (SketchyBar clips it) and
  no tab (the index strips them for a reason).
- **level round-trip**: for each level, `omni-menu-query <level>` matches the
  golden file in `tests/golden/`. Regenerate deliberately, review the diff.
- **glyph audit**: every codepoint in `bin/` and `sketchybar/` exists in
  `data/glyphs.tsv`. Guessing codepoints has shipped a bulldozer.

Run with `tests/run`. No framework; `bash` + `diff` + the harness. The harness
is trustworthy for *structure* (which rows, in what order) and not for
*dimensions* — it under-reports fzf chrome by several rows. Do not calibrate
`OMNI_CHROME` from it.

## Size

About 150 lines added (`omni-levels`, `tests/run`, the harness), about 200
removed from `omni-menu-query` and `omni-exec`. Net smaller.

## Not in scope

- Replacing bash. The 22 ms per-invocation floor is bash start-up plus sourcing
  `config.sh`; nothing in this plan changes it, and nothing needs to.
- A daemon. Every hot path is under 50 ms without one.
- Changing the row protocol. Three columns in, three columns out; column 4 is
  read only by `omni-exec`.
