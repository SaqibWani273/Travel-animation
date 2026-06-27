# SY Expedition — Travel Animation (Flutter)

This is my Flutter take on the [SY Expedition travel animation](https://dribbble.com/shots/3787326-SY-Expedition-travel-animation) shot on Dribbble. It's a little safari trip planner: you swipe between two full-screen pages, and tapping/dragging reveals a timeline that draws itself on and then bends into the actual trek route on a map.

I mostly built it to see how far I could push hand-tuned, gesture-driven motion in Flutter without reaching for any animation packages.

## Demo



https://github.com/user-attachments/assets/b1270911-7040-439a-80b2-835da83be1e7



> If the player doesn't load inline, open [`assets/demo.mp4`](assets/demo.mp4) directly.

## How it works

The whole screen is one big `Stack`. Every piece — the animal cutouts, the grey circle, the timeline, the little camp labels — is a `Positioned` child placed by hand, and the animations just nudge those positions, scales and opacities around. Keeping everything absolutely positioned is what made it possible to overlap and choreograph elements the way the original shot does.

A few things that make the motion feel smooth:

- **It reacts to the actual swipe, not a button press.** A listener on the `PageController` reads the live scroll offset and feeds it straight into the animations, so the next page starts revealing itself mid-drag — the circle scales in once you're ~70% across, and the giant background "72" slides along with your finger.
- **The controllers are chained, not fired all at once.** Several `AnimationController`s hand off to each other with listeners and `.then()` callbacks, so things happen in order: collapse the circle, draw the timeline up, then fade the tags in.
- **The route line is custom-painted.** A `CustomPainter` draws a Catmull-Rom spline and reveals it by trimming the path by arc length (`PathMetrics.extractPath`). The same painter morphs a straight timeline into the curved map route by lerping between two sets of control points, fading the labels in as it bends.
- **Transitions are layered.** `Slide`, `Fade` and `ScaleTransition` are stacked together (with some `AnimatedPositioned`/`AnimatedScale` for the simpler bits), plus a `Matrix4` scale + rotate + fade for the map reveal.
- **Timing is staggered with `Interval` curves** so the progress dots fade and widen on their own little schedule instead of all at once.
- **`provider`** handles the one bit of real state — the map toggle.

No `Hero` widgets here; the cross-page feel comes entirely from the scroll-driven controllers above.

## Run it

```bash
flutter pub get
flutter run
```
