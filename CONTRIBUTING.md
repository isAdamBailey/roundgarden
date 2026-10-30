# Contributing

## Local setup

Use Node 24.22.2 from `.nvmrc`, then install and start the web workspace from the repository root:

```sh
nvm use
npm ci
npm run dev
```

Build the web app with `npm run build`. The Vite app lives in `apps/web`; product specifications and cross-platform conventions live in `docs`.

## Changes and review

Keep changes focused and describe which issue checklist items they implement. During initial buildout, closely related low-risk items may share a PR if they remain easy to review. Include commands run and their results. For visual or gameplay changes, add desktop and narrow-mobile screenshots or recordings and describe any manual checks that remain.

Do not add external art without recording its source, creator, license, attribution requirements, and local file path in `docs/ASSETS.md`. Keep renderer-specific implementation inside its app unless a cross-platform representation has been agreed and documented.
