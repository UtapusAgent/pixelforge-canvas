# Build Notes

PixelForge Canvas is an MVP Linux desktop application using a Go executable and a Qt Quick/QML interface.

## Requirements

- Go 1.22 or newer.
- Qt 6 runtime with Qt Quick Controls installed.
- One of these QML launchers on `PATH`: `qml6`, `qml`, `qmlscene6`, or `qmlscene`.

On Debian/Ubuntu systems, the Qt runtime packages are usually provided by packages such as:

```sh
sudo apt install golang-go qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-dialogs qt6-qmltooling-plugins
```

Package names can vary by distribution.

## Development

```sh
make fmt
make test
make build
make run
```

The Go process writes the embedded QML UI into a temporary runtime directory and launches Qt. Core image processing and export helpers live in Go packages so they can be tested independently from the desktop runtime.

## Nix

The repository includes `flake.nix` with a development shell and a wrapped package:

```sh
nix develop
make test
make run
```

You can also build or run the package directly:

```sh
nix build
nix run
```

The flake provides Go, Qt 6, Qt Quick Controls, Qt tooling, and Wayland support. The packaged binary is wrapped with Qt plugin and QML import paths so the Go launcher can find the QML runtime.

## Helper Commands

```sh
pixelforge device-status
pixelforge bg-remove input.jpg output.png
pixelforge export-jpg input.png output.jpg
```

`bg-remove` is an MVP local cutout helper. It detects likely local GPU availability for status reporting and uses a CPU-safe segmentation fallback when a dedicated AI runtime is not configured.
