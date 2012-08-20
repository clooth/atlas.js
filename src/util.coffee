# Utilities to be used within Atlas

#### requestAnimationFrame polyfill
(() ->
    lastTime = 0
    vendors  = ['ms', 'moz', 'webkit', 'o']

    unless window.requestAnimationFrame
        for vendor in vendors
            window.requestAnimationFrame = window[vendor + 'RequestAnimationFrame']
            window.cancelAnimationFrame = window[vendor + 'CancelAnimationFrame'] || window[vendor + CancelRequestAnimationFrame]

    unless window.requestAnimationFrame
        window.requestAnimationFrame = (callback, element) ->
            currentTime = new Date().getTime()
            timeToCall = Math.max 0, 16 - (currentTime - lastTime)
            id = window.setTimeout(() ->
                callback(currentTime + timeToCall)
            , timeToCall)
            lastTime = currentTime + timeToCall
            id

    unless window.cancelAnimationFrame
        window.cancelAnimationFrame = (id) ->
            clearTimeout(id)
)()