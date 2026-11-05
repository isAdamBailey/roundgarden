import { defineConfig } from 'vite';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webRoot = fileURLToPath(new URL('.', import.meta.url));

export default defineConfig({
  root: webRoot,
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
