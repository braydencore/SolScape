# SolScape (Stonkscape)

A 2011-era RuneScape private server, built on top of [Void](https://github.com/GregHib/void) — an
open-source (BSD-3-Clause) Kotlin server emulator. In-game the server is branded **Stonkscape**.

Void is included as a git submodule under [`server/`](server), pointed at
[our own fork](https://github.com/braydencore/void) rather than upstream directly — this is where
our customizations (branding, starter kit, config tweaks, etc.) live and get committed, so they
persist independently of any one Codespace/machine. Pull upstream Void's own updates in with:
```bash
git -C server fetch upstream   # first: git -C server remote add upstream https://github.com/GregHib/void.git
git -C server merge upstream/main
```

## What's here vs. what you need to supply

| Component | Status |
|---|---|
| Server engine/game code (Void) | ✅ Included as submodule, builds successfully |
| Game cache (map/item/model data) | ❌ **Not included** — copyrighted Jagex assets, must be sourced separately |
| Game client | ✅ Our own branded fork ([`client-src/`](client-src)), builds to a runnable jar |

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

5. **Build our own branded client** — this is a much older codebase than the server and needs
   **Java 8** specifically (not 21+), so build it separately on whichever machine you'll actually
   play from:
   ```bash
   cd client-src
   ./gradlew :client:build -x test
   ```
   The runnable jar lands at `client-src/client/build/libs/client.jar`. Copy it into
   [`client/`](client) (rename to whatever `run-client.sh`/`.bat` expects, or update those scripts'
   jar-name pattern) and launch it the same way as before:
   ```bash
   ./client/run-client.sh    # macOS/Linux
   client\run-client.bat     # Windows
   ```
   These pass `-Dsun.java2d.uiScale=1`, which fixes a common Java-on-high-DPI-displays bug where
   click positions drift from what's rendered on screen (the window gets scaled by the OS but click
   coordinates don't, unless told not to). Log in with any username/password to create an account.

   **Optional — package as a native `.exe`/app** instead of a jar + launcher script, with the DPI
   fix and icon baked in permanently (no visible console window, feels like a normal installed
   game):
   ```bash
   jpackage --input client-src/client/build/libs --main-jar client.jar \
     --name Stonkscape --icon client-src/client/resources/icon-256.png \
     --java-options "-Dsun.java2d.uiScale=1" --type app-image
   ```
   `jpackage` ships with any JDK 14+ and must be run **on the OS you're packaging for** (a Windows
   `.exe` needs to be built on Windows) — run it locally on your own machine, not in a Codespace.

## Notes

- Default game port: `43594` (see `server/game/src/main/resources/game.properties`).
- Content, config, and gameplay tuning live entirely inside `server/`; see its own
  [README](server/README.md) and [wiki](https://github.com/GregHib/void/wiki) for adding
  scripts/content without touching engine internals.
- To pull upstream Void updates, see the fetch/merge commands above (our fork tracks `origin`,
  upstream Void tracks a separate `upstream` remote).
