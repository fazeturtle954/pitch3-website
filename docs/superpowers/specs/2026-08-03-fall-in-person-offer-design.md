# PITCH3 Fall In-Person Offer — Design Spec

**Date:** 2026-08-03
**Status:** Approved by Michael

## Goal

Revamp the in-person program for fall: a single **$500/month Unlimited** membership — unlimited in-person lessons, flexible scheduling 7 days a week (including weekends), small groups. Sell it directly on the site with a public price and a checkout button.

## Decisions (locked with Michael)

- **Offer:** $500/mo unlimited in-person lessons. Flexible timing, 7 days a week including weekends (NOT "mornings" — school is back in session).
- **Sales flow:** public price + Stripe checkout button on the page. "Book a Free Call" remains as a secondary path.
- **Stripe link:** does not exist yet. Button ships fully wired (styling + pixel tracking) but points to `mailto:kyle@pitch3.com` until Kyle creates the $500/mo subscription payment link. Swap spot marked with an HTML comment — one-line change. Nothing broken goes live.
- **Guarantee:** keep "+5 MPH in 12 weeks or next month free."
- **Group cap:** drop all "max 4 pitchers per group" language. Keep soft "small group" framing, no hard number.
- **Virtual program:** untouched. `join.html` / `virtual.html` stay exactly as-is ($150/mo, $397/12wks).
- **Fall framing:** "Fall Enrollment Open" — no specific start date, evergreen through the season.

## Scope

Two files change: `in-person.html` (revamp) and `index.html` (one path-card copy update). No CSS changes — the pricing card reuses the existing `join-card` classes from `join.html`. No new pages.

## `in-person.html` — section by section

1. **Meta description:** replace "Max 4 pitchers per group" copy → "Unlimited small-group in-person pitching training in Fort Lauderdale. $500/mo, flexible scheduling 7 days a week."
2. **Hero:** chip → "Fall Enrollment Open · Fort Lauderdale". Headline stays "Train on the field." Lede rewritten around unlimited lessons + flexible 7-day scheduling + small groups. CTAs: primary "Join Unlimited — $500/mo" → `#pricing` anchor; secondary "Book a Free Call" mailto.
3. **Pricing section (new, `id="pricing"`):** single card in `join-card` style. Eyebrow "UNLIMITED", price **$500/mo**. Bullets: unlimited in-person lessons · train any day, weekends included · scheduling flexed around school and games, handled personally · small-group sessions on the field · PitchLab velocity tracking every session. Guarantee line beneath the card. Button: "Join Unlimited →" with `PITCH3.track('InitiateCheckout', {currency:'USD', value:500})`, href = mailto placeholder + `<!-- SWAP: Stripe $500/mo payment link -->` comment.
4. **"How it works" section:** rewrite lede around the unlimited model (come as often as you want, times flex week to week, 7 days available). Stats row: **Unlimited** sessions · **7** days a week · **+5** MPH guarantee. Remove the "4 max per group" stat.
5. **Weekly-system + tech-stack sections:** keep as-is (proof/structure).
6. **Final CTA:** replace "Groups are capped at 4. Once it's full, it's full." → "Fall spots are limited. Small groups fill fast." CTAs: join button (`#pricing`) + free-call mailto.

## `index.html`

In-person path card `<p>` → "Unlimited lessons, 7 days a week. Fall enrollment open — $500/mo." Nothing else changes.

## Verification

- `grep -ri` the site for leftover "max 4" / "capped" / cap-era copy and stale schedule references.
- Open locally, click through all pages desktop + mobile-nav widths; confirm `#pricing` anchor, pixel wiring, and that virtual pages are untouched.
- Commit and push (auto-deploy to GitHub Pages per standing rule).

## Follow-up (post-launch, not in scope)

- Kyle creates the $500/mo Stripe subscription payment link → swap the placeholder href (one line).
