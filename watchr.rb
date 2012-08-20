watch( 'src/(.*)\.coffee' ) {
    |md| puts "Updating docs..."; system("docco src/#{md[1]}.coffee && git add docs")
}
