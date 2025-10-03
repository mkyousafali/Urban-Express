<script>
  import '../app.css';
  import { page } from '$app/stores';
  import BottomNav from '$lib/components/BottomNav.svelte';
  import TopBar from '$lib/components/TopBar.svelte';
  import BottomCartBar from '$lib/components/BottomCartBar.svelte';

  // Pages that should show navigation
  $: showNavigation = !$page.url.pathname.startsWith('/auth/');
  // Hide cart bar on checkout, finalize, pickup, and orders pages
  $: showCartBar = showNavigation && 
    !$page.url.pathname.startsWith('/checkout') && 
    !$page.url.pathname.startsWith('/finalize') && 
    !$page.url.pathname.startsWith('/pickup') &&
    !$page.url.pathname.startsWith('/orders');
</script>

{#if showNavigation}
  <TopBar />
{/if}

<main>
  <slot />
</main>

{#if showCartBar}
  <BottomCartBar />
{/if}
{#if showNavigation}
  <BottomNav />
{/if}

<style>
  main {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }
</style>