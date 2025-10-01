import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    port: 3000
  },
  resolve: {
    alias: {
      '@urban-express/ui': '../../../packages/ui/src'
    }
  }
});