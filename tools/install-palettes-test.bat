@echo off
setlocal

:: Optional: set your WoW Interface\AddOns folder explicitly if auto-detect does not find it.
:: Example: set "ADDONS_DIR=C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns"
set "ADDONS_DIR="

set "ZIP_URL=https://github.com/odd-brew/daylight-palettes/releases/download/palettes-test/PalettesTest.zip"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$addonsDir = $env:ADDONS_DIR;" ^
  "if (-not $addonsDir) {" ^
  "  $roots = @('C:\Program Files (x86)\World of Warcraft', 'C:\Program Files\World of Warcraft', 'D:\World of Warcraft', 'D:\Games\World of Warcraft', 'E:\World of Warcraft');" ^
  "  $candidates = @();" ^
  "  foreach ($r in $roots) {" ^
  "    if (Test-Path $r) {" ^
  "      Get-ChildItem -Path $r -Directory -ErrorAction SilentlyContinue | ForEach-Object {" ^
  "        $a = Join-Path $_.FullName 'Interface\AddOns';" ^
  "        if (Test-Path (Join-Path $a 'DaylightUI')) { $candidates += $a }" ^
  "      }" ^
  "    }" ^
  "  }" ^
  "  if ($candidates.Count -eq 1) {" ^
  "    $addonsDir = $candidates[0];" ^
  "  } elseif ($candidates.Count -gt 1) {" ^
  "    Write-Host 'Found multiple WoW AddOns folders with DaylightUI:' -ForegroundColor Yellow;" ^
  "    $candidates | ForEach-Object { Write-Host ('  ' + $_) };" ^
  "    throw 'Please edit ADDONS_DIR at the top of this script to pick one.';" ^
  "  } else {" ^
  "    throw 'Could not auto-detect your WoW AddOns folder containing DaylightUI. Please edit ADDONS_DIR at the top of this script.';" ^
  "  }" ^
  "}" ^
  "if (-not (Test-Path $addonsDir)) { throw ('AddOns folder not found: ' + $addonsDir) }" ^
  "Write-Host ('Target AddOns folder: ' + $addonsDir) -ForegroundColor Cyan;" ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
  "$tmpZip = Join-Path $env:TEMP 'PalettesTest.zip';" ^
  "Write-Host 'Downloading latest PalettesTest.zip from GitHub...';" ^
  "Invoke-WebRequest -Uri $env:ZIP_URL -OutFile $tmpZip -UseBasicParsing;" ^
  "$targetDir = Join-Path $addonsDir 'PalettesTest';" ^
  "if (Test-Path $targetDir) { Remove-Item -Recurse -Force $targetDir }" ^
  "Expand-Archive -Path $tmpZip -DestinationPath $addonsDir -Force;" ^
  "Remove-Item -Force $tmpZip -ErrorAction SilentlyContinue;" ^
  "$toc = Join-Path $targetDir 'PalettesTest.toc';" ^
  "$verLine = (Select-String -Path $toc -Pattern '^## Version:' | Select-Object -First 1).Line;" ^
  "Write-Host '';" ^
  "Write-Host ('Installed Palettes (Test): ' + $verLine) -ForegroundColor Green;" ^
  "Write-Host 'In WoW: turn off Palettes, turn on Palettes (Test), and run /reload.' -ForegroundColor Green;"

if errorlevel 1 (
  echo.
  echo Install failed. See error above.
)
echo.
pause
