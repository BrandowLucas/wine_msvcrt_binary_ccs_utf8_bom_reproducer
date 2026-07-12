@echo off
setlocal

set "ROOT=%~dp0.."
set "OUTPUT_DIR=%ROOT%\out-windows"
set "OUTPUT_FILE=%OUTPUT_DIR%\ccs-utf8-output.bin"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
del /q "%OUTPUT_FILE%" "%OUTPUT_DIR%\run.log" 2>nul

"%ROOT%\bin\ccs_utf8_bom_probe.exe" "%OUTPUT_FILE%" > "%OUTPUT_DIR%\run.log" 2>&1
type "%OUTPUT_DIR%\run.log"
exit /b %ERRORLEVEL%
