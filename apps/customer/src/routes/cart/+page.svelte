<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  
  // Redirect to checkout page instead of showing separate cart page
  onMount(() => {
    goto('/checkout');
  });
</script>

<!-- This page redirects to checkout -->
<div>Redirecting to checkout...</div>