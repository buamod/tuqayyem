#!/bin/bash

# Tuqayyem Development Status Checker
# Shows current status of emulators and Flutter processes

echo "📊 Tuqayyem Development Environment Status"
echo "=========================================="
echo "🕐 $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}ℹ️  ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️ ${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${PURPLE}📋${NC} $1"
}

# Auto-detect Android SDK
if [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
fi

# Check Flutter installation
echo "🚀 FLUTTER STATUS"
echo "=================="
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "$FLUTTER_VERSION"
    FLUTTER_PATH=$(which flutter)
    print_info "Location: $FLUTTER_PATH"
else
    print_error "Flutter not found in PATH"
    print_info "Install from: https://flutter.dev"
fi

# Check Flutter processes
echo ""
echo "⚡ ACTIVE PROCESSES"
echo "=================="
FLUTTER_PROCS=$(pgrep -f "flutter" 2>/dev/null || echo "")
if [ -n "$FLUTTER_PROCS" ]; then
    PROC_COUNT=$(echo "$FLUTTER_PROCS" | wc -l | tr -d ' ')
    print_warning "$PROC_COUNT Flutter process(es) running"
    echo "$FLUTTER_PROCS" | while read pid; do
        PROC_CMD=$(ps -p "$pid" -o command 2>/dev/null | tail -n 1 | cut -c1-60)
        print_info "  PID $pid: $PROC_CMD..."
    done
    print_info "Use kill scripts to stop: ./run_local/macbook/kill_*.sh"
else
    print_success "No Flutter processes running - ready to start fresh"
fi

# Check iOS Simulators
echo ""
echo "🍎 iOS SIMULATORS"
echo "================="
if command -v xcrun &> /dev/null; then
    print_success "Xcode command line tools installed"
    
    # Count available simulators
    TOTAL_SIMS=$(xcrun simctl list devices available | grep "iPhone" | wc -l | tr -d ' ')
    print_info "$TOTAL_SIMS iPhone simulators available"
    
    # Check running simulators
    BOOTED_SIMS=$(xcrun simctl list devices | grep "Booted" || echo "")
    if [ -n "$BOOTED_SIMS" ]; then
        BOOTED_COUNT=$(echo "$BOOTED_SIMS" | wc -l | tr -d ' ')
        print_success "$BOOTED_COUNT simulator(s) currently running:"
        echo "$BOOTED_SIMS" | while read line; do
            SIM_NAME=$(echo "$line" | sed 's/.*(\([^)]*\)).*/\1/' | cut -c1-40)
            print_info "  $SIM_NAME"
        done
    else
        print_warning "No iOS simulators currently running"
        print_info "Will auto-start when running: ./run_local/macbook/run_ios.sh"
    fi
    
    # Check Flutter iOS devices
    IOS_DEVICES=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios") | .name' 2>/dev/null || echo "")
    if [ -n "$IOS_DEVICES" ]; then
        print_success "Flutter can see iOS devices - ready to run!"
    else
        print_warning "Flutter doesn't see iOS devices yet (normal when no simulator running)"
    fi
else
    print_error "Xcode command line tools not installed"
    print_info "Install with: xcode-select --install"
fi

# Check Android SDK and Emulators
echo ""
echo "🤖 ANDROID SETUP"
echo "================"
if command -v adb &> /dev/null; then
    ADB_VERSION=$(adb version 2>/dev/null | head -n 1 | cut -d' ' -f5)
    print_success "Android SDK installed - ADB version $ADB_VERSION"
    
    # Check ANDROID_HOME
    if [ -n "$ANDROID_HOME" ]; then
        print_info "ANDROID_HOME: $ANDROID_HOME"
    else
        if [ -d "$HOME/Library/Android/sdk" ]; then
            print_info "Android SDK found at: $HOME/Library/Android/sdk (auto-detected)"
        fi
    fi
    
    # Check available AVDs
    AVDS=$(flutter emulators 2>/dev/null | grep "android" || echo "")
    if [ -n "$AVDS" ]; then
        AVD_COUNT=$(echo "$AVDS" | wc -l | tr -d ' ')
        print_success "$AVD_COUNT Android emulator(s) available:"
        echo "$AVDS" | while read line; do
            EMU_NAME=$(echo "$line" | awk '{print $2, $3}' | cut -c1-30)
            print_info "  $EMU_NAME"
        done
    else
        print_warning "No Android emulators found"
        print_info "Create one in Android Studio > Tools > AVD Manager"
    fi
    
    # Check running emulators
    ADB_DEVICES=$(adb devices 2>/dev/null | grep "emulator" || echo "")
    if [ -n "$ADB_DEVICES" ]; then
        RUNNING_COUNT=$(echo "$ADB_DEVICES" | wc -l | tr -d ' ')
        print_success "$RUNNING_COUNT emulator(s) currently running"
    else
        print_warning "No Android emulators currently running"
        print_info "Will auto-start when running: ./run_local/macbook/run_android.sh"
    fi
    
    # Check Flutter Android devices
    ANDROID_DEVICES=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "android") | .name' 2>/dev/null || echo "")
    if [ -n "$ANDROID_DEVICES" ]; then
        print_success "Flutter can see Android devices - ready to run!"
    else
        print_warning "Flutter doesn't see Android devices yet (normal when no emulator running)"
    fi
else
    print_error "Android SDK not found"
    if [ -d "$HOME/Library/Android/sdk" ]; then
        print_info "SDK exists at ~/Library/Android/sdk but ADB not in PATH"
        print_info "The run script will auto-detect and fix this"
    else
        print_info "Install Android Studio from: https://developer.android.com/studio"
    fi
fi

# Check project status
echo ""
echo "📱 PROJECT STATUS"
echo "================="
if [ -f "pubspec.yaml" ]; then
    PROJECT_NAME=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
    print_success "Flutter project: $PROJECT_NAME"
    
    # Check if dependencies are installed
    if [ -d ".dart_tool" ]; then
        print_success "Dependencies installed and ready"
    else
        print_warning "Dependencies not installed"
        print_info "Run: flutter pub get"
    fi
    
    # Check for build artifacts
    if [ -d "build" ]; then
        BUILD_SIZE=$(du -sh build 2>/dev/null | cut -f1)
        print_warning "Build artifacts present ($BUILD_SIZE)"
        print_info "Clean with: flutter clean"
    else
        print_success "Clean project - no build artifacts"
    fi
    
    # Check git status
    if [ -d ".git" ]; then
        if command -v git &> /dev/null; then
            BRANCH=$(git branch --show-current 2>/dev/null)
            if [ -n "$BRANCH" ]; then
                print_info "Git branch: $BRANCH"
            fi
        fi
    fi
else
    print_error "Not in a Flutter project directory"
    print_info "Navigate to your Flutter project root first"
fi

# Summary and recommendations
echo ""
echo "🚀 READY TO RUN"
echo "==============="

# Check overall readiness
READY_IOS=false
READY_ANDROID=false

if command -v xcrun &> /dev/null; then
    READY_IOS=true
    print_success "iOS ready - run: ./run_local/macbook/run_ios.sh"
else
    print_warning "iOS not ready - install Xcode"
fi

if command -v adb &> /dev/null || [ -d "$HOME/Library/Android/sdk" ]; then
    READY_ANDROID=true
    print_success "Android ready - run: ./run_local/macbook/run_android.sh"
else
    print_warning "Android not ready - install Android Studio"
fi

if [ "$READY_IOS" = true ] && [ "$READY_ANDROID" = true ]; then
    print_success "Both platforms ready - run: ./run_local/macbook/run_both.sh"
fi

echo ""
print_info "Other commands:"
echo "  🛑 Kill iOS:      ./run_local/macbook/kill_ios.sh"
echo "  🛑 Kill Android:  ./run_local/macbook/kill_android.sh"
echo "  📊 Check status:  ./run_local/macbook/status.sh"

echo ""
print_success "Status check complete! $(date +%H:%M:%S)"