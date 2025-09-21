#!/bin/bash

# Tuqayyem iOS Killer Script
# Stops all iOS simulators and Flutter processes

set -e

echo "🛑 Stopping iOS Development Environment..."
echo "=========================================="

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

# Kill iOS Simulator processes
print_status "Stopping iOS Simulator..."
pkill -f "Simulator" 2>/dev/null || true

# Shutdown all iOS simulators
print_status "Shutting down all iOS simulators..."
xcrun simctl shutdown all 2>/dev/null || true

# Kill Xcode processes (if any)
print_status "Stopping Xcode processes..."
pkill -f "Xcode" 2>/dev/null || true

# Clean up any remaining processes
print_status "Cleaning up remaining processes..."
pkill -f "ios_deploy" 2>/dev/null || true
pkill -f "idevice" 2>/dev/null || true

# Wait a moment for processes to terminate
sleep 2

# Verify simulators are shut down
RUNNING_SIMS=$(xcrun simctl list devices | grep "Booted" | wc -l)
if [ "$RUNNING_SIMS" -eq 0 ]; then
    print_success "All iOS simulators stopped successfully!"
else
    print_warning "Some simulators may still be running:"
    xcrun simctl list devices | grep "Booted"
fi

# Check if Flutter processes are still running
FLUTTER_PROCS=$(pgrep -f "flutter" 2>/dev/null | wc -l)
if [ "$FLUTTER_PROCS" -eq 0 ]; then
    print_success "All Flutter processes stopped!"
else
    print_warning "$FLUTTER_PROCS Flutter processes may still be running"
fi

print_success "iOS development environment cleanup complete!"
echo ""
print_status "You can now run './run_ios.sh' to start fresh."