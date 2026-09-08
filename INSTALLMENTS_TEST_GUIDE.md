# Installments + Early Bird — Test Guide

Ye guide batati hai ke installment plan aur early bird discount ka feature kaise
test karna hai, step by step.

---

## Feature kya karta hai (short recap)

- **Early Bird**: instructor course pe ek flat PKR discount rakhta hai jo ek
  deadline tak chalta hai. Deadline guzar jaye to khud-ba-khud band.
- **Installments**: student poori fees ek saath dene ke bajaye N mahine mein
  deta hai. Pehli qist = purchase khud. Har agli qist theek 1 mahine baad due.
- Qist waqt pe na di jaye (grace = agli qist ki due date tak) to course
  **auto-lock** ho jata hai. Progress bachi rehti hai. Qist paying karte hi
  turant unlock.

---

## Test 1 — Instructor: course banate waqt options set karna

1. Instructor account se login karein
2. **Create Course** (ya kisi maujooda course ko Edit karein)
3. Step 2 (Pricing) mein jayein — course **paid** hona chahiye (free nahi)
4. Yahan do naye toggle milenge:

**Early Bird Discount**
- Toggle ON karein
- Amount daalein (jaise `500`) — ye course price se **kam** hona chahiye
- Deadline chunein: ya to "N days from now" ya calendar se date

**Installment Plan**
- Toggle ON karein
- Count chunein: **2 se 12** ke darmiyan (jaise `3`)

5. Course save karein

**Kya check karna hai:**
- ✅ Amount price se zyada daalein to error aana chahiye
- ✅ Count 2 se kam ya 12 se zyada na le
- ✅ Save hone ke baad dobara Edit kholne pe values wahi dikhein

---

## Test 2 — Student: course kharidna (installment 1)

1. Student account se login karein
2. Wahi course kholein
3. **Price check karein** — agar Early Bird abhi active hai to price
   `(asal price − early bird amount)` dikhna chahiye
4. Buy pe click karein → payment screen khulegi

**Ahem:** yahan jo amount dikhega wo **poori fees nahi, sirf pehli qist** hogi.

Hisaab: `floor(effectivePrice / installmentCount)`

Misal:
- Course price = 3000, Early Bird = 500 → effective = 2500
- Installments = 3 → pehli qist = `floor(2500/3)` = **833**

5. Safepay se payment complete karein (sandbox/test mode mein)

**Kya check karna hai:**
- ✅ Payment screen pe sirf pehli qist ka amount ho, poori fees nahi
- ✅ Payment ke baad course enroll ho jaye aur content khule

---

## Test 3 — Installment schedule dekhna

Purchase ke baad student ko course ke andar ek **banner** dikhega:
> "Installment 2 of 3 — next due 21 Aug · View schedule"

Uspe click karein → **Installment Schedule screen** khulegi.

**Kya check karna hai:**
- ✅ Saari N qisten list mein hon
- ✅ Qist 1 = **Paid** (green), baaki = **Pending**
- ✅ Har qist ki due date **theek 1 mahina** aage ho
- ✅ **Sab qiston ka jama (total) = effective price ke barabar ho** — aakhri
  qist mein rounding ka farq adjust hota hai
  (misal upar wali: 833 + 833 + 834 = 2500 ✓)
- ✅ Pehli **unpaid** qist pe "Pay Now" button ho

---

## Test 4 — Agli qist ada karna

1. Schedule screen pe "Pay Now" dabayein
2. Safepay se payment karein
3. Wapas aane pe wo qist **Paid** ho jani chahiye

**Kya check karna hai:**
- ✅ Status Pending → Paid ho jaye
- ✅ **Payment History** mein alag row bane, label:
  `"<Course Title> — Installment 2 of 3"`
- ✅ Pehle se paid qist pe dobara pay na ho paye (error aana chahiye)

---

## Test 5 — Course auto-lock (overdue) — CRON test

Ye asli waqt mein 1 mahine baad hota hai, lekin test ke liye **manually
trigger** kar sakte hain.

### Step A: qist ko "purani" banayein (DB mein)

MongoDB mein us student ki enrollment dhoondein aur qist 2 ki `dueDate` ko
2 mahine peeche kar dein (taake grace period bhi guzar chuka ho):

```js
db.enrollments.updateOne(
  { userId: ObjectId("<STUDENT_ID>"), courseId: ObjectId("<COURSE_ID>") },
  { $set: {
      "installments.1.dueDate": new Date(Date.now() - 60*24*60*60*1000),
      "installments.2.dueDate": new Date(Date.now() - 30*24*60*60*1000)
  }}
)
```

> Note: array index 0-based hai — `installments.1` = qist **2**.

### Step B: cron manually chalayein

```bash
curl "https://icare-backend-inky.vercel.app/api/lms/installments/process?secret=<CRON_SECRET>"
```

Response aisa aana chahiye:
```json
{ "success": true, "remindersSent": 1, "locked": 1, "checked": 2 }
```

### Step C: nateeja check karein

- ✅ Student ko **in-app notification** aaye: "Course Locked — Installment Overdue"
- ✅ Student ko **email** bhi jaye
- ✅ Student course kholne ki koshish kare to **locked** dikhe — content na khule,
  banner ho: "Course locked — installment overdue, Pay Now"
- ✅ DB mein `installmentLocked: true` ho aur us qist ka status `overdue`
- ✅ **Progress/completions bilkul na miten** (DB mein check karein)

---

## Test 6 — Overdue qist de kar unlock karna

1. Locked course pe "Pay Now" dabayein
2. Overdue qist ki payment complete karein

**Kya check karna hai:**
- ✅ Course foran **unlock** ho jaye
- ✅ Saara purana progress waisa ka waisa ho
- ✅ Notification aaye: "access restored"
- ✅ DB mein `installmentLocked: false` ho jaye

---

## Test 7 — Cron dobara chalana (idempotency)

Wahi cron URL **dobara** chalayein usi din.

**Kya check karna hai:**
- ✅ Duplicate notification/email **na** jaye
- ✅ Response mein `remindersSent: 0, locked: 0` aaye
  (kyunki `dueReminderSentAt` / `installmentLocked` flags already set hain)

---

## Test 8 — Early Bird deadline guzarna

1. DB mein course ki `earlyBirdDeadline` ko kal ki date kar dein:

```js
db.courses.updateOne(
  { _id: ObjectId("<COURSE_ID>") },
  { $set: { earlyBirdDeadline: new Date(Date.now() - 24*60*60*1000) } }
)
```

2. Naye student account se wahi course kholein

**Kya check karna hai:**
- ✅ Ab price **poori** dikhe (early bird discount khatam)
- ✅ Qist ka hisaab bhi ab poori price pe ho

---

## Quick reference

| Cheez | Value |
|---|---|
| Cron URL | `/api/lms/installments/process?secret=<CRON_SECRET>` |
| Cron schedule (auto) | Roz subah 9 baje (`0 9 * * *`) |
| Pehli qist ka hisaab | `floor(effectivePrice / count)` |
| Aakhri qist | Baqi sab minus kar ke — rounding yahan adjust hoti hai |
| Grace period | Agli qist ki due date tak (aakhri qist ke liye +1 mahina) |
| Installment count range | 2 – 12 |
| Payment type (DB) | `course_installment` |

---

## Sabse tez smoke test (5 minute)

Agar sirf jaldi se check karna ho ke feature zinda hai:

1. Instructor: ek course pe installments ON karein, count = 2
2. Student: kharidein → amount aadha dikhna chahiye
3. Schedule screen kholein → 2 qisten dikhein, pehli paid
4. Cron URL chalayein → `{"success":true,...}` aana chahiye

Ye chaar step pass ho jayein to poora flow theek kaam kar raha hai.
