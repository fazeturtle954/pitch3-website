# PITCH3 Redesign — v1 Built

Hey — built this while you were AFK, per your "approve stuff and do as u recommend" instructions. Here's what's done and what you need to do.

## What's done

**Built a clean 4-page static site:**

- `index.html` — Home (hero, stats, two-path In-Person vs Virtual, coach intro, MLB picks, quote, CTA)
- `in-person.html` — All 4 program tiers (Youth / Elite / College / Pro), weekly system, tech stack
- `virtual.html` — "Now in Development · Inquire" framing + 5 tiers (Youth / Elite / College / Pro / **Strength Training**)
- `about.html` — Coach Kyle bio, credentials, MLB-player social proof, quote
- `styles.css` — Shared styles: white + black + electric royal blue (`#0046ff`), bold modern athletic
- `docs/superpowers/specs/2026-05-18-pitch3-redesign-design.md` — Full design spec

**Decisions I made on your behalf** (all reversible):
- Style: **C1 Electric Royal Blue** (the "1" you wanted me to hit)
- Booking link: `mailto:kyle@pitch3.com` placeholders everywhere — easy swap to Calendly later
- Domain: not bought; site will deploy to a Netlify subdomain for now
- Voice: trimmed-down version of the existing site's copy (kept Kyle's tone, cut blog-style fluff)

## How to preview right now

Double-click `index.html` in Finder. It'll open in your browser. Click around — all 4 pages work, nav is sticky, mobile-responsive.

## What I did NOT do (waiting for you)

1. **Did not push to GitHub.** Files are in a local git repo, uncommitted. You decide when to push.
2. **Did not deploy to Netlify.** You'll want to look at it first.
3. **Did not add real photos/videos.** Every image slot is a dashed-line placeholder labeled `SWAP IN: ...` describing what should go there.

## What you need to do when back

### 1. Look at the site
Open `index.html` in your browser. Click through all 4 pages. Tell me what's off and I'll fix it.

### 2. Drop in real Instagram media
Each placeholder is labeled. Here's the shopping list from `@kb3_baseball`:

| Placeholder | What to grab |
|---|---|
| `ig-hero-pitcher` (home) | Best pitcher-in-delivery photo or short clip — your hero asset |
| `ig-coach-kyle` (home) | Portrait of Coach Kyle, ideally action shot |
| `ig-facility-session` (in-person) | Best in-action / facility session photo |
| `ig-virtual-or-video` (virtual) | Remote training / video-call style asset (or a coaching breakdown clip) |
| `ig-coach-portrait` (about) | Portrait of Kyle — mound or field |
| `ig-with-mlb-player` (about) | Session photo with Sanabia or another MLB player |

Save each to `assets/` with descriptive names (e.g. `assets/hero-pitcher.jpg`), then I'll wire them in — or do it yourself by replacing each `<div class="media-slot">` with `<img src="assets/hero-pitcher.jpg" alt="...">`.

### 3. Confirm contact email
I used `kyle@pitch3.com` everywhere as a placeholder. Tell me the real email and I'll find-and-replace.

### 4. Decide on booking system
Calendly? Acuity? Email-only? Tell me which and I'll swap the mailto links for the real booking flow.

### 5. Decide on deploy
When ready, I can:
1. Create a GitHub repo (`pitch3-website` under your account)
2. Push the code
3. Connect to Netlify so it auto-deploys
4. Optionally point your existing Netlify subdomain (or a new one) at it

## File layout

```
pitch3-redesign/
├── index.html         home
├── in-person.html     in-person training (4 tiers)
├── virtual.html       virtual training (5 tiers incl. strength)
├── about.html         coach bio
├── styles.css         all styles
├── assets/            (empty — drop IG media here)
├── docs/superpowers/specs/2026-05-18-pitch3-redesign-design.md
└── SUMMARY.md         this file
```

Roughly 1,000 lines of clean code total. Compare to the existing 61 MB single page. 🙃
