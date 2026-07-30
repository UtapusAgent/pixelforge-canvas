# PixelForge Canvas

PixelForge Canvas is a Linux desktop image editing and canvas application built with Qt Quick/QML and Go.

The `main` branch started with product planning artifacts. The `mvp` branch contains the first working MVP:

- Detailed use cases for the requested feature set.
- GitHub issue source drafts used to seed the project backlog.
- Standalone mockups for each use case in `mockups/`.
- A Go launcher and core packages.
- A Qt Quick desktop UI for image placement, layers, text, drawing, background-removal state, and export.

## MVP Scope

- Import pictures from disk and arrange them on a freeform canvas.
- Drag, resize, align, snap, and distribute imported pictures.
- Manage an arbitrary number of foreground/background layers.
- Remove image backgrounds locally with GPU-accelerated AI when available.
- Add editable text with font, style, color, and alignment controls.
- Draw directly on the canvas with brush and eraser tools.
- Export final compositions as JPG or PNG.

## Build

See `docs/build.md`.

```sh
make test
make build
make run
```

The desktop runtime requires a Qt QML launcher such as `qml6` or `qmlscene`.

## Mockups

Open the files in `mockups/` with a browser to review the use-case concepts:

- `01-import-arrange-align.html`
- `02-layer-management.html`
- `03-ai-background-removal.html`
- `04-text-tool.html`
- `05-drawing-tool.html`
- `06-export.html`
