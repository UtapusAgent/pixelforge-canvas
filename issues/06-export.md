## Use Case

As a user finishing a composition, I want to export the visible canvas as JPG or PNG so I can share or publish the final image.

## Details

- Export as PNG or JPG.
- Preserve transparency for PNG.
- Flatten transparency against an explicit background color for JPG.
- Let the user choose destination path, filename, dimensions, and JPG quality.
- Warn before overwriting existing files.
- Report write errors without losing project state.

## Acceptance Criteria

- PNG and JPG export are available.
- PNG export can preserve transparency.
- JPG export clearly previews flattening/background color.
- Export respects visible layers, layer order, and canvas bounds.
- Failed writes show a useful error and leave the project unchanged.

## Mockup

See `mockups/06-export.html`.

