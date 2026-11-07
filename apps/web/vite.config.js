import { defineConfig } from 'vite';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webRoot = fileURLToPath(new URL('.', import.meta.url));
const androidBuild = process.env.ROUNDGARDEN_ANDROID_BUILD === 'true';

export default defineConfig({
  root: webRoot,
  // Android needs relative URLs because the game is served from a subdirectory.
  base: androidBuild ? './' : '/',
  build: {
    rollupOptions: {
      input: androidBuild
        ? resolve(webRoot, 'index.html')
        : {
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
