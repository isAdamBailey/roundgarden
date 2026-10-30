# Versioning and asset records

## Versioning

Use semantic versioning for released app artifacts: increment the patch number for compatible fixes, the minor number for compatible features, and the major number for incompatible changes. Keep the web workspace package version and native app marketing versions aligned for a coordinated release; platform build numbers remain platform-specific and increase for every submitted build. Before the first public release, document the chosen initial version and how coordinated releases will be tagged.

## Asset records

The current garden, plants, produce, and effects are generated in code; no external art files are currently checked in. When adding an external asset, add a row to `docs/ASSETS.md` before merging. Record the asset name and repository path, creator, original source URL, license and version, acquisition date, required attribution or modifications, and the apps that use it. Include the original license file where its terms require redistribution.

Generated code and assets created specifically for Roundgarden should be identified as project-created. Do not assume that a web renderer's procedural geometry or material can be reused directly by a native renderer; document the source representation and any platform-specific derivatives.
