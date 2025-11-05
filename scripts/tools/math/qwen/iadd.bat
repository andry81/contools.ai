@echo off
setlocal EnableDelayedExpansion

:: Validate command line arguments
if "%~1"=="" if "%~2"=="" (
    echo Error: Two numbers required as arguments.
    echo Usage: %0 ^<number1^> ^<number2^>
    exit /b 1
)
if "%~1"=="" (
    echo Error: First number is missing.
    exit /b 1
)
if "%~2"=="" (
    echo Error: Second number is missing.
    exit /b 1
)

set "num1=%~1"
set "num2=%~2"

:: Validate input format (allow optional sign followed by digits)
set "valid1=0"
set "valid2=0"
call :validate_input num1 valid1
call :validate_input num2 valid2
if !valid1! neq 1 (
    echo Error: Invalid number format for first argument.
    exit /b 1
)
if !valid2! neq 1 (
    echo Error: Invalid number format for second argument.
    exit /b 1
)

:: Determine signs and absolute values
set "sign1=+"
set "sign2=+"
if "!num1:~0,1!"=="-" (
    set "sign1=-"
    set "num1=!num1:~1!"
) else if "!num1:~0,1!"=="+" (
    set "num1=!num1:~1!"
)
if "!num2:~0,1!"=="-" (
    set "sign2=-"
    set "num2=!num2:~1!"
) else if "!num2:~0,1!"=="+" (
    set "num2=!num2:~1!"
)

:: Remove leading zeros
call :remove_leading_zeros num1
call :remove_leading_zeros num2

:: Handle zero values
if "!num1!"=="0" set "num1="
if "!num2!"=="0" set "num2="

:: Determine operation based on signs
if "!sign1!"=="!sign2!" (
    :: Same signs: Add absolute values, keep sign
    call :add_abs !num1! !num2! result
    if "!sign1!"=="-" if not "!result!"=="0" (
        set "result=-!result!"
    )
) else (
    :: Different signs: Subtract smaller from larger
    call :compare_abs !num1! !num2! comp_result
    if "!comp_result!"=="0" (
        set "result=0"
    ) else if "!comp_result!"=="1" (
        :: num1 > num2
        call :sub_abs !num1! !num2! result
        if "!sign1!"=="-" if not "!result!"=="0" (
            set "result=-!result!"
        )
    ) else (
        :: num2 > num1
        call :sub_abs !num2! !num1! result
        if "!sign2!"=="-" if not "!result!"=="0" (
            set "result=-!result!"
        )
    )
)

echo !result!
exit /b 0

:validate_input
:: %1 = variable name containing the number string, %2 = name of return variable
set "str_val=!%1!"
set "ret_var=%2"
set "len=0"
set "i=0"
set "temp=!str_val!"

:val_loop
if "!temp!"=="" goto val_done
set "c=!temp:~0,1!"
if !i! equ 0 (
    if "!c!"=="-" (
        set "temp=!temp:~1!"
        set /a i+=1
        goto val_loop
    )
    if "!c!"=="+" (
        set "temp=!temp:~1!"
        set /a i+=1
        goto val_loop
    )
)
if "!c!" LSS "0" goto val_invalid
if "!c!" GTR "9" goto val_invalid
set "temp=!temp:~1!"
set /a i+=1
set /a len+=1
goto val_loop

:val_done
if !len! GTR 0 (
    call set "%%ret_var%%=1"
) else (
    call set "%%ret_var%%=0"
)
goto :eof

:val_invalid
call set "%%ret_var%%=0"
goto :eof

:remove_leading_zeros
:: %1 = variable name
set "str_val=!%1!"
set "new_str="
set "leading=1"
set "i=0"

:rloop
set "c=!str_val:~%i%,1!"
if "!c!"=="" (
    if "!new_str!"=="" set "new_str=0"
    call set "%%1=!new_str!"
    goto :eof
)
if "!c!"=="0" (
    if "!leading!"=="1" (
        set /a i+=1
        goto rloop
    )
)
if not "!c!"=="0" set "leading=0"
set "new_str=!new_str!!c!"
set /a i+=1
goto rloop

:compare_abs
:: %1 = num1 value, %2 = num2 value, %3 = name of return variable
set "n1=%1"
set "n2=%2"
set "ret_var=%3"
if "!n1!"=="!n2!" (
    call set "%%ret_var%%=0"
    goto :eof
)
:: Calculate lengths manually
set "l1=0"
set "l2=0"
set "temp_n1=!n1!"
set "temp_n2=!n2!"
:len_loop1
if "!temp_n1!" neq "" (
    set /a l1+=1
    set "temp_n1=!temp_n1:~1!"
    goto len_loop1
)
:len_loop2
if "!temp_n2!" neq "" (
    set /a l2+=1
    set "temp_n2=!temp_n2:~1!"
    goto len_loop2
)
if !l1! lss !l2! (
    call set "%%ret_var%%=2"
    goto :eof
)
if !l1! gtr !l2! (
    call set "%%ret_var%%=1"
    goto :eof
)
:: Same length, compare character by character
for /l %%i in (0,1,!l1!) do (
    set "c1=!n1:~%%i,1!"
    set "c2=!n2:~%%i,1!"
    if defined c1 if defined c2 (
        if "!c1!" neq "!c2!" (
            if "!c1!" lss "!c2!" (
                call set "%%ret_var%%=2"
            ) else (
                call set "%%ret_var%%=1"
            )
            goto :eof
        )
    )
)
call set "%%ret_var%%=0"
goto :eof

:add_abs
:: %1 = num1 value, %2 = num2 value, %3 = name of result variable
set "n1=%1"
set "n2=%2"
set "ret_var=%3"
if "!n1!"=="" set "n1=0"
if "!n2!"=="" set "n2=0"

:: Calculate lengths manually
set "l1=0"
set "l2=0"
set "temp_n1=!n1!"
set "temp_n2=!n2!"
:len_loop_add1
if "!temp_n1!" neq "" (
    set /a l1+=1
    set "temp_n1=!temp_n1:~1!"
    goto len_loop_add1
)
:len_loop_add2
if "!temp_n2!" neq "" (
    set /a l2+=1
    set "temp_n2=!temp_n2:~1!"
    goto len_loop_add2
)

:: Pad shorter number with leading zeros
if !l1! gtr !l2! (
    set /a "pad_len=!l1!-!l2!"
    set "pad_str="
    for /l %%i in (1,1,!pad_len!) do set "pad_str=!pad_str!0"
    set "n2=!pad_str!!n2!"
    set "l2=!l1!"
) else if !l2! gtr !l1! (
    set /a "pad_len=!l2!-!l1!"
    set "pad_str="
    for /l %%i in (1,1,!pad_len!) do set "pad_str=!pad_str!0"
    set "n1=!pad_str!!n1!"
    set "l1=!l2!"
)

set "result="
set "carry=0"
set /a "idx=!l1!-1"

:add_loop
set /a "d1=!n1:~%idx%,1!"
set /a "d2=!n2:~%idx%,1!"
set /a "sum=!d1!+!d2!+!carry!"
set /a "digit=!sum!%%10"
set /a "carry=!sum!/10"
set "result=!digit!!result!"
if !idx! equ 0 (
    if !carry! neq 0 (
        set "result=!carry!!result!"
    )
    set "final_result=!result!"
    call :remove_leading_zeros final_result
    call set "%%ret_var%%=!final_result!"
    goto :eof
)
set /a idx-=1
goto add_loop

:sub_abs
:: %1 = num1 value (larger), %2 = num2 value (smaller), %3 = name of result variable
set "n1=%1"
set "n2=%2"
set "ret_var=%3"
if "!n1!"=="" set "n1=0"
if "!n2!"=="" set "n2=0"

:: Calculate lengths manually
set "l1=0"
set "l2=0"
set "temp_n1=!n1!"
set "temp_n2=!n2!"
:len_loop_sub1
if "!temp_n1!" neq "" (
    set /a l1+=1
    set "temp_n1=!temp_n1:~1!"
    goto len_loop_sub1
)
:len_loop_sub2
if "!temp_n2!" neq "" (
    set /a l2+=1
    set "temp_n2=!temp_n2:~1!"
    goto len_loop_sub2
)

:: Pad shorter number with leading zeros
set /a "pad_len=!l1!-!l2!"
set "pad_str="
for /l %%i in (1,1,!pad_len!) do set "pad_str=!pad_str!0"
set "n2=!pad_str!!n2!"

set "result="
set "borrow=0"
set /a "idx=!l1!-1"

:sub_loop
set /a "d1=!n1:~%idx%,1!"
set /a "d2=!n2:~%idx%,1!"
set /a "diff=!d1!-!d2!-!borrow!"
if !diff! lss 0 (
    set /a "diff+=10"
    set "borrow=1"
) else (
    set "borrow=0"
)
set "result=!diff!!result!"
if !idx! equ 0 (
    set "final_result=!result!"
    call :remove_leading_zeros final_result
    call set "%%ret_var%%=!final_result!"
    goto :eof
)
set /a idx-=1
goto sub_loop