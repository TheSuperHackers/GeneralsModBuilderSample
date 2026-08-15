@echo off

rem Builds every invalid multi source configuration in Project\Tests and expects each of them to fail.
rem These configurations cannot live in ModBundleItems.json, because most of them are rejected while
rem the configuration is read, which would abort every regular build of this project.

setlocal enabledelayedexpansion

set ThisDir=%~dp0.
set TestDir=%ThisDir%\..\..\Tests

call "%ThisDir%\..\Windows\RequestAdmin.bat" "%~s0" %*

if %errorlevel% EQU 111 (
    exit /B %errorlevel%
)

call "%ThisDir%\..\Windows\InstallModBuilder.bat"

if %errorlevel% EQU 222 (
    exit /B %errorlevel%
)

call "%ThisDir%\..\Windows\Setup.bat"

set FailCount=0

call :RunTest "ModBundleItems_Invalid_SourceAndMultiSource.json"  "Bundle file cannot specify 'source' and 'multiSource' together"
call :RunTest "ModBundleItems_Invalid_MissingTarget.json"         "BundleFile.target is mandatory with 'multiSource'"
call :RunTest "ModBundleItems_Invalid_WildcardTarget.json"        "BundleFile.target ... cannot contain a wildcard with 'multiSource'"
call :RunTest "ModBundleItems_Invalid_EmptyMultiSource.json"      "BundleFile.multiSource cannot be empty"
call :RunTest "ModBundleItems_Invalid_UnsupportedTargetType.json" "... is not supported for it."

echo.
if %FailCount% EQU 0 (
    echo All invalid multi source configurations failed as expected.
) else (
    echo %FailCount% invalid multi source configuration^(s^) did NOT fail as expected.
)

endlocal & exit /B %FailCount%


:RunTest
echo.
echo ==============================================================================
echo Test   : %~1
echo Expects: %~2
echo ==============================================================================

call "%ModBuilderExe%" ^
  --build ^
  --verbose-logging ^
  --config-list %ConfigFiles% "%TestDir%\%~1"

if errorlevel 1 (
    echo RESULT : PASS, the build failed as expected.
) else (
    echo RESULT : FAIL, the build succeeded but was expected to fail.
    set /A FailCount=FailCount+1
)

exit /B 0
