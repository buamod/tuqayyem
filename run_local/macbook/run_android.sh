#!/bin/bash

# Tuqayyem Android Runner Script
# Automatically starts Android emulator and runs the Flutter app

set -e  # Exit on any error

echo "🤖 Starting Tuqayyem Android Development Environment..."
echo "====================================================="

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

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in a Flutter project directory!"
    print_error "Please run this script from the root of your Flutter project."
    exit 1
fi

print_status "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_success "Flutter found: $(flutter --version | head -n 1)"

# Check for Flutter startup lock
print_status "Checking for Flutter locks..."
if [ -f "/tmp/flutter_tools_lock" ] || pgrep -f "flutter" > /dev/null; then
    print_warning "Flutter may be busy with another process..."
    print_status "Waiting for Flutter to be available..."
    
    # Wait up to 30 seconds for Flutter to be free
    LOCK_TIMEOUT=30
    LOCK_COUNTER=0
    while [ $LOCK_COUNTER -lt $LOCK_TIMEOUT ]; do
        if ! pgrep -f "flutter" > /dev/null 2>&1; then
            break
        fi
        echo -n "."
        sleep 2
        LOCK_COUNTER=$((LOCK_COUNTER + 2))
    done
    echo ""
    
    if [ $LOCK_COUNTER -ge $LOCK_TIMEOUT ]; then
        print_error "Flutter appears to be stuck. Try running: ./kill_android.sh first"
        exit 1
    fi
fi

# Auto-detect and set Android SDK path
if [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
fi

# Check Android SDK
print_status "Checking Android SDK..."
if ! command -v adb &> /dev/null; then
    print_error "Android SDK not found! Install Android Studio first."
    exit 1
fi

# Check if Android SDK is properly configured
ADB_VERSION=$(adb version 2>/dev/null | head -n 1 || echo "")
if [ -n "$ADB_VERSION" ]; then
    print_success "Android SDK found: $ADB_VERSION"
else
    print_warning "Android SDK may not be properly configured"
fi

# Clean any previous builds
print_status "Cleaning previous builds..."
flutter clean > /dev/null 2>&1

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get > /dev/null 2>&1

# Check current devices
print_status "Checking for running Android emulators..."
CURRENT_DEVICES=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "android") | .id' 2>/dev/null || echo "")

if [ -n "$CURRENT_DEVICES" ]; then
    print_success "Android emulator already running!"
    DEVICE_ID=$(echo "$CURRENT_DEVICES" | head -n 1)
    print_status "Using device: $DEVICE_ID"
else
    print_status "No Android emulator running. Starting one..."
    
    # Check available Android emulators
    print_status "Checking available Android emulators..."
    
    # First try flutter emulators
    AVAILABLE_EMULATORS=$(flutter emulators 2>/dev/null | grep "android" | head -n 1 | awk '{print $1}' || echo "")
    
    if [ -z "$AVAILABLE_EMULATORS" ]; then
        print_warning "No Android emulators found via Flutter"
        
        # Try to find Android SDK and emulator directly
        ANDROID_HOME_PATHS=(
            "$ANDROID_HOME"
            "$HOME/Library/Android/sdk"
            "$HOME/Android/Sdk"
            "/Applications/Android Studio.app/Contents/sdk"
        )
        
        for path in "${ANDROID_HOME_PATHS[@]}"; do
            if [ -d "$path/emulator" ]; then
                print_status "Found Android SDK at: $path"
                export ANDROID_HOME="$path"
                export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
                break
            fi
        done
        
        # Try again with updated PATH
        AVAILABLE_EMULATORS=$(flutter emulators 2>/dev/null | grep "android" | head -n 1 | awk '{print $1}' || echo "")
        
        if [ -z "$AVAILABLE_EMULATORS" ]; then
            print_error "No Android emulators available!"
            print_error "Please install Android Studio and create an AVD."
            print_status "Steps to fix:"
            print_status "1. Open Android Studio"
            print_status "2. Go to Tools > AVD Manager"
            print_status "3. Create a new Virtual Device"
            print_status "4. Or run: flutter emulators --create"
            exit 1
        fi
    fi
    
    # Get the first available Android emulator
    EMULATOR_ID=$(flutter emulators | grep "android" | head -n 1 | awk '{print $1}')
    
    if [ -z "$EMULATOR_ID" ]; then
        print_error "Could not find a suitable Android emulator!"
        exit 1
    fi
    
    print_status "Starting Android Emulator: $EMULATOR_ID..."
    flutter emulators --launch "$EMULATOR_ID" &
    
    print_status "Waiting for emulator to be ready..."
    
    # Smart waiting - check multiple conditions quickly
    TIMEOUT=60  # Reduced from 150 to 60 seconds
    COUNTER=0
    
    while [ $COUNTER -lt $TIMEOUT ]; do
        # Quick check if Flutter can see the device
        if flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "android") | .id' 2>/dev/null | grep -q "emulator"; then
            print_success "Flutter detected Android emulator!"
            break
        fi
        
        # Check if ADB can see emulator and it's ready
        if command -v adb &> /dev/null; then
            ADB_READY=$(adb devices 2>/dev/null | grep "emulator.*device" | wc -l)
            if [ "$ADB_READY" -gt 0 ]; then
                print_status "ADB sees emulator as ready, waiting for Flutter..."
                # Give Flutter a few more seconds to detect it
                sleep 5
                if flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "android") | .id' 2>/dev/null | grep -q "emulator"; then
                    print_success "Flutter now sees the emulator!"
                    break
                fi
            fi
        fi
        
        # Show progress every 10 seconds instead of every 24
        if [ $((COUNTER % 10)) -eq 0 ] && [ $COUNTER -gt 0 ]; then
            ADB_STATUS="Checking..."
            if command -v adb &> /dev/null; then
                ADB_COUNT=$(adb devices 2>/dev/null | grep "emulator" | wc -l)
                if [ "$ADB_COUNT" -gt 0 ]; then
                    ADB_STATUS="ADB Connected"
                fi
            fi
            print_status "Still waiting... ($COUNTER/${TIMEOUT}s) - $ADB_STATUS"
        fi
        
        echo -n "."
        sleep 2
        COUNTER=$((COUNTER + 2))
    done
    
    echo ""
    
    if [ $COUNTER -ge $TIMEOUT ]; then
        print_warning "Emulator taking longer than expected..."
        print_status "Checking if emulator is actually ready..."
        
        # Final check - maybe it's ready but Flutter is slow
        if command -v adb &> /dev/null; then
            ADB_READY=$(adb devices 2>/dev/null | grep "emulator.*device")
            if [ -n "$ADB_READY" ]; then
                print_success "Emulator is ready according to ADB, proceeding..."
            else
                print_error "Emulator failed to start properly"
                print_info "Try: ./kill_android.sh && ./run_android.sh"
                exit 1
            fi
        else
            print_error "Cannot verify emulator status"
            exit 1
        fi
    fi
    
    print_success "Android Emulator is ready!"
fi

# Quick final device check
print_status "Getting device ID..."

ANDROID_DEVICE=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "android") | .id' 2>/dev/null | head -n 1)

if [ -z "$ANDROID_DEVICE" ]; then
    # One more quick try
    sleep 2
    ANDROID_DEVICE=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "android") | .id' 2>/dev/null | head -n 1)
    
    if [ -z "$ANDROID_DEVICE" ]; then
        # Check if ADB sees it and use that
        if command -v adb &> /dev/null; then
            ADB_DEVICE=$(adb devices 2>/dev/null | grep "emulator" | head -n 1 | awk '{print $1}')
            if [ -n "$ADB_DEVICE" ]; then
                print_warning "Using ADB device ID: $ADB_DEVICE"
                ANDROID_DEVICE="$ADB_DEVICE"
            else
                print_error "No Android devices found!"
                exit 1
            fi
        else
            print_error "Cannot find Android device!"
            exit 1
        fi
    fi
fi

print_success "Android device ready: $ANDROID_DEVICE"

# Build the app first to avoid timeout issues
print_status "Building Android app..."
flutter build apk --debug > /dev/null 2>&1 || {
    print_warning "Build failed, but continuing with flutter run..."
}

# Check if Flutter is already running
FLUTTER_RUNNING=$(pgrep -f "flutter.*run" 2>/dev/null | wc -l)
if [ "$FLUTTER_RUNNING" -gt 0 ]; then
    print_warning "Flutter app appears to be already running!"
    print_status "Existing Flutter processes found:"
    pgrep -f "flutter.*run" 2>/dev/null | while read pid; do
        echo "  PID: $pid"
    done
    echo ""
    print_status "Options:"
    print_status "1. Kill existing processes and start fresh"
    print_status "2. Continue anyway (may cause conflicts)"
    print_status "3. Exit and manage manually"
    echo ""
    read -p "Choose option (1/2/3): " choice
    
    case $choice in
        1)
            print_status "Killing existing Flutter processes..."
            pkill -f "flutter.*run" 2>/dev/null || true
            sleep 2
            ;;
        2)
            print_warning "Continuing with existing processes..."
            ;;
        3)
            print_status "Exiting. Use './kill_android.sh' to clean up if needed."
            exit 0
            ;;
        *)
            print_warning "Invalid choice, continuing anyway..."
            ;;
    esac
fi

# Run the Flutter app
print_status "🚀 Launching Tuqayyem on Android..."
echo "====================================================="
print_status "Device: $ANDROID_DEVICE"
print_status "Hot reload: Press 'r'"
print_status "Hot restart: Press 'R'"
print_status "Quit: Press 'q'"
print_status "Help: Press 'h'"
echo ""

# Add error handling for flutter run
if ! flutter run -d "$ANDROID_DEVICE"; then
    print_error "Failed to run Flutter app!"
    print_status "Troubleshooting steps:"
    print_status "1. Check if the emulator is responsive"
    print_status "2. Try running: flutter doctor"
    print_status "3. Try: ./kill_android.sh && ./run_android.sh"
    exit 1
fi

print_success "Android session ended."