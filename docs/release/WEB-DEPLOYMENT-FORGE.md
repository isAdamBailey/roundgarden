# Deploy the web app with Laravel Forge

Roundgarden's web app is a static Vite site. The game logic is JavaScript that runs in each visitor's browser; the production server only needs to serve the built HTML, CSS, JavaScript, and other static files. It does not need a PHP app, database, or long-running Node process.

## Configure the Forge site

1. Create a Forge site using the **Static HTML / HTML** project type and connect this repository.
2. Set the site's web directory (document root) to `public` under the repository checkout. Forge's Nginx site should serve that directory.
3. Make sure Node.js 24.22.2 is available on the server, matching the repository's `.nvmrc`. Node is used during deployment to build the site; it is not needed to serve visitors.
4. In the site's deployment script, use the repository root as the working directory and build before copying the output into `public`:

```sh
cd "$FORGE_SITE_PATH"
git pull origin "$FORGE_SITE_BRANCH"
nvm install 24.22.2
nvm use 24.22.2
npm ci

# Store listing URLs are public and become part of the browser bundle.
# Keep these empty until each matching public listing is live.
export VITE_APP_STORE_URL="${VITE_APP_STORE_URL:-}"
export VITE_MAC_APP_STORE_URL="${VITE_MAC_APP_STORE_URL:-}"
export VITE_GOOGLE_PLAY_URL="${VITE_GOOGLE_PLAY_URL:-}"

npm run build
mkdir -p public
rsync -a --delete apps/web/dist/ public/
```

Set each `VITE_*_URL` in the Forge deployment environment or replace the export's empty fallback with the public store URL. These are not secrets: Vite embeds configured values in the generated JavaScript. Leave a variable empty to keep that platform's badge hidden. The build accepts iPhone/iPad and Mac App Store URLs only on `apps.apple.com`, and Google Play URLs only on `play.google.com`.

The build writes `apps/web/dist`. The `rsync` step publishes that output into Forge's `public` document root and removes stale files there. Keep generated build files out of Git. `privacy.html` and its stylesheet are included in the output; the privacy link works as a normal static page on refresh. Nginx serves the Three.js bundles directly, so do not configure a PHP front controller or use `vite preview` as the production server.

## Before public launch

- Confirm the domain's HTTPS certificate is active in Forge.
- Deploy with all store URL variables empty and confirm only live listings are configured before turning on their badges.
- Visit `/`, play a full round, open `/privacy.html` directly, and verify both pages and their assets load after a hard refresh.
- Recheck the privacy page against the final hosting/logging configuration and any changes to analytics, fonts, SDKs, or third-party services.

## References

- [Forge API site types and deployment scripts](https://forge.laravel.com/api-documentation)
- [Vite static deployment](https://vite.dev/guide/static-deploy)
- [Apple App Store badge guidelines](https://developer.apple.com/app-store/marketing/guidelines/)
- [Google Play marketing resources](https://developer.android.com/distribute/marketing-tools)
