# Generals Mod Builder Sample Project

A minimal Mod project showing how to build game release files with the
[Generals Mod Builder](https://github.com/TheSuperHackers/GeneralsModBuilder).
Copy this project as a starting point for your own Mod.

## Clone

The Mod Builder is a git submodule, so clone recursively:

```
git clone --recursive https://github.com/TheSuperHackers/GeneralsModBuilderSample
```

If the repository is already cloned, fetch the submodule with:

```
git submodule update --init --recursive
```

Nothing else needs to be installed. The Mod Builder launcher installs
[uv](https://docs.astral.sh/uv/) on first use, and uv then downloads a suitable
Python and the required packages by itself. The build tools such as crunch,
gametextcompiler and generalsbigcreator are downloaded on first build into
`Project/Scripts/Windows/.tools`, and are verified against the sha256 hashes in
[WindowsTools.json](Project/Scripts/Windows/WindowsTools.json).

## Build

Run any of the scripts in [Project/Scripts](Project/Scripts):

| Script | What it does |
| --- | --- |
| `BuildInstall.bat` | Builds the Mod and installs it into the game folder |
| `BuildInstallRun.bat` | Builds, installs, runs the game, then uninstalls when the game closes |
| `BuildInstallRunWithGui.bat` | The same, with the graphical interface |
| `BuildRelease.bat` | Builds the Mod and packs the release archives |
| `Uninstall.bat` | Removes the Mod from the game folder |

The configuration files are `Project/Mod*.json`, plus
[WindowsRunner.json](Project/Scripts/Windows/WindowsRunner.json) for game run
behaviour. See [Configuration Settings](https://github.com/TheSuperHackers/GeneralsModBuilder/blob/main/SETTINGS.md).

## Upgrade the Mod Builder

The submodule commit decides which Mod Builder version is used:

```
git submodule update --remote ThirdParty/GeneralsModBuilder
git add ThirdParty/GeneralsModBuilder
git commit -m "Upgrade the Mod Builder"
```
