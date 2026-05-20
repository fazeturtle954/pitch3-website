# PITCH3 Virtual Program — Coach Kyle's Playbook

**Last updated:** 2026-05-20
**Audience:** Coach Kyle Beard (running the virtual program day-to-day)

---

## What this document is

You're the coaching brain. Michael set up the website, payment system, and intake form — your job is everything that happens AFTER a parent signs up. This document walks you through exactly what to do, step by step. Read it once, then keep it as a reference.

---

## The four tools you'll use

| Tool | What it does | Where to find it |
|---|---|---|
| **Email** | Where you get alerts when new clients sign up | Whatever inbox Michael set up for notifications |
| **Google Sheet** ("PITCH3 Clients") | The master list of every paying client + their info | Google Drive → "PITCH3 Clients" |
| **TrueCoach** | The actual coaching app — programs, messaging, video review | https://truecoach.co — login Michael gave you |
| **Stripe Dashboard** | Where to handle refunds, billing questions, cancellations | https://dashboard.stripe.com — login Michael gave you (only needed occasionally) |

---

## How the whole flow works (the big picture)

```
1. Parent goes to pitch3.com/join → picks Monthly or 12-Week → pays via Stripe
2. Parent fills out an intake form (name, age, throwing hand, current velo,
   goals, parent contact, link to a video of their son's delivery)
3. The intake auto-appears as a new row in your Google Sheet
4. You get an email saying "New PITCH3 client: [Athlete name]"
5. ← THIS IS WHERE YOU TAKE OVER →
6. You watch the intake video, build/assign a program in TrueCoach,
   message the parent with their TrueCoach login.
7. You coach the kid going forward — daily messages, weekly program
   adjustments, video reviews, etc., all inside TrueCoach.
```

---

## ONE-TIME SETUP (do this before any clients arrive)

### Build your starter program library in TrueCoach

Before the first paying client signs up, build **5–10 template programs** in TrueCoach. These are reusable — you'll assign them to new clients with one click instead of building from scratch every time.

Suggested starter templates (adjust based on your typical clientele):

1. **HS pitcher · Velocity focus · Off-season** — 12 weeks, weight room emphasis, long-toss progression, velo plyo
2. **HS pitcher · Command focus · In-season** — lighter volume, command drills, recovery emphasis
3. **HS pitcher · Off-speed development** — pitch design block, spin rate work
4. **Youth pitcher (10–13) · Foundational** — arm care heavy, mechanics priorities, lower volume
5. **Travel ball (13–14) · Velocity + command split** — middle ground for early teens
6. **College pitcher · Off-season build** — pro-style programming
7. **College pitcher · In-season maintenance** — recovery + sharpness
8. **Pro / Indy ball · Off-season** — individualized blocks (you'll customize per client anyway)

Each program should include:
- Daily throwing program (long toss, mound work, etc.)
- Arm care protocol
- Strength & conditioning block
- Drill videos / explanations (TrueCoach lets you embed videos)

**Time investment:** ~2–4 hours one weekend to build all 5–10. After that, you assign them in 30 seconds per client.

---

## DAILY ROUTINE — when a new client signs up

When you get an email titled "New PITCH3 client: [Athlete name]" — do this:

### Step 1: Read the email (2 min)

It contains:
- Athlete name + date of birth
- Throwing hand
- Current fastball velocity
- Goal (Add velocity / Sharpen command / Develop off-speed / All of the above)
- Parent name, email, phone
- Plan they purchased (Monthly or Prepay)
- **LINK TO INTAKE VIDEO** (YouTube unlisted link)

### Step 2: Watch the intake video (5–10 min)

Click the YouTube link in the email. Watch their delivery — front view AND side view if they uploaded both. Take mental notes:
- Mechanics issues you see (late arm, slow hips, glove-side collapse, etc.)
- Age + maturity (does the body match the stated age?)
- Effort level / what their best stuff looks like

### Step 3: Open the Google Sheet, find their row

Go to Google Drive → "PITCH3 Clients" → Clients tab. Find the row with the new athlete's name (it'll have **Status = "Awaiting Diagnosis"**).

In the **Diagnosis Tags** column, type the categories you observed. Example tags:
```
hs, gain-weight, late-arm, fire-hips, arm-care
```
Or:
```
youth, foundational, low-volume, mechanics-priority
```

This isn't strict — use whatever shorthand makes sense to you. It's mostly for your future self (and for any VA / overseas help we hire later) so we can find similar clients fast.

In the **Kyle Notes** column, jot down anything important from the video that doesn't fit in tags (e.g. "Dad is overcoaching, address gently" or "Kid is bigger than stated age — adjust volume up").

### Step 4: Create the client in TrueCoach (~2 min)

1. Log into TrueCoach: https://truecoach.co
2. Go to **Clients** → **+ Add Client**
3. Fill in:
   - Name: from the email
   - Email: parent's email (from the email)
   - Phone (optional): parent's phone
4. Save

### Step 5: Assign a program template (~30 sec)

1. On the new client's profile in TrueCoach, click **Assign Program**
2. Pick the closest template from your library (built in the One-Time Setup)
3. **Tweak it for this specific client** — usually 2–5 quick adjustments. Common ones:
   - Swap drill X for drill Y based on their mechanics
   - Adjust weight room volume up/down based on age and training experience
   - Change long-toss distance based on their current velo

### Step 6: Send the welcome message (~2 min)

Inside TrueCoach, open the messaging tab with the new client. Send something like:

> Hey [parent name] (and [athlete name])!
>
> Coach Kyle here. I watched [athlete name]'s video — here's what I'm seeing and what we're going to work on first:
>
> [2–3 sentences of personalized observations from the video]
>
> Your Week 1 program is loaded in TrueCoach. Open the app, check today's workout, and reply here with any questions. I check messages every morning.
>
> Let's get to work.
>
> — Coach Kyle

### Step 7: Update the Google Sheet status (~10 sec)

Go back to the Sheet, find the same row, change the **Status** column from "Awaiting Diagnosis" → **"Active"**.

In the **TrueCoach Username** column, put their TrueCoach username (so you can find them fast in the future).

### Step 8: Reply to the parent's confirmation email (optional but nice)

The parent already got an automatic "you're in" email from the system. But if you want a personal touch, reply to the original notification email (or send a separate one) so they know a real human is on it:

> Hi [parent name],
>
> Got [athlete name]'s video. Just finished his Week 1 program and sent a message in TrueCoach with the details. Make sure to download the TrueCoach app (iOS / Android) and use the login info that was emailed to you — that's where the daily program lives.
>
> Reach out anytime. Excited to work with him.
>
> — Coach Kyle

**Total time for steps 1–8: ~20 min per new client.**

---

## ONGOING ROUTINE — daily messaging

### Each morning (~15–30 min total across all active clients)

1. Open TrueCoach → check the messages inbox
2. Reply to client questions — most will be quick:
   - "Is it okay to throw twice this week?"
   - "My elbow felt tight after yesterday, should I rest?"
   - "Can you check my mechanics on this video I just sent?"
3. **For anything mentioning pain, injury, or asking to modify the program** → respond personally and adjust the program if needed
4. **For routine questions** → quick reply, move on

### Each week (~10 min per client)

For each active client, take a quick look at their program adherence:

1. Did they complete most workouts this week?
2. Are they reporting issues (soreness, fatigue, plateauing)?
3. Do you need to adjust next week's program?
4. Send a brief check-in message: "Hey [name], good week. Heads up — next week we're [X]. Let me know if anything's tight before we start."

---

## SPECIAL SITUATIONS

### Client says they got injured

1. Respond ASAP in TrueCoach: "Stop throwing immediately. Tell me exactly where it hurts and what you were doing when it started."
2. If serious → recommend they see a doctor / PT. **Don't try to diagnose medical issues over text.**
3. In TrueCoach, **pause their program** (or replace with a return-to-throwing protocol if it's minor)
4. In the Google Sheet, change Status → **"Paused"**
5. Email Michael — he might want to pause their Stripe billing while they recover (so they're not paying for nothing)

### Client wants to cancel (Monthly plan)

1. Monthly clients can self-cancel through Stripe's customer portal — they got the link in their Stripe receipt
2. If they email you instead → reply with: "No problem. Open your most recent receipt email from Stripe and click 'Manage subscription' → 'Cancel.' Or I can do it for you — let me know."
3. If you cancel for them: log into Stripe Dashboard → Customers → find them → Cancel subscription
4. Update Google Sheet status → **"Cancelled"**
5. Send a kind farewell message in TrueCoach: "Best of luck, glad we got to work together, door is always open."

### Client wants a refund (Prepay)

1. Use your judgment. Reasons we'd refund:
   - Injury that's going to take months to heal (refund prorated remaining weeks)
   - Family crisis / can't continue
   - We're not delivering value (rare — but if so, refund and learn from it)
2. Reasons we wouldn't refund:
   - "Changed my mind" 3 weeks in
   - Not putting in the work and blaming the program
3. If you decide to refund: log into Stripe → Payments → find the charge → "Refund payment" → enter the prorated amount → Refund
4. Update Google Sheet status → **"Cancelled"**

### Parent emails with a pre-purchase question (hasn't signed up yet)

Just answer it like a normal sales conversation. If they're a good fit, point them to https://pitch3.com/join.html when they're ready.

### TrueCoach is broken / you can't access it

- Check https://status.truecoach.co — they sometimes have outages
- Email Michael — if it's been down for hours, we might temporarily message clients via email until it's back

### Something else weird happened

Email Michael. Don't try to fix anything in Stripe or the website yourself unless you're sure — call him first.

---

## QUICK REFERENCE — your morning checklist

Print this and put it on your fridge if you want:

```
☐ Check email for "New PITCH3 client" alerts
   → For each: watch video, fill diagnosis tags in Sheet,
     create client in TrueCoach, assign program, message them

☐ Open TrueCoach → Messages → reply to overnight messages
   → Pay attention to ANY message mentioning pain, hurt, tight,
     swollen — those need personal responses + program adjustments

☐ Check Sheet → any rows with Status = "Awaiting Diagnosis"
   that you haven't gotten to yet? (Goal: never let one sit
   more than 24 hours.)

That's it. ~30–60 min of work daily once you're at 5–10 clients.
```

---

## Questions for Michael (the software side)

Anything I haven't covered? Stuff that's NOT in this doc but you wonder about:

- "How do I check who's paid this month?" → Ask Michael, he'll show you in Stripe
- "Can we automate [X]?" → Probably yes, ask Michael
- "Is there a way to do [Y]?" → Ask Michael — he handles all the tech

You handle pitching. He handles software. That's the deal.

— PITCH3, 2026
