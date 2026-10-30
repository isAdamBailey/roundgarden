# Shared visual and interaction contract

## Product context

Roundgarden is a short-session game set in a floating, spherical, whimsical garden. The garden surrounds the player. Player-facing copy must not place it in space or among stars. The garden oddities drift toward the player; the player vaporizes them into light rather than catching, collecting, or harvesting them.

## Shared round rules

- A round lasts 60 seconds and can be paused, resumed, and restarted.
- The player looks freely around the centered viewpoint and aims with a center reticle.
- A completed click or tap on a reachable oddity vaporizes it. Decorative leaves and branches do not intercept the target query.
- Oddity values are 100, 250, or 500 points. Proximity multiplies the value by up to 3×.
- Show the current score and time clearly. Persist a local personal best where the platform supports it.
- Pause when the app enters the background and require an intentional resume.

The detailed web baseline and acceptance tests are in [the gameplay contract](GAMEPLAY-CONTRACT.md). Native controls adapt to platform conventions while preserving these outcomes.

## Visual rules

- Keep a lush, layered garden filling the full spherical view, with a soft organic storybook tone.
- Use foliage, stems, branches, and greenhouse glass as garden structure. Preserve visible depth and leave room to recognize and aim at drifting oddities.
- Make produce silhouettes distinguishable at a distance; reveal finer shape and surface detail as they approach.
- Use scale, motion, light, and target feedback to communicate distance and reach. Do not rely on color alone.
- Keep score, timer, reticle, controls, and feedback readable over the scene. Support reduced motion where practical.

## Platform adaptation

Web supports mouse drag, touch drag, click, tap, keyboard pause, and browser background pause. Native implementations may use the controls expected on each device, but must provide accessible labels, preserve the 360° view and center-target interaction, and match pause, scoring, and replay behavior. Record any platform-specific deviation and its reason before release.
