@echo off
setlocal enabledelayedexpansion
title Onyx Boox Faust 5 (C69HD) Button Remapper

echo ======================================================================
echo           Onyx Boox Faust 5 (C69HD) Hardware Button Remapper
echo ======================================================================
echo This script configures the physical center button on Onyx Boox Faust 5
echo (C69HD) devices. By default, long-pressing this button attempts to
echo toggle nonexistent frontlight and throws an error toast.
echo.
echo This tool remaps the button natively in the Onyx framework.
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
echo ======================================================================
echo  1. SELECT ACTION FOR BUTTON HOLD (LONG-PRESS)
echo ======================================================================
echo  [1] Recent Apps / App Switcher (Recommended)
echo  [2] Full Screen E-Ink Refresh (Clears ghosting)
echo  [3] Take Screenshot
echo  [4] Open E-Ink Refresh Mode Dialog
echo  [5] Go to Home Screen
echo  [6] Toggle A2 Speed Refresh Mode
echo  [7] Standard Back (No Long-Press Action)
echo  [8] Revert to Factory Default (Frontlight toggle)
echo.

set /p LP_CHOICE="Enter choice [1-8, Default: 1]: "
if "%LP_CHOICE%"=="" set LP_CHOICE=1

if "%LP_CHOICE%"=="1" (
    set LP_ACTION=KEYCODE_APP_SWITCH
    set LP_DESC=Recent Apps
) else if "%LP_CHOICE%"=="2" (
    set LP_ACTION=fullRefreshScreen
    set LP_DESC=Full Screen Refresh
) else if "%LP_CHOICE%"=="3" (
    set LP_ACTION=screenshot
    set LP_DESC=Take Screenshot
) else if "%LP_CHOICE%"=="4" (
    set LP_ACTION=showRefreshModeDialog
    set LP_DESC=E-Ink Refresh Mode Dialog
) else if "%LP_CHOICE%"=="5" (
    set LP_ACTION=back_to_home
    set LP_DESC=Go to Home Screen
) else if "%LP_CHOICE%"=="6" (
    set LP_ACTION=toggleA2
    set LP_DESC=Toggle A2 Refresh Mode
) else if "%LP_CHOICE%"=="7" (
    set LP_ACTION=
    set LP_DESC=Standard Back
) else if "%LP_CHOICE%"=="8" (
    set LP_ACTION=toggleFrontLight
    set LP_DESC=Factory Default Frontlight
) else (
    set LP_ACTION=KEYCODE_APP_SWITCH
    set LP_DESC=Recent Apps
)

echo.
echo ======================================================================
echo  2. SELECT ACTION FOR BUTTON TAP (SHORT-PRESS)
echo ======================================================================
echo  [1] Standard Back (Recommended)
echo  [2] Full Screen E-Ink Refresh
echo  [3] Take Screenshot
echo  [4] Go to Home Screen
echo  [5] Recent Apps / App Switcher
echo  [6] Open E-Ink Refresh Mode Dialog
echo.

set /p SP_CHOICE="Enter choice [1-6, Default: 1]: "
if "%SP_CHOICE%"=="" set SP_CHOICE=1

if "%SP_CHOICE%"=="1" (
    set SP_ACTION=
    set SP_DESC=Standard Back
) else if "%SP_CHOICE%"=="2" (
    set SP_ACTION=fullRefreshScreen
    set SP_DESC=Full Screen Refresh
) else if "%SP_CHOICE%"=="3" (
    set SP_ACTION=screenshot
    set SP_DESC=Take Screenshot
) else if "%SP_CHOICE%"=="4" (
    set SP_ACTION=back_to_home
    set SP_DESC=Go to Home Screen
) else if "%SP_CHOICE%"=="5" (
    set SP_ACTION=KEYCODE_APP_SWITCH
    set SP_DESC=Recent Apps
) else if "%SP_CHOICE%"=="6" (
    set SP_ACTION=showRefreshModeDialog
    set SP_DESC=E-Ink Refresh Mode Dialog
) else (
    set SP_ACTION=
    set SP_DESC=Standard Back
)

echo.
echo Applying mapping...
echo  - Short Press : %SP_DESC%
echo  - Long Press  : %LP_DESC%

adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"%SP_ACTION%\",\"longPressAction\":\"%LP_ACTION%\",\"repeat\":false}'"

if "%SP_ACTION%"=="" (
    adb shell "settings put global key_custom_side_key_short_press_enable 0"
) else (
    adb shell "settings put global key_custom_side_key_short_press_enable 1"
)

:: Broadcast reload to Onyx framework inside system_server
adb shell am broadcast -a onyx.action.refresh_keymapping >nul 2>nul

echo.
echo ======================================================================
echo [SUCCESS] Hardware button remapped successfully!
echo.
echo Active Settings.Global configuration:
adb shell "settings get global KEYCODE_BACK"
echo.
echo * Single Tap : %SP_DESC%
echo * Long Press : %LP_DESC%
echo * Persistent : Survives device reboots.
echo ======================================================================
echo.
echo [NOTE regarding Double-Press & Screen-Wake]:
echo * Double-Press: Onyx ROM natively supports Short and Long press.
echo   For true 3-way multi-press (single, double, hold), install the
echo   open-source 'Key Mapper' app (see README.md).
echo * Screen Wake: Android framework/kernel blocks KEY_BACK wake when asleep.
echo   Wake via the top Power button or a magnetic smart cover (Hall sensor).
echo ======================================================================
echo.
pause
