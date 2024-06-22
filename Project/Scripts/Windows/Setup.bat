@echo off

set SetupDir=%~dp0.

:: Version, size and hash. Sets which Mod Builder is used.
set ModBuilderVer=2.2
set ModBuilderArcSize=32146045
set ModBuilderArcSha256=d14929971a4c5c8ffaecc040c162e4badf2ebec2e4b6983c03f470a236c1a624

:: The mod config files. Relative to this setup file.
set ConfigFiles=^
    "%SetupDir%\..\..\ModBundleItems.json" ^
    "%SetupDir%\..\..\ModBundlePacks.json" ^
    "%SetupDir%\..\..\ModChangeLog.json" ^
    "%SetupDir%\..\..\ModFolders.json" ^
    "%SetupDir%\WindowsRunner.json" ^
    "%SetupDir%\WindowsTools.json"

:: Misc path setup.
set ModBuilderDir=%SetupDir%\.modbuilder\v%ModBuilderVer%
set ModBuilderExe=%ModBuilderDir%\generalsmodbuilder\generalsmodbuilder.exe
set ModBuilderArc=%ModBuilderDir%\generalsmodbuilder.7z
set ModBuilderArcUrl=https://github.com/TheSuperHackers/GeneralsModBuilder/releases/download/v%ModBuilderVer%/generalsmodbuilder_v%ModBuilderVer%.7z

:: Print setup info.
echo SETUP.BAT
echo modver %ModBuilderVer%
echo arcsiz %ModBuilderArcSize%
echo arcsha %ModBuilderArcSha256%
for %%f in (%ConfigFiles%) do (
    echo config %%f
)
echo moddir %ModBuilderDir%
echo modexe %ModBuilderExe%
echo arcfil %ModBuilderArc%
echo arcurl %ModBuilderArcUrl%
