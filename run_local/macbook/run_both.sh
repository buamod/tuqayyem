#!/bin/bash

# Tuqayyem Multi-Platform Runner
# Runs the app on both iOS and Android simultaneously

echo "📱 Starting Tuqayyem on Multiple Platforms..."
echo "============================================="

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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in a Flutter project directory!"
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Starting iOS emulator in background..."
"$SCRIPT_DIR/run_ios.sh" &
IOS_PID=$!

sleep 5

print_status "Starting Android emulator in background..."
"$SCRIPT_DIR/run_android.sh" &
ANDROID_PID=$!

print_success "Both platforms starting up!"
print_status "iOS PID: $IOS_PID"
print_status "Android PID: $ANDROID_PID"

echo ""
print_warning "Press Ctrl+C to stop both platforms"
echo ""

# Wait for user interrupt
trap 'print_status "Stopping both platforms..."; kill $IOS_PID $ANDROID_PID 2>/dev/null; exit 0' INT

# Wait for both processes
wait $IOS_PID $ANDROID_PID

print_success "Both platforms have stopped."