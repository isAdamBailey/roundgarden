# Android layout and interaction proposal

**Status:** proposed for owner review; this is a Phase 0 planning artifact, not
approval to begin the production app UI.

## Device and orientation approach

- Use one responsive scene on phones and tablets. Keep the garden centered
  and spherical; do not add tablet-only gameplay or stretch HUD text across the
  full display.
- Support portrait and landscape. Keep the current orientation while a round is
  active so rotation does not interrupt a touch gesture. Reflow the ready and
  result surfaces after orientation changes.
- Draw interactive content inside system-bar and display-cutout safe areas.
  Let the 3D garden extend behind system bars where the chosen renderer permits
  it, while keeping buttons, score, timer, labels, and focus targets inset.

## Phone composition

- The ready state uses a full-screen garden backdrop, a concise Roundgarden
  heading and invitation, two short control instructions, and one prominent
  button to enter the garden. Place it within comfortable one-hand reach in
  portrait.
- During play, pin score to the upper left and the 60-second timer to the upper
  right. Keep a small reticle at the visual center. Show the centered oddity's
  value and 1×/2×/3× proximity feedback close to the reticle, without covering
  the target.
- Keep a visible pause control at the lower right, above the system gesture
  area. The pause surface offers Resume and Leave; completion shows score,
  locally saved personal best, and a fresh-round action.
- In landscape, retain the centered reticle and move score/timer to the upper
  corners. Place pause above the lower safe inset. Do not place primary actions
  next to the display cutout.

## Tablet composition

- Preserve the same scene scale and HUD hierarchy. Use the added horizontal
  space for more garden visibility, not additional controls or a different
  game mode.
- Keep ready and completion copy in a readable, bounded panel over the scene;
  leave enough of the garden visible to understand the 360-degree setting.
- Keep HUD elements near the safe-area corners and retain a centered reticle.
  Verify both portrait and landscape rather than assuming tablets stay in one
  orientation.

## Touch, focus, and accessibility

- One-finger drag looks around through 360 degrees horizontally and the useful
  vertical range. Clamp pitch to prevent camera inversion.
- A tap without meaningful movement activates only a centered reachable
  oddity. A drag never vaporizes an object. The renderer must exclude foliage
  and greenhouse geometry from target selection.
- Expose Start, Pause, Resume, Leave, and Replay as standard accessible buttons.
  Announce score, remaining time, target value, reachability, and multiplier
  through accessible labels/state changes without announcing every animation
  frame. Keep a logical focus order and visible focus indicator.
- Respect Android font scaling and contrast settings. Provide a reduced-motion
  mode that suppresses nonessential idle sway and vaporization particles while
  preserving clear state changes and target feedback.
- Backgrounding an active round pauses time and garden motion. Returning shows
  the paused state and offers Resume or Leave.

## Far-to-near presentation

- Far: preserve a recognizable 100/250/500 silhouette and color/value cue.
- Mid: increase size and surface detail while maintaining the shared approach
  and recycle behavior.
- Reachable: make the oddity visibly actionable and show its value plus the
  1×/2×/3× band. Preserve the 12.8-unit maximum reach and 8.5/4.2-unit scoring
  boundaries from `docs/GAMEPLAY-CONTRACT.md`.
- Vaporize: provide an immediate light effect and score change. A miss,
  unreachable target, or decorative object adds no points.

## Review checklist

- Confirm this phone/tablet hierarchy, portrait/landscape behavior, and touch
  interaction before production UI implementation.
- Review captures from low-, mid-, and high-profile emulators. These results
  are not evidence of physical-device performance.
- Confirm the renderer spike can retain readable HUD, safe-area behavior, and
  the centered target while the camera turns through a full rotation.
