# Onyx Boox Faust 5 (C69HD) Hardware Button Remapper

A lightweight, permanent utility to fix and remap the physical center front hardware button on non-backlit Onyx Boox devices (specifically the **Onyx Boox Faust 5 / C69HD / Board C69_M_STAR**).

---

## 🔍 The Problem
On the non-backlit edition of the Onyx Boox Faust 5, the physical center front button acts as `BACK` on short-press, but its long-press action is hardcoded in the ROM's `framework-res.apk` (`res/raw/keypad.json`) to `"toggleFrontLight"`. 

Because this hardware edition has no frontlight LEDs, holding the button triggers an error toast across the screen:
> *"doesn't support frontlight"*

---

## 🛠️ How It Works
Onyx’s system framework contains an internal key mapping manager (`android.onyx.util.KeyboardEntryMap` running inside `system_server`). Before falling back to the hardcoded `keypad.json`, it queries Android’s `Settings.Global` for key overrides matching `KEYCODE_BACK`.

By injecting a JSON override into `Settings.Global KEYCODE_BACK` and sending the framework reload broadcast `onyx.action.refresh_keymapping`, the button can be cleanly repurposed:
- **No Root Required**: Operates completely within user ADB permissions.
- **No Battery Drain**: Handled natively in the OS window manager (`system_server`), requiring no persistent accessibility services or background keylogger apps.
- **Persistent**: Survives device reboots.

---

## ⚡ Quick Start (ADB One-Liner)

With USB Debugging enabled on your device:

### Windows Command Prompt (cmd.exe):
```cmd
adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"KEYCODE_APP_SWITCH\",\"repeat\":false}'"
adb shell am broadcast -a onyx.action.refresh_keymapping
```

### macOS / Linux / Bash:
```bash
adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"KEYCODE_APP_SWITCH\",\"repeat\":false}' && am broadcast -a onyx.action.refresh_keymapping"
```

### Directly on Device (Termux / Local Shell):
```sh
settings put global KEYCODE_BACK '{"keySet":["KEYCODE_BACK"],"shortPressAction":"","longPressAction":"KEYCODE_APP_SWITCH","repeat":false}'
am broadcast -a onyx.action.refresh_keymapping
```

---

## 📂 Included Scripts

| Script | Platform | Description |
|---|---|---|
| `c69hd_remap_button.bat` | Windows | Double-click interactive batch wizard |
| `c69hd_remap_button.sh` | Linux / macOS / Termux | Interactive shell script |
| `c69hd_remap_button.py` | Cross-Platform | Interactive Python CLI |

---

## 🎯 Supported Long-Press Actions

| Action | ID | Behavior |
|---|---|---|
| **Recent Apps** | `KEYCODE_APP_SWITCH` | Opens the multitasking / Recent Apps overview (Default) |
| **Full Screen Refresh** | `fullRefreshScreen` | Triggers a full E-ink hardware screen clear (clears ghosting) |
| **Screenshot** | `screenshot` | Takes a screenshot |
| **E-Ink Refresh Center** | `showRefreshModeDialog` | Opens the E-Ink Center refresh mode selector |
| **Home** | `back_to_home` | Returns directly to home screen |
| **Toggle A2** | `toggleA2` | Toggles fast A2 refresh mode on/off |
| **Disabled** | `""` | Disables long-press entirely (no action, no toast) |
| **Factory Default** | `toggleFrontLight` | Restores the stock frontlight toggle |

---

## 📄 License
MIT License. Free to use, modify, and distribute.
