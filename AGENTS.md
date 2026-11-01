# AGENTS.md

## Project overview

`sdk_build_dependency` (ducky7go org) is not a code project. It is a binary dependency store: the `Managed/` folder holds 200 tracked .NET assemblies copied from the "Escape from Duckov" game install (Unity `Managed` directory: `Assembly-CSharp.dll`, `TeamSoda.Duckov.Core.dll`, `ItemStatsSystem.dll`, `UnityEngine.CoreModule.dll`, `UniTask*.dll`, `Unity.TextMeshPro.dll`, DOTween, Odin, and others, about 40 MB in total). Consumers (verified in sibling checkouts) are `Ducky.Sdk` and `SuperDucky.Connector`: their `scripts/fetch_build_dependency.sh` downloads the latest GitHub release (its `zipball_url`, i.e. the source zip at the release tag, not the `Managed.zip` asset) into a git-ignored `./Managed/`, so builds and CI do not need a game install. The README here contains only the title.

These DLLs are third-party and game-vendor binaries. Do not modify, decompile-and-rewrite or "clean up" them.

## Repository layout

- `Managed/` - the game's managed assemblies, flat, DLL files only (no non-DLL files).
- `scripts/sync_managed.sh` - refreshes `Managed/` from a local game install.
- `.github/workflows/release.yml` - on a published GitHub Release, zips `Managed/` into `Managed.zip` and attaches it to that release (`softprops/action-gh-release@v1`).
- `.gitignore` - ignores only `.env`.

## Build / test / run

There is no build, test or package manifest. The only runnable piece is the sync script:

```bash
scripts/sync_managed.sh
```

It requires a local, untracked `.env` at the repo root that defines `MANAGED_SOURCE_DIR` (path to the game's source `Managed` folder). The script exits if `.env` or the variable is missing. It then deletes everything inside `Managed/` and runs `rsync -av --delete` from the source into `Managed/` (needs `rsync`). It is destructive to the working copy of `Managed/`, so run it only when you intend to update the assemblies. Never read, print or commit `.env`.

## Conventions

- Version bumps are commits whose message is just the version number (e.g. `1.3.14`; confirm what the number tracks before relying on it).
- Releases are cut as GitHub Releases; the workflow then attaches `Managed.zip`. The consumers' fetch script uses the latest release's source zipball, so the latest release tag must contain a committed, up-to-date `Managed/`.
- Update flow (derived from the script and workflow): run `scripts/sync_managed.sh` against the new game install, review `git status`, commit, then publish a GitHub Release so the workflow attaches `Managed.zip`.

## Gotchas

- Large binary diffs: every update rewrites DLLs in git history, so the repo grows. Do not commit unrelated binaries or intermediate files into `Managed/`; the sync deletes anything that is not in the game folder.
- `rsync --delete` mirrors the source exactly, so files that are in `Managed/` but not in the source folder are removed.
- The `.github/workflows/release.yml` zips everything under `Managed/` as it is at the release tag; make sure the sync was committed before publishing.
- The repo has no LICENSE file, and the contents are the game's own assemblies.

## Related repositories

- `ducky7go/Ducky.Sdk` and `SuperDucky.Connector` - download the latest release (source zipball) via `scripts/fetch_build_dependency.sh` (see their AGENTS.md).
- `ducky7go/dukcy-package-spec`, `ducky7go/ducky-cli`, `ducky7go/action-ducky-nuget` - packaging spec and tooling for the same mod ecosystem; no dependency on this repo.
