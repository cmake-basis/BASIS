@echo off

:: ############################################################################
:: @file  runtest.bat
:: @brief Helper script for execution of test command.
::
:: Copyright (c) University of Pennsylvania. All rights reserved.
:: See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
::
:: Contact: SBIA Group <sbia-software at uphs.upenn.edu>
:: ############################################################################

setlocal enableextensions
setlocal enabledelayedexpansion

:: ============================================================================
:: auxiliary functions
:: ============================================================================

:: ----------------------------------------------------------------------------
:: Remove all files and directories from the current working directory.
:clean
    for /d %d in (*) do rd /q /s %d
    if %ERRORLEVEL% neq 0 echo Failed to clean current working directory 1>&2
    goto :eof

:: ----------------------------------------------------------------------------
:: Output special information for inclusion in submission to CDash.
:print_dart_measurements
    for /f %h in ('hostname') echo ^<DartMeasurement name="Host Name" type="string"^>%h^</DartMeasurement^>
    echo ^<DartMeasurement name="Working Directory" type="string"^>%CD%^</DartMeasurement^>
    goto :eof

:: ============================================================================
:: main
:: ============================================================================

set clean_before=false
set clean_after=false
set dart=true
set cmd=

:parsearg
    if [%1] == [] goto checkargs
    if [%1] == [--clean-before] (
        set clean_before=true
    )
    if [%1] == [--clean-after] (
        set clean_after=true
    )
    if [%1] == [--nodart] (
        set dart=false
    )
    if [%1] == [--] goto appendargs
    set cmd=!cmd! "%1"
    shift
    goto parseargs

:appendargs
    if [%1] == [] goto checkargs
    set cmd=!cmd! "%1"
    shift

:checkargs
    if [%cmd%] == [] (
        echo "Missing test command!" 1>&2
        exit /b 1
    )

:pretest
    if %dart% == true call :print_dart_measurements
    if %clean_before% == true call :clean

:test
    call %cmd%
    set retval=%errorlevel%

:posttest
    if %clean_after% == true call :clean

exit /b %retval%
