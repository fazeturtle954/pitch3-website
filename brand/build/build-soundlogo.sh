#!/usr/bin/env bash
# Extract the PITCH3 sound-logo from a real pitch recording.
# Default source: assets/live-abs-vid.mp4, the first pitch (~1.7s in source).
# Output window: 1.2s–2.5s of source → 1.3s clip with the POP at t=0.5s.
# That gives ~0.5s of windup/seam sound before the pop, then ~0.8s of decay.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # brand/
ROOT="$(cd "$DIR/.." && pwd)"
SRC="${1:-$ROOT/assets/live-abs-vid.mp4}"
START="${2:-1.68}"      # pop attack begins right here so it lands at the cut
DUR="${3:-1.3}"

OUT="$DIR/audio/pitch3-soundlogo.wav"
mkdir -p "$(dirname "$OUT")"

FADE_OUT_ST=$(awk "BEGIN{printf \"%.3f\", $DUR-0.3}")

ffmpeg -y -ss "$START" -i "$SRC" -t "$DUR" -vn \
  -af "aformat=sample_rates=48000:channel_layouts=stereo,afade=t=in:st=0:d=0.005,afade=t=out:st=${FADE_OUT_ST}:d=0.3" \
  -c:a pcm_s16le "$OUT"

echo "Wrote $OUT (pop ~0.5s into clip)"
