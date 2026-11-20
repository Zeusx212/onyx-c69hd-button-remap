# Onyx Boox C69HD Hardware Button Remapper & Screen Wake

A complete utility suite to configure, remap, and enable hardware screen wake on the **Onyx Boox C69HD** (Board `C69_M_STAR`, Qualcomm SM6225 / Bengal, Android 11).

---

## 🔍 The Problem on C69HD
On the Onyx Boox C69HD, the physical center front button acts as `BACK` on short-press, but its long-press action is hardcoded in the ROM's `framework-res.apk` (`res/raw/keypad.json`) to `"toggleFrontLight"`. 

Because this hardware edition has no frontlight LEDs, holding the button triggers an error toast:
> *"doesn't support frontlight"*

Additionally, the physical buttons and double-tap touch gestures do not wake the screen from sleep on stock firmware.

---

## 🛠️ Part 1: Hardware Button Remapping (No Root Required)

Onyx’s system framework contains an internal key mapping manager (`android.onyx.util.KeyboardEntryMap` running inside `system_server`). Before falling back to the hardcoded `keypad.json`, it queries Android’s `Settings.Global` for key overrides matching `KEYCODE_BACK`.

By injecting a JSON override into `Settings.Global KEYCODE_BACK` and sending the framework reload broadcast `onyx.action.refresh_keymapping`, both **Short-Press (Tap)** and **Long-Press (Hold)** can be customized:
- **No Root Required**: Operates completely within user ADB permissions.
- **No Battery Drain**: Handled natively in the OS window manager (`system_server`), requiring no persistent accessibility services or background keylogger apps.
- **Persistent**: Survives device reboots.

### Quick Start (ADB One-Liner):
```sh
adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"KEYCODE_APP_SWITCH\",\"repeat\":false}'"
adb shell am broadcast -a onyx.action.refresh_keymapping
```

### Supported Native Actions:
| Action | ID | Behavior |
|---|---|---|
| **Recent Apps** | `KEYCODE_APP_SWITCH` | Opens the multitasking / Recent Apps overview (Default for Hold) |
| **Full Screen Refresh** | `fullRefreshScreen` | Triggers a full E-Ink hardware screen clear (clears ghosting) |
| **Screenshot** | `screenshot` | Captures a screenshot |
| **E-Ink Refresh Center** | `showRefreshModeDialog` | Opens the E-Ink Center refresh mode selector |
| **Home Screen** | `back_to_home` | Returns directly to the home screen |
| **Toggle A2 Mode** | `toggleA2` | Toggles fast A2 refresh mode on/off |
| **Standard Back** | `""` | Sends standard Android Back event (Default for Tap) |
| **Factory Default** | `toggleFrontLight` | Restores stock frontlight toggle |

---

## ⚡ Part 2: Hardware Screen Wake & Double Tap to Wake (Root / Magisk)

Stock Onyx ROMs have `config_wakeOnBackKeyPress` hardcoded to `false` in `framework-res.apk`, meaning physical buttons cannot wake the device from sleep.

The included **`c69hd-wake`** Magisk module solves this:
- **Center Button Wake**: Pressing the center button while asleep wakes the device instantly (< 30ms).
- **Side Page-Turn Button Wake**: Pressing either page-turn button while asleep also wakes the device.
- **Double Tap to Wake (DT2W)**: Double-tapping the touchscreen while asleep wakes the screen.
- **Full Compatibility**: When the device is awake, button events pass through normally to Onyx ROM, preserving all single-press and long-press custom mappings.

### Installing the Magisk Module:
Flash [`magisk/c69hd-wake.zip`](magisk/c69hd-wake.zip) in the Magisk app or via root ADB:
```sh
adb push magisk/c69hd-wake.zip /data/local/tmp/
adb shell su -c "/data/adb/magisk/magisk --install-module /data/local/tmp/c69hd-wake.zip"
adb reboot
```
See [`magisk/README.md`](magisk/README.md) for full technical documentation.

---

## 💡 Double-Press Remapping (3-Way Mapping)

Onyx's internal framework natively handles two states: `shortPressAction` (tap) and `longPressAction` (hold).

To assign a **third distinct action** to double-press (e.g. Single-Tap = Back, Double-Tap = E-Ink Refresh, Hold = Recent Apps), use the open-source **[Key Mapper](https://github.com/keymapperorg/KeyMapper)** app:
1. Install **Key Mapper** (free from F-Droid or GitHub Releases).
2. Enable Key Mapper in **Settings > Accessibility**.
3. Create a trigger on `Back` set to **Double Press** and choose your desired action.

---

## 📂 Included Scripts

| Script | Platform | Description |
|---|---|---|
| `c69hd_remap_button.bat` | Windows | Interactive batch wizard (remap Long-Press & Short-Press) |
| `c69hd_remap_button.sh` | Linux / macOS / Termux | Interactive shell script (remap Long-Press & Short-Press) |
| `c69hd_remap_button.py` | Cross-Platform | Interactive Python CLI (remap Long-Press & Short-Press) |
| `magisk/c69hd-wake.zip` | Android (Magisk) | Flashable Magisk module for Button Wake & DT2W |

---

## 📄 License
MIT License. Free to use, modify, and distribute.
