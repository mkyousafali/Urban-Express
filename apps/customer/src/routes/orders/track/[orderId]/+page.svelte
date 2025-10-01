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
  
  // Mock order data
  const orderData = {
    id: `#${orderId}`,
    status: 'in_transit',
    items: 'طرد شخصي',
    itemsEn: 'Personal package',
    pickupAddress: 'شارع الملك فهد، الرياض',
    pickupAddressEn: 'King Fahd Street, Riyadh',
    deliveryAddress: 'حي الملز، الرياض',
    deliveryAddressEn: 'Al-Malaz District, Riyadh',
    amount: 35.00,
    driver: {
      name: 'محمد العلي',
      nameEn: 'Mohammed Al-Ali',
      phone: '0501234567',
      rating: 4.8,
      vehicleType: 'دراجة نارية',
      vehicleTypeEn: 'Motorcycle'
    },
    timeline: [
      {
        status: 'order_placed',
        titleAr: 'تم تأكيد الطلب',
        titleEn: 'Order confirmed',
        time: '2024-10-01T12:00:00',
        completed: true
      },
      {
        status: 'driver_assigned',
        titleAr: 'تم تعيين السائق',
        titleEn: 'Driver assigned',
        time: '2024-10-01T12:30:00',
        completed: true
      },
      {
        status: 'pickup_completed',
        titleAr: 'تم الاستلام',
        titleEn: 'Picked up',
        time: '2024-10-01T13:15:00',
        completed: true
      },
      {
        status: 'in_transit',
        titleAr: 'في الطريق',
        titleEn: 'In transit',
        time: '2024-10-01T13:20:00',
        completed: false,
        current: true
      },
      {
        status: 'delivered',
        titleAr: 'تم التسليم',
        titleEn: 'Delivered',
        time: null,
        completed: false
      }
    ],
    estimatedArrival: '15:30',
    currentLocation: 'شارع العليا',
    currentLocationEn: 'Al-Olaya Street'
  };

  $: texts = currentLanguage === 'ar' ? {
    title: 'تتبع الطلب',
    orderDetails: 'تفاصيل الطلب',
    driverInfo: 'معلومات السائق',
    trackingInfo: 'معلومات التتبع',
    from: 'من',
    to: 'إلى',
    estimatedArrival: 'الوصول المتوقع',
    currentLocation: 'الموقع الحالي',
    amount: 'المبلغ',
    rating: 'التقييم',
    vehicleType: 'نوع المركبة',
    callDriver: 'اتصل بالسائق',
    chatDriver: 'راسل السائق',
    backToOrders: 'العودة للطلبات',
    orderTimeline: 'مراحل الطلب'
  } : {
    title: 'Track Order',
    orderDetails: 'Order Details',
    driverInfo: 'Driver Information',
    trackingInfo: 'Tracking Information',
    from: 'From',
    to: 'To',
    estimatedArrival: 'Estimated Arrival',
    currentLocation: 'Current Location',
    amount: 'Amount',
    rating: 'Rating',
    vehicleType: 'Vehicle Type',
    callDriver: 'Call Driver',
    chatDriver: 'Chat with Driver',
    backToOrders: 'Back to Orders',
    orderTimeline: 'Order Timeline'
  };

  function formatTime(timeString) {
    if (!timeString) return '';
    const time = new Date(timeString);
    return time.toLocaleTimeString(currentLanguage === 'ar' ? 'ar-SA' : 'en-US', {
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  function callDriver() {
    window.open(`tel:${orderData.driver.phone}`);
  }

  function chatWithDriver() {
    goto(`/chat/driver/${orderId}`);
  }
</script>

<div class="tracking-container">
  <header class="page-header">
    <Button variant="tertiary" size="sm" on:click={() => goto('/orders')}>
      ← {texts.backToOrders}
    </Button>
    <h1>{texts.title} {orderData.id}</h1>
  </header>

  <!-- Live Status Card -->
  <Card>
    <div class="status-card">
      <div class="status-icon in-transit">🚚</div>
      <div class="status-content">
        <h2>{currentLanguage === 'ar' ? 'في الطريق إليك' : 'On the way to you'}</h2>
        <p class="eta">{texts.estimatedArrival}: {orderData.estimatedArrival}</p>
        <p class="current-location">
          {texts.currentLocation}: {currentLanguage === 'ar' ? orderData.currentLocation : orderData.currentLocationEn}
        </p>
      </div>
    </div>
  </Card>

  <!-- Order Details -->
  <Card>
    <div class="section">
      <h3>{texts.orderDetails}</h3>
      <div class="order-info">
        <div class="info-row">
          <span class="label">{texts.from}:</span>
          <span>{currentLanguage === 'ar' ? orderData.pickupAddress : orderData.pickupAddressEn}</span>
        </div>
        <div class="info-row">
          <span class="label">{texts.to}:</span>
          <span>{currentLanguage === 'ar' ? orderData.deliveryAddress : orderData.deliveryAddressEn}</span>
        </div>
        <div class="info-row">
          <span class="label">{texts.amount}:</span>
          <span class="amount">{orderData.amount.toFixed(2)} ر.س</span>
        </div>
      </div>
    </div>
  </Card>

  <!-- Driver Info -->
  <Card>
    <div class="section">
      <h3>{texts.driverInfo}</h3>
      <div class="driver-card">
        <div class="driver-avatar">
          {(currentLanguage === 'ar' ? orderData.driver.name : orderData.driver.nameEn).charAt(0)}
        </div>
        <div class="driver-details">
          <h4>{currentLanguage === 'ar' ? orderData.driver.name : orderData.driver.nameEn}</h4>
          <div class="driver-rating">
            ⭐ {orderData.driver.rating}
          </div>
          <p class="vehicle-type">
            {currentLanguage === 'ar' ? orderData.driver.vehicleType : orderData.driver.vehicleTypeEn}
          </p>
        </div>
        <div class="driver-actions">
          <Button size="sm" on:click={callDriver}>
            📞 {texts.callDriver}
          </Button>
          <Button size="sm" variant="secondary" on:click={chatWithDriver}>
            💬 {texts.chatDriver}
          </Button>
        </div>
      </div>
    </div>
  </Card>

  <!-- Order Timeline -->
  <Card>
    <div class="section">
      <h3>{texts.orderTimeline}</h3>
      <div class="timeline">
        {#each orderData.timeline as step}
          <div class="timeline-step" class:completed={step.completed} class:current={step.current}>
            <div class="step-indicator">
              {#if step.completed}
                ✓
              {:else if step.current}
                ●
              {:else}
                ○
              {/if}
            </div>
            <div class="step-content">
              <h5>{currentLanguage === 'ar' ? step.titleAr : step.titleEn}</h5>
              {#if step.time}
                <p class="step-time">{formatTime(step.time)}</p>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </div>
  </Card>
</div>

<style>
  .tracking-container {
    padding: var(--space-4);
    min-height: 100vh;
    background: var(--color-surface);
    max-width: 600px;
    margin: 0 auto;
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
  }

  .section {
    padding: var(--space-4);
  }

  .section h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .status-card {
    display: flex;
    gap: var(--space-4);
    align-items: center;
    padding: var(--space-4);
  }

  .status-icon {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    background: var(--gradient-primary);
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
  }

  .status-content h2 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
  }

  .eta {
    color: var(--color-primary);
    font-weight: 600;
    font-size: 1.1rem;
    margin: 0 0 var(--space-1) 0;
  }

  .current-location {
    color: var(--color-ink-light);
    margin: 0;
  }

  .order-info, .info-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-3);
    padding-bottom: var(--space-2);
    border-bottom: 1px solid var(--color-border-light);
  }

  .info-row:last-child {
    border-bottom: none;
    margin-bottom: 0;
  }

  .label {
    color: var(--color-ink-light);
    font-weight: 500;
  }

  .amount {
    color: var(--color-primary);
    font-weight: 600;
  }

  .driver-card {
    display: flex;
    gap: var(--space-3);
    align-items: center;
  }

  .driver-avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: var(--gradient-primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    font-size: 1.2rem;
  }

  .driver-details {
    flex: 1;
  }

  .driver-details h4 {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
  }

  .driver-rating {
    color: var(--color-warning);
    font-weight: 500;
    margin-bottom: var(--space-1);
  }

  .vehicle-type {
    color: var(--color-ink-light);
    margin: 0;
    font-size: 0.875rem;
  }

  .driver-actions {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .timeline {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .timeline-step {
    display: flex;
    gap: var(--space-3);
    align-items: flex-start;
  }

  .step-indicator {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.875rem;
    font-weight: 600;
    background: var(--color-border);
    color: var(--color-ink-light);
    flex-shrink: 0;
  }

  .timeline-step.completed .step-indicator {
    background: var(--color-success);
    color: white;
  }

  .timeline-step.current .step-indicator {
    background: var(--color-primary);
    color: white;
    animation: pulse 2s infinite;
  }

  .step-content h5 {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
  }

  .step-time {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.875rem;
  }
</style>