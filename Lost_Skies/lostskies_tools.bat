:: Lost Skies Backup and Restore Worlds
:: Author: Tempus Thales
:: Description: This script allows you to backup and restore your Lost Skies worlds.
:: Note: This script was "loosely" derived from a script by DankHoneyOil from Lost Skies Discord https://discord.gg/lostskies
::
:: Version: 1.2
:: Date: 05/16/2025

@echo off
setlocal enabledelayedexpansion
title Lost Skies Backup And Restore Worlds
color 0a

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

:: Display warning message
cls
echo ================================
echo         IMPORTANT WARNING
echo ================================
echo.
echo If you have deleted worlds in-game, please be aware that:
echo 1. The save files are not actually deleted
echo 2. World numbers may not match their file names
echo 3. This can cause confusion when restoring worlds
echo.
echo It is recommended to use the "Manage World Files" option
echo to safely reorganize your world files before backing up
echo or restoring.
echo.
echo Press any key to continue...
pause >nul

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
if not exist "%folderpath%\backups" (
    mkdir "%folderpath%\backups" 2>nul
    if errorlevel 1 (
        echo Failed to create backups folder!
        echo Please check your permissions.
        pause
        exit /b 1
    )
)

:mainmenu
cls
echo ================================
echo Lost Skies - Backup and Restore
echo ================================
echo.
echo [B] Backup world saves
echo [R] Restore world saves
echo [M] Manage World Files
echo [E] Exit
echo.
set /p choice=Your choice: 

:: Validate input and go to the appropriate section
if /i "%choice%"=="B" goto :backup
if /i "%choice%"=="R" goto :restoremenu
if /i "%choice%"=="M" goto :manageworlds
if /i "%choice%"=="E" exit /b 0

echo Invalid choice. Please press B to back up, R to restore, M to manage worlds, or E to exit.
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
mkdir "%backupfolder%" 2>nul
if errorlevel 1 (
    echo Failed to create backup folder!
    echo Please check your permissions.
    pause
    goto :mainmenu
)

:: Check if any world files exist before backup
dir "%folderpath%\SaveData_World_*.sav" >nul 2>&1
if errorlevel 1 (
    echo No world save files found to backup!
    pause
    goto :mainmenu
)

:: Perform the backup file copying
xcopy "%folderpath%\SaveData_World_*.sav" "%backupfolder%" /y /k /h /i
if errorlevel 1 (
    echo Error occurred during backup!
    echo Please check if the files are in use by the game.
) else (
    echo.
    echo Worlds successfully backed up to:
    echo %backupfolder%
)
echo.
pause
goto :mainmenu

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

:manageworlds
cls
echo ================================
echo      Manage World Files
echo ================================
echo.
echo This will help you safely reorganize your world files.
echo.
echo WARNING: This process will:
echo 1. Create a backup of all world files
echo 2. Move world files to a temporary folder
echo 3. Help you identify and rename them correctly
echo.
echo Do you want to continue? (Y/N)
set /p confirm=Your choice: 

if /i not "%confirm%"=="Y" goto :mainmenu

:: Create backup of all world files
echo.
echo Creating backup of all world files...
set "backupfolder=%folderpath%\backups\world_management_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%"
mkdir "%backupfolder%" 2>nul
if errorlevel 1 (
    echo Failed to create backup folder!
    echo Please check your permissions.
    pause
    goto :mainmenu
)

:: Check if any world files exist before proceeding
dir "%folderpath%\SaveData_World_*.sav" >nul 2>&1
if errorlevel 1 (
    echo No world save files found to manage!
    pause
    goto :mainmenu
)

:: Create temporary folder
set "tempfolder=%folderpath%\temp_worlds"
if exist "%tempfolder%" (
    rd /s /q "%tempfolder%" 2>nul
    if errorlevel 1 (
        echo Failed to remove existing temporary folder!
        echo Please check if any files are in use.
        pause
        goto :mainmenu
    )
)
mkdir "%tempfolder%" 2>nul
if errorlevel 1 (
    echo Failed to create temporary folder!
    echo Please check your permissions.
    pause
    goto :mainmenu
)

:: Move all world files to temporary folder
echo.
echo Moving world files to temporary folder...
move "%folderpath%\SaveData_World_*.sav" "%tempfolder%" 2>nul
if errorlevel 1 (
    echo Error moving files to temporary folder!
    echo Please check if the game is running.
    pause
    goto :mainmenu
)

:: List available world files
echo.
echo Available world files:
echo.
set "count=0"
for %%F in ("%tempfolder%\SaveData_World_*.sav") do (
    set /a count+=1
    echo !count!. %%~nxF
)

echo.
echo Please follow these steps:
echo 1. Open the game and go to the worlds screen
echo 2. For each world file, move it back to the main folder
echo 3. Check in-game which world it is
echo 4. Rename it according to the order you want
echo.
echo Press any key when you're ready to start...
pause >nul

:renameworlds
cls
echo ================================
echo      Rename World Files
echo ================================
echo.
echo Current world files in temporary folder:
echo.
set "count=0"
for %%F in ("%tempfolder%\SaveData_World_*.sav") do (
    set /a count+=1
    echo !count!. %%~nxF
)

echo.
echo Enter the number of the world file you want to move (or 0 to finish):
set /p filenum=Your choice: 

if "%filenum%"=="0" goto :cleanup

if %filenum% LSS 1 goto :renameworlds
if %filenum% GTR %count% goto :renameworlds

:: Get the selected file
set "selectedfile="
set "current=0"
for %%F in ("%tempfolder%\SaveData_World_*.sav") do (
    set /a current+=1
    if !current!==%filenum% set "selectedfile=%%F"
)

echo.
echo Enter the new number for this world (0-4):
set /p newnum=Your choice: 

if %newnum% LSS 0 goto :renameworlds
if %newnum% GTR 4 goto :renameworlds

:: Move and rename the file
move "!selectedfile!" "%folderpath%\SaveData_World_%newnum%.sav"
echo.
echo File moved and renamed successfully.
echo.
echo Press any key to continue...
pause >nul
goto :renameworlds

:cleanup
cls
echo ================================
echo      Cleanup Complete
echo ================================
echo.
echo All world files have been reorganized.
echo The temporary folder will be removed.
echo.
echo Press any key to continue...
pause >nul

:: Remove temporary folder
rd /s /q "%tempfolder%" 2>nul
if errorlevel 1 (
    echo Warning: Could not remove temporary folder.
    echo You may need to remove it manually: %tempfolder%
    pause
)
goto :mainmenu