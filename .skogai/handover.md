# handover (2026-10-30, before harness-init)

## where we are

- `~/.dotfiles` is the mise history checkout of `skogai2/.dotfiles` (884 checkpoints, 2026-10-14 ..
  2026-10-30), not an old stow repo. 54 coverage entries, ~170 files. Read it with `mise dot history`,
  never raw git.
- Overview of how alive each tracked app is: `.skogai/tmp/dotfiles-overview.md` (throwaway, rebuild
  with `mise dot history -n 0 --json`). Active: mise, fish, omarchy, nvim, herdr, hypr, systemd,
  spotifast.
- PROJECT.md §1/§2 updated (commits 8c0719e, 21407ba): the cloudflared token in history (rotated,
  only the rewrite question is open), `containers` as the hole behind the `systemd/user` links, ~26
  unsorted `~/.config` names, and config outside `~/.config` as candidates.

## decisions (skogix, 2026-10-30)

- unsure whether something is config: track it, trim the noise within the hour
- config outside `~/.config` gets tracked in place, by the same path rules
- agents start out only reading repo files and get more authority as needed
- any secret that touched git or an agent is already rotated
- commits follow CLAUDE.md: no Co-Authored-By (earlier commits in this repo have one)

## next

1. `/vv-harness:harness-doctor` (read-only), then `/vv-harness:harness-init` in this repo, run by the
   lead and not by an agent. This is partly an experiment in harness orchestration.
2. Proposed features. Tests have to be scriptable:
   - F1 coverage check script: `ls ~/.config` + `~` candidates vs `mise dot` coverage + PROJECT.md
     lists, fails when an entry is undecided. This is the gate for the rest.
   - F2 `containers` tracked: every `systemd/user` link resolves to a tracked file
   - F3 likely-config batch decided
   - F4 unsorted names decided
   - F5 `~` files decided (shell rc, `.ssh/config`, `~/bin`, agent homes)
3. Orchestration: F3-F5 can run in parallel, but every `mise dot` command goes to one history. Agents
   return a verdict plus the exact command, and the lead runs the `mise dot` commands one at a time.

## open

- history rewrite for the Obsidian cookies + cloudflared token (skogix's call)
- 6 `systemd/user` links and `fish/completions/gptme.fish`, `nvim/.../theme.lua` point outside
  tracked paths
- `fcitx5` (9 files) still tracked while `fcitx` was dropped as noise: check it
