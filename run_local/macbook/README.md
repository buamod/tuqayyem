# Tuqayyem Local Development Scripts

Automated scripts for running Tuqayyem on iOS and Android emulators on macOS.

## 🚀 Quick Start

Make scripts executable (run once):
```bash
chmod +x run_local/macbook/*.sh
```

## 📱 Available Scripts

### iOS Development
```bash
# Start iOS simulator and run app
./run_local/macbook/run_ios.sh

# Stop all iOS simulators and processes
./run_local/macbook/kill_ios.sh
```

### Android Development
```bash
# Start Android emulator and run app
./run_local/macbook/run_android.sh

# Stop all Android emulators and processes
./run_local/macbook/kill_android.sh
```

### Multi-Platform
```bash
# Run on both iOS and Android simultaneously
./run_local/macbook/run_both.sh
```

## ✨ What These Scripts Do

### `run_ios.sh`
- ✅ Checks Flutter installation
- ✅ Cleans previous builds
- ✅ Gets Flutter dependencies
- ✅ Detects running iOS simulators
- ✅ Starts iOS simulator if none running
- ✅ Waits for simulator to be ready
- ✅ Launches Tuqayyem app
- ✅ Provides hot reload instructions

### `run_android.sh`
- ✅ Checks Flutter installation
- ✅ Cleans previous builds
- ✅ Gets Flutter dependencies
- ✅ Detects running Android emulators
- ✅ Starts Android emulator if none running
- ✅ Waits for emulator to be ready (up to 2 minutes)
- ✅ Pre-builds APK to avoid timeouts
- ✅ Launches Tuqayyem app
- ✅ Provides hot reload instructions

### `kill_*.sh` Scripts
- 🛑 Stops all Flutter processes
- 🛑 Stops all emulator processes
- 🛑 Cleans up background processes
- 🛑 Resets ADB server (Android)
- 🛑 Shuts down simulators gracefully
- 🛑 Cleans build artifacts

## 🎯 Usage Examples

**Start fresh iOS development:**
```bash
./run_local/macbook/kill_ios.sh    # Clean slate
./run_local/macbook/run_ios.sh     # Start fresh
```

**Quick Android test:**
```bash
./run_local/macbook/run_android.sh
# Press 'r' for hot reload, 'q' to quit
```

**Test on both platforms:**
```bash
./run_local/macbook/run_both.sh
# Both simulators will start automatically
```

## 🔧 Requirements

- macOS with Xcode installed
- Flutter SDK in PATH
- Android Studio with AVD configured
- `jq` for JSON parsing: `brew install jq`

## 🐛 Troubleshooting

**iOS Simulator won't start:**
- Check Xcode installation
- Verify iOS simulators are installed
- Try: `xcrun simctl list devices available`

**Android Emulator won't start:**
- Check Android Studio installation
- Verify AVD is created
- Try: `flutter emulators`

**Flutter not found:**
- Add Flutter to PATH in `~/.zshrc` or `~/.bash_profile`
- Restart terminal

**Permission denied:**
- Run: `chmod +x run_local/macbook/*.sh`

## 📝 Notes

- Scripts automatically handle emulator startup and shutdown
- iOS simulator typically starts faster than Android emulator
- Android emulator first boot can take 2-3 minutes
- Scripts include comprehensive error handling and status messages
- All output is color-coded for easy reading

## 🎨 Color Legend

- 🔵 **Blue**: Info/Status messages
- 🟢 **Green**: Success messages
- 🟡 **Yellow**: Warnings
- 🔴 **Red**: Errors

---

**Happy coding! 🚀**