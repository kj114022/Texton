# Alexandria App – Quick Start Guide

This document lists the final commands you need to run to get the **Alexandria** Android application up and running on an emulator.

---
## Prerequisites
- **Android SDK** installed (set `ANDROID_HOME` to the SDK path).
- **Java 11+** and **Gradle** (the project already includes the Gradle wrapper).
- An AVD (Android Virtual Device) created – e.g., `Medium_Phone_API_36.1`.

---
## 1. Set Android SDK environment variable
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
```
*(Adjust the path if your SDK lives elsewhere.)*

---
## 2. Start the emulator (if not already running)
```bash
$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.1 &
```
> The `&` runs the emulator in the background.

---
## 3. Wait for the emulator to finish booting
```bash
$ANDROID_HOME/platform-tools/adb wait-for-device
```
You should see `adb: device is offline` followed by `adb: device is online` when ready.

---
## 4. Build and install the debug APK on the running emulator
```bash
./gradlew installDebug
```
The task will compile the app and push `app-debug.apk` to the emulator.

---
## 5. Launch the application
Replace the activity name if it differs in your project.
```bash
$ANDROID_HOME/platform-tools/adb shell am start -n io.github.aloussase.booksdownloader/.MainActivity
```
You should now see the Alexandria app UI on the emulator.

---
## 6. (Optional) View log output
```bash
$ANDROID_HOME/platform-tools/adb logcat
```
Press **Ctrl+C** to stop.

---
### All‑in‑One Command (for quick testing)
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk && \
$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.1 & \
$ANDROID_HOME/platform-tools/adb wait-for-device && \
./gradlew installDebug && \
$ANDROID_HOME/platform-tools/adb shell am start -n io.github.aloussase.booksdownloader/.MainActivity
```
Run the block above in a single terminal session to spin up the emulator, install, and launch the app automatically.

---
**Enjoy!** 🎉
