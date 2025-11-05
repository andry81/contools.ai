@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

(
  for /L %%i in (1,1,10) do call "%%CONTOOLS_AI_ROOT%%/math/qwen/iadd.bat" -999999999999999999 -2147482649
) >nul

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
