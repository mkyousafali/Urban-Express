import adapter from '@sveltejs/adapter-auto';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    adapter: adapter(),
    alias: {
      '@urban-express/ui': '../../../packages/ui/src'
    }
  }
};

export default config;