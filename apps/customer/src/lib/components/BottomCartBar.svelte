<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { cartCount, cartTotal } from '$lib/stores/cart.js';
  import { deliveryFeeTiers, calculateDeliveryFee } from '$lib/stores/deliveryFee.js';
  import Button from './Button.svelte';

  let currentLanguage = 'ar';
  let itemCount = 0;
  let total = 0;
  let currentTiers = [];

  // Subscribe to cart updates and delivery tiers
  $: cartCount.subscribe(count => itemCount = count);
  $: cartTotal.subscribe(amount => total = amount);
  $: deliveryFeeTiers.subscribe(tiers => currentTiers = tiers);
  
  // Calculate delivery fee and final total
  $: deliveryFee = calculateDeliveryFee(total, currentTiers);
  $: finalTotal = total + deliveryFee;

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

  $: texts = currentLanguage === 'ar' ? {
    items: 'عنصر',
    total: 'المجموع',
    checkout: 'الدفع',
    sar: 'ر.س'
  } : {
    items: 'items',
    total: 'Total',
    checkout: 'Checkout',
    sar: 'SAR'
  };

  function goToCheckout() {
    goto('/checkout');
  }

  function goToCart() {
    goto('/cart');
  }
</script>

{#if itemCount > 0}
<div class="bottom-cart-bar" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="cart-info" on:click={goToCart}>
    <div class="cart-items">
      <span class="cart-icon">🛒</span>
      <span class="item-count">{itemCount} {texts.items}</span>
    </div>
    <div class="cart-total">
      <span class="total-label">{texts.total}:</span>
      <span class="total-amount">{finalTotal.toFixed(2)} {texts.sar}</span>
      {#if deliveryFee > 0}
        <small class="delivery-included">+{deliveryFee.toFixed(2)} {currentLanguage === 'ar' ? 'توصيل' : 'delivery'}</small>
      {/if}
    </div>
  </div>
  
  <Button variant="primary" size="md" on:click={goToCheckout}>
    {texts.checkout}
  </Button>
</div>
{/if}

<style>
  .bottom-cart-bar {
    position: fixed;
    bottom: 80px; /* Above bottom navigation */
    left: 0;
    right: 0;
    background: white;
    border-top: 1px solid var(--color-border);
    box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
    padding: 1rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    z-index: 90;
    animation: slideUp 0.3s ease-out;
  }

  @keyframes slideUp {
    from {
      transform: translateY(100%);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }

  .cart-info {
    flex: 1;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .cart-items {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .cart-icon {
    font-size: 1.2rem;
  }

  .item-count {
    font-size: 0.9rem;
    color: var(--color-ink);
    font-weight: 600;
  }

  .cart-total {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex-wrap: wrap;
  }

  .total-label {
    font-size: 0.9rem;
    color: var(--color-ink-light);
  }

  .delivery-included {
    font-size: 0.75rem;
    color: var(--color-primary);
    margin-left: 0.25rem;
  }

  .total-amount {
    font-size: 1.1rem;
    font-weight: 700;
    color: var(--color-primary);
  }

  /* Mobile optimizations */
  @media (max-width: 480px) {
    .bottom-cart-bar {
      padding: 0.75rem;
    }

    .cart-info {
      gap: 0.1rem;
    }

    .item-count, .total-label {
      font-size: 0.85rem;
    }

    .total-amount {
      font-size: 1rem;
    }
  }
</style>