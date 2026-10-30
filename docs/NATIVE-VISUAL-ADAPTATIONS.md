# Native garden visual adaptations

The web garden remains the visual reference. The native apps share one RealityKit
scene and adapt repeated geometry and detail to the device rather than copying
the Three.js implementation line for line.

## Foliage

Both renderers use a spherical canopy, layered leaves, visible midribs, warm
flowers, curling vines, and woody growth. RealityKit groups repeated leaves,
stems, veins, and branches by mesh and material. The native scene also branches
some woody runners and adds lateral leaf veins to a subset of the canopy so
high-frequency detail does not multiply across every leaf.

On systems with RealityKit low-level mesh instancing, the native canopy uses
900 main plants and 1,800 inner-glass clusters. The fallback path uses 180
plants and 300 clusters to keep the number of individual entities bounded.

## Produce

Pear, berry, and plum families use separate procedural profiles and rib
frequencies. Each pod has a three-leaf crown and a curled tendril. A grouped
freckle mesh appears inside 19 world units; a warm center glow appears inside
12. Those distance thresholds follow the web renderer's close-detail steps.
These details are children of the produce model, so they follow the approaching
pod without changing its aim target or reach.

## Review and remaining measurements

The web and native captures were reviewed side by side. The web still carries
more fine leaf and woody-branch detail; the native version favors a lower count
of secondary veins and a small number of grouped near-produce details to fit its
instancing fallback. This is an implementation adaptation, not a change to the
garden's spherical, whimsical direction or the produce-only targeting rule.

The screenshots and builds establish visual structure and platform support,
not frame-time or memory performance. Measure those on representative physical
iPhone/iPad devices and a Mac before release, as tracked in issue #1, Phase 7.
