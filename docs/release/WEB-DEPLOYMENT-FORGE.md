# Deploy the web app with Laravel Forge

Roundgarden's web app is a static Vite site. The game logic is JavaScript that runs in each visitor's browser; the production server only needs to serve the built HTML, CSS, JavaScript, and other static files. It does not need a PHP app, database, or long-running Node process.

## Configure the Forge site

1. Create a Forge site using the **Static HTML / HTML** project type and connect this repository.
2. Enable Forge zero-downtime deployments. Set **Root directory** to the repository root (`/current` in Forge's path display); do not add `apps/web/dist` to this field. Set **Web directory** to `/apps/web/dist`, so the effective document root is `/current/apps/web/dist`.
3. Node.js is already installed on the server and is used only during deployment to build the site. It is not needed to serve visitors.
4. Add the store URLs to the site's environment as `VITE_APP_STORE_URL` and `VITE_GOOGLE_PLAY_URL`. Use one Apple App Store URL for Apple devices; Apple handles device availability from that listing. Leave a value empty until its public listing exists. Enable Forge's automatic environment sourcing for the deployment script so these values are available during the build.
5. In the site's deployment script, build each new release before activating it. Forge handles fetching the repository and creating the release directory:

```sh
$CREATE_RELEASE()
cd "$FORGE_RELEASE_DIRECTORY"
npm ci
npm run build
$ACTIVATE_RELEASE()
```

These store URLs are public values, not secrets: Vite embeds them in the generated JavaScript at build time. They are not runtime server settings. If you prefer a file-based setup, place them in an untracked `apps/web/.env.production` on the server; Vite reads that file from the web app root during production builds. Never commit a file with live listing URLs. The build accepts Apple App Store URLs only on `apps.apple.com`, and Google Play URLs only on `play.google.com`.

Forge links the site's environment file into the configured web directory before running the deployment script. The tracked `apps/web/dist/.gitkeep` ensures that directory exists in a fresh release; Vite clears the output directory and replaces it with the built site before Forge activates the release. Keep generated build files out of Git. `privacy.html` and its stylesheet are included in the output; the privacy link works as a normal static page on refresh. Nginx serves the Three.js bundles directly, so do not configure a PHP front controller or use `vite preview` as the production server. Use `npm run build` here; `npm run dev` starts Vite's development server and is not the production build.

## Before public launch

- Confirm the domain's HTTPS certificate is active in Forge.
- Deploy with all store URL variables empty and confirm only live listings are configured before turning on their badges.
- Visit `/`, play a full round, open `/privacy.html` directly, and verify both pages and their assets load after a hard refresh.
- Recheck the privacy page against the final hosting/logging configuration and any changes to analytics, fonts, SDKs, or third-party services.

## References

- [Forge zero-downtime deployments](https://laravel.com/blog/forge-zero-downtime-deployments)
- [Forge API site types and deployment scripts](https://forge.laravel.com/api-documentation)
- [Vite static deployment](https://vite.dev/guide/static-deploy)
- [Apple App Store badge guidelines](https://developer.apple.com/app-store/marketing/guidelines/)
- [Google Play marketing resources](https://developer.android.com/distribute/marketing-tools)
