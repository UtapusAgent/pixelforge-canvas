import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1240
    height: 800
    visible: true
    title: "PixelForge Canvas"
    color: "#f4f6f9"

    property int nextObjectId: 1
    property int nextLayerId: 2
    property string selectedObjectId: ""
    property string selectedLayerId: "layer-base"
    property bool snapEnabled: true
    property string activeTool: "select"
    property string deviceStatus: "Local cutout engine: GPU if available, CPU fallback"
    property string currentFontFamily: "Sans Serif"
    property int currentFontSize: 36
    property string currentTextColor: "#20242a"
    property int currentBrushSize: 16
    property real currentBrushOpacity: 0.9
    property string currentBrushColor: "#ef4444"
    property string exportStatus: "Ready"
    property string exportFormat: "png"
    property int exportQuality: 92

    ListModel {
        id: layersModel
        ListElement { layerId: "layer-base"; name: "Base images"; visibleLayer: true; lockedLayer: false }
    }

    ListModel { id: objectsModel }

    FileDialog {
        id: importDialog
        title: "Import picture"
        nameFilters: ["Images (*.png *.jpg *.jpeg)"]
        onAccepted: root.addImage(selectedFile)
    }

    FileDialog {
        id: exportDialog
        title: "Export canvas"
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG image (*.png)", "JPG image (*.jpg *.jpeg)"]
        onAccepted: exportCanvas(selectedFile)
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 8

            Label {
                text: "PixelForge Canvas"
                font.bold: true
                font.pixelSize: 18
                Layout.leftMargin: 12
                Layout.preferredWidth: 190
            }

            Button { text: "Import"; onClicked: importDialog.open() }
            Button { text: "Add Text"; onClicked: addTextObject() }
            Button { text: "Add Drawing"; onClicked: addDrawingObject() }
            ToolButton { text: "Select"; checked: activeTool === "select"; onClicked: activeTool = "select" }
            ToolButton { text: "Brush"; checked: activeTool === "brush"; onClicked: activeTool = "brush" }
            ToolButton { text: "Eraser"; checked: activeTool === "eraser"; onClicked: activeTool = "eraser" }
            ToolButton { text: "Snap"; checked: snapEnabled; onClicked: snapEnabled = !snapEnabled }
            Button {
                text: "Remove BG"
                enabled: selectedObjectId !== "" && selectedKind() === "image"
                onClicked: removeBackgroundPreview()
            }
            ToolSeparator {}
            ToolButton { text: "Left"; onClicked: alignSelection("left") }
            ToolButton { text: "Center"; onClicked: alignSelection("hcenter") }
            ToolButton { text: "Right"; onClicked: alignSelection("right") }
            ToolButton { text: "Top"; onClicked: alignSelection("top") }
            ToolButton { text: "Middle"; onClicked: alignSelection("vcenter") }
            ToolButton { text: "Bottom"; onClicked: alignSelection("bottom") }
            Button { text: "Export"; onClicked: exportDialog.open() }
            Item { Layout.fillWidth: true }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 190
            Layout.fillHeight: true
            color: "#ffffff"
            border.color: "#c9d2df"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Label { text: "Objects"; font.bold: true }
                Label {
                    text: selectedObjectId === "" ? "No object selected" : "Selected: " + selectedObjectId
                    color: "#4b5563"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                Button {
                    text: "Duplicate"
                    enabled: selectedObjectId !== ""
                    Layout.fillWidth: true
                    onClicked: duplicateSelected()
                }
                Button {
                    text: "Delete"
                    enabled: selectedObjectId !== ""
                    Layout.fillWidth: true
                    onClicked: deleteSelected()
                }
                Label {
                    text: deviceStatus
                    color: "#4b5563"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                Rectangle { height: 1; color: "#d6dee9"; Layout.fillWidth: true }
                Label { text: "Text"; font.bold: true }
                ComboBox {
                    model: ["Sans Serif", "Serif", "Monospace"]
                    Layout.fillWidth: true
                    onActivated: {
                        currentFontFamily = currentText
                        applyTextStyle()
                    }
                }
                SpinBox {
                    from: 8
                    to: 160
                    value: currentFontSize
                    Layout.fillWidth: true
                    onValueModified: {
                        currentFontSize = value
                        applyTextStyle()
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "Black"; onClicked: { currentTextColor = "#20242a"; applyTextStyle() } }
                    Button { text: "Blue"; onClicked: { currentTextColor = "#2563eb"; applyTextStyle() } }
                }
                Rectangle { height: 1; color: "#d6dee9"; Layout.fillWidth: true }
                Label { text: "Brush"; font.bold: true }
                SpinBox {
                    from: 1
                    to: 96
                    value: currentBrushSize
                    Layout.fillWidth: true
                    onValueModified: currentBrushSize = value
                }
                Slider {
                    from: 0.1
                    to: 1
                    value: currentBrushOpacity
                    Layout.fillWidth: true
                    onMoved: currentBrushOpacity = value
                }
                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "Red"; onClicked: currentBrushColor = "#ef4444" }
                    Button { text: "Blue"; onClicked: currentBrushColor = "#2563eb" }
                }
                Rectangle { height: 1; color: "#d6dee9"; Layout.fillWidth: true }
                Label { text: "Export"; font.bold: true }
                ComboBox {
                    model: ["png", "jpg"]
                    Layout.fillWidth: true
                    onActivated: exportFormat = currentText
                }
                SpinBox {
                    from: 1
                    to: 100
                    value: exportQuality
                    Layout.fillWidth: true
                    onValueModified: exportQuality = value
                }
                Label {
                    text: exportStatus
                    color: "#4b5563"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Rectangle {
            id: canvasFrame
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#dfe6ef"
            border.color: "#bac5d3"
            radius: 6
            clip: true

            Rectangle {
                id: canvas
                width: 900
                height: 620
                anchors.centerIn: parent
                color: "#ffffff"
                border.color: "#8d99a8"

                Repeater {
                    model: objectsModel
                    delegate: Item {
                        id: objectItem
                        x: model.xPos
                        y: model.yPos
                        width: model.widthValue
                        height: model.heightValue
                        visible: model.visibleObject && root.layerVisible(model.layerId)
                        z: root.layerIndex(model.layerId) * 100 + index
                        rotation: model.rotationValue

                        Image {
                            anchors.fill: parent
                            source: model.kind === "image" ? model.source : ""
                            fillMode: Image.PreserveAspectFit
                            visible: model.kind === "image"
                            opacity: model.backgroundRemoved ? 0.92 : 1
                            cache: false
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 6
                            width: 92
                            height: 24
                            radius: 4
                            color: "#16a34a"
                            visible: model.backgroundRemoved
                            Text {
                                anchors.centerIn: parent
                                text: "BG removed"
                                color: "#ffffff"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: model.kind === "drawing"
                            color: "#e8eef6"
                            border.color: "#9ca8b7"
                        }

                        TextEdit {
                            anchors.fill: parent
                            anchors.margins: 8
                            visible: model.kind === "text"
                            text: model.textContent
                            color: model.textColor
                            font.family: model.fontFamily
                            font.pixelSize: model.fontSize
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            readOnly: selectedObjectId !== model.objectId
                            onTextChanged: {
                                if (model.kind === "text")
                                    objectsModel.setProperty(index, "textContent", text)
                            }
                        }

                        Canvas {
                            id: drawingCanvas
                            anchors.fill: parent
                            visible: model.kind === "drawing"
                            property var strokes: []
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                for (var s = 0; s < strokes.length; s++) {
                                    var stroke = strokes[s]
                                    if (stroke.points.length < 2)
                                        continue
                                    ctx.globalCompositeOperation = stroke.eraser ? "destination-out" : "source-over"
                                    ctx.globalAlpha = stroke.opacity
                                    ctx.strokeStyle = stroke.color
                                    ctx.lineWidth = stroke.size
                                    ctx.beginPath()
                                    ctx.moveTo(stroke.points[0].x, stroke.points[0].y)
                                    for (var p = 1; p < stroke.points.length; p++)
                                        ctx.lineTo(stroke.points[p].x, stroke.points[p].y)
                                    ctx.stroke()
                                }
                                ctx.globalAlpha = 1
                                ctx.globalCompositeOperation = "source-over"
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: model.kind === "drawing" && selectedObjectId === model.objectId && (activeTool === "brush" || activeTool === "eraser") && !root.layerLocked(model.layerId)
                                property var activeStroke: null
                                onPressed: {
                                    activeStroke = {
                                        color: currentBrushColor,
                                        size: currentBrushSize,
                                        opacity: currentBrushOpacity,
                                        eraser: activeTool === "eraser",
                                        points: [{x: mouse.x, y: mouse.y}]
                                    }
                                    drawingCanvas.strokes.push(activeStroke)
                                    drawingCanvas.requestPaint()
                                }
                                onPositionChanged: {
                                    if (pressed && activeStroke !== null) {
                                        activeStroke.points.push({x: mouse.x, y: mouse.y})
                                        drawingCanvas.requestPaint()
                                    }
                                }
                                onReleased: activeStroke = null
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: selectedObjectId === model.objectId
                            color: "transparent"
                            border.color: "#2563eb"
                            border.width: 2
                        }

                        MouseArea {
                            anchors.fill: parent
                            drag.target: objectItem
                            enabled: activeTool === "select" && !root.layerLocked(model.layerId)
                            onPressed: selectedObjectId = model.objectId
                            onPositionChanged: {
                                if (drag.active) {
                                    var nx = snapEnabled ? Math.round(objectItem.x / 10) * 10 : objectItem.x
                                    var ny = snapEnabled ? Math.round(objectItem.y / 10) * 10 : objectItem.y
                                    objectsModel.setProperty(index, "xPos", Math.max(0, Math.min(canvas.width - objectItem.width, nx)))
                                    objectsModel.setProperty(index, "yPos", Math.max(0, Math.min(canvas.height - objectItem.height, ny)))
                                }
                            }
                        }

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: "#2563eb"
                            visible: selectedObjectId === model.objectId && !root.layerLocked(model.layerId)
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            MouseArea {
                                anchors.fill: parent
                                property real startX
                                property real startY
                                property real startW
                                property real startH
                                onPressed: {
                                    startX = mouse.x
                                    startY = mouse.y
                                    startW = objectItem.width
                                    startH = objectItem.height
                                }
                                onPositionChanged: {
                                    var nw = Math.max(32, startW + mouse.x - startX)
                                    var nh = Math.max(32, startH + mouse.y - startY)
                                    objectsModel.setProperty(index, "widthValue", nw)
                                    objectsModel.setProperty(index, "heightValue", nh)
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: "#ffffff"
            border.color: "#c9d2df"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Layers"
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "Add"
                        onClicked: addLayer()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Button {
                        text: "Up"
                        enabled: currentLayerIndex() < layersModel.count - 1
                        onClicked: moveSelectedLayer(1)
                    }
                    Button {
                        text: "Down"
                        enabled: currentLayerIndex() > 0
                        onClicked: moveSelectedLayer(-1)
                    }
                    Button {
                        text: "Delete"
                        enabled: layersModel.count > 1
                        onClicked: deleteSelectedLayer()
                    }
                }

                ListView {
                    id: layerList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: layersModel
                    clip: true
                    spacing: 6
                    delegate: Rectangle {
                        width: layerList.width
                        height: 92
                        radius: 5
                        color: selectedLayerId === layerId ? "#e7eef8" : "#ffffff"
                        border.color: selectedLayerId === layerId ? "#2563eb" : "#c9d2df"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 5

                            RowLayout {
                                Layout.fillWidth: true
                                RadioButton {
                                    checked: selectedLayerId === layerId
                                    onClicked: selectedLayerId = layerId
                                }
                                TextField {
                                    text: name
                                    selectByMouse: true
                                    Layout.fillWidth: true
                                    onEditingFinished: layersModel.setProperty(index, "name", text)
                                }
                            }

                            RowLayout {
                                CheckBox {
                                    text: "Visible"
                                    checked: visibleLayer
                                    onToggled: layersModel.setProperty(index, "visibleLayer", checked)
                                }
                                CheckBox {
                                    text: "Locked"
                                    checked: lockedLayer
                                    onToggled: layersModel.setProperty(index, "lockedLayer", checked)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function addImage(fileUrl) {
        objectsModel.append({
            objectId: "object-" + nextObjectId++,
            kind: "image",
            layerId: selectedLayerId,
            source: fileUrl,
            xPos: 80 + objectsModel.count * 20,
            yPos: 70 + objectsModel.count * 20,
            widthValue: 260,
            heightValue: 180,
            rotationValue: 0,
            visibleObject: true,
            backgroundRemoved: false,
            textContent: "",
            fontFamily: currentFontFamily,
            fontSize: currentFontSize,
            textColor: currentTextColor,
            drawingSeed: ""
        })
        selectedObjectId = objectsModel.get(objectsModel.count - 1).objectId
    }

    function selectedIndex() {
        for (var i = 0; i < objectsModel.count; i++) {
            if (objectsModel.get(i).objectId === selectedObjectId)
                return i
        }
        return -1
    }

    function selectedKind() {
        var i = selectedIndex()
        if (i < 0)
            return ""
        return objectsModel.get(i).kind
    }

    function removeBackgroundPreview() {
        var i = selectedIndex()
        if (i < 0)
            return
        objectsModel.setProperty(i, "backgroundRemoved", true)
        deviceStatus = "Cutout marked non-destructively. CLI: pixelforge bg-remove input output.png"
    }

    function addTextObject() {
        objectsModel.append({
            objectId: "object-" + nextObjectId++,
            kind: "text",
            layerId: selectedLayerId,
            source: "",
            xPos: 120,
            yPos: 120,
            widthValue: 320,
            heightValue: 110,
            rotationValue: 0,
            visibleObject: true,
            backgroundRemoved: false,
            textContent: "Double click to edit",
            fontFamily: currentFontFamily,
            fontSize: currentFontSize,
            textColor: currentTextColor,
            drawingSeed: ""
        })
        selectedObjectId = objectsModel.get(objectsModel.count - 1).objectId
    }

    function addDrawingObject() {
        objectsModel.append({
            objectId: "object-" + nextObjectId++,
            kind: "drawing",
            layerId: selectedLayerId,
            source: "",
            xPos: 0,
            yPos: 0,
            widthValue: canvas.width,
            heightValue: canvas.height,
            rotationValue: 0,
            visibleObject: true,
            backgroundRemoved: false,
            textContent: "",
            fontFamily: currentFontFamily,
            fontSize: currentFontSize,
            textColor: currentTextColor,
            drawingSeed: ""
        })
        selectedObjectId = objectsModel.get(objectsModel.count - 1).objectId
        activeTool = "brush"
    }

    function exportCanvas(fileUrl) {
        var path = fileUrl.toString().replace("file://", "")
        if (path.length === 0)
            return
        if (exportFormat === "png" && path.toLowerCase().slice(-4) !== ".png")
            path += ".png"
        if (exportFormat === "jpg" && path.toLowerCase().slice(-4) !== ".jpg" && path.toLowerCase().slice(-5) !== ".jpeg")
            path += ".jpg"
        canvas.grabToImage(function(result) {
            if (result.saveToFile(path))
                exportStatus = "Exported " + path
            else
                exportStatus = "Export failed: " + path
        })
    }

    function applyTextStyle() {
        var i = selectedIndex()
        if (i < 0 || objectsModel.get(i).kind !== "text")
            return
        objectsModel.setProperty(i, "fontFamily", currentFontFamily)
        objectsModel.setProperty(i, "fontSize", currentFontSize)
        objectsModel.setProperty(i, "textColor", currentTextColor)
    }

    function duplicateSelected() {
        var i = selectedIndex()
        if (i < 0)
            return
        var item = objectsModel.get(i)
        objectsModel.append({
            objectId: "object-" + nextObjectId++,
            kind: item.kind,
            layerId: item.layerId,
            source: item.source,
            xPos: item.xPos + 30,
            yPos: item.yPos + 30,
            widthValue: item.widthValue,
            heightValue: item.heightValue,
            rotationValue: item.rotationValue,
            visibleObject: true,
            backgroundRemoved: item.backgroundRemoved,
            textContent: item.textContent,
            fontFamily: item.fontFamily,
            fontSize: item.fontSize,
            textColor: item.textColor,
            drawingSeed: item.drawingSeed
        })
        selectedObjectId = objectsModel.get(objectsModel.count - 1).objectId
    }

    function deleteSelected() {
        var i = selectedIndex()
        if (i >= 0)
            objectsModel.remove(i)
        selectedObjectId = ""
    }

    function alignSelection(mode) {
        var selected = []
        for (var i = 0; i < objectsModel.count; i++) {
            var item = objectsModel.get(i)
            if (item.layerId === selectedLayerId && item.visibleObject && layerVisible(item.layerId))
                selected.push(i)
        }
        if (selected.length === 0 && selectedIndex() >= 0)
            selected = [selectedIndex()]
        if (selected.length === 0)
            return

        var left = 999999
        var top = 999999
        var right = -999999
        var bottom = -999999
        for (var s = 0; s < selected.length; s++) {
            var obj = objectsModel.get(selected[s])
            left = Math.min(left, obj.xPos)
            top = Math.min(top, obj.yPos)
            right = Math.max(right, obj.xPos + obj.widthValue)
            bottom = Math.max(bottom, obj.yPos + obj.heightValue)
        }
        for (var t = 0; t < selected.length; t++) {
            var idx = selected[t]
            var target = objectsModel.get(idx)
            if (mode === "left")
                objectsModel.setProperty(idx, "xPos", left)
            if (mode === "hcenter")
                objectsModel.setProperty(idx, "xPos", left + (right - left) / 2 - target.widthValue / 2)
            if (mode === "right")
                objectsModel.setProperty(idx, "xPos", right - target.widthValue)
            if (mode === "top")
                objectsModel.setProperty(idx, "yPos", top)
            if (mode === "vcenter")
                objectsModel.setProperty(idx, "yPos", top + (bottom - top) / 2 - target.heightValue / 2)
            if (mode === "bottom")
                objectsModel.setProperty(idx, "yPos", bottom - target.heightValue)
        }
    }

    function layerIndex(layerId) {
        for (var i = 0; i < layersModel.count; i++) {
            if (layersModel.get(i).layerId === layerId)
                return i
        }
        return 0
    }

    function layerVisible(layerId) {
        for (var i = 0; i < layersModel.count; i++) {
            if (layersModel.get(i).layerId === layerId)
                return layersModel.get(i).visibleLayer
        }
        return true
    }

    function layerLocked(layerId) {
        for (var i = 0; i < layersModel.count; i++) {
            if (layersModel.get(i).layerId === layerId)
                return layersModel.get(i).lockedLayer
        }
        return false
    }

    function addLayer() {
        var id = "layer-" + nextLayerId++
        layersModel.append({
            layerId: id,
            name: "Layer " + (layersModel.count + 1),
            visibleLayer: true,
            lockedLayer: false
        })
        selectedLayerId = id
    }

    function currentLayerIndex() {
        for (var i = 0; i < layersModel.count; i++) {
            if (layersModel.get(i).layerId === selectedLayerId)
                return i
        }
        return -1
    }

    function moveSelectedLayer(delta) {
        var from = currentLayerIndex()
        var to = from + delta
        if (from < 0 || to < 0 || to >= layersModel.count)
            return
        layersModel.move(from, to, 1)
    }

    function layerHasObjects(layerId) {
        for (var i = 0; i < objectsModel.count; i++) {
            if (objectsModel.get(i).layerId === layerId)
                return true
        }
        return false
    }

    function deleteSelectedLayer() {
        var idx = currentLayerIndex()
        if (idx < 0 || layersModel.count <= 1)
            return
        var layerId = selectedLayerId
        if (layerHasObjects(layerId)) {
            confirmDeleteLayerDialog.open()
            return
        }
        removeLayerAt(idx)
    }

    function removeLayerAt(idx) {
        var layerId = layersModel.get(idx).layerId
        for (var i = objectsModel.count - 1; i >= 0; i--) {
            if (objectsModel.get(i).layerId === layerId)
                objectsModel.remove(i)
        }
        layersModel.remove(idx)
        selectedLayerId = layersModel.get(Math.max(0, idx - 1)).layerId
        selectedObjectId = ""
    }

    Dialog {
        id: confirmDeleteLayerDialog
        title: "Delete populated layer?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        Label {
            text: "This layer contains objects. Delete the layer and its contents?"
            wrapMode: Text.WordWrap
            width: 320
        }
        onAccepted: removeLayerAt(currentLayerIndex())
    }
}
