#!/usr/bin/env bash
# ==============================================================================
# Onyx Boox Faust 5 (C69HD) Hardware Button Remapper
#
# Configures the physical center button on Onyx Boox Faust 5 (C69HD) devices.
# Remaps Short-Press (Tap) and Long-Press (Hold) natively in the Onyx framework.
#
# Can be run directly from a host PC via ADB, OR pushed directly to the device
# and executed inside the Android shell / Termux.
# ==============================================================================

set -e

# Detect whether running directly inside Android shell or on a host machine
if [ -f "/system/bin/settings" ]; then
    RUN_CMD=""
else
    if ! command -v adb >/dev/null 2>&1; then
        echo "[ERROR] 'adb' command not found. Please install Android Platform Tools."
        exit 1
    fi
    RUN_CMD="adb shell"
    
    # Check if device is connected
    if ! adb get-state >/dev/null 2>&1; then
        echo "[ERROR] No connected/authorized ADB device found."
        echo "Please connect your Onyx Boox via USB with USB Debugging enabled."
        exit 1
    fi
fi

echo "======================================================================"
echo "          Onyx Boox Faust 5 (C69HD) Hardware Button Remapper"
echo "======================================================================"
echo ""
echo "--- 1. Choose LONG-PRESS (Hold) Action ---"
echo "  1) Recent Apps / App Switcher (Recommended)"
echo "  2) Full Screen E-Ink Refresh (Clears ghosting)"
echo "  3) Take Screenshot"
echo "  4) Open E-Ink Refresh Mode Dialog"
echo "  5) Return to Home Screen"
echo "  6) Toggle A2 Fast Refresh Mode"
echo "  7) Standard Back (No Long-Press Action)"
echo "  8) Revert to Factory Default (Frontlight toggle)"
echo ""
read -r -p "Enter choice [1-8, Default: 1]: " LP_CHOICE
LP_CHOICE="${LP_CHOICE:-1}"

case "$LP_CHOICE" in
    1) LP_ACTION="KEYCODE_APP_SWITCH"; LP_DESC="Recent Apps" ;;
    2) LP_ACTION="fullRefreshScreen"; LP_DESC="Full Screen Refresh" ;;
    3) LP_ACTION="screenshot"; LP_DESC="Take Screenshot" ;;
    4) LP_ACTION="showRefreshModeDialog"; LP_DESC="Refresh Mode Dialog" ;;
    5) LP_ACTION="back_to_home"; LP_DESC="Home Screen" ;;
    6) LP_ACTION="toggleA2"; LP_DESC="Toggle A2 Mode" ;;
    7) LP_ACTION=""; LP_DESC="Standard Back" ;;
    8) LP_ACTION="toggleFrontLight"; LP_DESC="Factory Default Frontlight" ;;
    *) LP_ACTION="KEYCODE_APP_SWITCH"; LP_DESC="Recent Apps" ;;
esac

echo ""
echo "--- 2. Choose SHORT-PRESS (Single Tap) Action ---"
echo "  1) Standard Back (Recommended)"
echo "  2) Full Screen E-Ink Refresh"
echo "  3) Take Screenshot"
echo "  4) Return to Home Screen"
echo "  5) Recent Apps / App Switcher"
echo "  6) Open E-Ink Refresh Mode Dialog"
echo ""
read -r -p "Enter choice [1-6, Default: 1]: " SP_CHOICE
SP_CHOICE="${SP_CHOICE:-1}"

case "$SP_CHOICE" in
    1) SP_ACTION=""; SP_DESC="Standard Back" ;;
    2) SP_ACTION="fullRefreshScreen"; SP_DESC="Full Screen Refresh" ;;
    3) SP_ACTION="screenshot"; SP_DESC="Take Screenshot" ;;
    4) SP_ACTION="back_to_home"; SP_DESC="Home Screen" ;;
    5) SP_ACTION="KEYCODE_APP_SWITCH"; SP_DESC="Recent Apps" ;;
    6) SP_ACTION="showRefreshModeDialog"; SP_DESC="Refresh Mode Dialog" ;;
    *) SP_ACTION=""; SP_DESC="Standard Back" ;;
esac

# Build JSON payload
JSON_PAYLOAD="{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"$SP_ACTION\",\"longPressAction\":\"$LP_ACTION\",\"repeat\":false}"

echo ""
echo "[*] Applying configuration..."
echo "  - Single Tap : $SP_DESC"
echo "  - Long Press : $LP_DESC"

if [ -z "$RUN_CMD" ]; then
    # Running directly on device
    settings put global KEYCODE_BACK "$JSON_PAYLOAD"
    if [ -n "$SP_ACTION" ]; then
        settings put global key_custom_side_key_short_press_enable 1
    else
        settings put global key_custom_side_key_short_press_enable 0
    fi
    am broadcast -a onyx.action.refresh_keymapping >/dev/null 2>&1
    SAVED=$(settings get global KEYCODE_BACK)
else
    # Running via ADB
    $RUN_CMD "settings put global KEYCODE_BACK '$JSON_PAYLOAD'"
    if [ -n "$SP_ACTION" ]; then
        $RUN_CMD "settings put global key_custom_side_key_short_press_enable 1"
    else
        $RUN_CMD "settings put global key_custom_side_key_short_press_enable 0"
    fi
    $RUN_CMD "am broadcast -a onyx.action.refresh_keymapping" >/dev/null 2>&1
    SAVED=$($RUN_CMD "settings get global KEYCODE_BACK")
fi

echo ""
echo "======================================================================"
echo "[SUCCESS] Button successfully remapped!"
echo ""
echo "Active Settings.Global configuration:"
echo "  $SAVED"
echo ""
echo "• Single Tap : $SP_DESC"
echo "• Long Press : $LP_DESC"
echo "• Persistent : Survives device reboots."
echo "======================================================================"
echo ""
echo "[NOTE regarding Double-Press & Screen-Wake]:"
echo "• Double-Press: Onyx ROM natively supports Short & Long press."
echo "  For true 3-way multi-press (single, double, hold), install the"
echo "  open-source 'Key Mapper' app (see README.md)."
echo "• Screen Wake: Android framework/kernel blocks KEY_BACK wake when asleep."
echo "  Wake via the top Power button or a magnetic smart cover (Hall sensor)."
echo "======================================================================"
