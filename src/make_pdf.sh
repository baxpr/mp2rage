#!/usr/bin/env bash

cd "${out_dir}"

fsleyes render -of robust.png \
    --scene ortho --displaySpace world --size 1800 600 \
    --layout horizontal --hideCursor \
    mp2rage_robust.nii.gz

fsleyes render -of t1.png \
    --scene ortho --displaySpace world --size 1800 600 \
    --layout horizontal --hideCursor \
    quant_t1.nii.gz

fsleyes render -of wmn.png \
    --scene ortho --displaySpace world --size 1800 600 \
    --layout horizontal --hideCursor \
    white_matter_nulled.nii.gz

montage \
    -mode concatenate robust.png t1.png wmn.png \
    -tile 1x3 -quality 100 -background black -gravity center \
    -border 20 -bordercolor black page.png

convert -size 2600x3365 xc:white \
        -gravity center \( page.png -resize 2400x \) -composite \
        -gravity North -pointsize 48 -annotate +0+100 \
        "MP2RAGE ${label}" \
        -gravity SouthEast -pointsize 48 -annotate +100+100 "$(date)" \
        mp2rage.pdf
