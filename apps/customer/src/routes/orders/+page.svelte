<script>
  import { onMount, onDestroy } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { cancellationSettings, cancellationActions } from '$lib/stores/cancellationSettings.js';
  
  let currentLanguage = 'ar';
  let currentCancellationSettings = {};
  let cancellationTimers = {};

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
  
  const orders = [
    {
      id: '#2847',
      status: 'delivered',
      items: 'مستندات مهمة',
      itemsEn: 'Important documents',
      destination: 'حي العليا',
      destinationEn: 'Al-Olaya District',
      amount: 45.00,
      date: '2024-09-28',
      deliveredAt: '2024-09-28T14:30:00'
    },
    {
      id: '#2856',
      status: 'in_transit',
      items: 'طرد شخصي',
      itemsEn: 'Personal package',
      destination: 'حي الملز',
      destinationEn: 'Al-Malaz District',
      amount: 35.00,
      date: '2024-10-01',
      eta: '15:30'
    }
  ];

  $: texts = currentLanguage === 'ar' ? {
    title: 'طلباتي',
    delivered: 'تم التسليم',
    inTransit: 'قيد التوصيل',
    pending: 'في الانتظار',
    trackOrder: 'تتبع الطلب',
    reorder: 'إعادة الطلب',
    viewReceipt: 'عرض الطلب',
    noOrders: 'لا توجد طلبات',
    startShopping: 'ابدأ التسوق'
  } : {
    title: 'My Orders',
    delivered: 'Delivered',
    inTransit: 'In Transit',
    pending: 'Pending',
    trackOrder: 'Track Order',
    reorder: 'Reorder',
    viewReceipt: 'View Order',
    noOrders: 'No orders found',
    startShopping: 'Start Shopping'
  };

  function getStatusColor(status) {
    switch(status) {
      case 'delivered': return 'var(--color-success)';
      case 'in_transit': return 'var(--color-primary)';
      case 'pending': return 'var(--color-warning)';
      default: return 'var(--color-ink-light)';
    }
  }

  function getStatusText(status) {
    switch(status) {
      case 'delivered': return texts.delivered;
      case 'in_transit': return texts.inTransit;
      case 'pending': return texts.pending;
      default: return status;
    }
  }

  function handleTrackOrder(orderId) {
    goto(`/orders/track/${orderId.replace('#', '')}`);
  }

  function handleReorder(order) {
    // Add to cart logic
    goto('/cart');
  }
</script>

<div class="orders-container">
  <header class="page-header">
    <h1>{texts.title}</h1>
  </header>

  {#if orders.length === 0}
    <div class="empty-orders">
      <p>{texts.noOrders}</p>
      <Button on:click={() => goto('/products')}>{texts.startShopping}</Button>
    </div>
  {:else}
    <div class="orders-list">
      {#each orders as order}
        <Card>
          <div class="order-card">
            <div class="order-header">
              <div class="order-id">{order.id}</div>
              <div class="order-status" style="color: {getStatusColor(order.status)}">
                {getStatusText(order.status)}
              </div>
            </div>
            
            <div class="order-details">
              <h3>{currentLanguage === 'ar' ? order.items : order.itemsEn}</h3>
              
              <div class="order-amount">{order.amount.toFixed(2)} ر.س</div>
            </div>
            
            <div class="order-actions">
              {#if order.status === 'in_transit'}
                <Button size="sm" on:click={() => handleTrackOrder(order.id)}>
                  {texts.trackOrder}
                </Button>
              {/if}
              
              {#if order.status === 'delivered'}
                <Button variant="secondary" size="sm">
                  {texts.viewReceipt}
                </Button>
              {/if}
              
              <Button variant="tertiary" size="sm" on:click={() => handleReorder(order)}>
                {texts.reorder}
              </Button>
            </div>
          </div>
        </Card>
      {/each}
    </div>
  {/if}
</div>

<style>
  .orders-container {
    padding: var(--space-4);
    min-height: 100vh;
    background: var(--color-surface);
  }

  .page-header {
    text-align: center;
    margin-bottom: var(--space-6);
  }

  .empty-orders {
    text-align: center;
    padding: var(--space-8);
  }

  .orders-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
    max-width: 600px;
    margin: 0 auto;
  }

  .order-card {
    padding: var(--space-4);
  }

  .order-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-3);
  }

  .order-id {
    font-weight: 600;
    color: var(--color-ink);
  }

  .order-status {
    font-size: 0.875rem;
    font-weight: 500;
  }

  .order-details h3 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
  }

  .destination, .eta {
    color: var(--color-ink-light);
    font-size: 0.875rem;
    margin: var(--space-1) 0;
  }

  .order-amount {
    color: var(--color-primary);
    font-weight: 600;
    margin: var(--space-2) 0;
  }

  .order-actions {
    display: flex;
    gap: var(--space-2);
    margin-top: var(--space-4);
    flex-wrap: wrap;
  }
</style>