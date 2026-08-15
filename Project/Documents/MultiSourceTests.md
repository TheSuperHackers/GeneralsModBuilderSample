# Multi Source Tests

Test coverage for the Mod Builder `multiSource` and `multiSourceTargetList` bundle file settings,
which build **one** target file from **several** source files. See
[SETTINGS.md](https://github.com/TheSuperHackers/GeneralsModBuilder/blob/main/SETTINGS.md) of the
Mod Builder for the setting reference.

> Requires Mod Builder v2.4 or newer. `Project/Scripts/Windows/Setup.bat` still pins an older version,
> so these configurations only build once that version pin is raised.

## Source files

All source files of these tests live under `Project/GameFilesEdited/MultiSource`. That folder is
deliberately kept out of `Data`, `Art` and `Window`, so that the wild cards of the other bundle items
(`Data/INI/**/*.ini`, `Window/*.wnd`, `Art/*.psd`, ...) do not pick the parts up and change what those
items build.

| Source file | Purpose |
|---|---|
| `MultiSource/INI/GameLOD_Part1..3.ini` | Line exact split of `Data/INI/GameLOD.ini`, so that appending the parts must reproduce the original file |
| `MultiSource/INI/Order/10_First.ini`, `20_Second.ini`, `30_Third.ini` | Prove the order of listed files and of wild card matches. `10_First.ini` opens an exclusion marker that `20_Second.ini` closes |
| `MultiSource/INI/Single/OnlyPart.ini` | A `multiSource` that resolves to exactly one source file |
| `MultiSource/Window/InGameChat_Part1..2.wnd` | Line exact split of `Window/InGameChat.wnd` |
| `MultiSource/Text/generals_base.str` | Base string labels |
| `MultiSource/Text/generals_override.str` | Redefines three labels of the base file and adds one |
| `MultiSource/Text/generals_extra.csf` | The only `.csf` used as a source. Redefines two labels of the base file and adds one |
| `MultiSource/Text/CsfSource/generals_extra.str` | The input that `generals_extra.csf` was generated from. Never referenced by a configuration, kept so the `.csf` can be regenerated |

`generals_extra.csf` is regenerated with the tool that the Mod Builder downloads anyway:

```
Project\Scripts\Windows\.tools\gametextcompiler.exe ^
  "LOAD_MULTI_STR(FILE_ID:0,FILE_PATH:<...>\MultiSource\Text\CsfSource\generals_extra.str,LANGUAGE:English)" ^
  "SAVE_CSF(FILE_ID:0,FILE_PATH:<...>\MultiSource\Text\generals_extra.csf)"
```

## Bundle items

The three items below are grouped in the `ProjectMultiSource` pack in `ModBundlePacks.json`. No
existing item or pack was changed, so a multi source regression cannot disturb the other tests.

### `SampleMultiSourceINI`

| Target | Covers | Expected result |
|---|---|---|
| `Data/INI/GameLODMultiSource.ini` | `multiSource`, ini append, params on the combined result | Byte identical to `Data/INI/GameLOD.ini` as built by `SampleINI`, which uses the same params |
| `Data/INI/MultiSourceOrder.ini` | `multiSourceTargetList`, listed order plus alphabetically sorted wild card matches, an exclusion marker spanning two source files | Parts in the order `30_Third`, `10_First`, `20_Second`, `30_Third`, and no `MultiSourceOrderExcluded` block |
| `Data/INI/MultiSourceSingle.ini` | A `multiSource` wild card that matches exactly one file | Content of `OnlyPart.ini`, under the target file name. Takes the single source copy path rather than the concatenation path |

### `SampleMultiSourceWindow`

| Target | Covers | Expected result |
|---|---|---|
| `Window/InGameChatMultiSource.wnd` | wnd append | Byte identical to `Window/InGameChat.wnd` as built by `SampleWindow`, which uses the same params |
| `Window/InGameChatWithEmptyWildcard.wnd` | A wild card in the middle of a `multiSource` that matches nothing | Built from the two parts. The log only notes `Wildcard '...' currently matches nothing` |
| `Window/InGameChatFromWildcard.wnd` | A `multiSource` that is only a wild card, next to a `sourceTargetList` in the same file entry | Both parts in alphabetical order. Only `source` may not be combined with `multiSource` |

### `SampleMultiSourceLanguages`

| Target | Sources | Combined by | Expected result |
|---|---|---|---|
| `Data/English/generals_multisource.csf` | str + str | Label merge | `MultiSource:OverriddenByStr01`, `...Str02` and `...ByCsfThenStr` carry the override text, `MultiSource:FromOverrideStr` is present |
| `Data/English/generals_multisource_with_csf.csf` | str + csf + str | Label merge | `MultiSource:OverriddenByCsf` from the csf, `MultiSource:OverriddenByCsfThenStr` from the override str, `MultiSource:FromExtraCsf` and `MultiSource:FromOverrideStr` both present |
| `Data/MultiSourceAppended.str` | str + str | Text append | Every label block of both files verbatim, including the labels that appear twice |
| `Data/MultiSourceMerged.str` | str + csf | Label merge | Every label exactly once. Also covers the temp file pre processing, because text params are combined with a merge |

A `str` target only merges labels when at least one source is a `csf`. From `str` sources alone it is
a plain text append, which is why the two `.str` targets above behave differently.

Every merging entry sets the `language` param on purpose. Without it the Mod Builder passes
`LANGUAGE:None` to `gametextcompiler`.

## Invalid configurations

Four of the five error cases are raised while the configuration is read, which aborts every build no
matter which pack is selected. They can therefore not live in `ModBundleItems.json` and are kept as
standalone configuration files in `Project/Tests` that are not part of the `ConfigFiles` list in
`Setup.bat`.

| Configuration file | Expected error |
|---|---|
| `ModBundleItems_Invalid_SourceAndMultiSource.json` | `Bundle file cannot specify 'source' and 'multiSource' together` |
| `ModBundleItems_Invalid_MissingTarget.json` | `BundleFile.target is mandatory with 'multiSource'` |
| `ModBundleItems_Invalid_WildcardTarget.json` | `BundleFile.target '...' cannot contain a wildcard with 'multiSource'` |
| `ModBundleItems_Invalid_EmptyMultiSource.json` | `BundleFile.multiSource cannot be empty` |
| `ModBundleItems_Invalid_UnsupportedTargetType.json` | `... of type 'ini' is not supported for it.` Raised in the Pre Build step, so this one carries its own pack to be built at all |

Run them all with:

```
Project\Scripts\Tests\BuildInvalidMultiSource.bat
```

The script builds each configuration on top of the regular ones, expects every run to fail, and exits
with the number of runs that unexpectedly succeeded.
