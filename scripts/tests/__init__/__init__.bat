@echo off

if defined CONTOOLS_AI_PROJECT_ROOT_INIT0_DIR if exist "%CONTOOLS_AI_PROJECT_ROOT_INIT0_DIR%\*" exit /b 0

set INIT_EXTERNALS=1

call "%%~dp0..\..\__init__\__init__.bat" || exit /b
