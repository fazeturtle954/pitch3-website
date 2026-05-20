# Signup Funnel (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a working `/join` signup funnel on pitch3.com that takes payment via Stripe, collects intake info via Tally, lands every new client in a Google Sheet, and notifies the owner — so paying clients can sign themselves up without any manual coordination.

**Architecture:** Two new static HTML pages on the existing GitHub Pages site, plus four hosted SaaS tools (Stripe, Tally, Google Sheets, Google Drive). No backend code. Stripe-hosted Checkout for payment. Tally-hosted form embedded on success page. Google Sheet as v1 client database. URL parameters carry the customer's email and chosen plan from Stripe through to the Tally form for pre-fill and tagging.

**Tech Stack:** HTML, CSS, GitHub Pages (existing). Stripe Payment Links (no code). Tally form builder (no code). Google Sheets + Drive (no code).

**Roles:**
- **Dev tasks** — Claude writes the code, owner reviews
- **Owner tasks** — Michael (owner) clicks through SaaS dashboards; Claude provides step-by-step instructions

---

## File Structure (code changes)

```
pitch3-redesign/
├── index.html           MODIFY    add "Join Program" link to .nav-links
├── virtual.html         MODIFY    add "Join Program" nav link + change main CTA
├── in-person.html       MODIFY    add "Join Program" nav link
├── about.html           MODIFY    add "Join Program" nav link
├── styles.css           MODIFY    add .join-* and .faq-* styles
├── join.html            NEW       marketing + pricing page
└── join/
    └── success.html     NEW       post-payment intake landing page
```

External (no repo file changes):
- Stripe: two Products + two Payment Links
- Tally: one intake form
- Google: one Sheet ("PITCH3 Clients") + one Drive folder ("PITCH3 Content Library" scaffold for Phase 2)

---

## Task 1: Stripe — Create Products and Payment Links

**Owner task** — Michael does this in the Stripe Dashboard.

**Deliverable:** Two Payment Link URLs that Claude will paste into `join.html` in Task 6.

- [ ] **Step 1: Log into Stripe**

Go to https://dashboard.stripe.com. If you don't have an account, create one and complete account verification (takes ~10 min — they need your business info to enable real payments).

- [ ] **Step 2: Create the Monthly Product**

In the Stripe Dashboard:
1. Click `Product catalog` in the left sidebar (under "More" if not visible).
2. Click `+ Add product`.
3. Fill in:
   - **Name:** `PITCH3 Virtual — Monthly`
   - **Description:** `Personalized daily throwing, arm care, and strength programming from Coach Kyle. Cancel anytime.`
   - **Image:** (optional — upload your PITCH3 logo)
4. Under "Pricing":
   - **Pricing model:** `Standard pricing`
   - **Price:** `$150.00 USD`
   - **Billing period:** `Monthly`
   - **Type:** `Recurring`
5. Click `Add product`.

- [ ] **Step 3: Create the 12-Week Prepay Product**

Click `+ Add product` again:
1. **Name:** `PITCH3 Virtual — 12-Week Prepay`
2. **Description:** `12 weeks of personalized daily programming from Coach Kyle. One-time payment, $53 off vs paying monthly.`
3. Under "Pricing":
   - **Pricing model:** `Standard pricing`
   - **Price:** `$397.00 USD`
   - **Type:** `One-time`
4. Click `Add product`.

- [ ] **Step 4: Create the Monthly Payment Link**

1. From the Monthly product's page, click `+ Create payment link`.
2. Confirm the price selected is `$150/month`.
3. Under "After payment":
   - Select `Don't show confirmation page`
   - Select `Redirect customers to your website`
   - **Success URL:** `https://fazeturtle954.github.io/pitch3-website/join/success.html?email={CUSTOMER_EMAIL}&plan=monthly`
4. Under "Options":
   - Enable `Apple Pay and Google Pay`
   - Enable `Allow promotion codes` (for future discount campaigns)
   - Under "Subscriptions": enable `Allow customers to manage their subscriptions` (this turns on the Stripe Customer Portal so parents can self-cancel)
5. Click `Create link`.
6. **Copy the URL** — it looks like `https://buy.stripe.com/xxxxxxxxx`. Paste it somewhere you'll remember (a sticky note, a doc). You'll give it to Claude in Task 6.

- [ ] **Step 5: Create the 12-Week Prepay Payment Link**

Same process from the 12-Week Prepay product's page:
1. Click `+ Create payment link`.
2. Confirm price is `$397 one-time`.
3. Under "After payment" → "Redirect customers to your website":
   - **Success URL:** `https://fazeturtle954.github.io/pitch3-website/join/success.html?email={CUSTOMER_EMAIL}&plan=prepay`
4. Enable Apple Pay / Google Pay and promotion codes.
5. Click `Create link`.
6. **Copy this URL too** — note which is which (Monthly vs Prepay).

- [ ] **Step 6: Test both Payment Links in Stripe Test Mode**

1. Toggle the dashboard to `Test mode` (top right corner).
2. In test mode, the products won't exist — repeat Steps 2–5 in test mode to create test versions.
3. Open the test Monthly Payment Link in a browser.
4. Use Stripe's test card: `4242 4242 4242 4242`, any future expiry, any CVC, any ZIP.
5. Confirm you land on `https://fazeturtle954.github.io/pitch3-website/join/success.html?email=YOURTESTEMAIL&plan=monthly` (the URL parameters should be filled in).
6. Confirm the page loads (it'll be a 404 right now — we build it in Task 7. That's fine; we're only verifying the redirect URL is correct.)

**Expected:** Both live-mode Payment Link URLs in hand. The redirect goes to the right URL with `email` and `plan` parameters populated.

---

## Task 2: Google Sheet — Create the client database

**Owner task** — Michael does this in Google Sheets.

**Deliverable:** A shared Google Sheet with two tabs and proper column headers. Tally will write to it in Task 4.

- [ ] **Step 1: Create the spreadsheet**

1. Go to https://sheets.google.com.
2. Click `+ Blank spreadsheet`.
3. Rename the file (top-left, click "Untitled spreadsheet"): `PITCH3 Clients`.

- [ ] **Step 2: Set up the Clients tab**

1. Rename `Sheet1` to `Clients` (right-click the tab at the bottom → Rename).
2. In Row 1, paste these column headers (one per cell, left to right):

```
Status | Plan | Joined | Athlete Name | Date of Birth | Throwing Hand | Velo | Goal | Parent Name | Parent Email | Parent Phone | Video URL | Height | Weight | Team | Years Pitching | Injuries | Notes | Diagnosis Tags | Kyle Notes | Program Started | Last Email Sent
```

3. Make Row 1 bold and freeze it: `View` → `Freeze` → `1 row`.

- [ ] **Step 3: Add a Status dropdown**

1. Click on column A (the `Status` column header).
2. Select the entire column except the header (click cell A2, then Ctrl+Shift+Down).
3. `Data` → `Data validation` → `+ Add rule`.
4. **Criteria:** `Dropdown` with these options:
   - `Awaiting Diagnosis`
   - `Active`
   - `Paused`
   - `Cancelled`
5. Click `Done`.

- [ ] **Step 4: Create the Coach Inbox tab**

1. Click the `+` at the bottom-left to add a new tab.
2. Rename it `Coach Inbox`.
3. In Row 1, paste these headers:

```
Date | Client (Athlete Name) | Client's Message | AI Classification | Status | Kyle's Reply | Sent to Client
```

4. Make Row 1 bold and freeze it.
5. Add a dropdown to the `Status` column (column E):
   - `Awaiting Kyle`
   - `Replied`

- [ ] **Step 5: Verify the layout**

Expected:
- File named `PITCH3 Clients`
- Two tabs: `Clients` (22 columns) and `Coach Inbox` (7 columns)
- Row 1 frozen and bold on both tabs
- Status dropdowns work on both tabs (try clicking a cell in column A of `Clients` — it should show the dropdown arrow)

- [ ] **Step 6: Note the Sheet ID for Tally**

Look at the URL: `https://docs.google.com/spreadsheets/d/SHEET_ID/edit#gid=0`. Copy the `SHEET_ID` portion. You'll need it in Task 4.

---

## Task 3: Google Drive — Create the content library scaffold

**Owner task** — Michael does this in Google Drive.

**Deliverable:** A folder structure ready to receive content videos (recorded later, for Phase 2).

- [ ] **Step 1: Create the top-level folder**

1. Go to https://drive.google.com.
2. Click `+ New` → `Folder`.
3. Name it `PITCH3 Content Library`.

- [ ] **Step 2: Create subfolders**

Inside `PITCH3 Content Library`, create two folders:
- `programs`
- `videos`

Inside `programs`, create:
- `velocity`
- `command`
- `off-speed`
- `arm-care`

Inside `videos`, create:
- `arm-care`
- `velocity`
- `command`
- `strength`

- [ ] **Step 3: Verify**

The folder tree should look like:
```
PITCH3 Content Library/
├── programs/
│   ├── velocity/
│   ├── command/
│   ├── off-speed/
│   └── arm-care/
└── videos/
    ├── arm-care/
    ├── velocity/
    ├── command/
    └── strength/
```

No content yet — that's Phase 2 work. This is just the scaffold.

---

## Task 4: Tally — Build the intake form

**Owner task** — Michael does this in Tally.

**Deliverable:** A live Tally form URL + an embed snippet that Claude will paste into `success.html` in Task 7.

- [ ] **Step 1: Sign up for Tally**

1. Go to https://tally.so.
2. Sign up (free tier is sufficient — unlimited submissions).
3. From the dashboard, click `+ Create form`.
4. Choose `Start from scratch`.
5. Name the form: `PITCH3 Virtual Program Intake`.

- [ ] **Step 2: Add the form intro**

At the top of the form, add a `Heading` block:
- **Text:** `One last step — tell us about your pitcher`

Add a `Paragraph` block below:
- **Text:** `Coach Kyle reads this personally to build your son's first program. Required fields only take 2 minutes. The optional section helps us nail the program from day one.`

- [ ] **Step 3: Add a hidden field for the plan**

1. Click `+` to add a block → search for `Hidden field`.
2. **Label:** `Plan`
3. **Default value:** leave blank
4. **URL parameter name:** `plan`

(This captures the `?plan=monthly` or `?plan=prepay` query string from the Stripe redirect URL.)

- [ ] **Step 4: Add the Required Info section**

Add a `Section` block titled `Required Info`.

Inside the section, add these question blocks in order:

1. `Short answer` → **Label:** `Athlete's full name` → **Required:** yes
2. `Date` → **Label:** `Date of birth` → **Required:** yes
3. `Multiple choice` → **Label:** `Throwing hand` → **Options:** `Right`, `Left` → **Required:** yes
4. `Number` → **Label:** `Current fastball velocity (mph)` → **Required:** yes
5. `Dropdown` → **Label:** `Primary pitching goal` → **Options:**
   - `Add velocity`
   - `Sharpen command`
   - `Develop off-speed`
   - `All of the above`
   → **Required:** yes
6. `Short answer` → **Label:** `Parent/guardian name` → **Required:** yes
7. `Email` → **Label:** `Parent email` → **Required:** yes → Enable `Pre-fill from URL parameter`: `email`
8. `Phone number` → **Label:** `Parent phone` → **Required:** yes
9. `URL` → **Label:** `Link to a recent video of your son's delivery` → **Help text:** `Upload to YouTube as 'unlisted' and paste the link here. Front view AND side view if possible.` → **Required:** yes

- [ ] **Step 5: Add the Optional section**

Add a second `Section` block titled `Optional — Helps Coach Kyle Build a Better Program`.

Inside:

1. `Number` → **Label:** `Height (inches)` → **Required:** no
2. `Number` → **Label:** `Weight (lbs)` → **Required:** no
3. `Short answer` → **Label:** `Current team / school` → **Required:** no
4. `Multiple choice` → **Label:** `Years pitching` → **Options:** `Less than 1`, `1–3 years`, `3–5 years`, `5+ years` → **Required:** no
5. `Long answer` → **Label:** `Any current or past arm injuries?` → **Help text:** `Strongly recommend filling out so we don't overload an arm that's recovering.` → **Required:** no
6. `Long answer` → **Label:** `Anything else Coach Kyle should know?` → **Required:** no

- [ ] **Step 6: Configure the thank-you message**

Click `Settings` (top-right) → `Form behaviour` → `After submission`:
- Select `Show thank you screen`
- **Title:** `✓ You're in.`
- **Message:** `Coach Kyle is personally reviewing your video. You'll get your first daily program email within 24 hours.`

- [ ] **Step 7: Connect to Google Sheets**

Click `Integrations` (top tab) → search `Google Sheets` → click `Connect`.
- Sign into the Google account that owns the `PITCH3 Clients` sheet.
- **Spreadsheet:** select `PITCH3 Clients`
- **Sheet:** `Clients`
- **Map fields:** match each Tally field to the matching Sheet column. Critical mappings:
  - Tally `Plan` (hidden field) → Sheet `Plan`
  - Tally `Athlete's full name` → Sheet `Athlete Name`
  - Tally `Date of birth` → Sheet `Date of Birth`
  - Tally `Throwing hand` → Sheet `Throwing Hand`
  - Tally `Current fastball velocity` → Sheet `Velo`
  - Tally `Primary pitching goal` → Sheet `Goal`
  - Tally `Parent/guardian name` → Sheet `Parent Name`
  - Tally `Parent email` → Sheet `Parent Email`
  - Tally `Parent phone` → Sheet `Parent Phone`
  - Tally `Link to video` → Sheet `Video URL`
  - Tally `Height` → Sheet `Height`
  - Tally `Weight` → Sheet `Weight`
  - Tally `Current team / school` → Sheet `Team`
  - Tally `Years pitching` → Sheet `Years Pitching`
  - Tally `Arm injuries` → Sheet `Injuries`
  - Tally `Anything else` → Sheet `Notes`
- Also set:
  - Sheet `Status` → Static value `Awaiting Diagnosis`
  - Sheet `Joined` → Current date (Tally has a built-in `Submitted At` field for this)

Save the integration.

- [ ] **Step 8: Set up the parent welcome email**

Still in Integrations → click `+ Add integration` → search `Email` → click `Connect`.
- **Send to:** Use the value from the `Parent email` field (dynamic).
- **Subject:** `You're in! Welcome to PITCH3 Virtual`
- **Body:**

```
Hey [Parent Name],

You're officially in. Coach Kyle is personally reviewing your son's video right now.

Within the next 24 hours, you'll get your first daily program email — throwing, arm care, and strength work for the day, built specifically for what your son needs.

Reply to any program email anytime with questions. We respond within 24 hours (usually faster).

Welcome to PITCH3.

— Coach Kyle Beard
PITCH3 Pitching
```

(Use the dynamic `[Parent Name]` and `[Athlete's full name]` fields from Tally's variable picker rather than typing them literally.)

Save.

- [ ] **Step 9: Set up the team/owner notification email**

Add another Email integration:
- **Send to:** `kyle@pitch3.com` (or your preferred address — this can be changed later)
- **Subject:** `New PITCH3 client: [Athlete's full name]`
- **Body:**

```
New paying client just signed up.

Plan: [Plan]
Athlete: [Athlete's full name] (DOB: [Date of birth])
Throwing hand: [Throwing hand]
Current velo: [Current fastball velocity] mph
Goal: [Primary pitching goal]

Parent: [Parent/guardian name]
Email: [Parent email]
Phone: [Parent phone]

INTAKE VIDEO: [Link to video]

Watch the video, assign diagnosis tags in the sheet, flip Status to "Active":
[link to PITCH3 Clients sheet]
```

(Replace `[link to PITCH3 Clients sheet]` with the actual Google Sheets URL.)

Save.

- [ ] **Step 10: Publish the form**

1. Click `Publish` (top-right).
2. Copy the form's **public URL** (looks like `https://tally.so/r/xxxxxxx`).
3. Click `Share` → `Embed` → select `Standard embed` → copy the JavaScript embed snippet (the one that includes `<script>` and `data-tally-src`). Paste both somewhere accessible — Claude will use them in Task 7.

- [ ] **Step 11: Test the form yourself**

Open the public URL in an incognito window. Fill it out with fake data. Submit. Verify:
1. The thank-you message displays inline.
2. A new row appears in the Clients tab of the Google Sheet with all your fake data.
3. The Status column shows `Awaiting Diagnosis`.
4. The welcome email arrives at the parent email address (try a real one you control).
5. The owner-notification email arrives at `kyle@pitch3.com` (or whichever address you used).

If any of those fail, go back and fix the integration. Don't proceed until all 5 work.

---

## Task 5: Add pricing-card and FAQ styles to styles.css

**Dev task** — Claude writes the CSS.

**Files:**
- Modify: `pitch3-redesign/styles.css` (append at end)

- [ ] **Step 1: Append the new styles**

Add this block at the end of `styles.css`:

```css

/* ===== JOIN PAGE — pricing cards ===== */
.join-pricing {
  padding: 70px 0;
  border-bottom: 1px solid var(--rule);
}
.join-pricing-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
  max-width: 900px;
  margin: 0 auto;
}
.join-card {
  background: #fff;
  border: 1px solid var(--rule);
  border-radius: 14px;
  padding: 36px 32px;
  position: relative;
  display: flex;
  flex-direction: column;
  transition: border-color .15s, box-shadow .15s, transform .15s;
}
.join-card:hover {
  border-color: var(--sky);
  box-shadow: 0 18px 40px rgba(10, 23, 51, 0.10);
  transform: translateY(-2px);
}
.join-card-eyebrow {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 3px;
  color: var(--ink-soft);
  text-transform: uppercase;
  margin-bottom: 14px;
}
.join-card.featured {
  border: 2px solid var(--sky);
  background: linear-gradient(180deg, #ffffff 0%, var(--blue-tint) 100%);
}
.join-card.featured .join-card-eyebrow {
  color: var(--blue);
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
.join-card.featured .join-card-eyebrow::before {
  content: "★";
  color: var(--sky);
  font-size: 14px;
}
.join-card-price {
  font-size: 56px;
  font-weight: 900;
  color: var(--blue);
  letter-spacing: -3px;
  line-height: 1;
  margin-bottom: 4px;
}
.join-card-period {
  font-size: 15px;
  color: var(--ink-soft);
  font-weight: 600;
  margin-bottom: 18px;
}
.join-card-tagline {
  font-size: 14px;
  color: var(--ink-soft);
  margin-bottom: 28px;
  min-height: 40px;
}
.join-card .btn {
  width: 100%;
  justify-content: center;
  padding: 14px 18px;
  font-size: 15px;
}
.join-card.featured .btn {
  background: var(--blue);
}
.join-card.featured .btn:hover {
  background: var(--blue-dark);
}

@media (max-width: 720px) {
  .join-pricing-grid { grid-template-columns: 1fr; }
}

/* ===== JOIN PAGE — what's included ===== */
.join-included {
  padding: 70px 0;
  border-bottom: 1px solid var(--rule);
}
.join-included-list {
  max-width: 720px;
  margin: 0 auto;
  list-style: none;
  padding: 0;
}
.join-included-list li {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 14px 0;
  border-bottom: 1px solid var(--rule);
  font-size: 17px;
  color: var(--ink);
  font-weight: 600;
}
.join-included-list li::before {
  content: "✓";
  color: var(--sky);
  font-size: 22px;
  font-weight: 900;
  line-height: 1;
  flex-shrink: 0;
}

/* ===== JOIN PAGE — FAQ ===== */
.join-faq {
  padding: 70px 0;
  border-bottom: 1px solid var(--rule);
}
.faq-list {
  max-width: 760px;
  margin: 0 auto;
}
.faq-item {
  border-bottom: 1px solid var(--rule);
}
.faq-item summary {
  cursor: pointer;
  padding: 22px 0;
  font-size: 17px;
  font-weight: 700;
  color: var(--ink);
  list-style: none;
  position: relative;
  padding-right: 30px;
}
.faq-item summary::-webkit-details-marker { display: none; }
.faq-item summary::after {
  content: "+";
  position: absolute;
  right: 0;
  top: 22px;
  font-size: 24px;
  font-weight: 700;
  color: var(--sky);
  transition: transform .15s;
}
.faq-item[open] summary::after {
  transform: rotate(45deg);
}
.faq-item p {
  color: var(--ink-soft);
  font-size: 15px;
  line-height: 1.65;
  margin: 0 0 22px;
  padding-right: 30px;
}

/* ===== JOIN SUCCESS PAGE ===== */
.join-success-banner {
  background: var(--blue-tint);
  padding: 40px 0;
  border-bottom: 1px solid var(--rule);
  text-align: center;
}
.join-success-banner h1 {
  font-size: clamp(22px, 3vw, 32px);
  font-weight: 900;
  color: var(--blue);
  margin: 0 0 8px;
  letter-spacing: -1px;
}
.join-success-banner p {
  font-size: 15px;
  color: var(--ink-soft);
  margin: 0;
}
.join-form-wrap {
  padding: 50px 0 80px;
  max-width: 720px;
  margin: 0 auto;
}
```

- [ ] **Step 2: Commit**

```bash
git add styles.css
git commit -m "Add pricing-card, FAQ, and join-success styles for /join pages"
git push
```

---

## Task 6: Build `/join.html` — marketing & pricing page

**Dev task** — Claude writes the HTML.

**Prerequisite:** Owner has the two Stripe Payment Link URLs from Task 1, Step 6.

**Files:**
- Create: `pitch3-redesign/join.html`

- [ ] **Step 1: Get the Stripe Payment Link URLs from owner**

Owner pastes both URLs in chat:
- Monthly: `https://buy.stripe.com/...`
- 12-Week Prepay: `https://buy.stripe.com/...`

Claude pastes them into the HTML below in place of `STRIPE_MONTHLY_URL` and `STRIPE_PREPAY_URL`.

- [ ] **Step 2: Create the file**

Create `pitch3-redesign/join.html` with this exact content (replace the two STRIPE_ placeholders):

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Join the Virtual Program — PITCH3</title>
<meta name="description" content="Personalized daily throwing, arm care, and strength programming from Coach Kyle Beard — diagnosed personally, delivered every morning. $150/mo or $397 for 12 weeks.">
<link rel="stylesheet" href="styles.css">
</head>
<body>

<nav class="nav">
  <div class="nav-inner">
    <a href="index.html" class="brand">PITCH<span>3</span></a>
    <button class="nav-toggle" aria-label="Menu" onclick="document.querySelector('.nav-links').classList.toggle('open')">☰</button>
    <ul class="nav-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="in-person.html">In-Person</a></li>
      <li><a href="virtual.html">Virtual</a></li>
      <li><a href="about.html">About</a></li>
      <li><a href="join.html" class="active">Join Program</a></li>
      <li><a class="btn" href="mailto:kyle@pitch3.com?subject=Free%20Call%20Request">Book a Free Call</a></li>
    </ul>
  </div>
</nav>

<header class="hero">
  <div class="wrap hero-grid">
    <div>
      <span class="chip">PITCH3 VIRTUAL PROGRAM</span>
      <h1 class="h1">Daily coaching.<br>Built by Coach Kyle.<br><span class="accent">Delivered to your phone.</span></h1>
      <p class="lede">Personalized throwing, arm care, and strength programming — diagnosed by Coach Kyle himself, then sent to your son every morning. Reply with questions anytime. Built over 20 years at the pro level.</p>
      <div class="hero-ctas">
        <a class="btn" href="#pricing">See Pricing →</a>
        <a class="btn btn-ghost" href="mailto:kyle@pitch3.com?subject=Virtual%20Program%20Question">Ask a Question</a>
      </div>
    </div>
    <a class="media-link" href="https://www.instagram.com/kb3_baseball/" target="_blank" rel="noopener" data-ig-slot="join-hero">
      <img class="media wide fit" src="assets/hero-pitcher.jpg" alt="PITCH3 pitcher in delivery">
    </a>
  </div>
</header>

<section class="guarantee">
  <div class="wrap">
    <div class="guarantee-card">
      <div class="guarantee-stripe"></div>
      <div class="guarantee-body">
        <div class="guarantee-eyebrow"><span class="guarantee-seal">★</span> THE PITCH3 GUARANTEE</div>
        <div class="guarantee-row">
          <div class="guarantee-num">+5<span class="guarantee-unit">MPH</span></div>
          <div class="guarantee-text">
            <div class="guarantee-line">Your son adds at least 5 MPH to his fastball in 12 weeks — or his next month is free.</div>
            <div class="guarantee-sub">A written, no-fine-print promise from Coach Kyle Beard.</div>
          </div>
        </div>
        <div class="guarantee-checks">
          <span class="guarantee-check">No fine print</span>
          <span class="guarantee-check">No qualifiers</span>
          <span class="guarantee-check">No long-term contract</span>
        </div>
      </div>
    </div>
  </div>
</section>

<section id="pricing" class="join-pricing">
  <div class="wrap">
    <div class="section-eyebrow" style="text-align:center;">Choose Your Plan</div>
    <h2 class="section-title" style="text-align:center;">Start today.<br>First program email in 24 hours.</h2>
    <div class="join-pricing-grid" style="margin-top: 50px;">

      <div class="join-card">
        <div class="join-card-eyebrow">MONTHLY</div>
        <div class="join-card-price">$150<span style="font-size: 22px; color: var(--ink-soft); font-weight: 700;">/mo</span></div>
        <div class="join-card-period">Cancel anytime</div>
        <div class="join-card-tagline">Best if you want to try the program month-to-month before committing.</div>
        <a class="btn" href="STRIPE_MONTHLY_URL">Start Monthly →</a>
      </div>

      <div class="join-card featured">
        <div class="join-card-eyebrow">BEST VALUE</div>
        <div class="join-card-price">$397<span style="font-size: 22px; color: var(--ink-soft); font-weight: 700;"> / 12 wks</span></div>
        <div class="join-card-period">One payment · Save $53</div>
        <div class="join-card-tagline">Best for serious players ready to commit to a full 12-week development cycle.</div>
        <a class="btn" href="STRIPE_PREPAY_URL">Start 12 Weeks →</a>
      </div>

    </div>
  </div>
</section>

<section class="join-included">
  <div class="wrap">
    <div class="section-eyebrow" style="text-align:center;">What's Included</div>
    <h2 class="section-title" style="text-align:center;">Everything your son needs<br>to throw harder, every day.</h2>
    <ul class="join-included-list" style="margin-top: 40px;">
      <li>Personalized daily throwing program — diagnosed by Coach Kyle himself</li>
      <li>Arm care protocol built for your son's age and level</li>
      <li>Strength &amp; conditioning programming</li>
      <li>Daily program email — delivered every morning</li>
      <li>Ask questions anytime — answered in 24 hours or less</li>
      <li>Programming that adapts by season (off-season, in-season)</li>
    </ul>
  </div>
</section>

<section class="join-faq">
  <div class="wrap">
    <div class="section-eyebrow" style="text-align:center;">Common Questions</div>
    <h2 class="section-title" style="text-align:center;">Before you start.</h2>
    <div class="faq-list" style="margin-top: 40px;">

      <details class="faq-item">
        <summary>How old does my son need to be?</summary>
        <p>We work with pitchers from age 10 through pro. The program is built around what's appropriate for your son's age and stage of development — Coach Kyle assigns the right starting point after watching the intake video.</p>
      </details>

      <details class="faq-item">
        <summary>What if he's already on a throwing program?</summary>
        <p>Tell us about it in the intake form. Coach Kyle will either build around what you're doing or recommend transitioning — whichever serves your son better.</p>
      </details>

      <details class="faq-item">
        <summary>When does his program start?</summary>
        <p>Within 24 hours of you signing up. Coach Kyle personally reviews your son's intake video, builds the first program, and the first daily email lands the next morning.</p>
      </details>

      <details class="faq-item">
        <summary>Can I cancel the monthly plan?</summary>
        <p>Yes, anytime — self-service through your Stripe account. No phone calls, no retention pitches. Cancel and you won't be charged again.</p>
      </details>

      <details class="faq-item">
        <summary>What if he gets injured?</summary>
        <p>Email us right away. We'll pause the program at no cost while he heals, then build a return-to-throwing plan when he's ready. Your subscription pauses too — you don't pay for time you're not training.</p>
      </details>

      <details class="faq-item">
        <summary>Do you offer in-person training too?</summary>
        <p>Yes — see our <a href="in-person.html">In-Person page</a> for Fort Lauderdale-based small-group training.</p>
      </details>

    </div>
  </div>
</section>

<section class="final-cta">
  <div class="wrap">
    <h2>Not sure yet?</h2>
    <p>Book a free 15-minute call with Coach Kyle. Bring every question. No pressure.</p>
    <a class="btn" href="mailto:kyle@pitch3.com?subject=Free%20Call%20Request">Book a Free Call →</a>
  </div>
</section>

<footer class="footer">
  <div class="wrap footer-inner">
    <div>© <span id="yr">2026</span> PITCH3 · Fort Lauderdale, FL</div>
    <div>
      <a href="https://www.instagram.com/kb3_baseball/" target="_blank" rel="noopener">@kb3_baseball</a> ·
      <a href="mailto:kyle@pitch3.com">kyle@pitch3.com</a>
    </div>
  </div>
</footer>

<script>document.getElementById('yr').textContent = new Date().getFullYear();</script>
</body>
</html>
```

- [ ] **Step 3: Open in browser locally and verify**

Run (or owner runs):
```bash
open http://localhost:8000/join.html
```

Expected:
- Page loads with the navy/sky design language.
- Hero section displays with the headline.
- The +5 MPH guarantee card renders correctly (reused from index.html design).
- Two pricing cards display side-by-side. The "BEST VALUE" card has the sky-blue border and gradient.
- "What's Included" checklist renders with sky-blue checks.
- FAQ accordion items expand/collapse on click.
- "Start Monthly →" button navigates to the Stripe Monthly Payment Link.
- "Start 12 Weeks →" button navigates to the Stripe Prepay Payment Link.

- [ ] **Step 4: Commit**

```bash
git add join.html
git commit -m "Add /join.html marketing and pricing page with two Stripe Payment Links"
git push
```

---

## Task 7: Build `/join/success.html` — post-payment intake page

**Dev task** — Claude writes the HTML.

**Prerequisite:** Owner has the Tally embed snippet from Task 4, Step 10.

**Files:**
- Create: `pitch3-redesign/join/success.html`

- [ ] **Step 1: Get the Tally form ID from owner**

Owner pastes the Tally form embed snippet in chat. It looks like:

```html
<script async src="https://tally.so/widgets/embed.js"></script>
<div data-tally-src="https://tally.so/embed/XXXXXXX?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1" loading="lazy" width="100%" height="500"></div>
```

Claude extracts the form ID (the `XXXXXXX` portion) for use below.

- [ ] **Step 2: Create the directory and file**

Run:
```bash
mkdir -p join
```

Create `pitch3-redesign/join/success.html` with this exact content (replace `TALLY_FORM_ID` with the actual form ID from Step 1):

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Welcome to PITCH3 Virtual — One Last Step</title>
<meta name="description" content="Payment confirmed. Tell us about your pitcher so Coach Kyle can build the first program.">
<link rel="stylesheet" href="../styles.css">
</head>
<body>

<nav class="nav">
  <div class="nav-inner">
    <a href="../index.html" class="brand">PITCH<span>3</span></a>
    <ul class="nav-links">
      <li><a href="../index.html">Home</a></li>
      <li><a href="../in-person.html">In-Person</a></li>
      <li><a href="../virtual.html">Virtual</a></li>
      <li><a href="../about.html">About</a></li>
    </ul>
  </div>
</nav>

<section class="join-success-banner">
  <div class="wrap">
    <h1>✓ Payment confirmed.</h1>
    <p>One last step — tell us about your pitcher so Coach Kyle can build the first program.</p>
  </div>
</section>

<section class="join-form-wrap">
  <div class="wrap">
    <!-- Tally form: passes email and plan from URL params -->
    <iframe
      id="tally-embed"
      src=""
      width="100%"
      height="1200"
      frameborder="0"
      title="PITCH3 Virtual Program Intake"
      style="border: none; background: transparent;"
    ></iframe>
  </div>
</section>

<footer class="footer">
  <div class="wrap footer-inner">
    <div>© <span id="yr">2026</span> PITCH3 · Fort Lauderdale, FL</div>
    <div>
      <a href="mailto:kyle@pitch3.com">kyle@pitch3.com</a>
    </div>
  </div>
</footer>

<script>
  document.getElementById('yr').textContent = new Date().getFullYear();

  // Pass email and plan from the Stripe redirect URL through to Tally
  const params = new URLSearchParams(window.location.search);
  const email = params.get('email') || '';
  const plan = params.get('plan') || '';
  const tallyUrl = `https://tally.so/embed/TALLY_FORM_ID?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1&email=${encodeURIComponent(email)}&plan=${encodeURIComponent(plan)}`;
  document.getElementById('tally-embed').src = tallyUrl;
</script>

</body>
</html>
```

- [ ] **Step 3: Test locally with fake URL parameters**

Open in browser:
```
http://localhost:8000/join/success.html?email=test@example.com&plan=monthly
```

Expected:
- The success banner shows at the top.
- The Tally form loads in the iframe below.
- The form's "Parent email" field is pre-filled with `test@example.com`.
- (You won't see the hidden Plan field, but it's there.)

- [ ] **Step 4: Test the form submission flow**

Fill out the form with fake data and submit.

Expected:
- The Tally thank-you message displays inside the iframe ("✓ You're in. Coach Kyle is personally reviewing...").
- A new row appears in the `Clients` tab of the Google Sheet with all fields populated AND the `Plan` column shows `monthly`.
- The welcome email arrives at the fake parent email (use a real one you control).
- The owner notification email arrives at `kyle@pitch3.com`.

- [ ] **Step 5: Commit**

```bash
git add join/success.html
git commit -m "Add /join/success.html with Tally intake form embed and URL param prefill"
git push
```

---

## Task 8: Add "Join Program" nav link to all existing pages

**Dev task** — Claude modifies four files.

**Files:**
- Modify: `index.html`
- Modify: `in-person.html`
- Modify: `virtual.html`
- Modify: `about.html`

- [ ] **Step 1: Update index.html nav**

In `pitch3-redesign/index.html`, find the `.nav-links` block (around lines 16–22) and add a new `<li>` for Join Program. The block should become:

```html
    <ul class="nav-links">
      <li><a href="index.html" class="active">Home</a></li>
      <li><a href="in-person.html">In-Person</a></li>
      <li><a href="virtual.html">Virtual</a></li>
      <li><a href="about.html">About</a></li>
      <li><a href="join.html">Join Program</a></li>
      <li><a class="btn" href="mailto:kyle@pitch3.com?subject=Free%20Call%20Request">Book a Free Call</a></li>
    </ul>
```

- [ ] **Step 2: Update in-person.html nav**

Same edit — find the `.nav-links` block and add the Join Program `<li>` between About and the Book button. Don't change the `active` class — `in-person.html` should keep `class="active"` on its own link.

- [ ] **Step 3: Update virtual.html nav**

Same edit. Virtual page keeps its own `active` class.

- [ ] **Step 4: Update about.html nav**

Same edit. About page keeps its own `active` class.

- [ ] **Step 5: Verify each page in browser**

Open each page in turn:
```
http://localhost:8000/
http://localhost:8000/in-person.html
http://localhost:8000/virtual.html
http://localhost:8000/about.html
```

Expected on each page:
- Nav shows: Home | In-Person | Virtual | About | Join Program | [Book a Free Call button]
- Clicking "Join Program" navigates to `/join.html`
- The current page's link is still highlighted as `active`

- [ ] **Step 6: Commit**

```bash
git add index.html in-person.html virtual.html about.html
git commit -m "Add Join Program nav link to all existing pages"
git push
```

---

## Task 9: Update `virtual.html` primary CTA to point at `/join.html`

**Dev task** — Claude modifies one file.

**Files:**
- Modify: `pitch3-redesign/virtual.html` (the primary call-to-action button)

- [ ] **Step 1: Read virtual.html to find the existing CTA**

Read the file and identify the main CTA — likely a `<a class="btn" href="mailto:...">` somewhere in the hero or a primary section. There may be more than one CTA on the page.

- [ ] **Step 2: Update the primary hero CTA**

Change the primary CTA href from the mailto link to `/join.html`. Update the button text to `Join the Virtual Program →`.

Example change:
```html
<!-- BEFORE -->
<a class="btn" href="mailto:kyle@pitch3.com?subject=Virtual%20Inquiry">Get Started →</a>

<!-- AFTER -->
<a class="btn" href="join.html">Join the Virtual Program →</a>
```

Leave any secondary CTAs (like "Book a Free Call") untouched — those still go to mailto links.

- [ ] **Step 3: Verify in browser**

Open `http://localhost:8000/virtual.html` and click the updated CTA. Expected: navigates to `/join.html`.

- [ ] **Step 4: Commit**

```bash
git add virtual.html
git commit -m "Update virtual.html primary CTA to link to /join.html"
git push
```

---

## Task 10: End-to-end Phase 1 test (live mode)

**Joint task** — Owner runs a real test purchase, Claude debugs any failures.

**Prerequisite:** Tasks 1–9 complete. Stripe is in **Live mode** (not test mode) — flip the dashboard toggle.

**Important:** This test costs you real money ($150 or $397). You can immediately refund it via Stripe Dashboard.

- [ ] **Step 1: Wait for GitHub Pages deploy**

After the last commit pushed, wait ~60 seconds for GitHub Pages to redeploy. Confirm by visiting `https://fazeturtle954.github.io/pitch3-website/join.html` in an incognito window — the page should load.

- [ ] **Step 2: Run the Monthly purchase flow**

In an incognito window:
1. Visit `https://fazeturtle954.github.io/pitch3-website/join.html`.
2. Click `Start Monthly →`.
3. On the Stripe page, enter your real card info (or Apple Pay).
4. Complete the purchase.

Expected: Stripe redirects you to `https://fazeturtle954.github.io/pitch3-website/join/success.html?email=YOUREMAIL&plan=monthly`.

- [ ] **Step 3: Submit the intake form**

Fill out the embedded Tally form with real data (your own info or a fake test client).

Expected:
- Tally thank-you message displays.
- New row in `PITCH3 Clients` sheet with `Plan = monthly`, `Status = Awaiting Diagnosis`.
- Welcome email arrives at the parent email you used.
- Owner notification email arrives at `kyle@pitch3.com`.

- [ ] **Step 4: Refund the test charge**

In Stripe Dashboard:
1. Go to `Payments`.
2. Click the test payment you just made.
3. Click `Refund payment` → confirm.
4. ALSO cancel the subscription: `Customers` → find yourself → `Cancel subscription`.

- [ ] **Step 5: Repeat with the Prepay flow**

Same as Steps 2–4, but click `Start 12 Weeks →` instead. Expected `plan=prepay` in the URL parameter and `Plan = prepay` in the Sheet.

- [ ] **Step 6: Test on mobile**

Open `https://fazeturtle954.github.io/pitch3-website/join.html` on your iPhone (Safari) and on an Android device if possible. Verify:
- The pricing cards stack vertically on mobile.
- Both buttons work.
- Apple Pay shows as an option on iPhone (will require a real test purchase to fully verify).

- [ ] **Step 7: Test the failed-payment fallback**

In a new incognito window:
1. Visit `/join.html`, click `Start Monthly`.
2. On the Stripe page, enter a card that will be declined: `4000 0000 0000 0002`.
3. Try to complete the purchase.

Expected: Stripe shows an inline error. You can use a different card or close the page. No redirect to success.html happens.

---

## MILESTONE — Phase 1 Complete

After Task 10 passes, Phase 1 is live. You can soft-launch immediately:
- Tell 2–3 friendly clients about `pitch3.com/join`.
- Let them sign up.
- You manually email them programs using whatever workflow you've been using.
- This validates the funnel (people actually pay, the form actually submits, you get notified) before we invest in Phase 2 (AI delivery).

**Recommended:** Run Phase 1 for at least 1 week with real users before starting Phase 2. You'll catch UX issues you can't anticipate, and you'll learn what kinds of questions clients actually ask (which feeds into Phase 2's Claude prompts).

### Owner SOP while running Phase 1 manually

Until Phase 2 is built, daily owner responsibilities are:

1. **Each morning:** Check your email for any new "New PITCH3 client: [Athlete Name]" notifications from Tally. For each one:
   - Watch the intake video (5–10 min).
   - Open the `PITCH3 Clients` Google Sheet.
   - Fill in the `Diagnosis Tags` column (e.g. `hs, gain-weight, late-arm, fire-hips, arm-care`).
   - Type the first week's program in the `Kyle Notes` column or send it directly to the parent via email reply.
   - Flip `Status` to `Active`.

2. **Each evening:** Open Stripe Dashboard (`Payments` tab) and check for any payments in the last 24 hours that DON'T have a matching row in the `Clients` sheet. That means a parent paid but didn't complete the intake form. Manually email them via the address Stripe captured: "Hey, we got your payment — to get your program started, please fill out this quick form: [Tally form URL]."

3. **Each week:** Check the Stripe Customer Portal usage — any cancellations? Any failed renewals? Address as needed.

This is sustainable for the first ~10 clients. Past that, the daily diagnosis + manual programming becomes the bottleneck — which is exactly when Phase 2 (AI delivery) becomes high-value.

When ready, ask Claude to write the **Phase 2 plan** covering Make.com workflows, Claude API integration, content library setup, and AI reply routing.

---

## Self-Review Notes

This plan was self-reviewed against the spec on 2026-05-19:

**Spec coverage:** All Components 1–5 and 9–10 from the spec (signup funnel side) are covered. Components 6–8 (content library beyond scaffolding, Make.com scenarios, email infrastructure) are deferred to the Phase 2 plan, as agreed in the scope check above.

**Placeholders:** None. All Stripe URLs, Tally embed IDs, and Sheet URLs are explicitly handed off between owner and dev tasks with clear "paste in chat" handoffs. The `STRIPE_MONTHLY_URL`, `STRIPE_PREPAY_URL`, and `TALLY_FORM_ID` markers in Tasks 6 and 7 are clearly labeled placeholders for Claude to substitute at execution time using values the owner provides in chat.

**Type consistency:** N/A — no programming types. HTML class names match between the CSS in Task 5 and the markup in Tasks 6–7 (`.join-card`, `.join-card.featured`, `.join-included-list`, `.faq-item`, `.join-success-banner`, `.join-form-wrap`).

**Known limitations:**
- This plan assumes the GitHub Pages site is the production URL (`https://fazeturtle954.github.io/pitch3-website/`). If a custom domain like `pitch3.com` is added later, the Stripe redirect URLs in Task 1 must be updated.
- The plan does not include Google Analytics / conversion tracking on `/join.html` — noted as optional in the spec.
