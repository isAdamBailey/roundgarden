# Android layout and interaction proposal

**Status:** proposed for owner review. This Phase 0 planning artifact does not
approve starting the production app UI.

**Tracker:** [Roundgarden Android plan, issue #19](https://github.com/isAdamBailey/roundgarden/issues/19).

## Scope, acceptance, and gates

This document covers Phase 0's checklist item:

> Document Android phone/tablet layout, touch/look/target controls, orientation, safe areas, HUD placement, accessibility, and the far-to-near gameplay presentation.

Mark the item complete after the owner approves the phone and tablet hierarchy,
portrait/landscape behavior, touch interactions, and accessibility approach,
and links this agreed document from issue #19. This proposal was checked against
`docs/GAMEPLAY-CONTRACT.md`, and `git diff --check` passes. Emulator captures
and performance measurements belong to the separate renderer-spike checklist
item; this document does not validate them.

This proposal does not choose a renderer. Record the choice after the Phase 0
renderer spike and ADR. The owner must review both the layout and renderer
choice before production Android UI work starts. Issue #19 also gates Android
implementation on completing the iOS release dependency; this planning document
does not satisfy that dependency.

## Device and orientation approach

- Use one responsive scene on phones and tablets. Keep the garden centered and
  spherical. Do not add tablet-only gameplay or stretch HUD text across the
  display.
- Support portrait and landscape. Lock the current orientation during a round
  so rotation does not interrupt touch gestures. Reflow ready and result
  surfaces after orientation changes.
- Keep interactive content inside system-bar and display-cutout safe areas. Let
  the 3D garden extend behind system bars where the renderer permits, while
  keeping buttons, score, timer, labels, and focus targets inset.

## Phone composition

- The ready state shows a full-screen garden backdrop, a concise Roundgarden
  heading and invitation, two short control instructions, and one prominent
  button to enter the garden. In portrait, place it within comfortable
  one-hand reach.
- During play, pin the score upper left and the 60-second timer upper right.
  Keep a small reticle at the visual center. Show the centered oddity's value
  and 1×/2×/3× proximity feedback near the reticle without covering the target.
- Keep a visible pause control at the lower right, above the system gesture
  area. The pause surface offers Resume and Leave. Completion shows the score,
  locally saved personal best, and an action to start a fresh round.
- In landscape, keep the centered reticle and move score and timer to the upper
  corners. Place pause above the lower safe inset. Keep primary actions away
  from the display cutout.

## Tablet composition

- Preserve the same scene scale and HUD hierarchy. Use the extra horizontal
  space to show more garden, not to add controls or a game mode.
- Keep ready and completion text in a readable, bounded panel over the scene.
  Leave enough garden visible to convey the 360-degree setting.
- Keep HUD elements near the safe-area corners and the reticle centered. Verify
  portrait and landscape; do not assume tablets stay in one orientation.

## Touch, focus, and accessibility

- A one-finger drag looks around 360 degrees horizontally and through the
  useful vertical range. Clamp pitch to prevent camera inversion.
- A tap without meaningful movement activates only a reachable oddity at the
  center. A drag never vaporizes an object. Exclude foliage and greenhouse
  geometry from target selection in the renderer.
- Expose Start, Pause, Resume, Leave, and Replay as standard accessible buttons.
  Use accessible labels or state changes to announce score, remaining time,
  target value, reachability, and multiplier without announcing every animation
  frame. Keep focus order logical and the focus indicator visible.
- Respect Android font scaling and contrast settings. Reduced-motion mode
  suppresses nonessential idle sway and vaporization particles while preserving
  clear state changes and target feedback.
- When an active round goes to the background, pause time and garden motion.
  On return, show the paused state and offer Resume or Leave.

## Far-to-near presentation

- Far: preserve a recognizable 100/250/500 silhouette and color/value cue.
- Mid: increase size and surface detail while maintaining the shared approach
  and recycle behavior.
- Reachable: make the oddity visibly actionable and show its value and 1×/2×/3×
  band. Preserve the 12.8-unit maximum reach and 8.5/4.2-unit scoring
  boundaries in `docs/GAMEPLAY-CONTRACT.md`.
- Vaporize: show an immediate light effect and score change. Misses,
  unreachable targets, and decorative objects add no points.

## Review checklist

- Confirm the phone/tablet hierarchy, portrait/landscape behavior, and touch
  interactions before production UI work.
- Review captures from low-, mid-, and high-profile emulators. They do not
  establish physical-device performance.
- Confirm the renderer spike can keep the HUD readable, respect safe areas, and
  keep the target centered while the camera turns through a full rotation.
