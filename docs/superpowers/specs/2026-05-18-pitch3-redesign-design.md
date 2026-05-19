# PITCH3 Website Redesign — Design Spec

**Date:** 2026-05-18
**Owner:** Michael (working on behalf of / with Coach Kyle Beard)
**Status:** v1 build — built autonomously while user was AFK, awaiting review

## Problem

Current site (`comforting-squirrel-954c92.netlify.app`) is a 61 MB single page that scrolls endlessly. Reads like a blog. Pictures don't fit their frames. Too much text. No clear path for a parent or athlete to find what they need.

## Goals

1. Clean, scannable homepage — parents and athletes can understand the offering in under 30 seconds.
2. Clear navigation: 4 pages, no clutter.
3. Add a Virtual Training section that mirrors the in-person tier structure.
4. Better media — slots ready for curated Instagram content from `@kb3_baseball`.

## Scope

**In scope (v1):**
- Static site: HTML/CSS/JS, no build step, no JS framework.
- 4 pages: Home, In-Person Training, Virtual Training, About.
- "Book a Free Call" CTA persists in nav and at section ends (links to `mailto:` placeholder for now).
- Responsive (mobile-first).
- Image/video slots clearly marked for content the user will provide.

**Out of scope (v1):**
- Booking system integration (Calendly etc.) — placeholder for now.
- CMS / admin UI — edits happen in HTML for now.
- Domain purchase / DNS — deploys to existing Netlify subdomain initially.
- Analytics, blog, e-commerce.
- Real Instagram media — placeholders until user provides files.

## Brand & Visual Direction

**Brand name:** PITCH3 (Instagram handle is KB3 but the program name stays PITCH3.)

**Style:** "C1 — Electric Royal" — selected by user. White + jet black + electric royal blue (`#0046ff`). Modern athletic, bold typography, lots of whitespace.

**Color tokens:**
- `--bg` — `#ffffff`
- `--ink` — `#0a0a0a`
- `--ink-soft` — `#4a4a4a`
- `--blue` — `#0046ff`
- `--blue-dark` — `#0033cc` (hover)
- `--rule` — `#e6e6e6`

**Typography:** System font stack (`-apple-system, system-ui, ...`). Headings: 900 weight, tight letter-spacing, often UPPERCASE for impact. Body: 400/500.

## Sitemap

```
/                   index.html       Home — overview, two paths (In-Person | Virtual), credentials
/in-person.html     In-Person        Full tier breakdown, weekly system, tech stack
/virtual.html       Virtual          Coming-soon framing, 5 tiers (incl. Strength Training)
/about.html         About            Coach Kyle bio, MLB picks developed, photo
```

CTA "Book a Free Call" persists in the nav as a button on every page.

## Page Designs

### Home (`index.html`)
1. **Top nav** — PITCH3 logo (left), nav links + Book button (right).
2. **Hero** — `5+ MPH GUARANTEED` chip → headline "Throw harder. Pitch smarter." → subline → primary CTA + secondary "See programs" link → hero image placeholder.
3. **Stats strip** — 3 numbers: `3` MLB First-Round Picks · `20+` Years Coaching · `4` Max Per Group.
4. **Two-path card section** — In-Person | Virtual. Big, clickable.
5. **Coach Kyle intro** — Photo + short bio + link to About.
6. **MLB picks strip** — 3 player cards with name, team, year.
7. **Final CTA** — "Ready to start?" + Book button.
8. **Footer** — IG link, email, copyright.

### In-Person (`in-person.html`)
1. Nav.
2. Page hero — "Train in Fort Lauderdale" + subline.
3. **4 tier cards** — Youth (10-13) / Elite (14-17) / College (18-22) / Pro. Each: included features bulleted, Book CTA.
4. **Weekly system** — Brief explanation: 7 days available, themed sessions, 1 makeup day.
5. **Tech stack** — PitchLab, NeuroTracker, kinematic assessment.
6. CTA + footer.

### Virtual (`virtual.html`)
1. Nav.
2. **Hero with "Now in Development" banner** — "Train from anywhere" + clear messaging that virtual programs are launching soon, inquire to get on the list.
3. **5 tier cards** — Youth Virtual / Elite Virtual / College Virtual / Pro Virtual / **Strength Training (Virtual)**. Each card explains what it'll include + "Inquire" CTA.
4. **How it'll work** — short bullets (video review, programming, check-ins).
5. CTA + footer.

### About (`about.html`)
1. Nav.
2. Hero photo of Kyle + headline "Coach Kyle Beard".
3. Bio (concise — pulled from existing site, trimmed).
4. **Credentials strip** — 4 chips (3 MLB First-Round Picks, 20+ Years, Head of Wahoos 7 yrs, MLB players trained).
5. **Pull quote** from Elih Villanueva.
6. CTA + footer.

## Responsive Behavior

- **Desktop (≥1024px):** 12-col layout, two-column hero, 4-up program grid.
- **Tablet (768-1023px):** 2-up program grid.
- **Mobile (<768px):** Single column. Nav collapses to hamburger toggle revealing vertical menu.

## Media Placeholders

Every image/video slot is marked in HTML with a `data-placeholder` attribute and a visible "SWAP IN: ..." label so user knows exactly what content to drop in:

```html
<div class="media-slot" data-placeholder="ig-hero-pitcher">
  SWAP IN: hero clip — pitcher in delivery from IG
</div>
```

## File Layout

```
pitch3-redesign/
├── index.html
├── in-person.html
├── virtual.html
├── about.html
├── styles.css
├── assets/                  (images user will provide)
├── docs/
│   └── superpowers/specs/2026-05-18-pitch3-redesign-design.md
├── SUMMARY.md               (next-steps note for user)
└── .gitignore
```

## Deferred Decisions (need user when back)

1. **Booking link** — Calendly? typeform? mailto: for now.
2. **Domain** — buy `pitch3.com`/`pitch3baseball.com` or stay on Netlify subdomain?
3. **Actual virtual program details** — pricing, frequency, what's included.
4. **Instagram media** — user said they'll provide files; I've left labeled slots.
5. **GitHub repo + Netlify deploy** — not done; user reviews first.
