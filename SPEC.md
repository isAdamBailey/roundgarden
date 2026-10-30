# Roundgarden: visual and gameplay handoff spec

## Purpose

Continue the Three.js game in `apps/web` as a tactile, whimsical garden that surrounds the player. From a centered 360-degree view, garden oddities drift closer; the player aims at the center reticle and clicks or taps to vaporize a nearby oddity into light.

Treat this document as the handoff brief for the next implementation pass. `PRODUCT.md` is the concise product baseline; this file records the visual direction and the next work requested by the user.

## Confirmed direction

- **World:** a spherical, whimsical garden that fills the player's view in every direction. Curved glass and star-like details may remain in the visuals, but copy must not claim a location or setting.
- **Mood:** lush, curious, soft and organic; garden oddities may feel playfully storybook-like.
- **Gameplay:** a 60-second round, mouse/touch looking and vaporizing, center-reticle targeting, and objects that visibly grow as they approach. Follow the shared rules in `docs/GAMEPLAY-CONTRACT.md` for scoring, pause, and replay.
- **Player:** floats in the middle and can look in every direction.
- **Visual priority:** increase the amount and variety of greenery across the sphere background. If the scene becomes an undifferentiated wall of green, add bark-brown branches, stems and other woody structure as a contrasting layer. Vegetables should sometimes drift partly behind this depth layer.
- **Produce priority:** give vegetables more crafted, individual detail, with the richest detail apparent at close range.

## Current implementation

- Entry point: `apps/web/src/main.js`; styles: `apps/web/src/style.css`; page metadata and visual contract: `apps/web/index.html`.
- Three.js + Vite. Use Node 26.13.0 from `.nvmrc` for local builds; Node 24 LTS is also supported.
- Procedural dome, translucent greenhouse shell and ribs; directional warm key light, hemisphere fill, a point fill, ACES tone mapping, and a 4096² directional shadow map.
- Foliage is procedurally distributed across the inside of the sphere. Leaves are instanced, curved meshes with central and branching veins; they cast and receive shadows. Stems, curling vines, flowers and pollen add variety.
- Floating produce uses several lathed silhouettes, small leaves, a curled tendril, and a glowing heart. Twelve pods drift toward the player, grow as distance closes, and respawn after vaporizing or passing the player.
- The raycaster targets produce meshes only. Keep foliage visually capable of occluding an oddity while allowing the player to target through foreground stems; vegetation must not make activation feel blocked or unreliable.
- The live development preview has been opened at `http://127.0.0.1:5174/`.

## Next visual pass

### 1. Make the garden feel more enveloping

- Add density and variety to the interior canopy so greenery occupies more of the spherical background in every direction, including between existing clusters.
- Mix leaf sizes, silhouettes, growth directions and colors. Avoid evenly spaced, identical clumps or a flat green wall. Let some near leaves frame the view, while retaining open sightlines toward drifting produce.
- Strengthen layered depth: small background leaves, larger middle-distance leaves, and occasional near tendrils or fronds. Preserve the feeling that all growth is rooted to the inner shell rather than floating independently.
- Add branches in a restrained bark-brown/olive-brown range if needed to break up the green. Use branching silhouettes, joints, bark grooves and a little warm edge light. Branches should weave through foliage and give objects something to pass behind; avoid turning the world into a bare forest or a rigid cage.
- Keep subtle curved structural cues and plant shadows, with open gaps that preserve depth. Vegetation remains the hero; these visual details do not establish a claimed setting.

### 2. Deepen directional light and foliage detail

- Keep one clear warm directional key light that produces readable shape and cast shadows. Use softer ambient/hemisphere fill to preserve detail in the shadow side without washing out the shadows.
- Tune shadow-camera coverage and map resolution for the whole visible garden. Avoid shadow acne, flicker, hard pixel stair-stepping, and shadows so black they hide leaf color. Check the leaves and branches at both close and far scales.
- Add secondary foliage detail where it helps scale: raised midribs, finer branching veins, slight edge curl, varied surface roughness, and restrained color variation. Keep leaf silhouettes smooth and botanical rather than geometric plates.
- Use subtle translucency/backlight on thin leaves only where it reads as plant tissue. Do not make every leaf glow.

### 3. Give close vegetables richer character

Preserve each vegetable’s readable silhouette at distance, then reveal more detail smoothly as it approaches. Prefer a small set of shared procedural meshes/materials or distance-aware detail over creating a large, unique high-cost model for every pod.

- **Far:** clean silhouette, recognizable color family and a simple highlight.
- **Middle:** visible lobes/ribs, soft color mottling or striping, a shaped stem, and distinct leaf/tendril silhouette.
- **Near/target range:** finer skin speckles or striations, richer roughness/specular response, vein detail on attached leaves, little imperfections, and a warm interior glow that makes target feedback legible.
- Give different pod families distinct forms (for example, curled gourd, root bulb, lantern fruit and spiral pod) rather than relying on hue alone.
- Keep the close-up treatment organic and tactile. Avoid hard square glows, planetary rings, generic sci-fi panels, or excessive metallic shine.
- Ensure added close detail does not change the current reach, overwhelm the reticle, or obscure the pod’s aiming target.

## Interaction and visual safeguards

- Maintain true 360-degree looking from the centered floating viewpoint.
- Keep camera motion comfortable and predictable on mouse and touch.
- Scale/animate approaching produce clearly enough that distance is understandable; reachable produce should glow without relying on color alone.
- Branches may cover part of a pod in the rendered image, but should not intercept the gameplay raycast. Keep enough pod visible to recognize and aim at it.
- Keep contrast around UI text, reticle, score and timer. The entry copy and HUD should remain legible over the richer background.
- Do not restore square sprite artifacts or oversized polygon shards. Use organic geometry, carefully bounded transforms and silhouette checks.
- Preserve responsive performance, especially on phones. Instance repeated leaves and details; use distance-aware detail and shadow quality if needed. If 4096² shadows or the increased canopy produce a visible frame-rate drop, prefer a scalable shadow setting while preserving the desktop-quality look.

## Acceptance criteria for the next pass

1. The interior sphere reads as a densely planted greenhouse in every direction, with visible depth and varied greenery rather than isolated repeated clusters.
2. Brown woody branches provide contrast only where the green canopy needs separation, and some vegetables visibly pass behind foliage/branches.
3. Foreground branches never make vaporizing an oddity impossible when it is centered and within range.
4. At least three levels of produce detail are perceptible during approach, with a clear increase in surface and leaf detail at close range.
5. Directional light gives leaves, stems and produce shape; shadows are visible and soft enough to avoid crushing detail or flickering.
6. HUD and vaporization feedback remain readable, mouse/touch activation still works, and desktop/mobile performance remains usable.
7. Build with `npm run build`; inspect the live preview at desktop and narrow mobile sizes. If appearance or gameplay changes, verify them in the browser rather than relying on the build alone.

## Suggested order of work

1. Inspect `apps/web/src/main.js`, `apps/web/src/style.css`, `PRODUCT.md`, and this handoff spec; capture the current scene before changing it.
2. Improve foliage distribution and branch silhouettes first; check whether brown contrast is necessary after adding greenery.
3. Refine directional shadows and leaf surface detail; check close and far foliage.
4. Add distance-aware vegetable surface/leaf details without changing the catch interaction.
5. Review the 360-degree scene and the UI overlay at desktop and mobile sizes, then build and summarize changes and any performance tradeoffs.
