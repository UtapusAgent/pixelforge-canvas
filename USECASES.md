# PixelForge Canvas Use Cases

## UC-01: Import, Drag, Arrange, and Align Pictures

**Primary actor:** Desktop user composing images.

**Goal:** Import multiple pictures from disk, position them freely on the canvas, and use alignment tools to create a clean composition.

**Preconditions**

- The application is running on Linux.
- The user has at least one readable image file on disk.
- Supported image files include common formats such as PNG and JPG.

**Main flow**

1. The user creates or opens a canvas.
2. The user imports one or more pictures from disk.
3. Each imported picture appears as a selectable object on the canvas.
4. The user drags objects to reposition them.
5. The user resizes or rotates selected objects when needed.
6. The user selects multiple objects.
7. The user chooses alignment actions such as align left, center, right, top, middle, bottom, distribute horizontally, or distribute vertically.
8. The canvas updates immediately while preserving image quality.

**Alternate flows**

- If an imported file is unsupported, the app shows a clear error and keeps the current canvas unchanged.
- If several objects overlap, the user can select the intended object through a layer/object list.
- If snapping is enabled, drag operations snap to guides, canvas edges, centers, and neighboring object bounds.

**Acceptance criteria**

- Multiple images can be imported into the same canvas.
- Imported pictures can be selected, dragged, resized, and aligned.
- Multi-select alignment affects only selected objects.
- The canvas remains responsive with several medium-size images loaded.
- Invalid files do not crash the application.

## UC-02: Manage Arbitrary Canvas Layers

**Primary actor:** User building compositions with foreground and background elements.

**Goal:** Create, reorder, rename, hide, lock, and delete as many layers as the composition needs.

**Preconditions**

- A canvas is open.

**Main flow**

1. The user opens the layer panel.
2. The user adds new layers for background, imported pictures, text, and drawing work.
3. The user drags layers in the layer list to change front-to-back order.
4. The canvas updates z-order immediately.
5. The user toggles layer visibility to inspect the composition.
6. The user locks a layer to prevent accidental edits.
7. The user renames layers to keep the project organized.

**Alternate flows**

- If a locked layer is selected on the canvas, transform handles are disabled and the layer panel explains the lock state.
- If the user deletes a layer containing content, the app asks for confirmation.
- If the user creates many layers, the layer panel remains scrollable and searchable/filterable.

**Acceptance criteria**

- Users can create an arbitrary number of layers within practical memory limits.
- Layer ordering maps directly to canvas foreground/background order.
- Visibility and lock states are reflected both in the layer panel and canvas behavior.
- Deleting a populated layer requires confirmation.

## UC-03: Remove Picture Backgrounds Locally With AI

**Primary actor:** User preparing cutouts from imported photos.

**Goal:** Remove the background from a selected picture using local AI acceleration, preferring GPU hardware when available.

**Preconditions**

- A canvas is open.
- At least one picture layer/object is selected.
- The required AI model assets are installed or can be downloaded through an approved setup flow.

**Main flow**

1. The user selects an imported picture.
2. The user chooses the background removal action.
3. The app shows device availability such as GPU acceleration, CPU fallback, and estimated processing state.
4. The user starts background removal.
5. The app processes the image locally.
6. The app previews the cutout mask and transparent result.
7. The user accepts the result.
8. The original image remains recoverable through undo or a non-destructive copy.

**Alternate flows**

- If GPU acceleration is unavailable, the user can continue with CPU processing or cancel.
- If the AI model is missing, the app offers a setup step before processing.
- If the result is imperfect, the user can refine the mask with brush-based keep/remove controls.

**Acceptance criteria**

- Background removal runs locally and does not upload user images.
- GPU acceleration is used when supported hardware and drivers are available.
- CPU fallback is available with clear performance messaging.
- The operation is undoable.
- Transparency is preserved for downstream editing and PNG export.

## UC-04: Add Editable Text With Font Controls

**Primary actor:** User adding captions, labels, or design typography.

**Goal:** Place editable text on the canvas and style it with different fonts, sizes, colors, and alignment options.

**Preconditions**

- A canvas is open.
- The system has installed fonts available through Qt font discovery.

**Main flow**

1. The user selects the text tool.
2. The user clicks or drags on the canvas to create a text box.
3. The user types text directly on the canvas.
4. The user changes font family, size, weight, style, fill color, alignment, and line spacing.
5. The user moves, resizes, and layers the text object like other canvas objects.
6. The user can reselect the text later and edit the content.

**Alternate flows**

- If a selected font is unavailable when a project is reopened, the app substitutes a fallback and warns the user.
- If text overflows its box, the user can resize the box or enable auto-fit.
- If the text is converted to a bitmap or outline later, the user receives a warning about editability.

**Acceptance criteria**

- Text remains editable after creation.
- Font selection uses installed system fonts.
- Text objects can be layered above or below pictures and drawings.
- Font changes update the canvas preview immediately.

## UC-05: Draw Directly Onto the Canvas

**Primary actor:** User annotating or creating freehand artwork.

**Goal:** Draw and erase strokes on the canvas with configurable brush settings.

**Preconditions**

- A canvas is open.
- The user has an active drawing layer or allows the app to create one automatically.

**Main flow**

1. The user selects the brush tool.
2. The app creates or activates a drawing layer.
3. The user chooses brush size, color, opacity, and hardness.
4. The user draws freehand strokes on the canvas.
5. The user switches to the eraser tool to remove parts of strokes.
6. The user can undo recent stroke operations.
7. Drawing content participates in layer ordering and export.

**Alternate flows**

- If the active layer is locked, the app offers to select or create an editable layer.
- If pressure-sensitive input is available, brush width or opacity can respond to pressure.
- If performance drops on large canvases, the app batches strokes while keeping pointer feedback smooth.

**Acceptance criteria**

- Brush and eraser tools work on drawing layers.
- Brush size, color, and opacity are user-controllable.
- Strokes are undoable.
- Drawing layers can be reordered, hidden, locked, and exported.

## UC-06: Export the Canvas as JPG or PNG

**Primary actor:** User finishing a composition.

**Goal:** Export the current canvas to JPG or PNG with expected size, quality, transparency, and destination controls.

**Preconditions**

- A canvas contains at least one visible object or a background.

**Main flow**

1. The user opens the export dialog.
2. The user chooses PNG or JPG.
3. The user selects destination path and filename.
4. For PNG, the user can preserve transparency.
5. For JPG, the user can choose quality and background fill color when transparency exists.
6. The app previews export dimensions and estimated output details.
7. The user confirms export.
8. The app writes the file and reports success.

**Alternate flows**

- If the destination is not writable, the app asks the user to choose another location.
- If JPG export would flatten transparency, the app clearly shows the chosen matte/background color.
- If a file already exists, the app asks before overwriting.

**Acceptance criteria**

- PNG and JPG export are both available.
- PNG can preserve transparency.
- JPG handles transparency by flattening against an explicit background color.
- Export respects visible layers, order, canvas bounds, and user-selected dimensions.
- Failed writes do not lose project state.

