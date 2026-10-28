# skogai config

How the machines skogai works on are configured, and the knowledge
behind that configuration. It's written for agents first: what each
part of the setup is, why it was chosen, and how to change it safely.

This repo holds no dotfiles and no machine state of its own. They
live where the tools that own them put them. This repo describes them
and routes to them.

## what is where

| what | where | versioned by |
|---|---|---|
| dotfiles (`~/.config/<app>/`) | in place, tracked by path rules | `mise dotfiles` history, synced to a private origin |
| machine state (packages, users, files, services, repos) | `~/.config/mise/config.toml` (`[bootstrap]`) | the same dotfiles history |
| knowledge, decisions, conventions | this repo, one page per concern | git |
| secrets | fnox + age (in progress) | ciphertext only |

## working here

- Read the page for a concern before changing anything in it. A page
  that contradicts the machine is wrong and gets fixed in the same turn.
- Read-only commands (`status`, `plan`, `diff`, `ls`, `--dry-run`) run
  freely. Anything that writes to the machine or pushes somewhere is
  confirmed first.
- Never read secret values into a conversation (`mise env`, `fnox get`,
  env files).
