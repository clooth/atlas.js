# **Atlas** is a library to be used with the Google Maps Javascript SDK
# to create customized interactive maps.

#### Atlas
class Atlas

    constructor: () ->
        @maps = []

    createMap: (options) ->
        map = new Atlas.Map(options)
        @maps.push map
        map


#### Atlas.Map
class Atlas.Map

    constructor: (@options) ->
        @container = @options.container
        @markers = []
        @map = new google.maps.Map(document.getElementById(@container),
                                   @options)

    addMarker: (options) ->
        marker = new Atlas.MapMarker(options)
        @markers.push marker
        marker

    showMarkers: () ->
        marker.setMap(@map) for marker in @markers

    fitToMarkers: (markers) ->
        markers = markers or @markers
        bounds = new google.maps.LatLngBounds()
        bounds.extend(marker.marker.getPosition()) for marker in markers
        @map.fitBounds(bounds)


#### Atlas.MapMarker
class Atlas.MapMarker

    constructor: (@options) ->
        # Marker position on the map
        @latitude  = @options.latitude or 60.0000
        @longitude = @options.longitude or 24.0000

        # The color of the marker can be anything Atlas automatically
        # darkens and lightens the chosen color when building the
        # marker image.
        @color = new jColour(@options.color or '#f00')

        # `@options.size` defines the width of the marker. The height is
        # always relative to the width and is automatically calculated.
        @size   = @options.size or 24
        @width  = @size
        @height = @size * 1.5

        # Minimum and maximum possible sizes for the marker, used in the basic grow / shrink
        # animation.
        @minSize = @size
        @maxSize = @size * 2

        # `@isGrown` is used when the grow and shrink animation is
        # being run. It specifies which direction we should be animating to
        @isGrown = false

        # Each marker is drawn on a `canvas` element
        @canvas = document.createElement 'canvas'
        @context = @canvas.getContext '2d'

        # Default options for `google.maps.Marker`
        markerOptions =
            position:  new google.maps.LatLng(@latitude, @longitude)
            title:     @options.title or 'Untitled Marker'
            animation: @options.animation or null

        # The main marker instance that we control
        @marker = new google.maps.Marker markerOptions

        # If `@options.map` was passed to the constructor, we can
        # automatically display the marker as it is created
        if @options.map?
            @marker.setMap @options.map
            this.render()

    setMap: (map) ->
        @marker.setMap(map)

    render: () ->
        @canvas.width = @width

        # The canvas height is always one fourth taller to make room for the
        # added dropshadow effect.
        @canvas.height = @height + @size / 4

        @context.clearRect 0, 0, @canvas.width, @canvas.height

        # Create the marker icon and assign it to the marker
        @icon = this.createIcon()
        @marker.setIcon(@icon)

    createIcon: () ->
        this.drawShadow()

        # Define all the colors
        baseColor = new jColour(@color.rgb())
        baseGradientColors =
            start: baseColor.lighten(5.5).hex()
            end: baseColor.darken(10).hex()

        baseGradient = @context.createLinearGradient 0, 0, @width, @height
        baseGradient.addColorStop 0, baseGradientColors.start
        baseGradient.addColorStop 1, baseGradientColors.end

        borderColor = new jColour(@color.rgb())
        borderGradientColors =
            start: borderColor.darken(10).transparentize(90).hex()
            end: borderColor.darken(15).transparentize(90).hex()

        borderGradient = @context.createLinearGradient 0, 0, @width, @height
        borderGradient.addColorStop 0, borderGradientColors.start
        borderGradient.addColorStop 1, borderGradientColors.end

        # Draw the basic marker shape
        @context.lineWidth = 1.5
        pinShapeParams = [
            [1.5, 0.0, @width - 3.5, @height, baseGradient, borderGradient],
            [2.0, 1.0, @width - 4.25, @height - 2.5, new jColour(@color.rgb()).lighten(25).hex(), false],
            [2.0, 2.5, @width - 4.25, @height - 4.0, baseGradient, false]
        ]
        for params in pinShapeParams
            @context.fillStyle   = if params[4] then params[4] else false
            @context.strokeStyle = if params[5] then params[5] else false
            @context.pinShape(params...)

        # Draw the middle white ball
        @context.beginPath()
        @context.arc @width / 2, @height / 3, @width / 6, Math.PI * 2, 0, false
        @context.fillStyle = '#fff'
        @context.fill()

        return new google.maps.MarkerImage @canvas.toDataURL(),
            new google.maps.Size @width, @canvas.height,
            new google.maps.Point 0, 0,
            new google.maps.Point @width / 2, @height

    drawShadow: () ->
        size =
            width:  @width / 2
            height: @width / 2

        position =
            x: @width / 2 - size.width / 2
            y: @height - size.height

        center =
            x: position.x + size.width / 2
            y: position.y + size.height / 2

        gradient = @context.createRadialGradient(
            center.x,
            center.y,
            0,
            center.x,
            center.y,
            size.width / 2
        )
        gradient.addColorStop 0, 'rgba(0, 0, 0, 0.30)'
        gradient.addColorStop 1, 'rgba(0, 0, 0, 0)'

        @context.setTransform 1, 0, 0, 0.5, 0, 0
        @context.translate 0, @height + size.height / 2

        @context.fillStyle = gradient
        @context.fillRect position.x, position.y, size.width, size.height
        @context.fill()

        @context.closePath()
        @context.setTransform 1, 0, 0, 1, 0, 0

    drawPinShape: (x, y, width, height, fill, stroke) ->
        center =
            x: x + width / 2,
            y: x + height / 2

        arcPosition =
            y: y + height / 3

        @context.beginPath()

        # Draw the arc across the top of the shape
        @context.arc @center.x, y + height / 3, width / 2, Math.PI, 0, false

        # Draw the right-side line to the bottom middle
        @context.bezierCurveTo(
            x + width,
            arcPosition.y + height / 4,
            center.x + width / 3,
            center.y,
            center.x,
            y + height
        )

        # Draw the left side curve but start from the top left area
        @context.moveTo x, arcPosition.bottom
        @context.bezierCurveTo(
            x,
            arcPosition.y + height / 4,
            center.x - width / 3,
            center.y,
            center.y,
            y + height
        )

        # Do we want to fill the shape?
        if fill
            @context.fillStyle = fill
            @context.fill()

        # What about stroke?
        if stroke
            @context.strokeStyle = stroke
            @context.stroke()

    animateSize: (currentSize, minSize, maxSize) ->
        @minSize = minSize
        @maxSize = maxSize

        if @isGrown and currentSize <= @minSize
            @isGrown = false
            return

        if !@isGrown and size >= @maxSize
            @isGrown = true
            return

        newSize = if @isGrown then currentSize - 1 else currentSize + 1

        @width = newSize
        @height = newSize * 1.5

        requestAnimationFrame () =>
            this.animateSize(newSize, minSize, maxSize)

window.Atlas = Atlas