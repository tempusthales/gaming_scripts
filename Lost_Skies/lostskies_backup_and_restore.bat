:: Lost Skies Backup and Restore Worlds
:: Author: Tempus Thales
:: Description: This script allows you to backup and restore your Lost Skies worlds.
:: Version: 1.0
:: Date: 05/16/2025

@echo off
setlocal enabledelayedexpansion
title Lost Skies Backup And Restore Worlds
color 0a

:: Check if Lost Skies folder exists
set "found=0"
for /d %%F in ("%userprofile%\AppData\LocalLow\Bossa Games\LostSkies\SaveData\7656*") do (
    set "folderpath=%%F"
    set "found=1"
    goto :folderFound
)
:folderFound

if "%found%"=="0" (
    echo Lost Skies save folder not found!
    echo Please make sure the game is installed and you've played it at least once.
    pause
    exit /b 1
)

:: Create backups folder if it doesn't exist
if not exist "%folderpath%\backups" mkdir "%folderpath%\backups"

:mainmenu
cls
echo ================================
echo Lost Skies - Backup and Restore
echo ================================
echo.
echo [B] Backup world saves
echo [R] Restore world saves
echo [E] Exit
echo.
set /p choice=Your choice: 

:: Validate input and go to the appropriate section
if /i "%choice%"=="B" goto :backup
if /i "%choice%"=="R" goto :restoremenu
if /i "%choice%"=="E" exit /b 0

echo Invalid choice. Please press B to back up, R to restore, or E to exit.
pause
goto :mainmenu

:backup
cls
echo Creating backup with timestamp...
:: Get current date and time for backup folder
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set "timestamp=%mydate%_%mytime%"

:: Create timestamped backup folder
set "backupfolder=%folderpath%\backups\backup_%timestamp%"
mkdir "%backupfolder%"

:: Perform the backup file copying
xcopy "%folderpath%\SaveData_World_*.sav" "%backupfolder%" /y /k /h /i
if errorlevel 1 (
    echo Error occurred during backup!
) else (
    echo.
    echo Worlds successfully backed up to:
    echo %backupfolder%
)
echo.
pause
goto mainmenu

:restoremenu
cls
echo ================================
echo        Restore World Save
echo ================================
echo.
echo Which world do you want to restore?
echo.
echo 1. World 1
echo 2. World 2
echo 3. World 3
echo 4. World 4
echo 5. World 5
echo.
echo 6. Back to Main Menu
echo.
set /p choice=Enter a number (1-6): 

:: Check if user chose to go back
if "%choice%"=="6" goto :mainmenu

:: Validate choice
if "%choice%"=="" goto restoremenu
if %choice% LSS 1 goto restoremenu
if %choice% GTR 6 goto restoremenu

:: Map user choice (1-5) to file index (0-4)
set /a fileindex=%choice% - 1

:: Find most recent backup
set "latest_backup="
for /f "delims=" %%i in ('dir /b /ad /o-n "%folderpath%\backups"') do (
    if not defined latest_backup set "latest_backup=%%i"
)

if not defined latest_backup (
    echo.
    echo No backups found!
    echo Please create a backup first.
    echo.
    pause
    goto restoremenu
)

set "sourcefile=%folderpath%\backups\%latest_backup%\SaveData_World_%fileindex%.sav"
set "targetfile=%folderpath%\SaveData_World_%fileindex%.sav"

:: Confirm overwrite
if not exist "%sourcefile%" (
    echo.
    echo Backup for World %choice% not found.
    echo.
    pause
    goto restoremenu
)

echo.
echo Are you sure you want to restore World %choice%?
echo This will overwrite the current save file.
echo.
echo Source: %sourcefile%
echo Target: %targetfile%
echo.
set /p confirm=Type Y to confirm: 
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    goto restoremenu
)

:: Perform restore
copy /y "%sourcefile%" "%targetfile%" >nul
if errorlevel 1 (
    echo.
    echo Error occurred during restore!
) else (
    echo.
    echo World %choice% has been successfully restored.
    echo File: SaveData_World_%fileindex%.sav
)
echo.
pause
goto restoremenu