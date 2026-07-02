#!/usr/bin/env bash
# Build the PITCH3 outro clip: black screen + logo holding, with a synth
# whoosh + thud (and resonant low tail). Append this to the end of a video;
# overlay the transparent logo PNG on your footage first for the "logo over
# the clip" beat, then this provides the cut-to-black hold.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # brand/
LOGO="$DIR/logo/pitch3-logo-outline.png"
OUT_DIR="$DIR/outro"
mkdir -p "$OUT_DIR"

# Geometry / timing
W=1080; H=1920; FPS=30; DUR=3.0
LOGO_W=900            # logo width within the frame
FADE_IN=0.2
FADE_OUT_ST=2.6
FADE_OUT_D=0.4

render() {
  local w=$1 h=$2 out=$3
  ffmpeg -y \
    -f lavfi -i "color=c=black:s=${w}x${h}:r=${FPS}:d=${DUR}" \
    -loop 1 -t ${DUR} -i "$LOGO" \
    -f lavfi -i "anoisesrc=d=0.4:color=pink:a=0.6:r=44100" \
    -f lavfi -i "sine=f=68:d=${DUR}:r=44100" \
    -f lavfi -i "sine=f=102:d=${DUR}:r=44100" \
    -filter_complex "
      [1:v]scale=${LOGO_W}:-1,format=rgba,
           fade=t=in:st=0:d=${FADE_IN}:alpha=1,
           fade=t=out:st=${FADE_OUT_ST}:d=${FADE_OUT_D}:alpha=1[logo];
      [0:v][logo]overlay=(W-w)/2:(H-h)/2:format=auto,format=yuv420p[v];
      [2:a]highpass=f=200,lowpass=f=8000,
           afade=t=in:st=0:d=0.06,afade=t=out:st=0.25:d=0.15,volume=0.7[wh];
      [3:a]volume=0.8,afade=t=in:st=0:d=0.005,afade=t=out:st=0.15:d=2.6,adelay=90|90[thud];
      [4:a]volume=0.25,afade=t=out:st=0.15:d=2.0,adelay=90|90[harm];
      [wh][thud][harm]amix=inputs=3:normalize=0:duration=longest,
           afade=t=out:st=${FADE_OUT_ST}:d=${FADE_OUT_D},alimiter=limit=0.9[a]
    " \
    -map "[v]" -map "[a]" \
    -c:v libx264 -pix_fmt yuv420p -r ${FPS} \
    -c:a aac -b:a 192k \
    -movflags +faststart -t ${DUR} \
    "$out"
}

render $W $H "$OUT_DIR/pitch3-outro-vertical.mp4"
echo "Wrote $OUT_DIR/pitch3-outro-vertical.mp4"
