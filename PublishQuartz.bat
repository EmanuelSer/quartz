@echo off
setlocal EnableExtensions

REM Quartz publish script. Place this file in your quartz repo root.
REM It copies your Obsidian vault into quartz\content, then commits and pushes.

REM Path to your Obsidian vault (edit this if your path is different):
set "SRC=F:\Emanuel Ser\Emanuel Ser's Vault"

REM Resolve repo (this script's folder) and content path automatically:
pushd "%~dp0" || (
echo Could not change to script directory. Aborting.
goto :fail
)
set "REPO=%CD%"
set "DST=%REPO%\content"

REM Checks
if not exist "%SRC%" (
echo Source vault not found: "%SRC%"
goto :failPop
)
if not exist "%REPO%.git" (
echo Not a Git repo: "%REPO%"
goto :failPop
)
if not exist "%DST%" (
echo Creating content folder...
mkdir "%DST%" || goto :failPop
)

REM Ensure Git is available
git --version >nul 2>&1 || (
echo Git is not installed or not on PATH.
goto :failPop
)

echo.
echo Syncing vault -> content...
robocopy "%SRC%" "%DST%" /MIR /R:1 /W:2 /MT:8 /XJ /NFL /NDL /NP ^
/XD ".git" ".obsidian" ".trash" ".quartz-cache" ^
/XF "Thumbs.db" "desktop.ini"
set "RC=%ERRORLEVEL%"
if %RC% GEQ 8 (
echo Robocopy failed (code %RC%).
goto :failPop
)

echo.
echo Committing and pushing...
git -C "%REPO%" add -A
git -C "%REPO%" commit -m "Publish from Vault on %DATE% %TIME%" || echo Nothing to commit.
git -C "%REPO%" push || (
echo git push failed.
goto :failPop
)

echo.
echo Done. Published successfully.
popd
pause
exit /b 0

:failPop
popd
:fail
echo.
echo Publish failed. See messages above.
pause
exit /b 1