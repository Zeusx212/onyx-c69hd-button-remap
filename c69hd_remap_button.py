#!/usr/bin/env python3
"""
Onyx Boox Faust 5 (C69HD) Hardware Button Remapper
Cross-platform tool to configure the physical center hardware button on Onyx devices.
"""

import subprocess
import sys
import json

ACTIONS = {
    "1": ("Recent Apps (Overview)", "KEYCODE_APP_SWITCH"),
    "2": ("Full Screen E-Ink Refresh", "fullRefreshScreen"),
    "3": ("Take Screenshot", "screenshot"),
    "4": ("Open E-Ink Refresh Mode Dialog", "showRefreshModeDialog"),
    "5": ("Return to Home Screen", "back_to_home"),
    "6": ("Toggle A2 Speed Refresh Mode", "toggleA2"),
    "7": ("Disable Long-Press (No action, no error toast)", ""),
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

def main():
    print("=" * 66)
    print("       Onyx Boox Faust 5 (C69HD) Hardware Button Remapper")
    print("=" * 66)

    # Check device connection
    devices_out = run_adb(["devices"])
    lines = [l for l in devices_out.splitlines() if l.strip() and not l.startswith("*")]
    if len(lines) <= 1:
        print("[ERROR] No connected ADB devices detected.")
        print("Please plug in your Onyx Boox and ensure USB Debugging is enabled.")
        sys.exit(1)

    print("[OK] Device connected!\n")
    print("Choose what you want the physical button LONG-PRESS to do:\n")
    for key, (label, action) in ACTIONS.items():
        suffix = " [Default]" if key == "1" else ""
        print(f"  [{key}] {label}{suffix}")

    choice = input("\nEnter choice [1-8, Default: 1]: ").strip() or "1"
    if choice not in ACTIONS:
        print(f"Invalid choice '{choice}'. Defaulting to Recent Apps (1).")
        choice = "1"

    label, action = ACTIONS[choice]
    print(f"\n[*] Applying: {label} ({action})...")

    payload = {
        "keySet": ["KEYCODE_BACK"],
        "shortPressAction": "",
        "longPressAction": action,
        "repeat": False
    }
    json_str = json.dumps(payload, separators=(',', ':'))

    # Put setting and broadcast reload
    run_adb(["shell", "settings", "put", "global", "KEYCODE_BACK", json_str])
    run_adb(["shell", "am", "broadcast", "-a", "onyx.action.refresh_keymapping"])

    # Verify
    saved = run_adb(["shell", "settings", "get", "global", "KEYCODE_BACK"])

    print("=" * 66)
    print("[SUCCESS] Hardware button remapped successfully!")
    print(f"\nActive Configuration in Settings.Global:")
    print(f"  {saved}\n")
    print("• Tap: Standard Back")
    print(f"• Hold: {label}")
    print("• Persistent: Survives device reboots.")
    print("=" * 66)

if __name__ == "__main__":
    main()
