## Use Case

As a user composing an image, I want to import multiple pictures from disk, drag them around, and align selected pictures so I can build a clean canvas layout quickly.

## Details

- Import PNG and JPG files from the Linux file picker.
- Represent each import as a selectable canvas object.
- Support drag, resize, rotate, multi-select, snap guides, and alignment actions.
- Include align left, center, right, top, middle, bottom, distribute horizontally, and distribute vertically.
- Keep invalid imports from changing the current canvas.

## Acceptance Criteria

- Multiple images can be imported into one canvas.
- Imported images can be selected, moved, resized, and rotated.
- Multi-select alignment affects only selected objects.
- Snapping can target canvas edges, centers, guides, and neighboring object bounds.
- Unsupported files produce a user-visible error without crashing.

## Mockup

See `mockups/01-import-arrange-align.html`.

