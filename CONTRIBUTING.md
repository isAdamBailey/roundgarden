# Contributing

## Local setup

Use Node 24.22.2 from `.nvmrc`, then install and start the web workspace from the repository root:

```sh
nvm use
npm ci
npm run dev
```

Build the web app with `npm run build`. The Vite app lives in `apps/web`; product specifications and cross-platform conventions live in `docs`.

## Native spike checks

The RealityKit spike requires Xcode. Format its Swift sources and check formatting with:

```sh
xcrun swift-format format --in-place spikes/RealityKitSpike/RealityKitSpike/*.swift
xcrun swift-format lint --strict spikes/RealityKitSpike/RealityKitSpike/*.swift
```

Build the iOS Simulator and macOS targets with the commands in `.github/workflows/native-spike.yml`. These prototype builds disable code signing, so simulator and generic macOS builds do not need a signing identity. Installing on a physical iPhone or iPad requires configuring a local Apple development team and provisioning profile in Xcode.

## Changes and review

Keep changes focused and describe which issue checklist items they implement. During initial buildout, closely related low-risk items may share a PR if they remain easy to review. Include commands run and their results. For visual or gameplay changes, add desktop and narrow-mobile screenshots or recordings and describe any manual checks that remain.

### Define and report completion

Before starting a slice, identify the issue checklist items, the observable result that completes each item, the required validation, and any prerequisite phase gate. Keep the slice bounded to those outcomes.

Finish the implementation, required validation, self-review, and issue progress-log update before handing off. Mark an item complete only when its result and validation are complete and the evidence is recorded. A phase is complete only when every required item at its gate is complete, the work is reviewed, and any approved deviations have an explicit follow-up. A merged PR alone does not pass a phase gate.

Do not stop without a clear outcome. If blocked, report the specific blocker, what was attempted, the evidence, what remains, and the owner decision or external event needed to continue. Complete independent work that does not depend on the blocker.

End a work session with one clear state: **complete** (with evidence), **draft PR** (with reason, remaining work, readiness condition, and next action), or **blocked** (with evidence and the needed unblock). Update the issue progress log with the PR link, validation/review status, follow-ups, and next action.

### Draft pull requests

Open a draft only when there is a concrete reason it is not ready for review. State the exact readiness condition and list remaining work; do not open an empty or unexplained draft just to signal progress. Use every field in the PR template, especially the draft reason, passed and pending validation, and next action.

Do not add external art without recording its source, creator, license, attribution requirements, and local file path in `docs/ASSETS.md`. Keep renderer-specific implementation inside its app unless a cross-platform representation has been agreed and documented.
