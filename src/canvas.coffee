# **Canvas.coffeee** contains a set of extensions to `CanvasRenderingContext2D` which
# are actively used in Atlas.js


## Custom pin shape for `CanvasRenderingContext2D`
CanvasRenderingContext2D::pinShape = (x, y, width, height, fill=false, stroke=false) ->
    # Center coordinates of the pin
    center =
        x: x + width / 2
        y: y + height / 2

    # Coordinates for where the top arc ends
    arc =
        y: y + height / 3


    # Start drawing
    this.beginPath()

    # The arc shape that fills up the top part of the marker
    this.arc center.x, y + height / 3, width / 2, Math.PI, 0, false

    # The right half of the pin tip
    this.bezierCurveTo x + width, arc.y + height / 4, center.x + width / 3, center.y, center.x, y + height

    # The left half of the pin tip
    this.moveTo x, arc.y
    this.bezierCurveTo x, arc.y + height / 4, center.x - width / 3, center.y, center.x, y + height

    # Apply fill and stroke if wanted
    this.fill()   if fill
    this.stroke() if stroke
