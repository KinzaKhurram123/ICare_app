# Pre-deploy check

Run this before every backend deploy:

```bash
cd icare-backend
npm run lint:deploy
```

Exit 0 = safe to deploy. Any output = fix it first.

## Why this exists

On 2026-09-08 LMS live sessions broke: `POST /live-sessions/course/:id/set-live`
returned 500, no session document was created, and the instructor's page then
polled `GET /live-sessions/:id` in a 404 loop behind a yellow
"could not notify students" banner.

The cause was one line in `routes/live-sessions.js`. `template` was declared
with `const` **inside** an `if` block:

```js
if (sessionId && sessionId !== req.params.courseId) {
  const template = await LiveSession.findById(...).lean();   // block-scoped
}
...
await LiveSession.create({
  ...(template?.linkedModuleId ? { ... } : {}),   // out of scope -> ReferenceError
});
```

`?.` guards against a null *value*, not against an *undeclared* name, so this
threw `ReferenceError: template is not defined` while building the create()
payload — before the session was ever written.

Two things made it hard to spot:

- **It is not a syntax error.** `node --check` passes, the server starts fine,
  and the deploy looks successful. It only fails at runtime, on one path.
- **It only hits the fresh-create path.** If a `live` session already existed,
  or a heartbeat was under 2 minutes old, the handler returned early and never
  reached the bad line. So it worked while stale sessions were lying around and
  broke once they were cleaned up — which is why it read as "works for a day or
  two, then everything is broken the next day".

`npm run lint:deploy` catches exactly this (`no-undef`) in about a minute across
all 135 backend files.

## Why `no-dupe-keys` is not in the gate

`routes/labs.js` (~line 202) and `routes/pharmacy.js` (~line 262) build their
profile response as `{ id, _id, ...profile, _id, id }` — re-asserting the keys
*after* the spread on purpose, so `profile._id` cannot override the user's id.
That works (last key wins) but it trips `no-dupe-keys`, which would leave the
gate permanently red and therefore ignored. The earlier `id`/`_id` in those two
objects are dead weight and could be dropped some time when those routes are
being touched anyway — not worth a risky edit to working production code.

## Also worth knowing

Most `catch` blocks in `routes/live-sessions.js` reply `res.status(500)` without
logging, so the server log stayed silent through the whole outage. `set-live`
now logs its stack. Any handler you touch, give the same treatment:

```js
} catch (e) {
  console.error('<route> FAILED:', e);
  res.status(500).json({ success: false, message: e.message });
}
```
