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

