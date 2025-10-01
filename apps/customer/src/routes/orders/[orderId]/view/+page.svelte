<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';

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
  
  // Get order ID from URL params
  $: orderId = $page.params.orderId;
  
  // Mock order data - in real app, this would be fetched from API
  const orderData = {
    id: `UE${orderId}`,
    items: [
      {
        id: 1,
        nameAr: 'طماطم طازجة محلية',
        nameEn: 'Fresh Local Tomatoes',
        quantity: 2,
        price: 5.50,
        image: '🍅'
      },
      {
        id: 2,
        nameAr: 'موز طازج',
        nameEn: 'Fresh Bananas',
        quantity: 1,
        price: 6.75,
        image: '🍌'
      },
      {
        id: 3,
        nameAr: 'خبز توست أبيض',
        nameEn: 'White Toast Bread',
        quantity: 1,
        price: 6.25,
        image: '🍞'
      }
    ],
    subtotal: 18.50,
    deliveryFee: 0,
    total: 18.50,
    status: 'in_transit'
  };

  $: texts = currentLanguage === 'ar' ? {
    title: 'عرض الطلب',
    orderNumber: 'رقم الطلب',
    items: 'المنتجات',
    quantity: 'الكمية',
    price: 'السعر',
    subtotal: 'المجموع الفرعي',
    deliveryFee: 'رسوم التوصيل',
    total: 'المجموع الكلي',
    sar: 'ر.س',
    free: 'مجاني',
    backToTracking: 'العودة للتتبع',
    readOnlyNote: 'هذا عرض فقط - لا يمكن تعديل الطلب'
  } : {
    title: 'View Order',
    orderNumber: 'Order Number',
    items: 'Items',
    quantity: 'Quantity',
    price: 'Price',
    subtotal: 'Subtotal',
    deliveryFee: 'Delivery Fee',
    total: 'Total',
    sar: 'SAR',
    free: 'Free',
    backToTracking: 'Back to Tracking',
    readOnlyNote: 'This is view only - order cannot be modified'
  };

  function goBackToTracking() {
    goto(`/orders/track/${orderId}`);
  }
</script>

<div class="order-view-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <header class="page-header">
    <Button variant="tertiary" size="sm" on:click={goBackToTracking}>
      ← {texts.backToTracking}
    </Button>
    <h1>{texts.title}</h1>
  </header>

  <!-- Order Info -->
  <Card>
    <div class="order-header">
      <h2>{texts.orderNumber}: {orderData.id}</h2>
      <div class="read-only-notice">
        <span class="notice-icon">👁️</span>
        <span>{texts.readOnlyNote}</span>
      </div>
    </div>
  </Card>

  <!-- Order Items -->
  <Card>
    <div class="section">
      <h3>{texts.items}</h3>
      <div class="items-list">
        {#each orderData.items as item}
          <div class="item-row">
            <div class="item-info">
              <div class="item-image">{item.image}</div>
              <div class="item-details">
                <h4>{currentLanguage === 'ar' ? item.nameAr : item.nameEn}</h4>
                <p class="item-quantity">{texts.quantity}: {item.quantity}</p>
              </div>
            </div>
            <div class="item-price">
              {item.price.toFixed(2)} {texts.sar}
            </div>
          </div>
        {/each}
      </div>
    </div>
  </Card>

  <!-- Order Summary -->
  <Card>
    <div class="section">
      <h3>{texts.total}</h3>
      <div class="summary-rows">
        <div class="summary-row">
          <span>{texts.subtotal}</span>
          <span>{orderData.subtotal.toFixed(2)} {texts.sar}</span>
        </div>
        <div class="summary-row">
          <span>{texts.deliveryFee}</span>
          <span>{orderData.deliveryFee === 0 ? texts.free : `${orderData.deliveryFee.toFixed(2)} ${texts.sar}`}</span>
        </div>
        <div class="summary-row total-row">
          <span>{texts.total}</span>
          <span>{orderData.total.toFixed(2)} {texts.sar}</span>
        </div>
      </div>
    </div>
  </Card>
</div>

<style>
  .order-view-container {
    padding: var(--space-4);
    min-height: 100vh;
    background: var(--color-surface);
    max-width: 600px;
    margin: 0 auto;
    padding-bottom: 100px; /* Account for bottom nav */
  }

  .page-header {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    margin-bottom: var(--space-6);
  }

  .page-header h1 {
    margin: 0;
    flex: 1;
    color: var(--color-ink);
  }

  .order-header {
    padding: var(--space-4);
  }

  .order-header h2 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
  }

  .read-only-notice {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    padding: var(--space-3);
    background: var(--color-warning-light, #fff3cd);
    border: 1px solid var(--color-warning, #ffc107);
    border-radius: 8px;
    color: var(--color-warning-dark, #856404);
    font-size: 0.9rem;
  }

  .notice-icon {
    font-size: 1.1rem;
  }

  .section {
    padding: var(--space-4);
  }

  .section h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .items-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .item-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-3);
    border: 1px solid var(--color-border-light);
    border-radius: 8px;
    background: var(--color-background, #f8fafc);
  }

  .item-info {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    flex: 1;
  }

  .item-image {
    width: 50px;
    height: 50px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    background: white;
    border-radius: 8px;
    border: 1px solid var(--color-border-light);
  }

  .item-details h4 {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
    font-size: 1rem;
  }

  .item-quantity {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.9rem;
  }

  .item-price {
    font-weight: 600;
    color: var(--color-primary);
    font-size: 1.1rem;
  }

  .summary-rows {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-2) 0;
    border-bottom: 1px solid var(--color-border-light);
  }

  .summary-row:last-child {
    border-bottom: none;
  }

  .total-row {
    font-weight: 700;
    font-size: 1.1rem;
    color: var(--color-primary);
    border-top: 2px solid var(--color-border);
    padding-top: var(--space-3);
    margin-top: var(--space-2);
  }

  /* Mobile optimizations */
  @media (max-width: 480px) {
    .order-view-container {
      padding: var(--space-3);
    }

    .item-row {
      flex-direction: column;
      align-items: flex-start;
      gap: var(--space-2);
    }

    .item-info {
      width: 100%;
    }

    .item-price {
      align-self: flex-end;
    }
  }
</style>