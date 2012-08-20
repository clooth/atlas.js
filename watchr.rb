watch( 'src/(.*)\.coffee' ) do |md|
    puts "Compiling coffeescript"
    filelist = [
        "src/jColour.coffee",
        "src/util.coffee",
        "src/canvas.coffee",
        "src/atlas.coffee"
    ]
    filelistString = filelist.join(" ")
    system("coffee -o . --join atlas.js --compile #{filelistString}")

    puts "Uglifying javascript"
    system("uglifyjs -o atlas.min.js atlas.js")

    puts "Updating docs..."
    system("docco src/#{md[1]}.coffee && git add docs")
end
