# PITCH3 Virtual Program — Signup Funnel + AI Coaching Delivery Design

**Date:** 2026-05-19
**Owner:** Michael Kass (PITCH3)
**Scope:** v1 launch — sell virtual program on pitch3.com, deliver coaching via Kyle-diagnosed + AI-delivered email workflow
**Estimated build time:** 10–14 calendar days (~25 hrs of dev, ~2 hrs/day of owner time + content recording in parallel)

---

## Problem

PITCH3 needs to start enrolling paying clients into its virtual coaching program without (a) building a native app, (b) paying an outsourced overseas messaging team, or (c) requiring Coach Kyle to personally respond to every client message every day.

The solution: Kyle is the diagnostic brain (~10 min per new client to watch their intake video and assign category tags), and an AI workflow handles everything else — daily program delivery, routine Q&A, escalating only safety-critical messages (pain, injury, program-change requests) back to Kyle.

This preserves the premium "Coach Kyle's program" positioning at the $150/mo price point while removing the daily messaging grind and eliminating recurring staff cost.

## Non-goals

We are explicitly NOT building any of these for v1. They are noted as future work but out of scope:

- A native iOS or Android app
- A custom client portal on pitch3.com (athletes log in, see programs, etc.)
- Integration with TrueCoach, TrainHeroic, or any other coach platform (decided against — their messaging is closed and we'd lose the AI benefits)
- AI-driven diagnosis from video (Kyle does diagnosis personally; AI only handles delivery and routine Q&A)
- SMS delivery (v1.1 — email only for v1)
- Real-time chat (everything is async email)
- Custom CRM, custom analytics dashboard, custom client portal

All of the above are deliberate later-version scope, dropped to fit the ~2-week build budget and to validate the AI-delivery model before investing in heavier infrastructure.

## Solution overview

A two-part system, both living in the existing pitch3.com static-site repo and a small set of connected SaaS tools. No custom backend code.

**Part 1 — Signup funnel (3–5 days)**

Two new pages on pitch3.com:
1. **`/join.html`** — marketing + pricing page where parents choose Monthly ($150/mo) or 12-Week Prepay ($397).
2. **`/join/success.html`** — post-payment landing page that embeds an intake form.

After payment + intake, automation writes the new client into a Google Sheet and pings Kyle to diagnose.

**Part 2 — AI coaching delivery (5–7 days)**

A Make.com workflow that:
- Waits for Kyle to fill in the diagnosis tags on a new client's row
- Picks the right videos and program text from a tagged Google Drive content library
- Sends the client a daily email at 6am with their program for the day
- Receives client email replies and routes them through Claude API:
  - Routine question → AI drafts and sends a reply in Kyle's voice
  - Pain / injury / program-change → flagged to a "Coach Inbox" tab in the Google Sheet + email to Kyle; AI sends auto-reply ("Coach Kyle will get back to you within 24 hours")
- Kyle answers escalated messages via a simple Sheet form; AI delivers the response

## Architecture

```
                                  pitch3.com/join.html
                                          │
                                          │ [Start Monthly] or [Start 12 Weeks]
                                          ▼
                              Stripe Checkout (hosted by Stripe)
                                          │
                                          │ payment succeeds → redirect with ?email + ?plan
                                          ▼
                              pitch3.com/join/success.html
                                          │
                                          │ embedded Tally intake form
                                          ▼
                              Tally form submission
                                          │
            ┌─────────────────────────────┼──────────────────────────────────┐
            ▼                             ▼                                  ▼
   Welcome email to parent       New row in Google Sheet              Email to Kyle:
   ("We're reviewing video,       (Status: Awaiting Diagnosis)         "New client needs
   program starts within 24 hrs")                                       diagnosis"
                                          │
                                          │ Kyle watches intake video,
                                          │ types tags into "Diagnosis" column
                                          │ (Status: Active)
                                          ▼
                              Make.com workflow detects new Active client:
                              ─────────────────────────────────────────────
                              1. Reads tags from Sheet
                              2. Calls Claude API to assemble personalized
                                 program text + select videos from
                                 Google Drive library
                              3. Schedules daily email send (6am client time)
                                          │
                                          ▼
                              Client receives daily email
                                          │
                                          │ replies to email
                                          ▼
                              Make.com routes reply to Claude API:
                              ─────────────────────────────────────────────
                              Classification: routine / safety-critical
                                          │
                          ┌───────────────┴────────────────┐
                          ▼                                ▼
                  Routine question                 Pain / injury / change
                          │                                │
                          ▼                                ▼
                AI drafts reply,               Flagged to "Coach Inbox"
                AI sends in Kyle's voice       tab in Google Sheet +
                                               email alert to Kyle.
                                               AI sends auto-reply:
                                               "Coach Kyle will respond
                                               within 24 hours."
                                                          │
                                                          ▼
                                                Kyle replies via Sheet form;
                                                AI delivers his message.
```

## Components

### Component 1: `/join.html` — marketing & pricing page

Reuses the existing site's design system (navy/sky palette, framed-card aesthetic, existing nav and footer). Sections top-to-bottom:

1. **Hero** — headline "Join the PITCH3 Virtual Program," sub-headline about daily personalized programming, hero image of Coach Kyle or a pitcher in delivery.
2. **Pricing** — two cards side by side:
   - **Monthly** — $150/month, "Cancel anytime," CTA `[Start Monthly]`
   - **12-Week Prepay** — $397, badged "★ BEST VALUE — Save $53," CTA `[Start 12 Weeks]`
3. **What's Included** — checklist:
   - Personalized daily throwing program — diagnosed by Coach Kyle himself
   - Arm care protocol built for your son's age and level
   - Strength & conditioning programming
   - Daily video coaching emails — sent every morning
   - Ask questions anytime — answered in 24 hours or less
   - Programming adjusted by season (off-season, in-season)
4. **Guarantee** — reuse the existing `.guarantee` framed-card component from index.html (no new code).
5. **FAQ** — accordion or visible list answering:
   - How old does my son need to be?
   - What if he's already on a throwing program?
   - When does his program start?
   - Can I cancel the monthly plan?
   - What if he gets injured?
   - Do you offer in-person training too? (link to /in-person.html)
6. **Final CTA** — "Not sure yet? Book a free 15-min call with Kyle →" (mailto link, same as existing).

Each pricing card button links to a Stripe Payment Link URL (created in the Stripe dashboard during setup).

### Component 2: `/join/success.html` — post-payment intake page

Minimal page consisting of:
- Brief confirmation banner: "✓ Payment confirmed. One more step to get your son started."
- Embedded Tally form (using Tally's JS embed snippet for an inline embed — not iframe redirect — so the post-submit thank-you renders inside our page rather than navigating away). The page reads `email` and `plan` from the URL parameters set by Stripe's redirect and pre-fills the Tally form's email field and hidden `plan` field.
- Existing site nav and footer for consistency.

After Tally form submission, the embed displays an inline thank-you message:
> "✓ You're in. Coach Kyle is personally reviewing your video. You'll get your first daily program email within 24 hours."

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
| **Link to a recent video of your delivery** (now required — Kyle needs it to diagnose) | URL field, with note: "Upload to YouTube as 'unlisted' and paste the link here. Both a front view and a side view if possible." |

**Optional (asked, skippable):**
| Field | Type |
|---|---|
| Height (inches) and weight (lbs) | two numbers |
| Current team / school | text |
| Years pitching | dropdown: <1 / 1–3 / 3–5 / 5+ |
| Any current or past arm injuries? | text area, with note: "Strongly recommend filling out so we don't overload an arm that's recovering." |
| Anything else Kyle should know? | text area |

Note: video link is upgraded from optional to **required** because Kyle's diagnosis is now central to the workflow. Without a video, there's no way to assign meaningful tags.

Form layout: single page with two visually separated sections ("Required Info" / "Optional — Helps Coach Kyle Build a Better Program") and a single `[Submit & Get Started]` button.

### Component 4: Stripe configuration

Two Products created in Stripe Dashboard:
- **PITCH3 Virtual — Monthly** — $150 USD recurring monthly subscription
- **PITCH3 Virtual — 12-Week Prepay** — $397 USD one-time payment

Each Product gets a Payment Link configured to:
- Redirect on success to `https://pitch3.com/join/success.html?email={CUSTOMER_EMAIL}&plan=monthly` (or `plan=prepay`). The `email` and `plan` URL parameters let the success page pre-fill the Tally form's email field and tag the row with the plan that was purchased.
- Enable Apple Pay and Google Pay
- For monthly: enable Stripe Customer Portal so parents can self-manage cancellations

### Component 5: Google Sheets client database

A single Google Sheet named "PITCH3 Clients" shared with Kyle. Two tabs:

**Tab 1: Clients**

| Column | Type | Who fills |
|---|---|---|
| Status | Dropdown: `Awaiting Diagnosis` / `Active` / `Paused` / `Cancelled` | Auto (Tally) → Kyle → Make.com |
| Plan | Text: `Monthly` or `Prepay` | Auto (Tally) |
| Joined | Date | Auto (Tally) |
| Athlete Name | Text | Auto (Tally) |
| Date of Birth | Date | Auto (Tally) |
| Throwing Hand | L/R | Auto (Tally) |
| Velo | Number | Auto (Tally) |
| Goal | Text | Auto (Tally) |
| Parent Name | Text | Auto (Tally) |
| Parent Email | Email | Auto (Tally) |
| Parent Phone | Phone | Auto (Tally) |
| Video URL | URL | Auto (Tally) |
| Height / Weight | Numbers | Auto (Tally) |
| Team / School | Text | Auto (Tally) |
| Years Pitching | Text | Auto (Tally) |
| Injuries | Text | Auto (Tally) |
| Notes | Text | Auto (Tally) |
| **Diagnosis Tags** | Text (comma-separated, e.g. "HS, gain-weight, late-arm, fire-hips, arm-care") | **Kyle** |
| Kyle Notes | Text (private coaching notes) | Kyle |
| Program Started | Date | Auto (Make.com) |
| Last Email Sent | Date | Auto (Make.com) |

**Tab 2: Coach Inbox**

| Column | Filled by |
|---|---|
| Date | Auto |
| Client (Athlete Name) | Auto |
| Client's Message | Auto (forwarded from email) |
| AI Classification | Auto (Claude API: `pain` / `injury` / `program-change` / `personal`) |
| Status | Dropdown: `Awaiting Kyle` / `Replied` |
| Kyle's Reply | Kyle types here |
| Sent to Client | Date (auto when Make.com sends) |

Kyle reviews this tab daily/weekly, types replies into the "Kyle's Reply" column, marks status `Replied`, and Make.com automatically formats and sends the reply to the client.

### Component 6: Content library (Google Drive)

A shared Google Drive folder named "PITCH3 Content Library" with the following structure:

```
PITCH3 Content Library/
├── programs/                    ← Program templates (text/markdown)
│   ├── velocity/
│   │   ├── hs-gain-weight.md
│   │   ├── hs-maintain.md
│   │   └── youth-foundation.md
│   ├── command/
│   ├── off-speed/
│   └── arm-care/
└── videos/                      ← Drill demonstration videos
    ├── arm-care/
    │   ├── j-band-warmup.mp4
    │   ├── shoulder-tube.mp4
    │   └── (etc.)
    ├── velocity/
    │   ├── late-arm-drill.mp4
    │   ├── hip-fire-drill.mp4
    │   └── (etc.)
    ├── command/
    └── strength/
```

**Tag conventions** (used in both filenames/folders and in the Sheet's "Diagnosis Tags" column):

| Category | Example tags |
|---|---|
| Level | `youth` / `middle-school` / `hs` / `college` / `pro` |
| Body goal | `gain-weight` / `lean-out` / `maintain` |
| Mechanical issue | `late-arm` / `early-arm` / `slow-hips` / `fire-hips` / `glove-side-collapse` / `(others Kyle adds)` |
| Focus | `velocity` / `command` / `off-speed` / `arm-care` / `strength` |

Each video file is named with the tags it addresses (e.g. `hip-fire-drill_velocity_fire-hips_hs.mp4`). Each program template lists which drill videos to include for which day of the week.

**v1 starter library:** ~20–30 videos and ~10 program templates, recorded by Kyle in the first weekend. The library grows weekly as Kyle records new content. Make.com passes the library's tag index plus the client's diagnosis tags to the Claude API, which selects the matching content and assembles the daily email (see Component 7, Scenario B).

### Component 7: Make.com AI workflow

Three Make.com scenarios (workflows):

**Scenario A: New Client Diagnosis Alert**
- Trigger: New row added to "Clients" tab (from Tally)
- Action: Send email to Kyle — "New client awaiting diagnosis: [Athlete Name]. Video link: [URL]. Click here to open Sheet: [link]."

**Scenario B: Daily Program Send**
- Trigger: Runs daily at 5:30am US Eastern time (PITCH3's home time zone). Clients in other zones receive the email at the local equivalent. v1.1 will add a per-client timezone field captured at intake.
- For each row in "Clients" tab where Status = `Active`:
  - Read Diagnosis Tags
  - Determine today's program (day-of-week from Program Started date, e.g. Day 12 = mid-week-2 of program)
  - Call Claude API: "Given these tags [X], today is Day [N] of program, pick the appropriate program template and drill videos from this library [Drive folder index]. Format as a friendly email in Coach Kyle's voice."
  - Send email to parent + athlete with embedded video links
  - Update "Last Email Sent" column

**Scenario C: Incoming Reply Routing**
- Trigger: New email received at `programs@pitch3.com`
- Action:
  - Match sender email to a client row in "Clients" tab
  - Call Claude API with system prompt: "Classify this client message as: `routine` (clarification about today's drill, schedule, etc.) OR `pain` / `injury` / `program-change` / `personal`. If routine, draft a reply in Kyle's voice — supportive, concise, no medical advice. If anything else, return classification only."
  - If routine: AI sends reply directly to client
  - If escalated: add row to "Coach Inbox" tab with classification, send Kyle an email alert, send client an auto-reply: "Coach Kyle will get back to you within 24 hours."
  - Separately: when Kyle fills in "Kyle's Reply" column and status changes to `Replied`, a fourth small scenario sends Kyle's reply to the client formatted as an email.

**Safety guardrails enforced in Claude API system prompt:**
- AI never gives medical advice
- AI never recommends pushing through pain
- AI never modifies a client's program structure
- AI never sets velocity targets or volume increases
- ANY message containing pain/injury/medical terms is escalated regardless of AI classification confidence
- A keyword list (`pain`, `hurt`, `injury`, `swollen`, `tight`, `clicking`, `ER`, `doctor`, etc.) forces escalation as a backstop

### Component 8: Email infrastructure

- **Sending email:** Gmail account (`programs@pitch3.com`) authenticated to Make.com. All daily program emails and AI replies sent from this address.
- **Receiving email:** Same `programs@pitch3.com` inbox; Make.com polls for new messages every 5 minutes.
- **Parent welcome email:** Sent by Tally on form submission (configured in Tally's email settings).
- **Stripe receipt:** Sent by Stripe automatically.

### Component 9: Nav updates across existing pages

A new "Join Program" link is added to the `.nav-links` list in:
- `index.html`
- `in-person.html`
- `virtual.html`
- `about.html`

Styled the same as existing nav links. The `virtual.html` page additionally gets its primary CTA updated from the existing mailto link to a `[Join the Virtual Program →]` button linking to `/join.html`.

### Component 10: Failed-onboarding fallback

The one edge case requiring active monitoring: parent pays via Stripe but never submits the Tally intake form (closes the browser, gets distracted).

Mitigation for v1:
- Stripe captures the parent's email at checkout.
- A simple daily Stripe-dashboard check (or a Make.com scenario polling Stripe) flags any successful payment that doesn't have a matching Tally submission within 24 hours.
- Kyle manually reaches out to the parent via the Stripe email to collect intake info another way.

This is acknowledged as a manual process for v1.

## Data flow

1. Parent lands on `/join.html`.
2. Clicks `[Start Monthly]` → redirected to Stripe Payment Link.
3. Pays on Stripe Checkout.
4. Stripe redirects to `/join/success.html?email=...&plan=monthly`.
5. Parent fills out embedded Tally intake form (including the now-required intake video URL).
6. On submission, in parallel:
   - Tally sends welcome email to parent ("Coach Kyle is reviewing your video...")
   - Tally appends a row to the Clients tab with Status = `Awaiting Diagnosis`
   - Make.com Scenario A sends diagnosis-alert email to Kyle
7. Kyle (within 24 hours):
   - Watches the intake video (5–10 min)
   - Types comma-separated tags into the Diagnosis Tags column
   - Changes Status to `Active`
8. Make.com Scenario B (next 5:30am) detects the Active client, calls Claude API to assemble program, sends daily program email.
9. Daily thereafter: Scenario B sends a fresh program email at 5:30am.
10. When client replies: Scenario C routes via Claude API — either auto-replies (routine) or escalates to Kyle (safety/personal).
11. When Kyle replies via Sheet form: AI delivers his response to the client.

## Error handling

| Error | Behavior |
|---|---|
| Stripe payment declined | Stripe shows error inline; parent retries. |
| Parent cancels Stripe Checkout | Bounced back to `/join.html` with banner: "Your payment didn't go through. Try again or contact kyle@pitch3.com." |
| Tally form submission fails (network) | Tally's built-in retry handles it. |
| Parent paid but didn't submit intake within 24 hrs | Kyle manually emails parent (Component 10). |
| Card declines on monthly renewal | Stripe auto-retries 3 times, emails parent, suspends if all fail. No work on our side. |
| Make.com scenario fails (API down, etc.) | Make.com sends Kyle an alert; he can manually email the client's daily program from a template while the issue is fixed. |
| Claude API returns nonsense / unhelpful reply | Worst-case for routine messages is a polite-but-unhelpful AI reply. Kyle can manually re-respond. For escalated messages, Claude only does classification, not content — so failure mode is "everything escalates to Kyle" (safe). |
| Client emails with a safety issue but AI misclassifies as routine | The hard-coded keyword backstop (`pain`, `hurt`, etc.) forces escalation regardless of AI judgment. |
| Kyle is on vacation / can't diagnose for 3 days | Auto-email to parent on day 2: "Apologies — Coach Kyle is reviewing a high volume of new intakes. Your program will start within 24 hours." |
| Client wants to cancel | Monthly: self-service via Stripe Customer Portal. Prepay: emails programs@pitch3.com → escalated to Kyle → manual refund via Stripe Dashboard if applicable. |

## Testing plan

End-to-end test before launch:
1. Owner makes a real $150 monthly purchase using a real card (with a Stripe discount code that refunds it).
2. Confirms Stripe redirect lands on `/join/success.html` with email and plan pre-filled in the Tally form.
3. Fills out the intake form as a fake parent (including a real video link).
4. Verifies the welcome email arrives within 1 minute.
5. Verifies a new row appears in the Google Sheet with all fields populated.
6. Verifies Kyle gets the diagnosis-alert email.
7. Kyle types fake tags into the Diagnosis column and sets Status to Active.
8. Verifies that the next 5:30am cycle sends a daily program email with appropriate content.
9. Replies to the daily program email with a routine question ("can I do this drill barefoot?") — verifies AI auto-reply within 5 min.
10. Replies with a safety message ("my elbow hurts after yesterday") — verifies it lands in Coach Inbox + Kyle gets alert + client gets the 24-hour auto-reply.
11. Kyle types a reply in the Coach Inbox form — verifies client receives it formatted correctly.
12. Repeats for the 12-Week Prepay product.
13. Tests on iPhone Safari, Android Chrome, desktop Chrome.
14. Tests Apple Pay and Google Pay.
15. Tests cancellation via Stripe Customer Portal.

After launch, the first 3 real clients are soft-launched (told personally about the new flow) so any rough edges are caught with friendly users.

## Tooling cost summary

| Tool | Purpose | Cost |
|---|---|---|
| Stripe | Payments | 2.9% + $0.30/transaction, no monthly fee |
| Tally | Intake form (hosting + email + Sheets sync) | Free tier covers v1 |
| Google Sheets / Drive | Client DB + content library | Free (or included with Workspace) |
| Google Workspace | `programs@pitch3.com` inbox | $6/user/month |
| Make.com | AI workflow orchestration | $29/mo (Core plan, covers ~10K ops/month — fine for first 50 clients) |
| Claude API | LLM for content assembly + reply classification & generation | ~$0.50–$2 per client per month at typical usage |
| GitHub Pages | Static site hosting | Free |

**Monthly running cost while filling first 20 clients:** ~$50–$80/mo fixed + ~$10–$40/mo variable in Claude usage. **No outsourced team cost.**

**At 50 clients:** ~$80–$100/mo fixed + ~$25–$100/mo variable. Still <10% of what an overseas team would cost.

## Known limitations (v1 only)

These are accepted for v1 and become later-version priorities once the funnel is proving demand:

1. **No SMS** — email only. v1.1 will add an optional SMS reminder ("Today's program is in your inbox") via Twilio.
2. **No client portal** — clients can't browse past programs in one place; everything lives in their inbox. v2.
3. **Kyle is a single point of failure** — if Kyle takes vacation, diagnoses pile up. v1 mitigation: auto-apology emails on day 2 of delay. Long-term: a backup coach reviewer.
4. **AI replies may sound generic** — the system prompt tries to capture Kyle's voice but tone calibration improves over time. Kyle should spot-read AI replies for the first 2 weeks and tune the prompt.
5. **Make.com as the workflow engine** scales fine to ~500 clients on the Core plan. Past that, migration to a real backend is recommended.
6. **Content library starts thin** — launches with ~20–30 videos and ~10 program templates; Kyle adds more weekly. First few clients may get content that's "close but not perfect" for their tags.
7. **No analytics dashboard** — Kyle reads the Google Sheet directly. GA4 can be added on /join for conversion tracking.

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

Everything else (Make.com scenarios, Google Sheets, Drive content library, Claude API integration) is configured in those external services — no files in the repo.

## Build sequence

**Phase 1 — Signup funnel (Days 1–4)**

| Day | Work | Owner time |
|---|---|---|
| Day 1 | Dev builds `join.html` and pricing-card CSS in parallel with owner setting up Stripe Products and Payment Links | ~90 min Stripe setup + 30 min review |
| Day 2 | Dev builds `join/success.html` and wires Tally embed; owner builds the Tally form using the field list in Component 3 | ~60 min Tally + 30 min testing |
| Day 3 | Dev adds nav updates across existing pages, drafts welcome email copy; owner sets up Google Sheet with both tabs and Drive content library folder structure | ~60 min sheet + drive + 30 min review |
| Day 4 | End-to-end test of the signup flow only (no AI delivery yet) — fake purchase, real intake, verify Sheet write + emails | ~90 min together |

**Phase 2 — AI delivery (Days 5–10)**

| Day | Work | Owner time |
|---|---|---|
| Day 5 | Dev sets up Make.com account, builds Scenario A (diagnosis alert email) | ~30 min review |
| Day 6 | Dev builds Scenario B (daily program send), wires Claude API, writes system prompt for content assembly | ~60 min testing |
| Day 7 | Dev builds Scenario C (incoming reply routing), writes classification prompt with safety guardrails | ~60 min testing |
| Day 8 | Dev builds the Kyle-reply-delivery scenario; owner records 10–15 starter videos for content library | ~3 hrs recording |
| Day 9 | End-to-end AI test — fake client, fake replies (routine + safety), verify every path | ~2 hrs together |
| Day 10 | Polish: tune system prompts based on test results, write Kyle's daily SOP (15 min/day: check Sheet, diagnose new clients, reply to Coach Inbox), draft template program emails | ~2 hrs |

**Phase 3 — Soft launch (Days 11–14)**

| Day | Work | Owner time |
|---|---|---|
| Days 11–14 | Onboard first 2–3 friendly clients (paid, or comped). Owner records additional library videos in parallel. Monitor every AI reply for the first week, tune as needed. | ~1–2 hrs/day |

## Owner's daily/weekly responsibilities post-launch

**Daily (~15 min):**
- Check Clients tab for new `Awaiting Diagnosis` rows; watch video + assign tags + flip to `Active`
- Check Coach Inbox tab for any new escalated messages; type reply, mark `Replied`

**Weekly (~1–2 hrs):**
- Record 2–5 new content library videos to expand coverage
- Spot-review a sample of AI replies sent during the week for tone/accuracy
- Refine Diagnosis Tag conventions as new patterns emerge

**Monthly (~30 min):**
- Review which tags are most/least requested → guides what content to record next
- Review Stripe revenue + Make.com / Claude API spend
- Adjust pricing or program length if needed

## Open questions deferred to implementation

These do not need to be answered now but will come up during the build:

- Exact wording for the Claude API system prompts (content assembly, reply classification, reply generation). Drafted in Phase 2, tuned during testing.
- Exact wording of the parent welcome email and Coach Kyle voice samples for AI tone calibration. Owner provides a few representative emails he's already written for AI to mimic.
- Exact FAQ answers on /join.html. Owner provides substance, dev writes polished version.
- Whether to add Google Analytics on /join for conversion tracking (recommended but not blocking).
- Whether the Tally video URL field requires both a front view AND side view (recommended for diagnosis quality) or accepts either one.
- Whether Kyle wants to record his own "intro video" for the welcome email vs a static written welcome.
