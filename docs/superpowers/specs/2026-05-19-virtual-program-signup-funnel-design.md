# PITCH3 Virtual Program — Signup Funnel Design

**Date:** 2026-05-19
**Owner:** Michael Kass (PITCH3)
**Scope:** v1 launch — sell virtual program from pitch3.com, hand off to existing coach platform
**Estimated build time:** 4–5 calendar days (~10 hrs of dev, ~2 hrs/day of owner time)

---

## Problem

PITCH3 needs to start enrolling paying clients into its virtual coaching program. The website (pitch3.com) currently has no way for a parent or athlete to sign up — every conversion path leads to a "Book a Free 15-min Call" mailto link, which puts every new client through a manual sales call.

A small overseas team will deliver the actual day-to-day coaching (throwing programs, arm care, strength programming, messaging, video review). The owner (Coach Kyle) oversees but is not in the daily messaging loop.

## Non-goals

We are explicitly NOT building any of these for v1. They are noted as future work but out of scope:

- A native iOS or Android app
- A custom client portal on pitch3.com (athletes log in, see programs, etc.)
- In-app messaging between clients and coaches
- A program library on pitch3.com
- Video upload / review tooling on pitch3.com
- A Stripe-webhook-driven auto-provisioning system for the coach platform
- A custom owner-oversight dashboard
- A custom CRM

All of the above are deliberate v2 (or later) scope, dropped to fit the 1-week build budget and to validate demand before building infrastructure.

## Solution overview

Add two new pages to pitch3.com:

1. **`/join.html`** — marketing + pricing page where parents choose Monthly ($150/mo) or 12-Week Prepay ($397).
2. **`/join/success.html`** — post-payment landing page that embeds an intake form.

After payment + intake, three things fire automatically:
- Parent gets a welcome email
- A new row appears in a Google Sheet that serves as the v1 client database
- The overseas team gets a notification email

The overseas team then manually onboards the client into TrueCoach (or whichever coach platform is chosen post-launch — the decision is deferred and does not affect this build) within 24 hours.

No backend code is written. Stripe (hosted Checkout), Tally (hosted form), and Google Sheets handle every dynamic piece via their built-in integrations.

## Architecture

```
pitch3.com/join.html
  │
  │ [Start Monthly] or [Start 12 Weeks]
  ▼
Stripe Checkout (hosted by Stripe)
  │
  │ payment succeeds → redirect
  ▼
pitch3.com/join/success.html
  │
  │ embedded Tally form for intake
  ▼
Tally form submission
  │
  ├──▶ Auto-email to parent (welcome)
  ├──▶ Append row to "PITCH3 Clients" Google Sheet
  └──▶ Auto-email to team@pitch3.com (new client notification)
            │
            ▼
       Overseas team (manual, ≤24 hrs):
         1. Creates client in TrueCoach
         2. Assigns starter program by age + goal
         3. Replies to parent with login + Week 1 program
         4. Updates Google Sheet status to "Onboarded"
```

## Components

### Component 1: `/join.html` — marketing & pricing page

Reuses the existing site's design system (navy/sky palette, framed-card aesthetic, existing nav and footer). Sections top-to-bottom:

1. **Hero** — headline "Join the PITCH3 Virtual Program," sub-headline about daily programming, hero image of Coach Kyle or a pitcher in delivery.
2. **Pricing** — two cards side by side:
   - **Monthly** — $150/month, "Cancel anytime," CTA `[Start Monthly]`
   - **12-Week Prepay** — $397, badged "★ BEST VALUE — Save $53," CTA `[Start 12 Weeks]`
3. **What's Included** — checklist:
   - Personalized daily throwing program
   - Arm care protocol built for your son's age and level
   - Strength & conditioning programming
   - Direct messaging with the PITCH3 coaching team
   - Video form reviews — send a clip, get feedback
   - Programming adjusted by season (off-season, in-season)
4. **Guarantee** — reuse the existing `.guarantee` framed-card component from index.html (no new code).
5. **FAQ** — accordion or visible list answering:
   - How old does my son need to be?
   - What if he's already on a throwing program?
   - When does his program start?
   - Can I cancel the monthly plan?
   - What if he gets injured?
6. **Final CTA** — "Not sure yet? Book a free 15-min call with Kyle →" (mailto link, same as existing).

Each pricing card button links to a Stripe Payment Link URL (created in the Stripe dashboard during setup).

### Component 2: `/join/success.html` — post-payment intake page

Minimal page consisting of:
- Brief confirmation banner: "✓ Payment confirmed. One more step to get your son started."
- Embedded Tally form (using Tally's JS embed snippet for an inline embed — not iframe redirect — so the post-submit thank-you renders inside our page rather than navigating away). The page reads `email` and `plan` from the URL parameters set by Stripe's redirect and pre-fills the Tally form's email field and hidden `plan` field.
- Existing site nav and footer for consistency.

After Tally form submission, the embed displays an inline thank-you message:
> "✓ You're in. Coach Kyle's team will email you within 24 hours with your TrueCoach login and Week 1 program."

### Component 3: Tally intake form

Built in Tally's UI. Fields:

**Required (will not submit without):**
| Field | Type |
|---|---|
| Athlete's full name | text |
| Date of birth | date picker |
| Throwing hand | L / R radio |
| Current fastball velocity (mph) | number |
| Primary pitching goal | dropdown: Add velocity / Sharpen command / Develop off-speed / All of the above |
| Parent/guardian name | text |
| Parent email | email |
| Parent phone | tel |

**Optional (asked, skippable):**
| Field | Type |
|---|---|
| Height (inches) and weight (lbs) | two numbers |
| Current team / school | text |
| Years pitching | dropdown: <1 / 1–3 / 3–5 / 5+ |
| Any current or past arm injuries? | text area, with note: "Strongly recommend filling out so we don't overload an arm that's recovering." |
| Link to a recent video of your delivery | URL field, with note: "Upload to YouTube as 'unlisted' and paste the link here." |

Form layout: single page with two visually separated sections ("Required Info" / "Optional — Helps Us Build a Better Program") and a single `[Submit & Get Started]` button.

### Component 4: Stripe configuration

Two Products created in Stripe Dashboard:
- **PITCH3 Virtual — Monthly** — $150 USD recurring monthly subscription
- **PITCH3 Virtual — 12-Week Prepay** — $397 USD one-time payment

Each Product gets a Payment Link configured to:
- Redirect on success to `https://pitch3.com/join/success.html?email={CUSTOMER_EMAIL}&plan=monthly` (or `plan=prepay`). The `email` and `plan` URL parameters let the success page pre-fill the Tally form's email field and tag the row with the plan that was purchased.
- Enable Apple Pay and Google Pay
- For monthly: enable Stripe Customer Portal so parents can self-manage cancellations

### Component 5: Google Sheets client database

A single sheet named "PITCH3 Clients" shared with the owner and the overseas team. Columns:

| Status | Plan | Joined | Athlete Name | Date of Birth | Throwing Hand | Velo | Goal | Parent Name | Parent Email | Parent Phone | Height | Weight | Team | Years | Injuries | Video URL | TrueCoach Username | Coach Notes |

The `Status` column uses a dropdown with three values:
- `Awaiting Onboarding`
- `Onboarded`
- `Active`

Tally is configured to append a new row on every submission, populating all data columns. The team manually updates `Status`, `TrueCoach Username`, and `Coach Notes`.

### Component 6: Email automations

Three emails fire on submission, all configured inside Tally:

1. **Parent welcome email** — friendly "You're in. Coach Kyle's team will email you within 24 hours" message, signed by Coach Kyle.
2. **Team notification email** — sent to a shared inbox (e.g. `team@pitch3.com`), subject: "New PITCH3 client: [Athlete Name]," body containing all intake fields and the plan they purchased.
3. **Receipt** — sent by Stripe automatically, no configuration needed.

### Component 7: Nav updates across existing pages

A new "Join Program" link is added to the `.nav-links` list in:
- `index.html`
- `in-person.html`
- `virtual.html`
- `about.html`

Styled the same as existing nav links. The `virtual.html` page additionally gets its primary CTA updated from the existing mailto link to a `[Join the Virtual Program →]` button linking to `/join.html`.

### Component 8: Failed-onboarding fallback

The one edge case requiring active monitoring: parent pays via Stripe but never submits the Tally intake form (closes the browser, gets distracted).

Mitigation for v1:
- Stripe captures the parent's email at checkout.
- A simple Stripe → email forward (or daily Stripe dashboard check) flags any successful payment that doesn't have a matching Tally submission within 24 hours.
- The overseas team manually reaches out to the parent via the Stripe email to collect intake info another way.

This is acknowledged as a manual process for v1. A Stripe webhook + automated reconciliation is v2.

## Data flow

1. Parent lands on `/join.html`.
2. Clicks `[Start Monthly]` → redirected to Stripe Payment Link for the Monthly product.
3. Pays on Stripe Checkout.
4. Stripe redirects to `/join/success.html`.
5. Parent fills out embedded Tally intake form.
6. Submission triggers (in parallel):
   - Welcome email to parent (Tally)
   - Notification email to team (Tally)
   - New row in Google Sheet (Tally)
7. Tally displays thank-you message.
8. Overseas team reads notification email, opens Google Sheet, picks up the new row.
9. Team creates client in TrueCoach, assigns program, replies to parent with login.
10. Team updates Google Sheet `Status` to `Onboarded`.

## Error handling

| Error | Behavior |
|---|---|
| Stripe payment declined | Stripe shows error inline; parent retries or uses different card. No bounce back to our site. |
| Parent cancels Stripe Checkout | Bounced back to `/join.html` with a banner: "Your payment didn't go through. Try again or contact kyle@pitch3.com." |
| Tally form submission fails (network) | Tally's built-in retry + error UI handles this. Parent sees error, retries. |
| Parent paid but didn't submit intake within 24 hours | Overseas team manually emails parent (see Component 8). |
| Card declines on monthly renewal | Stripe auto-retries 3 times over a week, emails parent, suspends subscription if all retries fail. No work on our side. |
| Google Sheet write fails | Tally surfaces this in its admin. Owner gets notified, manually re-enters the row from the notification email. Rare edge case. |

## Testing plan

End-to-end test before launch:
1. Owner makes a real $150 monthly purchase using a real card (with a Stripe test discount code that refunds it).
2. Confirms Stripe redirect lands on `/join/success.html`.
3. Fills out the intake form as a fake parent.
4. Verifies the welcome email arrives within 1 minute.
5. Verifies the team notification email arrives within 1 minute.
6. Verifies a new row appears in the Google Sheet with all fields populated correctly.
7. Repeats the test for the 12-Week Prepay product.
8. Tests on iPhone Safari, Android Chrome, and desktop Chrome.
9. Tests Apple Pay and Google Pay flows on mobile.
10. Tests cancellation of monthly subscription via Stripe Customer Portal.

After launch, the first 3 real clients are soft-launched (told personally about the new flow) so any rough edges are caught with friendly users.

## Tooling cost summary

| Tool | Purpose | Cost |
|---|---|---|
| Stripe | Payments | 2.9% + $0.30/transaction, no monthly fee |
| Tally | Intake form (hosting + email + Sheets sync) | Free tier covers v1 |
| Google Sheets | Client database | Free (or included with Google Workspace) |
| Google Workspace | Team email | $6/user/month (likely already paid) |
| GitHub Pages | Static site hosting | Free |
| TrueCoach (or chosen platform) | Coaching delivery | ~$50/month for first 50 clients |

**Monthly running cost while filling first 20 clients:** ~$50–$100/month.

## Known limitations (v1 only)

These are accepted for v1 and become v2 priorities once the funnel is proving demand:

1. **Manual onboarding scales to ~50 clients.** Beyond that, a Stripe webhook → TrueCoach API integration is needed.
2. **Google Sheets as a database breaks down with 3+ concurrent overseas team editors** in different timezones. Migration to Airtable or a real database is straightforward when needed.
3. **No analytics dashboard.** Owner reads the Google Sheet directly to see status. Conversion analytics from /join can be added via a simple GA4 install if desired.
4. **No automated "are you still coming?" follow-up** for parents who start but don't finish the intake. Manual outreach only.

## File-level changes in the repo

```
pitch3-redesign/
├── index.html           MODIFY    add "Join Program" nav link
├── virtual.html         MODIFY    nav link + main CTA changed to /join.html
├── in-person.html       MODIFY    add "Join Program" nav link
├── about.html           MODIFY    add "Join Program" nav link
├── styles.css           MODIFY    add pricing-card + FAQ styles
├── join.html            NEW       full marketing + pricing page
└── join/
    └── success.html     NEW       post-payment intake page with Tally embed
```

## Build sequence

| Day | Work | Owner time |
|---|---|---|
| Day 1 | Dev builds `join.html` and pricing-card CSS in parallel with owner setting up Stripe Products and Payment Links | ~90 min Stripe setup + 30 min review |
| Day 2 | Dev builds `join/success.html` and wires Tally embed; owner builds the Tally form using the field list in Component 3 | ~60 min Tally + 30 min testing |
| Day 3 | Dev adds nav updates across existing pages, drafts welcome + notification email copy; owner sets up Google Sheet and connects Tally | ~30 min sheet setup + 30 min review of email copy |
| Day 4 | End-to-end testing on desktop, iOS, Android with real payment + real intake + real email + real Sheet write | ~2 hrs together |
| Day 5 | Polish, write team SOP, soft-launch to first real client | ~3 hrs |

## Open questions deferred to implementation

These do not need to be answered now but will come up during the build:

- Final selection of coach platform (TrueCoach vs TrainHeroic vs CoachNow). Owner to evaluate via free trials in parallel with the build. Does not block any code work.
- Exact copy for the parent welcome email (drafted by dev, approved by owner during Day 3).
- Exact copy for the FAQ answers on /join.html (owner provides the substance, dev writes the polished version).
- Whether to add Google Analytics for conversion tracking (recommended but not blocking).
