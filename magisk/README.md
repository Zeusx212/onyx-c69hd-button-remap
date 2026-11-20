# Onyx Boox C69HD Physical Button Screen Wake Magisk Module

A lightweight, zero-battery-drain Magisk module for the **Onyx Boox C69HD** (board `C69_M_STAR`, Qualcomm SM6225 / Bengal) running Android 11.

---

## 🚀 Features

- **Physical Button Wake**:
  - **Center Button**: Pressing the center hardware button (scancode 158 / Back) wakes the device from Doze and deep sleep instantly (< 30ms).
  - **Side Page-Turn Buttons**: Pressing either hardware page-turn button (scancodes 104 / 109) also wakes the device from sleep.
  - **Zero Side Effects**: While awake, buttons pass through normally to Onyx ROM, preserving all single-tap and long-press actions configured by the Button Remapper tool.
- **Zero Battery Drain**:
  - Fully event-driven daemon running via Linux kernel `epoll` on hardware input nodes (`/dev/input/event0` and `/dev/input/event3`). Zero polling, 0% CPU consumption during idle/sleep.

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
2. The `c69hd-wake` daemon runs at boot via Magisk `service.sh`. When the device is asleep and an input event is registered on the center or side physical buttons, it injects Qualcomm PMIC `KEY_POWER` (116) on `/dev/input/event0` (`qpnp_pon`), waking the system server and E-Ink display immediately.
3. When the screen is awake, the daemon does nothing, ensuring single-press and long-press custom button mappings remain 100% operational.
