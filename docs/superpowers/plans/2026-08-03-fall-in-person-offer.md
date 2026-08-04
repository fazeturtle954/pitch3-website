# Fall In-Person Offer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sell the fall in-person program as a single $500/mo Unlimited membership on `in-person.html`, with a matching teaser on the home page.

**Architecture:** Static 4-page site (plain HTML + one shared `styles.css`), deployed to GitHub Pages via git push to `main`. This plan revamps `in-person.html` (hero, new pricing section, how-it-works rewrite, final CTA) and touches one card in `index.html`. No CSS changes — the pricing section reuses `join-card`, `join-included-list`, and `guarantee-line` classes already in `styles.css` (verified they don't depend on join-page-specific parents).

**Tech Stack:** Plain HTML/CSS, Meta Pixel helper at `assets/pixel.js` (`PITCH3.track(event, params)` — safe no-op until a real pixel ID is set).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-08-03-fall-in-person-offer-design.md`
- Offer copy: **$500/mo Unlimited** — flexible timing 7 days a week, weekends included. NEVER say "mornings".
- Remove ALL hard group-cap language ("max 4", "capped at 4"). Soft "small group" framing is allowed.
- Keep guarantee: "+5 MPH in 12 weeks — or his next month is free."
- Checkout button: wired with `PITCH3.track('InitiateCheckout', {currency:'USD', value:500})`, href is a **mailto placeholder** until Kyle's Stripe link exists — marked with `<!-- SWAP: ... -->` comment. Never ship a dead `#` link.
- `join.html`, `virtual.html`, `join/` and all virtual pricing stay untouched.
- Repo rule: after every commit in this repo, immediately `git push` (auto-deploys GitHub Pages). No confirmation needed.
- Working dir: `/Users/michaelkass/pitch3-redesign`.

---

### Task 1: Revamp `in-person.html`

**Files:**
- Modify: `in-person.html` (meta line 7, hero lines 27–41, how-it-works lines 43–68, final CTA lines 114–120; insert new pricing section after the hero's closing `</header>`)

**Interfaces:**
- Produces: section `id="pricing"` on `in-person.html` (Task 2's home-page card links to `in-person.html`; hero CTA links to `#pricing`).
- Consumes: `PITCH3.track` from `assets/pixel.js` (already loaded in `<head>`); CSS classes `join-pricing`, `join-pricing-grid`, `join-card featured`, `join-card-eyebrow/-price/-period/-tagline`, `join-included-list`, `guarantee-line`, `btn`, `btn-ghost` from `styles.css`.

- [ ] **Step 1: Confirm the "before" state (failing check)**

Run: `grep -Eci 'max 4|capped at 4' in-person.html`
Expected: `2` (meta description + final CTA). If different, re-read the file before editing. (Use `-E` — macOS BSD grep doesn't support `\|` alternation in basic mode.)

- [ ] **Step 2: Replace the meta description (line 7)**

Old:
```html
<meta name="description" content="Small-group in-person pitching training in Fort Lauderdale. Youth through Pro. Max 4 pitchers per group.">
```
New:
```html
<meta name="description" content="Unlimited small-group in-person pitching training in Fort Lauderdale. $500/mo, flexible scheduling 7 days a week.">
```

- [ ] **Step 3: Replace the hero block (chip, lede, CTAs — lines 30–35)**

Old:
```html
      <span class="chip">Fort Lauderdale · South Florida</span>
      <h1 class="h1">Train on the<br><span class="accent">field.</span></h1>
      <p class="lede">Live mound work. Real velocity tracking. Small-group development built around your son — age, level, schedule, all dialed in personally. Get on the field by reaching out.</p>
      <div class="hero-ctas">
        <a class="btn" href="mailto:kyle@pitch3.com?subject=In-Person%20Inquiry">Book a Free Call →</a>
      </div>
```
New:
```html
      <span class="chip">Fall Enrollment Open · Fort Lauderdale</span>
      <h1 class="h1">Train on the<br><span class="accent">field.</span></h1>
      <p class="lede">Unlimited in-person lessons for one flat rate. Come to the field as often as you want — flexible times, 7 days a week, weekends included. Small groups, live coaching, real velocity tracking every session.</p>
      <div class="hero-ctas">
        <a class="btn" href="#pricing">Join Unlimited — $500/mo</a>
        <a class="btn btn-ghost" href="mailto:kyle@pitch3.com?subject=In-Person%20Inquiry">Book a Free Call →</a>
      </div>
```

- [ ] **Step 4: Insert the pricing section directly after `</header>` (after line 41)**

```html
<section id="pricing" class="join-pricing">
  <div class="wrap">
    <div class="section-eyebrow" style="text-align:center;">Fall Membership</div>
    <h2 class="section-title" style="text-align:center;">One membership.<br>Unlimited lessons.</h2>
    <div class="join-pricing-grid" style="margin-top: 50px; grid-template-columns: 1fr; max-width: 440px;">

      <div class="join-card featured">
        <div class="join-card-eyebrow">UNLIMITED</div>
        <div class="join-card-price">$500<span style="font-size: 26px; color: var(--ink); font-weight: 800; letter-spacing: -0.5px;">/mo</span></div>
        <div class="join-card-period">Cancel anytime</div>
        <div class="join-card-tagline">Unlimited lessons on the field, all fall. Train every day if you want — your rate never changes.</div>
        <!-- SWAP: replace this mailto href with Kyle's $500/mo Stripe subscription payment link when it exists -->
        <a class="btn" href="mailto:kyle@pitch3.com?subject=Join%20Unlimited%20%E2%80%94%20%24500%2Fmo" onclick="PITCH3.track('InitiateCheckout', {currency:'USD', value:500})">Join Unlimited →</a>
      </div>

    </div>
    <ul class="join-included-list" style="margin-top: 46px; max-width: 560px;">
      <li>Unlimited in-person lessons — no session counting</li>
      <li>Train any day of the week, weekends included</li>
      <li>Times flexed around school and games — scheduling handled personally</li>
      <li>Small-group sessions on the field</li>
      <li>PitchLab velocity &amp; pitch tracking every session</li>
    </ul>
    <p class="guarantee-line" style="text-align:center; margin-top: 36px; margin-bottom: 0;">+5 MPH in 12 weeks — or his next month is free.</p>
  </div>
</section>
```

- [ ] **Step 5: Rewrite the "How it works" section (lines 43–68)**

Old (whole section — headline, lede, stats, CTA):
```html
    <div class="section-eyebrow">How it works</div>
    <h2 class="section-title">No fixed levels.<br>Built around your son.</h2>
    <p class="section-lede">Every pitcher gets matched to the right group, schedule, and program — based on age, level, and what's actually available on the field that week. Field availability, rain dates, and group composition all get handled personally. Reach out and we'll figure out the right fit on the call.</p>

    <div class="stats" style="margin-top: 50px;">
      <div class="stat">
        <div class="stat-num">4</div>
        <div class="stat-label">Max pitchers per group</div>
      </div>
      <div class="stat">
        <div class="stat-num">1:1</div>
        <div class="stat-label">Scheduling handled personally</div>
      </div>
      <div class="stat">
        <div class="stat-num">+5</div>
        <div class="stat-label">MPH velocity guarantee</div>
      </div>
    </div>

    <div style="text-align:center; margin-top: 40px;">
      <a class="btn" href="mailto:kyle@pitch3.com?subject=In-Person%20Inquiry">Book a Free Call →</a>
    </div>
```
New:
```html
    <div class="section-eyebrow">How it works</div>
    <h2 class="section-title">Come as often<br>as you want.</h2>
    <p class="section-lede">One membership covers everything. Your son trains as many days as he wants — sessions run 7 days a week, and times flex around school, games, and rain dates. Group composition and scheduling get handled personally, so every session has the right pitchers on the field.</p>

    <div class="stats" style="margin-top: 50px;">
      <div class="stat">
        <div class="stat-num">∞</div>
        <div class="stat-label">Unlimited lessons included</div>
      </div>
      <div class="stat">
        <div class="stat-num">7</div>
        <div class="stat-label">Days a week available</div>
      </div>
      <div class="stat">
        <div class="stat-num">+5</div>
        <div class="stat-label">MPH velocity guarantee</div>
      </div>
    </div>

    <div style="text-align:center; margin-top: 40px;">
      <a class="btn" href="#pricing">Join Unlimited — $500/mo</a>
    </div>
```

- [ ] **Step 6: Replace the final CTA copy (lines 116–118)**

Old:
```html
    <h2>Lock in your spot.</h2>
    <p>Groups are capped at 4. Once it's full, it's full. Most families decide on the call.</p>
    <a class="btn" href="mailto:kyle@pitch3.com?subject=Free%20Call%20Request">Book a Free Call →</a>
```
New:
```html
    <h2>Lock in your fall spot.</h2>
    <p>Fall spots are limited — small groups fill fast. Join today or grab a free call first.</p>
    <a class="btn" href="#pricing">Join Unlimited — $500/mo</a>
```

Note: the `.final-cta` section is dark navy; its `.btn` styling already works there (same pattern as `index.html`'s final CTA). Keep the free-call path alive by leaving the nav's "Book a Free Call" button and hero secondary CTA as-is.

- [ ] **Step 7: Verify the "after" state**

Run: `grep -Eci 'max 4|capped|morning' in-person.html`
Expected: `0` (grep exits 1 when count is 0 — that's the pass state)
Run: `grep -c 'id="pricing"' in-person.html && grep -c 'value:500' in-person.html`
Expected: `1` and `1`
Run: `open in-person.html` — visually confirm: hero chip says Fall Enrollment Open, both hero buttons render side by side, pricing card shows $500/mo with star eyebrow, checklist renders with ✓ marks, guarantee line centered, stats show ∞/7/+5, final CTA button jumps to pricing. Narrow the window below 720px and check the card stacks and nav toggle works.

- [ ] **Step 8: Commit and push**

```bash
git add in-person.html
git commit -m "Revamp in-person page: \$500/mo unlimited fall membership"
git push
```

---

### Task 2: Update home-page path card + site-wide sweep

**Files:**
- Modify: `index.html:93`

**Interfaces:**
- Consumes: `in-person.html` with `id="pricing"` section (Task 1). The card already links to `in-person.html` — href unchanged.

- [ ] **Step 1: Replace the in-person path card copy (line 93)**

Old:
```html
        <p>Live mound work. Real velocity tracking. Small-group development on the field.</p>
```
New:
```html
        <p>Unlimited lessons, 7 days a week. Fall enrollment open — $500/mo.</p>
```

- [ ] **Step 2: Site-wide contradiction sweep**

Run: `grep -rniE 'max 4|capped' --include='*.html' .`
Expected: no matches (exit code 1). Do NOT grep site-wide for "morning" — `join.html` and `join/thanks.html` legitimately say "every morning" about the virtual program, which stays untouched.
Run: `git diff --stat`
Expected: only `index.html` modified (Task 1 already committed). Confirm `join.html`, `virtual.html`, `join/` untouched.
Run: `open index.html` — confirm the in-person card reads correctly and clicks through to the revamped page.

- [ ] **Step 3: Commit and push**

```bash
git add index.html
git commit -m "Home: tease \$500/mo unlimited fall offer on in-person card"
git push
```

- [ ] **Step 4: Verify live deploy**

Wait ~1–2 min for GitHub Pages, then:
Run: `curl -s https://fazeturtle954.github.io/pitch3-website/in-person.html | grep -c 'value:500'`
Expected: `1`
