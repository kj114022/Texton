#!/bin/bash

# Script to monitor Alexandria app logs during testing

export ANDROID_HOME=/Users/tourist/Library/Android/sdk

echo "===== Alexandria App Test Monitor ====="
echo "Clearing logcat..."
$ANDROID_HOME/platform-tools/adb logcat -c

echo ""
echo "Monitoring logs. Perform a search in the app now..."
echo "Press Ctrl+C to stop"
echo ""

$ANDROID_HOME/platform-tools/adb logcat | grep --line-buffered -E "BookSearchViewModel|LibgenSource|AnnasArchive|OceanOfPdf|BookSearchRepository"
