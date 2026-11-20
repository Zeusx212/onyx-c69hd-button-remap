# Onyx Boox Faust 5 (C69HD) Hardware Button Remapper

A lightweight, permanent utility to configure and remap the physical center front hardware button on Onyx Boox devices (specifically the **Onyx Boox Faust 5 / C69HD / Board C69_M_STAR**).

---

## 🔍 The Problem
On the non-backlit edition of the Onyx Boox Faust 5, the physical center front button acts as `BACK` on short-press, but its long-press action is hardcoded in the ROM's `framework-res.apk` (`res/raw/keypad.json`) to `"toggleFrontLight"`. 

Because this hardware edition has no frontlight LEDs, holding the button triggers an error toast across the screen:
> *"doesn't support frontlight"*

---

## 🛠️ How It Works
Onyx’s system framework contains an internal key mapping manager (`android.onyx.util.KeyboardEntryMap` running inside `system_server`). Before falling back to the hardcoded `keypad.json`, it queries Android’s `Settings.Global` for key overrides matching `KEYCODE_BACK`.

By injecting a JSON override into `Settings.Global KEYCODE_BACK` and sending the framework reload broadcast `onyx.action.refresh_keymapping`, both **Short-Press (Tap)** and **Long-Press (Hold)** can be customized:
- **No Root Required**: Operates completely within user ADB permissions.
- **No Battery Drain**: Handled natively in the OS window manager (`system_server`), requiring no persistent accessibility services or background keylogger apps.
- **Persistent**: Survives device reboots.

---

## ⚡ Quick Start (ADB One-Liner)

With USB Debugging enabled on your device:

### Remap Long-Press to Recent Apps & Short-Press to Back (Default):
```sh
adb shell "settings put global KEYCODE_BACK '{\"keySet\":[\"KEYCODE_BACK\"],\"shortPressAction\":\"\",\"longPressAction\":\"KEYCODE_APP_SWITCH\",\"repeat\":false}'"
adb shell am broadcast -a onyx.action.refresh_keymapping
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
| `c69hd_remap_button.bat` | Windows | Double-click interactive batch wizard (remap Long-Press & Short-Press) |
| `c69hd_remap_button.sh` | Linux / macOS / Termux | Interactive shell script (remap Long-Press & Short-Press) |
| `c69hd_remap_button.py` | Cross-Platform | Interactive Python CLI (remap Long-Press & Short-Press) |

---

## 🎯 Supported Native Actions

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

## 💡 Double-Press Remapping

### Native ROM Limitations:
Onyx's internal framework (`android.onyx.util.KeyboardEntry`) natively supports two press states:
- `shortPressAction` (Single click / tap)
- `longPressAction` (Hold down)

There is **no native double-press handler** in Onyx's ROM or AOSP's Back key pipeline.

### Solution for Double-Press (3-Way Mapping):
To have **three distinct actions** on the single physical button (e.g. Single-Tap = Back, Double-Tap = E-Ink Refresh, Hold = Recent Apps), use the open-source **[Key Mapper](https://github.com/keymapperorg/KeyMapper)** app:

1. Download and install **Key Mapper** (free, open source on F-Droid or GitHub Releases).
2. Enable Key Mapper in **Settings > Accessibility**.
3. Create a new trigger:
   - Record Trigger: Press the physical center button (`Back`).
   - Trigger Type: Set to **Double Press** (or Single / Long press).
   - Action: Select your desired action (e.g., Open App, Screenshot, Split Screen, etc.).
4. When using Key Mapper for double-press, you can leave the native tool configured with Single-Tap as Back and Long-Press as Recent Apps.

---

## ⚡ Screen Wake (Wake on Button Press)

### Technical Analysis & Limitations:
- The center physical button is mapped to `qpnp_pon` (Qualcomm PMIC power-on chip) at `/dev/input/event0` with Linux keycode `158` (`KEY_BACK`).
- In `/system/usr/keylayout/Generic.kl`, line 158 is configured as `key 158 BACK` (lacking the `WAKE` flag, unlike `key 116 POWER WAKE`).
- In Android's window manager policy (`PhoneWindowManager.isWakeKeyWhenScreenOff`), waking on `KEYCODE_BACK` is gated by `config_wakeOnBackKeyPress`, which is hardcoded to `false` in `/system/framework/framework-res.apk`.
- Because the device runs a non-rooted production build with read-only dm-verity partitions (`/system`), `Generic.kl` and `framework-res.apk` cannot be altered.

### Recommended Screen Wake Alternative:
The Onyx Boox Faust 5 has built-in **Double-Tap to Wake**:
- You can wake the device by double-tapping anywhere on the E-Ink touchscreen.
- Ensure it is enabled in your device settings (`Settings.Secure double_tap_to_wake=1`).
- Alternatively, use the top physical **Power Button**, which is the designated hardware wake key.

---

## 📄 License
MIT License. Free to use, modify, and distribute.
