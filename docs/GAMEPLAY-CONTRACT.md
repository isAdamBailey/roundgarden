# Shared gameplay contract

This contract defines the shared one-minute round for the web, iOS, and macOS games. Platforms may adapt controls and presentation, but the round rules and player outcomes stay the same.

## Round loop

1. The player enters a 60-second round. Starting or replaying resets the timer and current score to zero.
2. The player floats at the center of a spherical, whimsical garden and looks all around as garden oddities drift closer.
3. Oddities have visible point values. Ordinary oddities are worth 100 points; higher-value types are worth 250 or 500. The closer the player lets an oddity drift before acting, the greater the proximity multiplier, up to 3×.
4. The player centers a nearby oddity and activates the platform's primary action. It vaporizes into light; the player does not catch or keep it. The score increases by its point value times the proximity multiplier. Provide immediate visual feedback and optional sound feedback.
5. The round ends at zero seconds. Show the final score and the player's locally saved personal best, with an option to start a fresh round.

Garden foliage and branches may visually overlap an oddity, but they must never block targeting. Show an oddity's value when centered and make higher-value types recognizable through visual cues. Show proximity value through the reticle or nearby targeting feedback without permanently labeling every object.

## Round states

- **Ready:** The player can look around before starting. Garden oddities drift slowly as part of the living scene.
- **Playing:** The 60-second clock runs, oddities approach at gameplay speed, and vaporizing a reachable target scores.
- **Paused:** The clock and gameplay motion stop; look and activation input cannot change the round. The player can resume or leave the round.
- **Complete:** The clock is stopped and the final score and personal best are displayed. Starting again creates a fresh round with a score of zero and a full 60 seconds.

Leaving a paused or completed round returns to Ready. Pause must not reset the score or remaining time. Backgrounding or deactivating an app pauses an active round; returning presents the paused state so play does not advance unseen.

## Platform controls

| Action | Web | iOS | macOS |
| --- | --- | --- | --- |
| Look around | Drag with mouse or touch | One-finger drag | Mouse or trackpad drag; keyboard look may be offered as an accessibility option |
| Vaporize centered oddity | Click or tap | Tap | Click or trackpad click; Return/Space may be offered when a target is centered |
| Pause or resume | Escape, plus an always-available on-screen control | Visible pause/resume button | Escape and a visible in-window control |
| Start or replay | Activate the start/replay button | Tap the start/replay button | Activate the start/replay button by pointer or keyboard |

A drag is a look gesture; only a completed click or tap without meaningful movement activates a target. Native apps should use their standard navigation and safe-area/window conventions while keeping the same round states and scoring rules.

## Timing and scoring rules

- A round starts with exactly 60 seconds and a current score of zero.
- The timer measures active-play time. It does not advance while paused or while the app is backgrounded.
- An ordinary oddity starts at 100 points; higher-value oddities are worth 250 or 500. The player sees an oddity's value when it is centered.
- Proximity multiplies the oddity's value by up to 3×. Communicate the active multiplier through target feedback. Do not add a streak bonus.
- Misses, unreachable targets, and decorative interactions add no points.
- Save the best completed round score locally on the device. Do not imply a global leaderboard.
- At zero seconds, target activation stops and the completion screen shows the final score and local personal best.
- Replay always starts a new round; it does not carry the current score or remaining time over.

## Current web baseline and implementation work

The web reference implements the 60-second timer, 360-degree drag look, center-reticle targeting, 100/250/500 point values, proximity multipliers, pause/resume, local personal best, completion, and fresh replay. Product language describes vaporizing garden oddities into light. Decorative foliage remains outside the target raycast. Native apps should follow this contract and use the web game as the behavior reference.
