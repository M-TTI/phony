# Phony
Phony is an osu! beatmap compatible, fully local audio player built with flutter.
Supported audio formats : `.mp3`, `.flac`, `.ogg`, `.wav`. 

## Installation
### Android
Download the apk from the [releases page](https://github.com/M-TTI/phony/releases).

Requires Android 5.0 (API 21) or newer.

1. Enable installation from unknown sources for your browser or file manager (Settings -> Apps -> Special access -> Install unknown apps).
2. Download the apk from the [releases page](https://github.com/M-TTI/phony/releases) and open it.
3. Grant the audio permission when prompted.

### Linux (x64)
Download the archive for your platform from the [releases page](https://github.com/M-TTI/phony/releases).
Phony needs **libmpv** at runtime for linux.
Install it for you distribution:
##### Debian/Ubuntu
```bash
sudo apt install libmpv2
```
##### Arch
```bash
sudo pacman -S mpv
```
##### Fedora
```bash
sudo dn install mpv-libs
```
Extract archive:
```bash
tar -xzf phony-<version>-linux-x64.tar.gz
cd phony-<version>-linux-x64
```
Run phony:
```
chmod +x phony
./phony
```
Phony Linux has currently only been tested on Fedora 42 with glibc 2.41.

### Windows (x64)
Download the archive from the [releases page](https://github.com/M-TTI/phony/releases).
Extract `phony-<version>-windows-x64.zip` and run `phony.exe`.

Windows will warn that the publisher is unknown, because the executable is not code-signed. Choose **More info -> Run anyway**.

## Building from source

Requires the Flutter SDK (3.44+) and the platform toolchain: Visual Studio 2022 or later with
the C++ workload for Windows and the Android SDK for Android.

Clone the repository:
```bash
git clone git@github.com:M-TTI/phony.git
cd phony
```
Download the dependencies:
```bash
flutter pub get
```
Run build_runner (required for Drift generated files):
```bash
dart run build_runner build --delete-conflicting-outputs
```
Then build for the platform of your choice:
```
flutter build apk --release
flutter build linux --release
flutter build windows --release
```

## License

This project is licensed under the [GPL 3 License](https://github.com/M-TTI/phony/blob/dev/LICENSE)