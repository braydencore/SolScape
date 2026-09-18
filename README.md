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

5. **Build a distributable installer — Windows, one step:**
   Double-click [`build-stonkscape-client.bat`](build-stonkscape-client.bat) (run it from inside
   your local clone of this repo). It pulls the latest code, builds our branded client fork, and
   packages it into a single **`Stonkscape-1.0.0.exe` installer** (in `dist/`) with the icon and
   high-DPI click-drift fix baked in. That one file is what you hand to players — they run it, it
   installs itself with a Start Menu/Desktop shortcut, done. No Java 8 install needed for you either
   — Gradle fetches it automatically on first run.

   Requires, on **your** build machine only (never for players):
   - A JDK 14+ with `jpackage` (the same [Temurin](https://adoptium.net/temurin/releases/) install
     used for the server covers this).
   - The [WiX Toolset](https://github.com/wixtoolset/wix3/releases) — needed by `jpackage` to build
     a Windows installer rather than just a plain app folder.

   **macOS/Linux, or if you'd rather do it by hand:**
   ```bash
   cd client-src
   ./gradlew :client:shadowJar        # jar lands in client-src/client/build/libs/
   cp client-src/client/build/libs/void-client-*.jar client/
   ./client/run-client.sh             # or client\run-client.bat on Windows
   ```
   To package your own native app/exe instead of the jar+script combo:
   ```bash
   jpackage --input client-src/client/build/libs --main-jar <the-jar-file> \
     --name Stonkscape --icon client-src/client/resources/icon.ico \
     --java-options "-Dsun.java2d.uiScale=1" --type app-image
   ```
   `jpackage` must run **on the OS you're packaging for** (a Windows `.exe` needs Windows) — do this
   locally, not in a Codespace. Log in with any username/password to create an account.

## Notes

- Default game port: `43594` (see `server/game/src/main/resources/game.properties`).
- Content, config, and gameplay tuning live entirely inside `server/`; see its own
  [README](server/README.md) and [wiki](https://github.com/GregHib/void/wiki) for adding
  scripts/content without touching engine internals.
- To pull upstream Void updates, see the fetch/merge commands above (our fork tracks `origin`,
  upstream Void tracks a separate `upstream` remote).
