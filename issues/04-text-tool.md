## Use Case

As a user adding labels or captions, I want editable text objects with font controls so I can add typography directly to the canvas.

## Details

- Create text boxes by clicking or dragging on the canvas.
- Edit text in place.
- Support font family, size, weight, style, fill color, alignment, and line spacing.
- Use installed system fonts discovered through Qt.
- Allow text objects to be moved, resized, and layered.

## Acceptance Criteria

- Text remains editable after creation.
- Installed system fonts are available in the font picker.
- Style changes update the canvas preview immediately.
- Text objects can be ordered above or below images and drawing layers.
- Missing fonts on reopen use a fallback and show a warning.

## Mockup

See `mockups/04-text-tool.html`.

