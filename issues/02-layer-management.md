## Use Case

As a user building a composition, I want to create and manage as many layers as I need so I can control foreground and background ordering.

## Details

- Add, rename, reorder, hide, lock, and delete layers.
- Drag layers to change front-to-back order.
- Reflect layer visibility and lock state in canvas interactions.
- Confirm deletion when a layer contains content.
- Keep the layer panel usable when many layers exist.

## Acceptance Criteria

- Users can create arbitrary layers within practical memory limits.
- Layer order directly controls canvas z-order.
- Hidden layers do not render on the canvas or in export.
- Locked layers cannot be accidentally edited.
- Deleting populated layers requires confirmation.

## Mockup

See `mockups/02-layer-management.html`.

