#!/usr/bin/env bash
# ==============================================================================
# Onyx Boox Faust 5 (C69HD) Hardware Button Remapper
#
# Fixes the physical center button on non-backlit Onyx Boox Faust 5 (C69HD)
# devices. By default, long-pressing this button attempts to toggle frontlight,
# which triggers the error toast: "doesn't support frontlight".
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

ACTION="$1"

if [ -z "$ACTION" ]; then
    echo "======================================================================"
    echo "          Onyx Boox Faust 5 (C69HD) Hardware Button Remapper"
    echo "======================================================================"
    echo "Select an action for the physical button LONG-PRESS:"
    echo ""
    echo "  1) Recent Apps / App Switcher (Recommended)"
    echo "  2) Full Screen E-Ink Refresh (Clears ghosting)"
    echo "  3) Take Screenshot"
    echo "  4) Open E-Ink Refresh Mode Dialog"
    echo "  5) Return to Home Screen"
    echo "  6) Toggle A2 Fast Refresh Mode"
    echo "  7) Disable Long-Press Completely (No action, no error toast)"
    echo "  8) Revert to Factory Default (Frontlight toggle)"
    echo ""
    read -r -p "Enter choice [1-8, Default: 1]: " CHOICE
    CHOICE="${CHOICE:-1}"

    case "$CHOICE" in
        1) ACTION="KEYCODE_APP_SWITCH" ;;
        2) ACTION="fullRefreshScreen" ;;
        3) ACTION="screenshot" ;;
        4) ACTION="showRefreshModeDialog" ;;
        5) ACTION="back_to_home" ;;
        6) ACTION="toggleA2" ;;
        7) ACTION="" ;;
        8) ACTION="toggleFrontLight" ;;
        *) ACTION="KEYCODE_APP_SWITCH" ;;
    esac
fi

# Build JSON payload
if [ -z "$ACTION" ]; then
    JSON_PAYLOAD='{"keySet":["KEYCODE_BACK"],"shortPressAction":"","longPressAction":"","repeat":false}'
    DESC="Disabled (No action)"
else
    JSON_PAYLOAD="{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"$ACTION\",\"repeat\":false}"
    DESC="$ACTION"
fi

echo ""
echo "[*] Applying configuration: $DESC..."

if [ -z "$RUN_CMD" ]; then
    # Running directly on device
    settings put global KEYCODE_BACK "$JSON_PAYLOAD"
    am broadcast -a onyx.action.refresh_keymapping >/dev/null 2>&1
    SAVED=$(settings get global KEYCODE_BACK)
else
    # Running via ADB
    $RUN_CMD "settings put global KEYCODE_BACK '$JSON_PAYLOAD'"
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
echo "Short press remains standard BACK."
echo "Long press is now mapped to: $DESC."
echo "This setting is persistent and survives device reboots."
echo "======================================================================"
