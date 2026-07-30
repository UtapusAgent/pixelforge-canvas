## Use Case

As a user preparing a cutout, I want to remove the background from a selected picture with local AI acceleration so I can isolate subjects without uploading private images.

## Details

- Run background removal locally.
- Prefer GPU acceleration when supported hardware and drivers are available.
- Offer CPU fallback with clear performance messaging.
- Preserve the original image through undo or non-destructive editing.
- Preview the mask/result before applying.
- Allow later mask refinement with keep/remove brushes.

## Acceptance Criteria

- Background removal does not upload the user image.
- GPU acceleration is used when available.
- CPU fallback is available when GPU acceleration is unavailable.
- The result supports transparency.
- The operation is undoable.

## Mockup

See `mockups/03-ai-background-removal.html`.

