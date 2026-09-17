# SolScape

A 2011-era RuneScape private server, built on top of [Void](https://github.com/GregHib/void) — an
open-source (BSD-3-Clause) Kotlin server emulator.

Void is included as a git submodule under [`server/`](server) so it can be updated against upstream
independently of this repo's own scripts/docs.

## What's here vs. what you need to supply

| Component | Status |
|---|---|
| Server engine/game code (Void) | ✅ Included as submodule, builds successfully |
| Game cache (map/item/model data) | ❌ **Not included** — copyrighted Jagex assets, must be sourced separately |
| Game client (`void-client`) | ❌ Not included — see [void-client releases](https://github.com/GregHib/void-client/releases) |

> [!IMPORTANT]
> The game cache is proprietary RuneScape client data owned by Jagex. It is **not** part of Void's
> open-source license and is not included in this repository. Running a server with it is a
> long-standing legal gray area that every RuneScape private server occupies — Jagex has issued
> takedowns against RSPS projects in the past. Keep any deployment private/non-commercial and
> understand the risk before running this for real.

## Setup

1. **Clone with submodules:**
   ```bash
   git clone --recurse-submodules <this-repo-url>
   # or, if already cloned:
   git submodule update --init --recursive
   ```

2. **Install Java 21+** (e.g. [Temurin](https://adoptium.net/temurin/releases/?package=jre)).

3. **Supply the game cache** — extract a compatible revision-634 RuneScape cache into
   `server/data/cache/`. Void's community links a pre-modified cache in its
   [README](https://github.com/GregHib/void#quick-setup); alternatively see the wiki's
   [cache-building guide](https://github.com/GregHib/void/wiki/cache-building) to build your own from
   a legally-obtained client.

4. **Build and run the server:**
   ```bash
   cd server
   ./gradlew :game:build -x test   # build only the server (skips the desktop cache-editor tool,
                                    # which needs Android/Compose deps not always reachable in CI)
   ./gradlew run                   # run the dev server directly
   ```
   You should see `[Main] - Void loaded in ...ms` once it's up.

5. **Connect with a client** — download a [void-client release](https://github.com/GregHib/void-client/releases)
   (or build it from source) and log in with any username/password to create an account.

## Notes

- Default game port: `43594` (see `server/game/src/main/resources/game.properties`).
- Content, config, and gameplay tuning live entirely inside `server/`; see its own
  [README](server/README.md) and [wiki](https://github.com/GregHib/void/wiki) for adding
  scripts/content without touching engine internals.
- To pull upstream Void updates: `git submodule update --remote server`.
