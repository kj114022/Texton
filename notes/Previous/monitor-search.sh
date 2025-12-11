#!/bin/bash

# Quick Test Script for Alexandria Search

export ANDROID_HOME=/Users/tourist/Library/Android/sdk

echo "================================"
echo " Alexandria Search Test Monitor"
echo "================================"
echo ""
echo "1. Clearing old logs..."
$ANDROID_HOME/platform-tools/adb logcat -c

echo "2. App is running. Ready to monitor search."
echo ""
echo "NOW: Open the app and search for 'Harry Potter'"
echo ""
echo "Monitoring logs (Press Ctrl+C to stop)..."
echo "================================"
echo ""

$ANDROID_HOME/platform-tools/adb logcat | grep --line-buffered -E "BookSearchFragment|BookSearchViewModel|LibgenSource|AnnasArchive|OceanOfPdf" --color=always
