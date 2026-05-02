# myapp

Flutter mobile POC. See [`.spec/constitution.md`](.spec/constitution.md) for the project spec.

## Toolchain layout

These instructions assume the layout produced during the initial setup:

| Tool | Path |
|---|---|
| Flutter SDK | `C:\dev\tools\flutter` |
| Android SDK | `C:\dev\tools\android-sdk` |
| `sdkmanager` | `C:\dev\tools\android-sdk\cmdline-tools\latest\bin\sdkmanager.bat` |
| `avdmanager` | `C:\dev\tools\android-sdk\cmdline-tools\latest\bin\avdmanager.bat` |
| `emulator` | `C:\dev\tools\android-sdk\emulator\emulator.exe` |

If your paths differ, substitute accordingly.

## Android SDK setup (Windows)

If `flutter build apk` fails with **"No Android SDK found. Try setting the ANDROID_HOME environment variable"**, work through this section.

### 1. Install JDK 17 or 21

Required by `sdkmanager` and the Gradle build. Verify with:

```powershell
java -version
```

If missing, install OpenJDK (e.g. Eclipse Temurin or Amazon Corretto) and ensure `java` is on `PATH`.

### 2. Download the Android command-line tools

Download "Command line tools only" (Windows) from <https://developer.android.com/studio#command-line-tools-only> and extract such that the final layout is:

```
C:\dev\tools\android-sdk\
  cmdline-tools\
    latest\
      bin\sdkmanager.bat
      lib\
      NOTICE.txt
      source.properties
```

The `latest\` directory is **mandatory** — `sdkmanager` refuses to run if `cmdline-tools` is flat (it can't determine the SDK root). If you extracted the zip directly into `cmdline-tools\`, move every file/folder one level down into a new `latest\` subdirectory before continuing.

### 3. Set environment variables (persistent)

In an **elevated** PowerShell, set them at the user level so every new shell sees them:

```powershell
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\dev\tools\android-sdk", "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "C:\dev\tools\android-sdk", "User")
```

Then add to `PATH` (also user-level):

```powershell
$path = [Environment]::GetEnvironmentVariable("Path", "User")
$additions = @(
    "C:\dev\tools\flutter\bin",
    "C:\dev\tools\android-sdk\cmdline-tools\latest\bin",
    "C:\dev\tools\android-sdk\platform-tools",
    "C:\dev\tools\android-sdk\emulator"
)
foreach ($a in $additions) {
    if ($path -notlike "*$a*") { $path = "$path;$a" }
}
[Environment]::SetEnvironmentVariable("Path", $path, "User")
```

**Open a fresh terminal** for the changes to take effect. Confirm with:

```powershell
echo $env:ANDROID_HOME
sdkmanager --version
```

### 4. Accept licenses and install required packages

Flutter 3.41 needs `compileSdk=36`, `targetSdk=36`, `minSdk=24`, plus build-tools 36 and platform-tools.

```powershell
sdkmanager --licenses              # press 'y' to accept each, or pipe 'y' in: cmd /c "echo y| sdkmanager --licenses"
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

The Gradle build may auto-install older companion versions (`platforms;android-35`, `build-tools;35.0.0`, `cmake;3.22.1`) on first run — that's expected.

### 5. Point Flutter at the SDK

```powershell
flutter config --android-sdk "C:\dev\tools\android-sdk"
flutter doctor
```

`flutter doctor` should report `[√] Android toolchain - develop for Android devices`. If it still complains, re-check that `ANDROID_HOME` is set in **the same shell** you're running `flutter` from (env var changes don't propagate to already-open terminals).

### 6. Build

```powershell
flutter build apk --debug
```

Output: `build\app\outputs\flutter-apk\app-debug.apk`.

## Running on an Android emulator

Assumes the SDK setup above is complete and `flutter`, `sdkmanager`, `avdmanager`, `emulator` are on `PATH`.

### 1. Install the emulator and a system image

The emulator binary and a bootable system image aren't part of the cmdline-tools install:

```powershell
sdkmanager "emulator" "system-images;android-34;google_apis;x86_64"
sdkmanager --licenses
```

`google_apis;x86_64` is the right pick for Intel/AMD Windows hosts. On an ARM laptop use `arm64-v8a` instead.

### 2. Create an AVD (one-off)

```powershell
avdmanager create avd --name pixel_api37 `
    --package "system-images;android-37.0;google_apis_playstore_ps16k;x86_64" `
    --device "pixel_8_pro"
```

Press Enter when it asks about a custom hardware profile (defaults are fine). The AVD is stored under `%USERPROFILE%\.android\avd\`.

List existing AVDs:

```powershell
emulator -list-avds
```

### 3. Start the emulator

```powershel
emulator -avd pixel_api37
```

Leave that window running. First boot takes a minute or two. If startup is slow or graphics glitch, try `-gpu swiftshader_indirect`.

### 4. Run the app

In a separate terminal, from the project root:

```powershell
flutter devices         # confirm the emulator is listed
flutter run             # auto-picks the running emulator
```

Hot reload with `r`, hot restart with `R`, quit with `q`.

## Common commands

```powershell
flutter pub get          # fetch dependencies
flutter analyze          # static analysis
flutter build apk --debug
flutter doctor           # diagnose toolchain issues
```
