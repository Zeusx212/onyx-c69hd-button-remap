#!/usr/bin/env python3
"""
Onyx Boox Faust 5 (C69HD) Hardware Button Remapper
Cross-platform tool to configure the physical center hardware button on Onyx devices.
"""

import subprocess
import sys
import json

ACTIONS = {
    "1": ("Recent Apps (Overview / App Switcher)", "KEYCODE_APP_SWITCH"),
    "2": ("Full Screen E-Ink Refresh (Clears ghosting)", "fullRefreshScreen"),
    "3": ("Take Screenshot", "screenshot"),
    "4": ("Open E-Ink Refresh Mode Dialog", "showRefreshModeDialog"),
    "5": ("Return to Home Screen", "back_to_home"),
    "6": ("Toggle A2 Speed Refresh Mode", "toggleA2"),
    "7": ("Standard Back Key Event", ""),
    "8": ("Revert to Factory Default (Frontlight toggle)", "toggleFrontLight"),
}

def run_adb(args):
    try:
        res = subprocess.run(["adb"] + args, capture_output=True, text=True, check=True)
        return res.stdout.strip()
    except FileNotFoundError:
        print("[ERROR] 'adb' was not found in your system PATH.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] ADB command failed: {e.stderr.strip()}")
        sys.exit(1)

def display_menu(title, default_key):
    print(f"\n--- {title} ---")
    for key, (label, action) in ACTIONS.items():
        suffix = " [Recommended]" if key == default_key else ""
        print(f"  [{key}] {label}{suffix}")
    choice = input(f"\nEnter choice [1-8, Default: {default_key}]: ").strip() or default_key
    if choice not in ACTIONS:
        print(f"Invalid choice '{choice}'. Defaulting to [{default_key}].")
        choice = default_key
    return ACTIONS[choice]

def main():
    print("=" * 70)
    print("       Onyx Boox Faust 5 (C69HD) Hardware Button Remapper")
    print("=" * 70)

    # Check device connection
    devices_out = run_adb(["devices"])
    lines = [l for l in devices_out.splitlines() if l.strip() and not l.startswith("*")]
    if len(lines) <= 1:
        print("[ERROR] No connected ADB devices detected.")
        print("Please plug in your Onyx Boox and ensure USB Debugging is enabled.")
        sys.exit(1)

    print("[OK] Device connected!\n")
    print("Configure physical button actions (Tap & Hold):")

    # 1. Long Press action (Hold)
    lp_label, lp_action = display_menu("1. Choose LONG-PRESS (Hold) Action", "1")

    # 2. Short Press action (Tap)
    sp_label, sp_action = display_menu("2. Choose SHORT-PRESS (Single Tap) Action", "7")

    print("\n[*] Applying configuration...")

    payload = {
        "keySet": ["KEYCODE_BACK"],
        "shortPressAction": sp_action,
        "longPressAction": lp_action,
        "repeat": False
    }
    json_str = json.dumps(payload, separators=(',', ':'))

    # Set Global settings
    run_adb(["shell", f"settings put global KEYCODE_BACK '{json_str}'"])
    
    # If short press is customized (not standard back), enable short press flag
    if sp_action:
        run_adb(["shell", "settings put global key_custom_side_key_short_press_enable 1"])
    else:
        run_adb(["shell", "settings put global key_custom_side_key_short_press_enable 0"])

    # Broadcast reload to Onyx framework
    run_adb(["shell", "am", "broadcast", "-a", "onyx.action.refresh_keymapping"])

    # Verify
    saved = run_adb(["shell", "settings", "get", "global", "KEYCODE_BACK"])

    print("=" * 70)
    print("[SUCCESS] Hardware button remapped successfully!")
    print(f"\nActive Configuration in Settings.Global:")
    print(f"  {saved}\n")
    print(f"• Single Tap : {sp_label}")
    print(f"• Long Press : {lp_label}")
    print("• Persistent : Survives device reboots.")
    print("=" * 70)
    print("\n[NOTE regarding Double-Press & Screen-Wake]:")
    print("• Double-Press: Onyx ROM natively supports Short & Long press.")
    print("  To enable true 3-way multi-press (single, double, hold), install the")
    print("  open-source 'Key Mapper' app (see README.md for details).")
    print("• Screen Wake: Android kernel/framework blocks waking from sleep via")
    print("  KEY_BACK on non-root builds. Wake via the top Power button or a")
    print("  magnetic smart cover (Hall sensor).")
    print("=" * 70)

if __name__ == "__main__":
    main()
