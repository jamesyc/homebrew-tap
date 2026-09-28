# Homebrew Tap

Homebrew formulae for projects.

## Usage

```sh
brew tap jamesyc/tap
```

You can also install a formula directly without a separate tap step:

```sh
brew install jamesyc/tap/<formula>
```

## Formulae

### canonshuttercount

Read the original Canon EOS 5D shutter count over USB. Both PC Connect and
Print/PTP are supported; hardware validation has been completed on Apple Silicon
macOS with firmware 1.1.1. Linux camera behavior remains unverified.

```sh
brew install jamesyc/tap/canonshuttercount
canonshuttercount
```

Wait for the camera's card activity to finish before reading. A read starting in
PC Connect leaves USB in Print/PTP; power-cycle to return to the camera's saved
Communication setting.

### tcapsule

Deploy modern Samba to Apple AirPort Time Capsules.

```sh
brew install jamesyc/tap/tcapsule
tcapsule configure
tcapsule deploy
tcapsule doctor
```

### acp

AirPyrt Tools for Apple AirPort and Time Capsule ACP.

```sh
brew install jamesyc/tap/acp
acp --help
```
