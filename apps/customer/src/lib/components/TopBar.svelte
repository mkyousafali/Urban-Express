<script>
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { cartCount } from '$lib/stores/cart.js';

  let currentLanguage = 'ar';
  let notificationCount = 2;
  let cartItemCount = 0;

  // Subscribe to cart count updates
  $: cartCount.subscribe(count => cartItemCount = count);

  // Load language from localStorage
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }
  });

  // Listen for language changes
  function handleStorageChange(event) {
    if (event.key === 'language') {
      currentLanguage = event.newValue || 'ar';
    }
  }

  onMount(() => {
    window.addEventListener('storage', handleStorageChange);
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  });

  function toggleLanguage() {
    const newLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
    currentLanguage = newLanguage;
    localStorage.setItem('language', newLanguage);
    
    // Update document direction
    document.documentElement.dir = newLanguage === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = newLanguage;
    
    // Dispatch storage event for other components
    window.dispatchEvent(new StorageEvent('storage', {
      key: 'language',
      newValue: newLanguage
    }));
  }

  function goToNotifications() {
    goto('/notifications');
  }

  function goToCart() {
    goto('/cart');
  }

  $: texts = currentLanguage === 'ar' ? {
    appName: 'أوربان إكسبرس',
    language: 'En'
  } : {
    appName: 'Urban Express',
    language: 'عر'
  };
</script>

<header class="top-bar">
  <div class="top-bar-content">
    <!-- App Logo -->
    <div class="app-brand">
      <div class="logo">
        <img src="/logo.png" alt="Urban Express Logo" />
      </div>
    </div>

    <!-- Right side actions -->
    <div class="top-actions">
      <!-- Language Toggle -->
      <button class="language-btn" on:click={toggleLanguage}>
        {texts.language}
      </button>

      <!-- Cart -->
      <button class="cart-btn" on:click={goToCart}>
        <span class="cart-icon">🛒</span>
        {#if cartItemCount > 0}
          <span class="cart-badge">{cartItemCount}</span>
        {/if}
      </button>

      <!-- Notifications -->
      <button class="notification-btn" on:click={goToNotifications}>
        <span class="notification-icon">🔔</span>
        {#if notificationCount > 0}
          <span class="notification-badge">{notificationCount}</span>
        {/if}
      </button>
    </div>
  </div>
</header>

<style>
  .top-bar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background: white;
    border-bottom: 1px solid var(--color-border-light);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    z-index: 100;
    height: 60px;
  }

  .top-bar-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: 100%;
    padding: 0 1rem;
    max-width: 1200px;
    margin: 0 auto;
  }

  .app-brand {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .logo {
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .logo img {
    height: 48px;
    width: auto;
    object-fit: contain;
  }

  .app-name {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--color-primary);
    margin: 0;
  }

  .top-actions {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .language-btn {
    padding: 0.5rem 1rem;
    background: var(--color-surface);
    border: 2px solid var(--color-border);
    border-radius: 8px;
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--color-ink);
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .language-btn:hover {
    border-color: var(--color-primary);
    background: var(--color-primary-light);
  }

  .cart-btn {
    position: relative;
    padding: 0.5rem;
    background: none;
    border: none;
    cursor: pointer;
    border-radius: 8px;
    transition: background-color 0.2s ease;
  }

  .cart-btn:hover {
    background: var(--color-surface);
  }

  .cart-icon {
    font-size: 1.25rem;
  }

  .cart-badge {
    position: absolute;
    top: 0;
    right: 0;
    background: var(--color-primary);
    color: white;
    font-size: 0.7rem;
    font-weight: 600;
    padding: 0.15rem 0.4rem;
    border-radius: 10px;
    min-width: 16px;
    text-align: center;
    line-height: 1;
  }

  .notification-btn {
    position: relative;
    padding: 0.5rem;
    background: none;
    border: none;
    cursor: pointer;
    border-radius: 8px;
    transition: background-color 0.2s ease;
  }

  .notification-btn:hover {
    background: var(--color-surface);
  }

  .notification-icon {
    font-size: 1.25rem;
  }

  .notification-badge {
    position: absolute;
    top: 0;
    right: 0;
    background: var(--color-accent);
    color: white;
    font-size: 0.7rem;
    font-weight: 600;
    padding: 0.15rem 0.4rem;
    border-radius: 10px;
    min-width: 16px;
    text-align: center;
    line-height: 1;
  }

  /* Add top padding to body content to account for fixed header */
  :global(body) {
    padding-top: 60px;
  }

  /* Responsive adjustments */
  @media (max-width: 480px) {
    .top-bar-content {
      padding: 0 0.75rem;
    }

    .app-name {
      font-size: 1.1rem;
    }

    .logo {
      font-size: 1.6rem;
    }

    .top-actions {
      gap: 0.75rem;
    }

    .language-btn {
      padding: 0.4rem 0.8rem;
      font-size: 0.85rem;
    }
  }
</style>