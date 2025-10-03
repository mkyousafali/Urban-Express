<script>
  import { onMount, onDestroy } from 'svelte';
  import { goto } from '$app/navigation';
  import { fade, scale } from 'svelte/transition';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { cartStore, cartTotal, cartActions } from '$lib/stores/cart.js';
  import { cancellationSettings, cancellationActions } from '$lib/stores/cancellationSettings.js';

  // State variables
  let currentLanguage = 'ar';
  let cartItems = [];
  let total = 0;
  let selectedBranch = null;
  let showOrderConfirmation = false;
  let orderNumber = '';
  let orderPlacedTime = null;
  let cancellationTimer = null;
  let timeRemaining = 60; // Will be updated from settings
  let canCancelOrder = false;
  let currentCancellationSettings = {};
  let loading = false;

  // Branch data with pickup operating hours
  const branches = [
    {
      id: 1,
      nameAr: 'فرع العليا',
      nameEn: 'Olaya Branch',
      addressAr: 'الرياض، حي العليا، شارع الملك فهد',
      addressEn: 'Riyadh, Olaya District, King Fahd Road',
      phone: '+966 11 123 4567',
      pickupService: {
        isActive: true,
        isAvailable24Hours: false,
        startTime: '08:00',
        endTime: '22:00',
        displayAr: '8:00 ص - 10:00 م',
        displayEn: '8:00 AM - 10:00 PM'
      }
    },
    {
      id: 2,
      nameAr: 'فرع النخيل',
      nameEn: 'Al Nakheel Branch',
      addressAr: 'الرياض، حي النخيل، شارع الأمير محمد',
      addressEn: 'Riyadh, Al Nakheel District, Prince Mohammed Street',
      phone: '+966 11 234 5678',
      pickupService: {
        isActive: true,
        isAvailable24Hours: true,
        startTime: '00:00',
        endTime: '23:59',
        displayAr: '24 ساعة',
        displayEn: '24 Hours'
      }
    },
    {
      id: 3,
      nameAr: 'فرع السليمانية',
      nameEn: 'Al Sulaimaniyah Branch',
      addressAr: 'الرياض، حي السليمانية، شارع التحلية',
      addressEn: 'Riyadh, Al Sulaimaniyah District, Tahlia Street',
      phone: '+966 11 345 6789',
      pickupService: {
        isActive: false, // This branch has pickup service disabled
        isAvailable24Hours: false,
        startTime: '09:00',
        endTime: '21:00',
        displayAr: '9:00 ص - 9:00 م',
        displayEn: '9:00 AM - 9:00 PM'
      }
    }
  ];

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'الاستلام من المتجر',
    selectBranch: 'اختر الفرع',
    branchPlaceholder: 'اختر فرع للاستلام',
    orderSummary: 'ملخص الطلب',
    items: 'عناصر',
    total: 'المجموع',
    placeOrder: 'تأكيد الطلب',
    processing: 'جاري المعالجة...',
    orderPlaced: 'تم تأكيد الطلب',
    orderNumber: 'رقم الطلب',
    thankYou: 'شكراً لك! سيتم إشعارك عند تأكيد طلبك.',
    timeRemaining: 'الوقت المتبقي للإلغاء',
    cancelOrder: 'إلغاء الطلب',
    viewOrders: 'عرض الطلبات',
    orderCancelled: 'تم إلغاء الطلب بنجاح',
    sar: 'ريال',
    viewLocation: 'عرض الموقع',
    branchInfo: 'معلومات الفرع'
  } : {
    title: 'Pick Up From Store',
    selectBranch: 'Select Branch',
    branchPlaceholder: 'Choose a branch for pickup',
    orderSummary: 'Order Summary',
    items: 'items',
    total: 'Total',
    placeOrder: 'Place Order',
    processing: 'Processing...',
    orderPlaced: 'Order Placed',
    orderNumber: 'Order Number',
    thankYou: 'Thank you! We will notify you once we confirm your order.',
    timeRemaining: 'Time remaining to cancel',
    cancelOrder: 'Cancel Order',
    viewOrders: 'View Orders',
    orderCancelled: 'Order cancelled successfully',
    sar: 'SAR',
    viewLocation: 'View Location',
    branchInfo: 'Branch Information'
  };

  // Load language and data on mount
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Subscribe to stores
    const unsubscribeCart = cartStore.subscribe(items => {
      cartItems = items;
      // Add sample data if cart is empty and not showing confirmation
      if (items.length === 0 && !showOrderConfirmation) {
        const sampleItems = [
          {
            id: 1,
            name: currentLanguage === 'ar' ? 'برجر لحم' : 'Beef Burger',
            price: 25.99,
            quantity: 2
          },
          {
            id: 2,
            name: currentLanguage === 'ar' ? 'بيتزا مارجريتا' : 'Margherita Pizza',
            price: 45.50,
            quantity: 1
          }
        ];
        cartStore.set(sampleItems);
      }
    });

    const unsubscribeTotal = cartTotal.subscribe(value => {
      total = value;
    });

    const unsubscribeCancellation = cancellationSettings.subscribe(settings => {
      currentCancellationSettings = settings;
      timeRemaining = settings.allowedTimeSeconds || 60;
    });

    // Listen for language changes
    function handleStorageChange(event) {
      if (event.key === 'language') {
        currentLanguage = event.newValue || 'ar';
        document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
        document.documentElement.lang = currentLanguage;
      }
    }

    window.addEventListener('storage', handleStorageChange);

    return () => {
      unsubscribeCart();
      unsubscribeTotal();
      unsubscribeCancellation();
      window.removeEventListener('storage', handleStorageChange);
      if (cancellationTimer) {
        clearInterval(cancellationTimer);
      }
    };
  });

  // Functions (copied from checkout page)
  function handleBranchChange(event) {
    const branchId = parseInt(event.target.value);
    selectedBranch = branches.find(branch => branch.id === branchId) || null;
  }

  // Check if pickup service is available at current time
  function isPickupServiceAvailable(branch) {
    if (!branch || !branch.pickupService.isActive) {
      return false;
    }

    if (branch.pickupService.isAvailable24Hours) {
      return true;
    }

    const now = new Date();
    const currentTime = now.getHours() * 60 + now.getMinutes(); // Convert to minutes
    
    const [startHour, startMinute] = branch.pickupService.startTime.split(':').map(Number);
    const [endHour, endMinute] = branch.pickupService.endTime.split(':').map(Number);
    
    const startTime = startHour * 60 + startMinute;
    const endTime = endHour * 60 + endMinute;

    return currentTime >= startTime && currentTime <= endTime;
  }

  // Get filtered branches (only those with active pickup service)
  function getAvailableBranches() {
    return branches.filter(branch => branch.pickupService.isActive);
  }

  function generateOrderNumber() {
    return 'PU' + Date.now().toString().slice(-6);
  }

  async function placeOrder() {
    if (!selectedBranch) {
      alert(texts.selectBranch);
      return;
    }

    // Check if pickup service is available
    if (!isPickupServiceAvailable(selectedBranch)) {
      const message = currentLanguage === 'ar' ? 
        `عذراً، خدمة الاستلام متاحة فقط خلال ${selectedBranch.pickupService.displayAr}` :
        `Sorry, pickup service is only available during ${selectedBranch.pickupService.displayEn}`;
      alert(message);
      return;
    }

    loading = true;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Generate order number and set order time
      orderNumber = generateOrderNumber();
      orderPlacedTime = new Date();
      
      // Set cancellation timer
      timeRemaining = currentCancellationSettings.allowedTimeSeconds || 60;
      canCancelOrder = true;
      
      // Start countdown
      startCancellationTimer();
      
      // Show confirmation popup
      showOrderConfirmation = true;
      
      // Clear cart after a short delay (like checkout page)
      setTimeout(() => {
        cartActions.clearCart();
      }, 500);
      
    } catch (error) {
      console.error('Order placement failed:', error);
      alert('Failed to place order. Please try again.');
    } finally {
      loading = false;
    }
  }

  function startCancellationTimer() {
    cancellationTimer = setInterval(() => {
      timeRemaining -= 1;
      
      if (timeRemaining <= 0) {
        clearInterval(cancellationTimer);
        canCancelOrder = false;
        timeRemaining = 0;
      }
    }, 1000);
  }

  function cancelOrder() {
    if (!canCancelOrder || timeRemaining <= 0) return;
    
    // Clear timer
    if (cancellationTimer) {
      clearInterval(cancellationTimer);
    }
    
    // Reset states
    canCancelOrder = false;
    showOrderConfirmation = false;
    orderPlacedTime = null;
    timeRemaining = currentCancellationSettings.allowedTimeSeconds || 60;
    
    // Show cancellation message
    alert(texts.orderCancelled);
    
    // Go back to products
    goto('/products');
  }

  function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  function closeOrderConfirmation() {
    showOrderConfirmation = false;
    
    // Clear timer if still running
    if (cancellationTimer) {
      clearInterval(cancellationTimer);
    }
    
    // Reset cancellation states
    canCancelOrder = false;
    orderPlacedTime = null;
    timeRemaining = currentCancellationSettings.allowedTimeSeconds || 60;
    
    goto('/orders');
  }

  function updateQuantity(productId, newQuantity) {
    if (newQuantity <= 0) {
      cartActions.removeFromCart(productId);
    } else {
      cartActions.updateQuantity(productId, newQuantity);
    }
  }

  function openLocation() {
    if (selectedBranch) {
      const query = encodeURIComponent(currentLanguage === 'ar' ? selectedBranch.nameAr : selectedBranch.nameEn);
      window.open(`https://maps.google.com/?q=${query}`, '_blank');
    }
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="pickup-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Header -->
  <div class="header">
    <button class="back-btn" on:click={() => goto('/finalize')}>
      {currentLanguage === 'ar' ? '←' : '→'}
    </button>
    <h1>{texts.title}</h1>
  </div>

  <!-- Branch Selection -->
  <Card>
    <div class="branch-selection">
      <label for="branch-select">{texts.selectBranch}</label>
      <select 
        id="branch-select" 
        on:change={handleBranchChange} 
        class="branch-select"
      >
        <option value="">{texts.branchPlaceholder}</option>
        {#each getAvailableBranches() as branch}
          <option value={branch.id}>
            {currentLanguage === 'ar' ? branch.nameAr : branch.nameEn}
          </option>
        {/each}
      </select>
      
      {#if selectedBranch}
        <div class="branch-info">
          <h3>{currentLanguage === 'ar' ? selectedBranch.nameAr : selectedBranch.nameEn}</h3>
          <p class="address">
            📍 {currentLanguage === 'ar' ? selectedBranch.addressAr : selectedBranch.addressEn}
          </p>
          <p class="phone">📞 {selectedBranch.phone}</p>
          
          <!-- Operating Hours -->
          <div class="operating-hours">
            <p class="hours-label">
              {currentLanguage === 'ar' ? 'ساعات الاستلام:' : 'Pickup Hours:'}
            </p>
            <p class="hours-display">
              🕒 {currentLanguage === 'ar' ? selectedBranch.pickupService.displayAr : selectedBranch.pickupService.displayEn}
            </p>
          </div>
          
          <!-- Service Status -->
          <div class="service-status {isPickupServiceAvailable(selectedBranch) ? 'available' : 'unavailable'}">
            <p>
              {isPickupServiceAvailable(selectedBranch) ? 
                (currentLanguage === 'ar' ? 'الخدمة متاحة الآن' : 'Service currently available') :
                (currentLanguage === 'ar' ? 'الخدمة غير متاحة حالياً' : 'Service currently unavailable')
              }
            </p>
          </div>
          
          <button class="location-btn" on:click={openLocation}>
            📍 {texts.viewLocation}
          </button>
        </div>
      {/if}
    </div>
  </Card>

  <!-- Order Summary -->
  <Card>
    <div class="order-summary">
      <h2>{texts.orderSummary}</h2>
      
      {#if cartItems && cartItems.length > 0}
        <div class="cart-items">
          {#each cartItems as item}
            <div class="cart-item">
              <div class="item-image">
                <div class="item-icon">{item.icon || '🍽️'}</div>
              </div>
              
              <div class="item-details">
                <h3>{item.name || 'Unnamed Item'}</h3>
                <div class="item-price">
                  {(item.price || 0).toFixed(2)} {texts.sar}
                </div>
                <div class="item-unit">/ {currentLanguage === 'ar' ? 'وحدة' : 'unit'}</div>
              </div>
              
              <div class="item-actions">
                <div class="quantity-controls">
                  <button class="quantity-btn" on:click={() => updateQuantity(item.id, (item.quantity || 1) - 1)}>−</button>
                  <span class="quantity-display">{item.quantity || 1}</span>
                  <button class="quantity-btn" on:click={() => updateQuantity(item.id, (item.quantity || 1) + 1)}>+</button>
                </div>
                
                <div class="item-total">
                  {((item.price || 0) * (item.quantity || 1)).toFixed(2)} {texts.sar}
                </div>
                
                <button class="remove-btn" on:click={() => cartActions.removeFromCart(item.id)}>
                  {currentLanguage === 'ar' ? 'إزالة' : 'Remove'}
                </button>
              </div>
            </div>
          {/each}
        </div>
        
        <div class="summary-section">
          <div class="summary-row">
            <span>{cartItems.length} {texts.items}</span>
            <span>{(total || 0).toFixed(2)} {texts.sar}</span>
          </div>
          <div class="summary-row total-row">
            <span>{texts.total}: {(total || 0).toFixed(2)} {texts.sar}</span>
          </div>
        </div>
      {:else}
        <div class="empty-cart">
          <p>{currentLanguage === 'ar' ? 'السلة فارغة' : 'Cart is empty'}</p>
        </div>
      {/if}
    </div>
  </Card>

  <!-- Place Order Button -->
  <div class="place-order">
    <Button 
      variant="primary" 
      fullWidth 
      disabled={!selectedBranch || loading || !isPickupServiceAvailable(selectedBranch)}
      on:click={placeOrder}
    >
      {loading ? texts.processing : texts.placeOrder}
    </Button>
  </div>
</div>

<!-- Order Confirmation Popup (Copied from checkout page) -->
{#if showOrderConfirmation}
  <div class="popup-overlay" transition:fade={{ duration: 200 }}>
    <div class="popup-content" transition:scale={{ duration: 200 }}>
      
      <div class="popup-body">
        <div class="success-icon">✅</div>
        <h2 class="order-title">{texts.orderPlaced}</h2>
        <p class="order-number">
          <strong>{texts.orderNumber}:</strong> {orderNumber}
        </p>
        <p class="thank-you-message">{texts.thankYou}</p>

        <!-- Branch Information -->
        {#if selectedBranch}
          <div class="branch-info-popup">
            <h4>{texts.branchInfo}:</h4>
            <div class="branch-details">
              <p class="branch-name">{currentLanguage === 'ar' ? selectedBranch.nameAr : selectedBranch.nameEn}</p>
              <p class="branch-address">{currentLanguage === 'ar' ? selectedBranch.addressAr : selectedBranch.addressEn}</p>
              <p class="branch-phone">📞 {selectedBranch.phone}</p>
              <button class="location-btn" on:click={openLocation}>
                📍 {texts.viewLocation}
              </button>
            </div>
          </div>
        {/if}

        <!-- Cancellation Timer Section (Copied from checkout) -->
        {#if canCancelOrder && timeRemaining > 0}
          <div class="timer-section">
            <p class="timer-text">{texts.timeRemaining}:</p>
            <div class="timer-container">
              <div class="timer-bar">
                <div class="timer-progress" style="width: {(timeRemaining / (currentCancellationSettings.allowedTimeSeconds || 60)) * 100}%"></div>
              </div>
            </div>
            <div class="timer-display">{formatTime(timeRemaining)}</div>
            <button class="cancel-order-btn" on:click={cancelOrder}>
              {texts.cancelOrder}
            </button>
          </div>
        {/if}
      </div>
      
      <div class="popup-actions">
        <button class="btn-primary" on:click={closeOrderConfirmation}>
          {texts.viewOrders}
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .pickup-container {
    padding: 1rem;
    max-width: 600px;
    margin: 0 auto;
    background: #f8f9fa;
    min-height: 100vh;
  }

  .header {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }

  .back-btn {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 50%;
    background: white;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .header h1 {
    margin: 0;
    color: #2563eb;
    font-size: 1.5rem;
    flex: 1;
  }

  .lang-toggle {
    background: #2563eb;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: 500;
  }

  .lang-toggle:hover {
    background: #1d4ed8;
  }

  .debug-info {
    font-size: 0.8rem;
    color: #6b7280;
    background: #f3f4f6;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
  }

  .branch-selection {
    margin-bottom: 1rem;
  }

  .branch-selection label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #374151;
  }

  .branch-select {
    width: 100%;
    padding: 0.75rem;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    font-size: 1rem;
    background: white;
  }

  .branch-select:focus {
    outline: none;
    border-color: #2563eb;
  }

  .branch-info {
    margin-top: 1rem;
    padding: 1rem;
    background: #f3f4f6;
    border-radius: 8px;
  }

  .branch-info h3 {
    margin: 0 0 0.5rem 0;
    color: #2563eb;
  }

  .address, .phone {
    margin: 0.25rem 0;
    color: #6b7280;
    font-size: 0.9rem;
  }

  .operating-hours {
    margin: 1rem 0;
    padding: 0.75rem;
    background: #f0f9ff;
    border-radius: 6px;
    border-left: 4px solid #2563eb;
  }

  .hours-label {
    margin: 0 0 0.25rem 0;
    font-weight: 600;
    color: #1e40af;
    font-size: 0.9rem;
  }

  .hours-display {
    margin: 0;
    color: #374151;
    font-size: 0.9rem;
  }

  .service-status {
    margin: 1rem 0;
    padding: 0.75rem;
    border-radius: 6px;
    text-align: center;
  }

  .service-status.available {
    background: #d1fae5;
    border: 1px solid #10b981;
    color: #047857;
  }

  .service-status.unavailable {
    background: #fee2e2;
    border: 1px solid #ef4444;
    color: #dc2626;
  }

  .service-status p {
    margin: 0;
    font-size: 0.9rem;
    font-weight: 500;
  }

  .order-summary h2 {
    margin: 0 0 1rem 0;
    color: #374151;
    font-size: 1.25rem;
  }

  .cart-items {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .cart-item {
    display: flex;
    gap: 1rem;
    padding: 1rem;
    border: 1px solid var(--color-border);
    border-radius: 12px;
    background: var(--color-surface);
  }

  .item-image {
    flex-shrink: 0;
    width: 80px;
    height: 80px;
    background: white;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--color-border);
  }

  .item-icon {
    font-size: 2.5rem;
  }

  .item-details {
    flex: 1;
  }

  .item-details h3 {
    font-size: 1rem;
    font-weight: 600;
    color: var(--color-ink);
    margin: 0 0 0.5rem 0;
    line-height: 1.3;
  }

  .item-price {
    font-size: 1rem;
    font-weight: 700;
    color: var(--color-primary);
    margin-bottom: 0.25rem;
  }

  .item-unit {
    font-size: 0.85rem;
    color: var(--color-ink-light);
  }

  .item-actions {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 0.5rem;
  }

  .quantity-controls {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .quantity-btn {
    width: 32px;
    height: 32px;
    border: 2px solid var(--color-border);
    background: white;
    border-radius: 6px;
    font-size: 1.1rem;
    font-weight: bold;
    color: var(--color-ink);
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .quantity-btn:hover {
    border-color: var(--color-primary);
    background: var(--color-primary-light);
  }

  .quantity-display {
    font-size: 1rem;
    font-weight: bold;
    color: var(--color-ink);
    min-width: 30px;
    text-align: center;
    padding: 0.5rem;
    border: 2px solid var(--color-border);
    border-radius: 6px;
    background: white;
  }

  .item-total {
    font-size: 1.1rem;
    font-weight: 700;
    color: var(--color-ink);
  }

  .remove-btn {
    background: none;
    border: none;
    color: var(--color-error);
    font-size: 0.9rem;
    cursor: pointer;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    transition: background 0.2s ease;
  }

  .remove-btn:hover {
    background: var(--color-error-light);
  }

  .order-total {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 2px solid #e5e7eb;
  }

  .summary-section {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 2px solid #e5e7eb;
  }

  .summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
    padding: 0.25rem 0;
  }

  .summary-row.total-row {
    margin-top: 0.5rem;
    padding-top: 0.5rem;
    border-top: 1px solid #e5e7eb;
    font-weight: 600;
    color: #2563eb;
    font-size: 1.1rem;
  }

  .total-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.5rem;
  }

  .total-row.final {
    margin-top: 0.5rem;
    padding-top: 0.5rem;
    border-top: 1px solid #e5e7eb;
    color: #2563eb;
    font-size: 1.1rem;
  }

  .place-order {
    margin: 1.5rem 0;
  }

  .empty-cart {
    text-align: center;
    padding: 2rem;
    color: #6b7280;
  }

  .empty-cart p {
    margin: 0;
    font-size: 1.1rem;
  }

  /* Popup Styles */
  .popup-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .popup-content {
    background: white;
    border-radius: 12px;
    max-width: 400px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  }

  .popup-body {
    padding: 2rem 1.5rem 1.5rem;
    text-align: center;
  }

  .success-icon {
    font-size: 3rem;
    margin-bottom: 1rem;
  }

  .order-title {
    margin: 0 0 1rem 0;
    color: #374151;
    font-size: 1.5rem;
    font-weight: 600;
  }

  .order-number {
    color: #374151;
    margin: 0 0 1rem 0;
    font-size: 1rem;
  }

  .thank-you-message {
    color: #6b7280;
    margin: 0 0 1.5rem 0;
    font-size: 0.9rem;
    line-height: 1.4;
  }

  .branch-info-popup {
    background: #f8f9fa;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1.5rem;
    text-align: left;
  }

  .branch-info-popup h4 {
    margin: 0 0 0.75rem 0;
    color: #374151;
    font-size: 1rem;
  }

  .branch-name {
    font-weight: 600;
    color: #2563eb;
    margin: 0 0 0.5rem 0;
  }

  .branch-address {
    color: #6b7280;
    font-size: 0.9rem;
    margin: 0 0 0.5rem 0;
  }

  .branch-phone {
    color: #6b7280;
    font-size: 0.9rem;
    margin: 0 0 1rem 0;
  }

  .location-btn {
    background: #2563eb;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: 500;
    transition: all 0.2s;
    width: 100%;
  }

  .location-btn:hover {
    background: #1d4ed8;
  }

  .timer-section {
    background: #fef3c7;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1.5rem;
    text-align: center;
  }

  .timer-text {
    margin: 0 0 0.75rem 0;
    font-size: 0.9rem;
    color: #92400e;
    font-weight: 500;
  }

  .timer-container {
    position: relative;
    margin-bottom: 0.75rem;
  }

  .timer-bar {
    width: 100%;
    height: 6px;
    background: #fde68a;
    border-radius: 3px;
    overflow: hidden;
  }

  .timer-progress {
    height: 100%;
    background: #f59e0b;
    transition: width 1s linear;
  }

  .timer-display {
    font-size: 1.5rem;
    font-weight: bold;
    color: white;
    font-family: 'Courier New', monospace;
    background: #f59e0b;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    display: inline-block;
    min-width: 80px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 1rem;
  }

  .cancel-order-btn {
    background: white;
    color: #ef4444;
    border: 2px solid #ef4444;
    padding: 0.75rem 2rem;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.2s;
    font-size: 0.9rem;
  }

  .cancel-order-btn:hover {
    background: #ef4444;
    color: white;
  }

  .popup-actions {
    padding: 1.5rem;
    border-top: 1px solid #e5e7eb;
  }

  .btn-primary {
    width: 100%;
    padding: 0.875rem;
    border: none;
    background: #22c55e;
    color: white;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 1rem;
  }

  .btn-primary:hover {
    background: #16a34a;
  }

  /* RTL Support */
  [dir="rtl"] .header {
    flex-direction: row-reverse;
  }

  [dir="rtl"] .cart-item {
    flex-direction: row-reverse;
  }

  /* Mobile Responsive */
  @media (max-width: 640px) {
    .pickup-container {
      padding: 0.5rem;
    }

    .popup-content {
      width: 95%;
      margin: 1rem;
    }

    .popup-actions {
      flex-direction: column;
    }
  }
</style>