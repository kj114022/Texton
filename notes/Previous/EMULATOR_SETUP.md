# Android Emulator Setup and Running Guide

This guide walks you through setting up and running the Pantheon app on an Android emulator.

## Prerequisites

You need to have the Android SDK installed on your system. The SDK should be located at:
- macOS/Linux: `~/Library/Android/sdk` or `/Users/$USER/Library/Android/sdk`
- Windows: `%LOCALAPPDATA%\Android\Sdk`

Set the `ANDROID_HOME` environment variable:
```bash
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
```

## Step 1: List Available Virtual Devices (AVDs)

Before starting an emulator, check which Android Virtual Devices are available:

```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/emulator/emulator -list-avds
```

This will show a list of available emulators. Example output:
```
Medium_Phone_API_36.1
```

## Step 2: Start the Android Emulator

Start an emulator using one of the AVDs from the previous step:

```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.1 &
```

The `&` at the end runs the emulator in the background so you can continue using the terminal.

**Note:** The emulator may take 30-60 seconds to fully boot up.

## Step 3: Wait for Emulator to Boot

Wait for the emulator to be fully ready before installing the app:

```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb wait-for-device
echo "Emulator is ready!"
```

You can also check connected devices at any time:

```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb devices
```

Example output when emulator is running:
```
List of devices attached
emulator-5554   device
```

## Step 4: Build and Install the App

Once the emulator is running and ready, build and install the app:

```bash
./gradlew installDebug
```

This command will:
1. Build the debug version of the app
2. Install it on the connected emulator/device

## Step 5: Launch the App

After installation, launch the app:

```bash
export ANDROID_HOME=/Users/tourist/Library/Android/sdk
$ANDROID_HOME/platform-tools/adb shell am start -n io.github.aloussase.booksdownloader/.MainActivity
```

## Quick Start (All-in-One)

Here's a script to do everything at once:

```bash
#!/bin/bash

# Set Android SDK path
export ANDROID_HOME=/Users/tourist/Library/Android/sdk

# Start emulator in background (replace with your AVD name)
$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.1 &

# Wait for device to be ready
echo "Waiting for emulator to boot..."
$ANDROID_HOME/platform-tools/adb wait-for-device

# Give it a few more seconds to fully initialize
sleep 10

# Build and install the app
echo "Building and installing app..."
./gradlew installDebug

# Launch the app
echo "Launching Pantheon..."
$ANDROID_HOME/platform-tools/adb shell am start -n io.github.aloussase.booksdownloader/.MainActivity

echo "Done! App should now be running."
```

## Useful ADB Commands

Here are some helpful commands for debugging and managing the app:

### View Logs
```bash
$ANDROID_HOME/platform-tools/adb logcat | grep Pantheon
```

### Uninstall the App
```bash
$ANDROID_HOME/platform-tools/adb uninstall io.github.aloussase.booksdownloader
```

### Clear App Data
```bash
$ANDROID_HOME/platform-tools/adb shell pm clear io.github.aloussase.booksdownloader
```

### Stop the Emulator
```bash
$ANDROID_HOME/platform-tools/adb -s emulator-5554 emu kill
```

## Troubleshooting

### Emulator not starting
- Make sure you have enough RAM (emulator needs at least 2GB)
- Check if hardware acceleration is enabled (Intel HAXM on macOS/Windows, or KVM on Linux)
- Try starting with more verbose logging: `emulator -avd <AVD_NAME> -verbose`

### App not installing
- Check if there's enough space on the emulator: `adb shell df`
- Try uninstalling and reinstalling: `adb uninstall io.github.aloussase.booksdownloader && ./gradlew installDebug`

### Build errors
- Clean the project first: `./gradlew clean`
- Check your Gradle version: `./gradlew --version`
- Sync Gradle files in Android Studio if available

## Creating a New AVD (Optional)

If you need to create a new Android Virtual Device:

1. Open Android Studio
2. Go to Tools → AVD Manager
3. Click "Create Virtual Device"
4. Select a device definition (e.g., Pixel 5)
5. Select a system image (e.g., API 36)
6. Configure AVD settings and click "Finish"

Or use the command line:
```bash
$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd -n MyEmulator -k "system-images;android-36;google_apis;x86_64"
```
