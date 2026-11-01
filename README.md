# Roundgarden

A Three.js + Vite game about a garden that goes all the way around. See [issue #1](https://github.com/isAdamBailey/roundgarden/issues/1) for the implementation plan.

Use Node 24.22.2 from `.nvmrc` for development.

```sh
nvm use
npm install
npm run dev
```

The browser app lives in `apps/web`. Build it from the repository root with `npm run build`. See [contributor instructions](CONTRIBUTING.md) and the [shared visual and interaction contract](docs/VISUAL-AND-INTERACTION-CONTRACT.md).

The public landing page links directly into the browser game and includes a privacy page at `/privacy.html`. Store badges stay hidden until their public listing URLs are configured; see [`apps/web/.env.example`](apps/web/.env.example). For the static Laravel Forge build and deployment setup, see [the Forge runbook](docs/release/WEB-DEPLOYMENT-FORGE.md).
