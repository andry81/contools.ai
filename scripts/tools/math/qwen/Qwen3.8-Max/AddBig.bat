@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem  AddBig.bat
rem  Adds two signed decimal integers that may exceed 32-bit.
rem  Usage: AddBig.bat [number1] [number2]
rem  If numbers are omitted, the script prompts for them.
rem ============================================================

set "ARG1=%~1"
set "ARG2=%~2"

if not defined ARG1 set /p "ARG1=Enter first signed integer: "
if not defined ARG2 set /p "ARG2=Enter second signed integer: "

call :trim ARG1
call :trim ARG2

call :parse ARG1 SIGN1 ABS1
if errorlevel 1 (
    echo ERROR: Invalid first integer.
    exit /b 1
)

call :parse ARG2 SIGN2 ABS2
if errorlevel 1 (
    echo ERROR: Invalid second integer.
    exit /b 1
)

rem Normalize negative zero to positive zero.
if "!ABS1!"=="0" set "SIGN1=+"
if "!ABS2!"=="0" set "SIGN2=+"

if not "!SIGN1!"=="!SIGN2!" goto opposite_signs

rem Same sign: add absolute values.
call :absadd ABS1 ABS2 SUMABS
set "SIGNRESULT=!SIGN1!"
goto finalize

:opposite_signs
rem Opposite signs: subtract smaller absolute value from larger one.
call :abscompare ABS1 ABS2 CMP

if "!CMP!"=="0" (
    set "SIGNRESULT=+"
    set "SUMABS=0"
    goto finalize
)

if "!CMP!"=="1" (
    call :abssub ABS1 ABS2 SUMABS
    set "SIGNRESULT=!SIGN1!"
    goto finalize
)

call :abssub ABS2 ABS1 SUMABS
set "SIGNRESULT=!SIGN2!"

:finalize
if "!SUMABS!"=="0" set "SIGNRESULT=+"

if "!SIGNRESULT!"=="+" (
    set "RESULT=!SUMABS!"
) else (
    set "RESULT=-!SUMABS!"
)

echo !RESULT!
endlocal
exit /b 0


rem ===================== functions =====================

:trim <variableName>
rem Trims leading and trailing spaces from the variable.
set "tm_s=!%~1!"

:trim_left
if defined tm_s if "!tm_s:~0,1!"==" " (
    set "tm_s=!tm_s:~1!"
    goto trim_left
)

:trim_right
if defined tm_s if "!tm_s:~-1!"==" " (
    set "tm_s=!tm_s:~0,-1!"
    goto trim_right
)

set "%~1=!tm_s!"
exit /b 0


:parse <inputVariable> <signVariable> <absVariable>
rem Parses an optional + or - sign and validates decimal digits.
rem Removes leading zeros from the absolute value.
set "ps_s=!%~1!"
if not defined ps_s exit /b 1

set "ps_sign=+"
set "ps_first=!ps_s:~0,1!"

if "!ps_first!"=="+" (
    set "ps_s=!ps_s:~1!"
) else if "!ps_first!"=="-" (
    set "ps_sign=-"
    set "ps_s=!ps_s:~1!"
)

if not defined ps_s exit /b 1

call :stripzeros ps_s ps_s

rem Validate that only decimal digits remain.
rem The sentinel "#" guarantees ps_test is never empty.
set "ps_test=!ps_s!#"

for %%d in (0 1 2 3 4 5 6 7 8 9) do set "ps_test=!ps_test:%%d=!"

if not "!ps_test!"=="#" exit /b 1

set "%~2=!ps_sign!"
set "%~3=!ps_s!"
exit /b 0


:stripzeros <variableName> <outputVariable>
rem Removes leading zeros. Returns "0" for an all-zero or empty value.
set "sz_s=!%~1!"

:stripzeros_loop
if defined sz_s if "!sz_s:~0,1!"=="0" (
    set "sz_s=!sz_s:~1!"
    goto stripzeros_loop
)

if not defined sz_s set "sz_s=0"
set "%~2=!sz_s!"
exit /b 0


:strlen <variableName> <outputLength>
rem Computes string length. Uses a sentinel character.
set "sl_s=!%~1!#"
set "sl_len=0"

for %%P in (32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!sl_s:~%%P,1!" neq "" (
        set /a sl_len+=%%P
        set "sl_s=!sl_s:~%%P!"
    )
)

set "%~2=!sl_len!"
exit /b 0


:absadd <absVariable1> <absVariable2> <outputVariable>
rem Adds two non-negative decimal strings.
set "aa_a=!%~1!"
set "aa_b=!%~2!"

call :strlen aa_a aa_la
call :strlen aa_b aa_lb

set /a aa_max=aa_la
if !aa_lb! gtr !aa_max! set /a aa_max=aa_lb

set aa_carry=0
set "aa_res="

rem Process digits from right to left.
for /l %%i in (1,1,!aa_max!) do (
    set "aa_da=0"
    set "aa_db=0"

    if %%i leq !aa_la! set "aa_da=!aa_a:~-%%i,1!"
    if %%i leq !aa_lb! set "aa_db=!aa_b:~-%%i,1!"

    set /a aa_total=aa_da+aa_db+aa_carry
    set /a aa_digit=aa_total %% 10, aa_carry=aa_total / 10

    set "aa_res=!aa_digit!!aa_res!"
)

if !aa_carry! neq 0 set "aa_res=!aa_carry!!aa_res!"
if not defined aa_res set "aa_res=0"
if "!aa_res:~0,1!"=="0" call :stripzeros aa_res aa_res

set "%~3=!aa_res!"
exit /b 0


:abssub <largerAbsVariable> <smallerAbsVariable> <outputVariable>
rem Subtracts smaller non-negative decimal string from larger one.
rem Caller must ensure larger >= smaller.
set "as_a=!%~1!"
set "as_b=!%~2!"

call :strlen as_a as_la
call :strlen as_b as_lb

set as_borrow=0
set "as_res="

rem Process digits from right to left.
for /l %%i in (1,1,!as_la!) do (
    set "as_da=!as_a:~-%%i,1!"
    set "as_db=0"

    if %%i leq !as_lb! set "as_db=!as_b:~-%%i,1!"

    set /a as_diff=as_da-as_db-as_borrow

    if !as_diff! lss 0 (
        set /a as_diff+=10
        set as_borrow=1
    ) else (
        set as_borrow=0
    )

    set "as_res=!as_diff!!as_res!"
)

call :stripzeros as_res as_res
set "%~3=!as_res!"
exit /b 0


:abscompare <absVariable1> <absVariable2> <outputCompare>
rem outputCompare:
rem   1  if first absolute value is greater
rem  -1  if first absolute value is smaller
rem   0  if equal
set "ac_a=!%~1!"
set "ac_b=!%~2!"

call :strlen ac_a ac_la
call :strlen ac_b ac_lb

if !ac_la! gtr !ac_lb! (
    set "%~3=1"
    exit /b 0
)

if !ac_la! lss !ac_lb! (
    set "%~3=-1"
    exit /b 0
)

set /a ac_last=ac_la-1

for /l %%i in (0,1,!ac_last!) do (
    set "ac_da=!ac_a:~%%i,1!"
    set "ac_db=!ac_b:~%%i,1!"

    if !ac_da! gtr !ac_db! (
        set "%~3=1"
        exit /b 0
    )

    if !ac_da! lss !ac_db! (
        set "%~3=-1"
        exit /b 0
    )
)

set "%~3=0"
exit /b 0
