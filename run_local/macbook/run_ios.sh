#!/bin/bash

# Tuqayyem iOS Runner Script
# Automatically starts iOS simulator and runs the Flutter app

set -e  # Exit on any error

echo "🍎 Starting Tuqayyem iOS Development Environment..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Clean any previous builds
print_status "Cleaning previous builds..."
flutter clean > /dev/null 2>&1

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get > /dev/null 2>&1

# Check current devices
print_status "Checking for running iOS simulators..."
CURRENT_DEVICES=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios") | .id' 2>/dev/null || echo "")

if [ -n "$CURRENT_DEVICES" ]; then
    print_success "iOS simulator already running!"
    DEVICE_ID=$(echo "$CURRENT_DEVICES" | head -n 1)
    print_status "Using device: $DEVICE_ID"
else
    print_status "No iOS simulator running. Starting one..."
    
    # Check available iOS simulators
    print_status "Checking available iOS simulators..."
    AVAILABLE_SIMS=$(xcrun simctl list devices available | grep "iPhone" | head -n 1)
    
    if [ -z "$AVAILABLE_SIMS" ]; then
        print_error "No iOS simulators available!"
        print_error "Please install Xcode and iOS simulators."
        exit 1
    fi
    
    # Extract device ID from the first iPhone simulator
    DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 16 Plus" | head -n 1 | grep -o '([A-F0-9-]*)' | tr -d '()')
    
    if [ -z "$DEVICE_ID" ]; then
        # Fallback to any iPhone
        DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone" | head -n 1 | grep -o '([A-F0-9-]*)' | tr -d '()')
    fi
    
    if [ -z "$DEVICE_ID" ]; then
        print_error "Could not find a suitable iOS simulator!"
        exit 1
    fi
    
    print_status "Starting iOS Simulator (Device ID: $DEVICE_ID)..."
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    
    # Open Simulator app
    open -a Simulator
    
    print_status "Waiting for simulator to be ready..."
    
    # Smart waiting for iOS - much faster detection
    TIMEOUT=45  # Reduced from 90 to 45 seconds
    COUNTER=0
    
    while [ $COUNTER -lt $TIMEOUT ]; do
        # Quick check if Flutter can see the device
        if flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios") | .id' 2>/dev/null | grep -q "$DEVICE_ID"; then
            print_success "Flutter detected iOS simulator!"
            break
        fi
        
        # Check if simulator is booted
        SIM_STATUS=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted\|Shutdown" || echo "Starting")
        
        if [ "$SIM_STATUS" = "Booted" ]; then
            print_status "Simulator booted, waiting for Flutter..."
            # Give Flutter a moment to detect it
            sleep 3
            if flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios") | .id' 2>/dev/null | grep -q "$DEVICE_ID"; then
                print_success "Flutter now sees the simulator!"
                break
            fi
        fi
        
        # Show progress every 8 seconds
        if [ $((COUNTER % 8)) -eq 0 ] && [ $COUNTER -gt 0 ]; then
            print_status "Still waiting... ($COUNTER/${TIMEOUT}s) - Status: $SIM_STATUS"
        fi
        
        echo -n "."
        sleep 2
        COUNTER=$((COUNTER + 2))
    done
    
    echo ""
    
    if [ $COUNTER -ge $TIMEOUT ]; then
        # Final check - maybe it's ready but Flutter is slow
        SIM_STATUS=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted" || echo "")
        if [ "$SIM_STATUS" = "Booted" ]; then
            print_success "Simulator is booted, proceeding..."
        else
            print_error "iOS simulator failed to start"
            print_info "Try: ./kill_ios.sh && ./run_ios.sh"
            exit 1
        fi
    fi
    
    print_success "iOS Simulator is ready!"
fi

# Final device check
print_status "Verifying iOS device availability..."
sleep 2

IOS_DEVICE=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios") | .id' 2>/dev/null | head -n 1)

if [ -z "$IOS_DEVICE" ]; then
    print_error "iOS simulator not detected by Flutter!"
    print_warning "Trying alternative approach..."
    
    # Try launching emulator via Flutter
    flutter emulators --launch apple_ios_simulator
    sleep 10
    
    IOS_DEVICE=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios") | .id' 2>/dev/null | head -n 1)
    
    if [ -z "$IOS_DEVICE" ]; then
        print_error "Failed to start iOS simulator!"
        print_error "Please check your Xcode installation and try again."
        exit 1
    fi
fi

print_success "iOS device ready: $IOS_DEVICE"

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
            print_status "Exiting. Use './kill_ios.sh' to clean up if needed."
            exit 0
            ;;
        *)
            print_warning "Invalid choice, continuing anyway..."
            ;;
    esac
fi

# Run the Flutter app
print_status "🚀 Launching Tuqayyem on iOS..."
echo "=================================================="
print_status "Device: $IOS_DEVICE"
print_status "Hot reload: Press 'r'"
print_status "Hot restart: Press 'R'" 
print_status "Quit: Press 'q'"
print_status "Help: Press 'h'"
echo ""

# Add error handling for flutter run
if ! flutter run -d "$IOS_DEVICE"; then
    print_error "Failed to run Flutter app!"
    print_status "Troubleshooting steps:"
    print_status "1. Check if the simulator is responsive"
    print_status "2. Try running: flutter doctor"
    print_status "3. Try: ./kill_ios.sh && ./run_ios.sh"
    exit 1
fi

print_success "iOS session ended."