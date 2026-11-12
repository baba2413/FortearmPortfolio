#!/usr/bin/env bash
# Build web-optimized assets from the original (git-ignored) media folder.
#
# Usage: scripts/build-assets.sh [SOURCE_MEDIA_DIR] [OUTPUT_DIR]
#   SOURCE_MEDIA_DIR  defaults to ./media
#   OUTPUT_DIR        defaults to ./assets
#
# Requires ffmpeg. media/demo/ is intentionally not used.
set -euo pipefail

SRC="${1:-media}"
OUT="${2:-assets}"
IMG_MAX=1920   # longest side for images, px
VIDEO_CRF=26   # H.264 quality (lower = better/larger)
VIDEO_H=1080   # output video height

mkdir -p "$OUT"

img() { # src dst
  echo "image: $1 -> $OUT/$2"
  ffmpeg -v error -y -i "$SRC/$1" \
    -vf "scale='if(gt(iw,ih),min($IMG_MAX,iw),-2)':'if(gt(iw,ih),-2,min($IMG_MAX,ih))'" \
    -q:v 4 "$OUT/$2"
}

vid() { # src base-name
  echo "video: $1 -> $OUT/$2.mp4 (+ poster)"
  ffmpeg -v error -y -i "$SRC/$1" \
    -vf "scale=-2:'min($VIDEO_H,ih)'" \
    -c:v libx264 -preset slow -crf "$VIDEO_CRF" -pix_fmt yuv420p \
    -an -movflags +faststart "$OUT/$2.mp4"
  ffmpeg -v error -y -ss 0.5 -i "$OUT/$2.mp4" -frames:v 1 -q:v 5 "$OUT/$2.jpg"
}

img "01_simulation.jpg"   "01_simulation.jpg"
img "02_hardware(1).jpg"  "02_hardware_1.jpg"
img "02_hardware(2).jpg"  "02_hardware_2.jpg"

vid "03_teleoperation.mov" "03_teleoperation"
vid "04_sim2real.mov"      "04_sim2real"
vid "05_vla.MOV"           "05_vla"

echo "done:"
du -h "$OUT"/*
