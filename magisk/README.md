# Onyx Boox C69HD Hardware Screen Wake & DT2W Magisk Module

A lightweight, zero-battery-drain Magisk module for the **Onyx Boox C69HD** (board `C69_M_STAR`, Qualcomm SM6225 / Bengal) running Android 11.

---

## 🚀 Features

- **Physical Button Wake**:
  - Center hardware button (scancode 158 / Back) wakes device from Doze and deep sleep instantly (< 30ms).
  - Side hardware page-turn buttons (scancodes 104 / 109) also wake the device from sleep.
  - While awake, buttons pass through normally to Onyx ROM, preserving all single-tap and long-press actions configured by the Button Remapper tool.
- **Double Tap to Wake (DT2W)**:
  - Tapping the screen twice in quick succession while asleep wakes the device.
  - Arms the FocalTech `fts_ts` touchscreen hardware gesture mode upon boot.
- **Zero Idle Battery Drain**:
  - Fully event-driven daemon running via Linux kernel `epoll` on hardware input nodes and `dmesg -w`. Zero polling, 0% CPU at idle.

---

## 📦 Installation

### Method 1: Magisk App (Recommended)
1. Transfer `c69hd-wake.zip` to your Onyx Boox C69HD.
2. Open the **Magisk** app.
3. Tap **Modules** -> **Install from storage**.
4. Select `c69hd-wake.zip`.
5. Reboot the device.

### Method 2: ADB Root Shell
```sh
adb push c69hd-wake.zip /data/local/tmp/
adb shell su -c "/data/adb/magisk/magisk --install-module /data/local/tmp/c69hd-wake.zip"
adb reboot
```

---

## 🔍 How It Works

1. On stock Onyx Boox C69HD ROMs, `config_wakeOnBackKeyPress` is hardcoded to `false` in `framework-res.apk`. Keylayout `.kl` overlays alone fail to wake Android from deep sleep because Android's `PhoneWindowManager` drops non-power wake events.
2. The `c69hd-wake` daemon runs at boot via Magisk `service.sh`. When the device is asleep and an input event is registered on the center or side physical buttons, or when a double-tap is recognized on the touchscreen, it injects Qualcomm PMIC `KEY_POWER` (116) on `/dev/input/event0` (`qpnp_pon`), waking the system server and E-Ink display immediately.
3. When the screen is awake, the daemon does nothing, ensuring single-press and long-press custom button mappings remain 100% operational.
