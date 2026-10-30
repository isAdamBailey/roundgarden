# Shared assets

This workspace is reserved for cross-platform asset conventions and source assets. Record licenses and attribution alongside any external asset before adding it.

The starter produce catalog is currently renderer-independent Swift data in `packages/game-core` (`GardenContent.starterOddities`): stable integer IDs, a produce family, a 100/250/500 point value, a scale cue, and a palette index. Native renderers create their own meshes from those definitions. Keep authored source files and license/attribution records here when art assets are added. The current iOS foliage and produce meshes are procedural prototypes and have no external asset dependencies.
