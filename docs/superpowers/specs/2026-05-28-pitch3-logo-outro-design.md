# PITCH3 Logo + Video Outro — Design

**Date:** 2026-05-28
**Status:** Approved (pending spec review)

## Goal

Create a PITCH3 brand logo and a reusable video outro the user can append to their
videos (primarily Instagram reels). The outro mimics a reference reel: the logo
appears, the screen cuts to black, and the logo holds for ~1 second with a short
sound. The user edits in CapCut, so deliverables must drop in without special tooling.

## Brand constraints

Pulled from the live site (`styles.css`):

- Background / dark base: navy `#0a1733` (`--blue`), darker `#050e22` (`--blue-dark`)
- Accent: sky blue `#4ea8ff` (`--sky`)
- Text: white `#ffffff`
- Wordmark on site: `PITCH` + `3`, the `3` in sky blue, heavy/condensed, uppercase

## Logo (approved via visual companion)

- Wordmark **PITCH3** set in **Anton** (condensed display face), italic via `skewX(-6deg)`.
- White letters with a **navy `#0a1733` outline** (so they stay legible over the mound).
- The **3** in sky blue `#4ea8ff` (also outlined).
- A short **velocity streak** (sky-blue gradient) to the left, conveying "throw harder."
- A **pitcher's mound** (sky-blue curved hill) under the word; the **top crossbar of the
  T doubles as the pitching rubber** sitting on the mound peak. No separate rubber shape.
- Reference implementation: the approved HTML/CSS lives in the brainstorm session
  (`logo-final.html`). Key values: font-size 72px baseline, word transform
  `translate(90px,77px) skewX(-6deg)`, navy text-shadow ring, mound path
  `M0 44 C50 44, 70 8, 120 8 C170 8, 190 44, 240 44 Z` (sky fill).

## Deliverables

1. **Static logo image files** (rendered from the approved HTML for pixel fidelity):
   - Transparent-background PNG, high-res (~2000px wide).
   - On-navy PNG and on-white PNG variants.
   - Purpose: overlay on any video in CapCut for the "logo over footage, no background"
     look; also usable for profile images, thumbnails, the website.

2. **Animated outro clip** (the primary append-to-end asset):
   - **Vertical 1080×1920** (reels) as primary; **1920×1080** horizontal as secondary.
   - H.264 MP4 with audio baked in (imports cleanly into CapCut).

## Outro animation structure (~2.5s, tunable)

| Time | Visual | Audio |
|------|--------|-------|
| 0.00–0.45s | Brand navy bg; wordmark flies in from left riding the velocity streak, slight scale-up | Whoosh swells |
| ~0.45s | Wordmark lands, T settles onto the mound rubber; small shake; mound pops in | Deep ~70Hz thud, fast decay |
| ~0.50s | Hard **cut to black** | (thud tail) |
| 0.50–2.20s | Logo holds dead-still on black ~1.5s | Low rumble tail fades |
| 2.20–2.50s | Quick fade out | Fade to silence |

## Sound design

Generated entirely with ffmpeg (no copyright risk):

- **Whoosh:** filtered noise (`anoisesrc`) through a sweeping band-pass + rising volume
  envelope, timed to the fly-in.
- **Thud:** low sine (~60–80Hz) with a fast decay envelope (and optional short click
  transient) at the impact moment.
- Mixed and faded to match the visual beats.

## Build pipeline

1. **Render logo PNG** — a standalone transparent-background HTML of the approved logo,
   screenshotted with **headless Chrome**
   (`--headless --screenshot --default-background-color=00000000`, high `--window-size`
   and device scale for resolution). Chrome is already installed; this guarantees the
   asset matches exactly what was approved (Anton font, navy outline, skew).
2. **Install ffmpeg** — `brew install ffmpeg` (one-time prerequisite; user approved).
3. **Animate + score** — ffmpeg takes the transparent PNG and:
   - composites the fly-in over navy using time-based `overlay` x/`fade` expressions,
   - performs the hard cut to black and the hold,
   - synthesizes whoosh + thud, mixes, and fades,
   - encodes vertical (primary) and horizontal MP4s.
4. Repeatable via a small shell script so timing/dimensions can be re-rendered on tweak.

## File layout

```
pitch3-redesign/
  brand/
    logo/
      pitch3-logo.png            # transparent
      pitch3-logo-navy.png
      pitch3-logo-white.png
      pitch3-logo.html           # source HTML used for rendering
    outro/
      pitch3-outro-vertical.mp4  # 1080x1920 (primary)
      pitch3-outro-horizontal.mp4# 1920x1080
    build/
      render-logo.sh             # Chrome screenshot
      build-outro.sh             # ffmpeg animation + audio
```

## Notes / open considerations

- This repo auto-pushes to GitHub on commit. Brand assets going public is fine; the
  MP4 files add repo weight. If undesired, keep `brand/outro/*.mp4` local (gitignore)
  and commit only the logo PNGs + build scripts.
- Timing, exact sound character, and whether to also produce a square (1080×1080) or an
  alpha-channel overlay version (ProRes/WebM) are easy follow-ups after the first render.

## Out of scope

- Original/melodic music composition (user will add their own music in-editor if desired;
  the outro ships with the synth whoosh+thud only).
- Full motion-graphics package (lower-thirds, intros) — this is the outro + logo only.
