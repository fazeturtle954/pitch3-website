#!/usr/bin/env bash
# Bake the PITCH3 outro onto a video:
#   1. logo fades in over the last 1.5s of YOUR footage (clear background)
#   2. logo is at full opacity at the cut, so it stays continuous (no re-fade)
#   3. hard cut to black, logo holds, then fades out
# Audio: the synth sound-logo (brand/audio/pitch3-soundlogo.wav) is placed so its
# riser leads in over the last 0.5s of footage and the impact lands ON the cut.
#
# Usage: stamp-outro.sh <input-video> [output-video]
# Output matches the input's width/height (designed for vertical reels).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # brand/
LOGO="$DIR/logo/pitch3-logo-outline.png"
SOUNDLOGO="$DIR/audio/pitch3-soundlogo.wav"

IN="${1:?usage: stamp-outro.sh <input-video> [output-video]}"
OUT="${2:-${IN%.*}-pitch3.mp4}"

[ -f "$SOUNDLOGO" ] || { echo "Missing $SOUNDLOGO — run build-soundlogo.sh first"; exit 1; }

probe() { ffprobe -v error "$@" -of default=nw=1:nk=1 "$IN" | head -1 | tr -d '[:space:]'; }
W=$(probe -select_streams v:0 -show_entries stream=width)
H=$(probe -select_streams v:0 -show_entries stream=height)
D=$(probe -show_entries format=duration)
HAS_AUDIO=$(probe -select_streams a -show_entries stream=index)

FPS=30
TAIL=2.0
LOGO_W=$(awk "BEGIN{printf \"%d\", $W*0.82}")
FADE_ST=$(awk "BEGIN{printf \"%.3f\", $D-1.5}")           # logo begins fading in here
TAIL_FADE_ST=$(awk "BEGIN{printf \"%.3f\", $TAIL-0.4}")   # tail logo fade-out start
TOTAL=$(awk "BEGIN{printf \"%.3f\", $D+$TAIL}")           # final duration
SL_DELAY=$(awk "BEGIN{printf \"%d\", $D*1000}")           # impact lands AT the cut (no lead-in)
FADE_AUD=$(awk "BEGIN{printf \"%.3f\", $D-0.05}")         # tiny footage-audio fade at the cut

# Footage audio (faded at the cut), or generated silence if the source has none.
if [ -n "$HAS_AUDIO" ]; then
  FA="[0:a]aformat=sample_rates=48000:channel_layouts=stereo,afade=t=out:st=${FADE_AUD}:d=0.05,apad=whole_dur=${TOTAL}[fa]"
else
  FA="anullsrc=r=48000:cl=stereo,atrim=0:${TOTAL}[fa]"
fi

ffmpeg -y \
  -i "$IN" \
  -loop 1 -t "$D" -i "$LOGO" \
  -f lavfi -t "$TAIL" -i "color=c=black:s=${W}x${H}:r=${FPS}" \
  -loop 1 -t "$TAIL" -i "$LOGO" \
  -i "$SOUNDLOGO" \
  -filter_complex "
    [0:v]scale=${W}:${H},fps=${FPS},setsar=1,format=yuv420p[fbase];
    [1:v]scale=${LOGO_W}:-1,format=rgba,fade=t=in:st=${FADE_ST}:d=1.0:alpha=1[lf];
    [fbase][lf]overlay=(W-w)/2:(H-h)/2,setsar=1,format=yuv420p[fv];
    [3:v]scale=w='${LOGO_W}*(1+0.55*exp(-14*t))':h='${LOGO_W}*(1+0.55*exp(-14*t))/3':eval=frame,format=rgba,fade=t=out:st=${TAIL_FADE_ST}:d=0.4:alpha=1[lt];
    [2:v][lt]overlay=x='(W-w)/2':y='(H-h)/2':eval=frame,setsar=1,format=yuv420p[tv];
    [fv][tv]concat=n=2:v=1:a=0[vo];
    ${FA};
    [4:a]aformat=sample_rates=48000:channel_layouts=stereo,adelay=${SL_DELAY}|${SL_DELAY}[sl];
    [fa][sl]amix=inputs=2:normalize=0:duration=longest,alimiter=limit=0.95,atrim=0:${TOTAL}[ao]
  " \
  -map "[vo]" -map "[ao]" \
  -c:v libx264 -pix_fmt yuv420p -r ${FPS} \
  -c:a aac -b:a 192k -movflags +faststart \
  "$OUT"

echo "Wrote $OUT"
