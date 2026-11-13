@echo off
setlocal enabledelayedexpansion
title Onyx Boox Faust 5 (C69HD) Button Remapper

echo ======================================================================
echo           Onyx Boox Faust 5 (C69HD) Hardware Button Remapper
echo ======================================================================
echo This script fixes the physical center button on non-backlit Onyx Boox
echo Faust 5 (C69HD) devices. By default, long-pressing this button tries to
echo toggle the nonexistent frontlight and throws an error toast:
echo   "doesn't support frontlight"
echo.
echo This tool remaps the long-press action natively in the Onyx framework.
echo ======================================================================
echo.

:: Check for ADB
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] ADB is not found in your PATH.
    echo Please install ADB or place adb.exe in this folder.
    echo.
    pause
    exit /b 1
)

:: Check connected devices
echo Checking connected ADB devices...
adb get-state >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] No authorized ADB device found!
    echo 1. Connect your Onyx Boox with a USB cable.
    echo 2. Ensure USB Debugging is turned ON in Developer options.
    echo 3. Unlock the device screen and accept the ADB debugging prompt.
    echo.
    pause
    exit /b 1
)

echo [OK] Device detected!
echo.
echo Choose what you want the physical button LONG-PRESS to do:
echo.
echo  [1] Recent Apps / App Switcher (Recommended)
echo  [2] Full Screen E-Ink Refresh (Clears ghosting)
echo  [3] Take Screenshot
echo  [4] Open E-Ink Refresh Mode Dialog
echo  [5] Go to Home Screen
echo  [6] Toggle A2 Speed Refresh Mode
echo  [7] Disable Long-Press Completely (Do nothing, no error toast)
echo  [8] Revert to Factory Default (Frontlight toggle)
echo.

set /p CHOICE="Enter choice [1-8, Default: 1]: "
if "%CHOICE%"=="" set CHOICE=1

if "%CHOICE%"=="1" (
    set ACTION=KEYCODE_APP_SWITCH
    set DESC=Recent Apps
) else if "%CHOICE%"=="2" (
    set ACTION=fullRefreshScreen
    set DESC=Full Screen Refresh
) else if "%CHOICE%"=="3" (
    set ACTION=screenshot
    set DESC=Take Screenshot
) else if "%CHOICE%"=="4" (
    set ACTION=showRefreshModeDialog
    set DESC=E-Ink Refresh Mode Dialog
) else if "%CHOICE%"=="5" (
    set ACTION=back_to_home
    set DESC=Go to Home Screen
) else if "%CHOICE%"=="6" (
    set ACTION=toggleA2
    set DESC=Toggle A2 Refresh Mode
) else if "%CHOICE%"=="7" (
    set ACTION=none
    set DESC=Disabled
) else if "%CHOICE%"=="8" (
    set ACTION=toggleFrontLight
    set DESC=Factory Default Frontlight
) else (
    echo Invalid choice. Defaulting to Recent Apps.
    set ACTION=KEYCODE_APP_SWITCH
    set DESC=Recent Apps
)

echo.
echo Applying mapping: %DESC% (%ACTION%)...

if "%ACTION%"=="none" (
    :: Setting longPressAction to empty string disables the action completely
    adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"\",\"repeat\":false}'"
) else (
    adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"%ACTION%\",\"repeat\":false}'"
)

:: Broadcast reload to Onyx framework inside system_server
adb shell am broadcast -a onyx.action.refresh_keymapping >nul 2>nul

echo.
echo ======================================================================
echo [SUCCESS] Applied successfully!
echo.
echo Verification from device:
adb shell settings get global KEYCODE_BACK
echo.
echo Test it now by holding down the physical center front button!
echo (Normal short press will continue to function as BACK).
echo ======================================================================
echo.
pause
