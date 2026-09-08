# Handoff: Bookings History back button is dead on web (mobile-emulated) layout

## Symptom
On `icare.com.co/patient/bookings-history` (Patient role, web app, viewed at
mobile width ~334-400px in Chrome), the back arrow next to "Home" at the top
of the dark blue gradient card does not respond to clicks at all. Confirmed
live via injected `debugPrint` inside the button's `onTap` — **the print
never fired**, so this is not a navigation-logic bug, it's the tap never
reaching the handler.

## What's already been tried and ruled out
1. **`GestureDetector` → `Material`+`InkWell`**: replaced the button's
   `GestureDetector` with `Material(type: transparency) + InkWell` (same
   pattern used successfully elsewhere in this file, e.g. `_categoryTile`).
   Still didn't fire when this specific build made it to the browser (see
   #3 below — that build likely never actually shipped).
2. **Moved the button into a real `AppBar`** (`lib/screens/bookings_history.dart`
   `build()`): added `appBar: AppBar(leading: const CustomBackButton(color:
   Colors.white), title: Text('Home'...))` and deleted the old header-drawn
   button entirely. `CustomBackButton` is the same widget confirmed working
   on "My Prescriptions" and other AppBar-based screens. **Deployed and
   verified byte-for-byte on the live server (`curl` Content-Length matched
   the local build exactly)** — but the screenshot after this deploy still
   shows the OLD gradient-card-only layout with no separate AppBar bar
   visible above it, on both the mobile-width view AND the desktop sidebar
   layout.
3. Confirmed the deployed `main.dart.js` is not stale (correct byte count),
   so the AppBar code did compile and ship. It's just not rendering / not
   receiving taps.

## Prime suspect: nested Scaffold swallowed by the web shell
`lib/screens/bookings_history.dart`'s `Scaffold` (with the new `appBar:`)
is not the root Scaffold — it renders as `activePage` inside
`lib/screens/tabs.dart`'s `TabsScreen`, via a `ShellRoute` in
`lib/navigators/app_router.dart`. Look at `lib/screens/tabs.dart` around
line 447 (`final Widget activePage = widget.child;`) and its two use sites
(~line 532 for the mobile branch, ~line 594 for the web/desktop branch).

Hypothesis: however `activePage` is embedded (a `Column`/`Expanded`
combination per the web branch, something else for mobile-width-in-web),
either:
- the child Scaffold's `appBar` never actually mounts inside that layout
  (e.g. it's wrapped in something that only takes `body`, discarding
  `appBar`), or
- it does mount but is rendered with zero/negative height or gets covered,
  or
- Flutter's nested-Scaffold-inside-Scaffold interaction is behaving
  unexpectedly here specifically at mobile width inside the web shell
  (screenshots show the SAME broken layout at both mobile viewport width
  and full desktop sidebar width — so this is not a `MediaQuery`/breakpoint
  branch issue, both `TabsScreen` branches are affected the same way, or
  only the web/desktop branch runs regardless of viewport since this was
  loaded via `icare.com.co` proper, not a native mobile build).

**Start here**: read `lib/screens/tabs.dart` in full, especially how
`activePage` flows into the widget tree in both the `if (!isWeb)` mobile
branch and the web/desktop branch below it (search `_WebTopBar`,
`LayoutBuilder`, `ClipRect`, `Expanded` around line 548-600). Determine
whether a child Scaffold's own `appBar` can ever render there, or whether
this shell fundamentally does not support screens supplying their own
`AppBar` (in which case EVERY screen that relies on `Scaffold(appBar: ...)`
inside this shell may have the same latent issue — worth grepping for how
many other in-shell screens use `appBar:` and whether they're confirmed
working, e.g. does "My Prescriptions" mentioned above as "working" also
live inside this same ShellRoute, or does it escape to a different
Navigator context like a `MaterialPageRoute` push?).

## Also still broken / same investigation likely applies
- **"Lab Results/Reports" drawer item** opening `/patient/lab-orders` was
  ALSO reported broken (bounces to home) earlier in this debugging session,
  before the back-button issue became the focus. Same shell-rendering
  root cause is plausible — worth checking after the back button is fixed.
- **Pending/Upcoming category-tile chevrons** on the same Bookings History
  page WERE confirmed working (bottom sheet opens correctly) — so not
  everything on this screen is broken, only the header back button. This
  is a useful contrast: `_categoryTile`'s `Material`+`InkWell` at
  `lib/screens/bookings_history.dart:544` onward works; something about
  the button now living in `appBar:` specifically does not render/receive
  taps the same way.

## Files most relevant
- `lib/screens/bookings_history.dart` — the screen in question, `build()`
  around line 104-130 has the current `appBar:` attempt.
- `lib/screens/tabs.dart` — the shell that embeds every screen as
  `activePage`; this is almost certainly where the actual bug lives.
- `lib/navigators/app_router.dart` — confirms `/patient/bookings-history`
  is a plain `GoRoute` child of the app's single `ShellRoute` (search
  `bookings-history` — currently around line 507), same shell as every
  other in-app screen.
- `lib/widgets/back_button.dart` — `CustomBackButton` + `goBackOrHome()`,
  confirmed working when used from an AppBar `leading:` slot in screens
  that DO escape the shell (e.g. pushed via `Navigator.push`/
  `MaterialPageRoute` rather than being a `GoRoute` inside the ShellRoute) —
  worth double-checking whether "My Prescriptions" is actually a
  ShellRoute child too, or a separate push, since that changes what
  "confirmed working" actually proves.

## Deploy pipeline (for after you have a fix)
Credentials and exact steps: see `lib/../` memory notes or ask the user —
but in short: `flutter build web --release` in this directory
(`D:\ICare_app-wajahat`), then upload `build/web/main.dart.js` to
`vhuser@vh.itserver.biz:/tmp/` via `pscp`, then on the server
`sudo cp /tmp/main.dart.js /var/www/icare/`. Verify with
`curl -sI https://icare.com.co/main.dart.js` and compare `Content-Length`
against the local file's byte size — this has been the only reliable way
to confirm a deploy actually landed, since Flutter's web service worker
previously caused six consecutive "fixes" to silently not apply (already
resolved separately by adding a custom `web/flutter_bootstrap.js` that
disables the service worker — do not remove that file).

## What NOT to do
- Don't re-attempt the `GestureDetector`→`InkWell` swap alone again without
  also fixing the shell-embedding issue — it was already tried and the
  build that shipped it still didn't work, most likely because the shell
  problem is upstream of any widget-level tap-handling fix.
- Don't assume a hard refresh / cache issue — the service worker is
  disabled and `Content-Length` was verified byte-for-byte against the
  live server after every deploy in this session.
