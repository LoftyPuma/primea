# for file in assets/parallel_logos/*.svg; do
# TODO: think about setting `--current-color=<0xFF000000>` for each parallel
#   output_file="${file%.svg}.svg.vec"
# done
dart run vector_graphics_compiler --input-dir "assets/parallel_logos/" --out-dir "assets/parallel_logos/vec/"