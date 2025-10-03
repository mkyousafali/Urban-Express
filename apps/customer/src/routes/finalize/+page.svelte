<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { cartStore, cartCount, cartTotal } from '$lib/stores/cart.js';
  
  let currentLanguage = 'ar';
  let cartItems = [];
  
  // Delivery service configuration
  const deliveryService = {
    isActive: true,
    operatingHours: {
      startTime: "08:00",
      endTime: "23:00"
    },
    minimumOrder: 50,
    is24Hours: false,
    deliveryFee: 15.00,
    displayAr: "التوصيل متاح من 8:00 ص إلى 11:00 م",
    displayEn: "Delivery available from 8:00 AM to 11:00 PM"
  };
  
  // Use reactive declarations for store values
  $: total = $cartTotal;
  $: itemCount = $cartCount;

  // Load language from localStorage and listen for changes
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Listen for language changes from other tabs/pages
    function handleStorageChange(event) {
      if (event.key === 'language') {
        currentLanguage = event.newValue || 'ar';
        document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
        document.documentElement.lang = currentLanguage;
      }
    }

    window.addEventListener('storage', handleStorageChange);
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  });

  // Subscribe to cart store
  onMount(() => {
    const unsubscribe = cartStore.subscribe(items => {
      cartItems = items;
      // If cart is empty, redirect to home
      if (items.length === 0) {
        goto('/');
      }
    });

    return () => {
      unsubscribe();
    };
  });

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'إنهاء طلبك',
    subtitle: 'اختر طريقة استلام طلبك',
    pickupFromStore: 'الاستلام من المتجر',
    pickupDescription: 'ادفع في المتجر',
    pickupBenefits: [],
    delivery: 'التوصيل',
    deliveryDescription: 'سنوصل طلبك إلى موقعك',
    deliveryBenefits: ['توصيل لباب منزلك', 'دفع عند الاستلام', 'تتبع الطلب'],
    orderSummary: 'ملخص الطلب',
    items: 'عنصر',
    total: 'المجموع',
    sar: 'ر.س',
    continue: 'متابعة',
    backToCart: 'العودة إلى السلة',
    collectionLocation: '',
    estimatedTime: '',
    serviceUnavailable: 'الخدمة غير متاحة حالياً',
    minimumOrder: 'الحد الأدنى للطلب',
    operatingHours: 'ساعات العمل',
    currentTime: 'الوقت الحالي'
  } : {
    title: 'Finalize Your Order',
    subtitle: 'Choose how you want to receive your order',
    pickupFromStore: 'Pick Up From Store',
    pickupDescription: 'Pay at store',
    pickupBenefits: [],
    delivery: 'Delivery',
    deliveryDescription: 'We will deliver your order to your location',
    deliveryBenefits: ['Door-to-door delivery', 'Cash on delivery', 'Track your order'],
    orderSummary: 'Order Summary',
    items: 'items',
    total: 'Total',
    sar: 'SAR',
    continue: 'Continue',
    backToCart: 'Back to Cart',
    collectionLocation: '',
    estimatedTime: '',
    serviceUnavailable: 'Service currently unavailable',
    minimumOrder: 'Minimum order',
    operatingHours: 'Operating hours',
    currentTime: 'Current time'
  };

  // Helper function to check if delivery service is available
  function isDeliveryServiceAvailable() {
    if (!deliveryService.isActive) return false;
    if (deliveryService.is24Hours) return true;
    
    const now = new Date();
    const currentTimeStr = now.toTimeString().slice(0, 5); // HH:MM format
    
    // Convert time to minutes for easier comparison
    function timeToMinutes(timeStr) {
      const [hours, minutes] = timeStr.split(':').map(Number);
      return hours * 60 + minutes;
    }
    
    const currentMinutes = timeToMinutes(currentTimeStr);
    const startMinutes = timeToMinutes(deliveryService.operatingHours.startTime);
    const endMinutes = timeToMinutes(deliveryService.operatingHours.endTime);
    
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  // Check if order meets minimum requirements
  function meetsMinimumOrder() {
    return total >= deliveryService.minimumOrder;
  }

  // Get service status message
  function getDeliveryStatusMessage() {
    if (!deliveryService.isActive) {
      return currentLanguage === 'ar' ? 'خدمة التوصيل غير متاحة حالياً' : 'Delivery service is currently unavailable';
    }
    
    if (!meetsMinimumOrder()) {
      return currentLanguage === 'ar' 
        ? `الحد الأدنى للطلب ${deliveryService.minimumOrder} ريال` 
        : `Minimum order ${deliveryService.minimumOrder} SAR`;
    }
    
    if (!isDeliveryServiceAvailable()) {
      return currentLanguage === 'ar' 
        ? 'خدمة التوصيل مغلقة حالياً'
        : 'Delivery service is currently closed';
    }
    
    return null; // Service is available
  }

  function choosePickup() {
    goto('/pickup');
  }

  function chooseDelivery() {
    const statusMessage = getDeliveryStatusMessage();
    if (statusMessage) {
      alert(statusMessage);
      return;
    }
    goto('/checkout');
  }

  function goBack() {
    history.back();
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="finalize-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Header -->
  <header class="page-header">
    <Button variant="outline" size="sm" on:click={goBack}>
      ← {texts.backToCart}
    </Button>
    <h1>{texts.title}</h1>
    <div></div> <!-- Spacer for flexbox -->
  </header>

  <p class="subtitle">{texts.subtitle}</p>

  <!-- Order Summary -->
  <Card>
    <div class="order-summary">
      <h3>{texts.orderSummary}</h3>
      <div class="summary-details">
        <div class="summary-row">
          <span>{itemCount} {texts.items}</span>
          <span>{total.toFixed(2)} {texts.sar}</span>
        </div>
        <div class="summary-row total-row">
          <span>{texts.total}</span>
          <span>{total.toFixed(2)} {texts.sar}</span>
        </div>
      </div>
    </div>
  </Card>

  <!-- Fulfillment Options -->
  <div class="options-section">
    <!-- Pick Up From Store -->
    <Card>
      <button class="option-card pickup" on:click={choosePickup} type="button">
        <div class="option-icon">🏪</div>
        <div class="option-content">
          <h3>{texts.pickupFromStore}</h3>
          <p class="option-description">{texts.pickupDescription}</p>
          <ul class="benefits-list">
            {#each texts.pickupBenefits as benefit}
              <li>✓ {benefit}</li>
            {/each}
          </ul>
          <div class="store-info">
            <p class="store-location">{texts.collectionLocation}</p>
            <p class="estimated-time">{texts.estimatedTime}</p>
          </div>
        </div>
        <div class="option-arrow">›</div>
      </button>
    </Card>

    <!-- Delivery -->
    <Card>
      <button 
        class="option-card delivery {getDeliveryStatusMessage() ? 'unavailable' : ''}" 
        on:click={chooseDelivery} 
        type="button"
        disabled={!!getDeliveryStatusMessage()}
      >
        <div class="option-icon">🚚</div>
        <div class="option-content">
          <h3>{texts.delivery}</h3>
          <p class="option-description">{texts.deliveryDescription}</p>
          <ul class="benefits-list">
            {#each texts.deliveryBenefits as benefit}
              <li>✓ {benefit}</li>
            {/each}
          </ul>
          
          <!-- Operating Hours -->
          <div class="service-info">
            <div class="operating-hours">
              <span class="label">{texts.operatingHours}:</span>
              <span class="time">
                {currentLanguage === 'ar' ? deliveryService.displayAr : deliveryService.displayEn}
              </span>
            </div>
            
            <!-- Minimum Order -->
            <div class="minimum-order">
              <span class="label">{texts.minimumOrder}:</span>
              <span class="amount">{deliveryService.minimumOrder} {texts.sar}</span>
            </div>
            
            <!-- Service Status -->
            {#if getDeliveryStatusMessage()}
              <div class="service-status unavailable">
                ⚠️ {getDeliveryStatusMessage()}
              </div>
            {:else}
              <div class="service-status available">
                ✅ {currentLanguage === 'ar' ? 'متاح الآن' : 'Available now'}
              </div>
            {/if}
          </div>
          
          <div class="delivery-note">
            <p>💰 رسوم التوصيل ستحدد في الصفحة التالية</p>
            <p>💰 Delivery charges will be determined on the next page</p>
          </div>
        </div>
        <div class="option-arrow">›</div>
      </button>
    </Card>
  </div>
</div>

<style>
  .finalize-container {
    min-height: 100vh;
    background: var(--color-surface);
    padding: var(--space-4);
    max-width: 600px;
    margin: 0 auto;
    padding-top: calc(60px + 1rem);
    padding-bottom: calc(80px + 1rem); /* Account for bottom navigation */
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-4);
  }

  .page-header h1 {
    margin: 0;
    color: var(--color-ink);
    font-size: 1.5rem;
  }

  .subtitle {
    text-align: center;
    color: var(--color-ink-light);
    margin-bottom: var(--space-6);
    font-size: 1.1rem;
  }

  .order-summary {
    padding: var(--space-4);
  }

  .order-summary h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
    font-size: 1.1rem;
    border-bottom: 1px solid var(--color-border);
    padding-bottom: var(--space-2);
  }

  .summary-details {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: var(--color-ink-light);
  }

  .total-row {
    font-weight: 600;
    color: var(--color-ink);
    border-top: 1px solid var(--color-border);
    padding-top: var(--space-2);
    margin-top: var(--space-2);
    font-size: 1.1rem;
  }

  .options-section {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
    margin-top: var(--space-6);
  }

  .option-card {
    display: flex;
    align-items: flex-start;
    gap: var(--space-4);
    padding: var(--space-4);
    cursor: pointer;
    transition: all 0.2s ease;
    border-radius: var(--radius-lg);
    border: none;
    background: transparent;
    width: 100%;
    text-align: left;
  }

  .option-card:hover {
    background: var(--color-surface-variant);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .option-icon {
    font-size: 2.5rem;
    flex-shrink: 0;
  }

  .option-content {
    flex: 1;
  }

  .option-content h3 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
    font-size: 1.2rem;
  }

  .option-description {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink-light);
    line-height: 1.4;
  }

  .benefits-list {
    list-style: none;
    padding: 0;
    margin: 0 0 var(--space-3) 0;
  }

  .benefits-list li {
    margin-bottom: var(--space-1);
    color: var(--color-success-dark);
    font-weight: 500;
    font-size: 0.9rem;
  }

  .store-info, .delivery-note {
    background: var(--color-surface-variant);
    padding: var(--space-2);
    border-radius: var(--radius-md);
    margin-top: var(--space-2);
  }

  .store-location, .estimated-time {
    margin: 0;
    font-size: 0.85rem;
    color: var(--color-ink-light);
  }

  .store-location {
    margin-bottom: var(--space-1);
  }

  .delivery-note p {
    margin: 0;
    font-size: 0.85rem;
    color: var(--color-ink-light);
  }

  .delivery-note p:first-child {
    margin-bottom: var(--space-1);
  }

  /* Service info styles */
  .service-info {
    margin: var(--space-3) 0;
    padding: var(--space-2);
    background: var(--color-surface-variant);
    border-radius: var(--radius-sm);
    font-size: 0.85rem;
  }

  .operating-hours, .minimum-order {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-1);
  }

  .operating-hours .label, .minimum-order .label {
    color: var(--color-ink-light);
    font-weight: 500;
  }

  .operating-hours .time, .minimum-order .amount {
    color: var(--color-ink);
    font-weight: 600;
  }

  .service-status {
    margin-top: var(--space-2);
    padding: var(--space-1) var(--space-2);
    border-radius: var(--radius-sm);
    font-size: 0.8rem;
    font-weight: 500;
    text-align: center;
  }

  .service-status.available {
    background: rgba(34, 197, 94, 0.1);
    color: #059669;
    border: 1px solid rgba(34, 197, 94, 0.2);
  }

  .service-status.unavailable {
    background: rgba(239, 68, 68, 0.1);
    color: #dc2626;
    border: 1px solid rgba(239, 68, 68, 0.2);
  }

  /* Unavailable option styles */
  .option-card.unavailable {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .option-card.unavailable:hover {
    background: transparent;
    transform: none;
    box-shadow: none;
  }

  .option-arrow {
    font-size: 1.5rem;
    color: var(--color-ink-light);
    align-self: center;
  }

  .pickup .option-icon {
    color: #f59e0b;
  }

  .delivery .option-icon {
    color: var(--color-primary);
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .finalize-container {
      padding: var(--space-2);
      padding-top: calc(60px + 0.5rem);
      padding-bottom: calc(80px + 0.5rem);
    }

    .page-header {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .page-header h1 {
      text-align: center;
    }

    .option-card {
      flex-direction: column;
      text-align: center;
    }

    .option-arrow {
      align-self: center;
      transform: rotate(90deg);
    }
  }
</style>