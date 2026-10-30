# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Three.js + Vite, confirmed by the user.

## Users

Players using a desktop or mobile browser. The first build is a casual, immersive 360-degree game.

## Product Purpose

Let the player float at the center of a whimsical garden that surrounds them, look in every direction, and vaporize drifting garden oddities into light. Success is measured by the score earned during a one-minute round.

## Positioning

The player looks all around a spherical garden and vaporizes nearby oddities. Higher-value oddities and closer timing raise the score.

## Operating Context

Played in a modern browser on desktop or mobile. Mouse or touch controls look around and activate a centered oddity. A round lasts 60 seconds; pause, resume, and backgrounding must preserve the remaining time and score. Camera based hand tracking is not part of the first build.

## Capabilities and Constraints

- Render the 3D game using WebGL through Three.js.
- Objects visibly increase in apparent size as they approach.
- The first version uses mouse and touch input.
- Targeting is limited to nearby objects within the player's aiming reach. Foliage and branches never block a valid target.
- Ordinary oddities are worth 100 points; higher-value types are worth 250 or 500. Proximity multiplies the value up to 3×.
- Save the best completed round score locally on the device.
- WebXR and camera-based hand tracking are undecided future options.

## Brand Commitments

The selected product name is **Roundgarden**.

The confirmed world is a whimsical garden that surrounds the player, with strange garden oddities, curling stems, flowers, and dense foliage. Product copy does not claim the garden is in space or among stars.

## Evidence on Hand

No existing assets, logo, or product evidence was supplied.

## Product Principles

- Keep the player floating at the center of a complete, explorable sphere.
- Make distance and reach understandable through object scale and motion.
- Make vaporizing an oddity immediate and comfortable with mouse or touch.
- Keep the round, pause, scoring, and local personal-best rules consistent across platforms.
