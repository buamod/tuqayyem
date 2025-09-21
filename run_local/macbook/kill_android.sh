#!/bin/bash

# Tuqayyem Android Killer Script
# Stops all Android emulators and Flutter processes

set -e

echo "🛑 Stopping Android Development Environment..."
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Kill Flutter processes
print_status "Stopping Flutter processes..."
pkill -f "flutter" 2>/dev/null || true
pkill -f "dart" 2>/dev/null || true

# Kill Android emulator processes
print_status "Stopping Android emulators..."
pkill -f "emulator" 2>/dev/null || true
pkill -f "qemu" 2>/dev/null || true

# Kill ADB server
print_status "Stopping ADB server..."
if command -v adb &> /dev/null; then
    adb kill-server 2>/dev/null || true
fi

# Kill Android Studio processes (if any)
print_status "Stopping Android Studio processes..."
pkill -f "studio" 2>/dev/null || true
pkill -f "Android Studio" 2>/dev/null || true

# Kill Gradle daemon processes
print_status "Stopping Gradle daemons..."
pkill -f "gradle" 2>/dev/null || true

# Clean up any remaining Android processes
print_status "Cleaning up remaining Android processes..."
pkill -f "android" 2>/dev/null || true

# Wait a moment for processes to terminate
sleep 3

# Restart ADB server to clean state
if command -v adb &> /dev/null; then
    print_status "Restarting ADB server..."
    adb start-server 2>/dev/null || true
fi

# Verify emulators are stopped
if command -v adb &> /dev/null; then
    RUNNING_EMULATORS=$(adb devices | grep "emulator" | wc -l)
    if [ "$RUNNING_EMULATORS" -eq 0 ]; then
        print_success "All Android emulators stopped successfully!"
    else
        print_warning "Some emulators may still be running:"
        adb devices | grep "emulator"
    fi
else
    print_warning "ADB not found, cannot verify emulator status"
fi

# Check if Flutter processes are still running
FLUTTER_PROCS=$(pgrep -f "flutter" 2>/dev/null | wc -l)
if [ "$FLUTTER_PROCS" -eq 0 ]; then
    print_success "All Flutter processes stopped!"
else
    print_warning "$FLUTTER_PROCS Flutter processes may still be running"
fi

# Clean build artifacts
print_status "Cleaning build artifacts..."
if [ -f "pubspec.yaml" ]; then
    flutter clean > /dev/null 2>&1 || true
fi

print_success "Android development environment cleanup complete!"
echo ""
print_status "You can now run './run_android.sh' to start fresh."