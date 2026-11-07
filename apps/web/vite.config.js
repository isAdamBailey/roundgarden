import { defineConfig } from 'vite';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webRoot = fileURLToPath(new URL('.', import.meta.url));

export default defineConfig({
  root: webRoot,
  // Android bundles this build under android_asset/game, so asset URLs must
  // remain relative to the packaged index.html instead of the domain root.
  base: process.env.ROUNDGARDEN_ANDROID_BUILD === 'true' ? './' : '/',
  build: {
    rollupOptions: {
      input: {
        main: resolve(webRoot, 'index.html'),
        privacy: resolve(webRoot, 'privacy.html'),
        support: resolve(webRoot, 'support.html')
      },
      output: {
        manualChunks: (id) => id.includes('/node_modules/three/') ? 'three' : undefined
      }
    }
  }
});
