<script>
  import { onMount, onDestroy } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import { cartStore, cartTotal, cartActions } from '$lib/stores/cart.js';
  import { deliveryFeeTiers, calculateDeliveryFee, getDeliveryFeeDescription } from '$lib/stores/deliveryFee.js';
  import { cancellationSettings, cancellationActions } from '$lib/stores/cancellationSettings.js';
  
  let currentLanguage = 'ar';
  let cartItems = [];
  let total = 0;
  let selectedPaymentMethod = '';  // Start with empty string instead of 'cash'
  let showOrderConfirmation = false;
  let showPaymentMethods = false; // New state for payment method visibility
  let orderNumber = '';
  let currentTiers = [];
  let orderPlacedTime = null;
  let cancellationTimer = null;
  let timeRemaining = 60; // Default 60 seconds, will be updated from settings
  let canCancelOrder = false;
  let currentCancellationSettings = {};

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'إتمام الطلب',
    backToProducts: 'العودة للمنتجات',
    yourOrder: 'طلبك',
    emptyCart: 'السلة فارغة',
    shopNow: 'تسوق الآن',
    paymentMethod: 'طريقة الدفع',
    choosePaymentMethod: 'اختر طريقة الدفع',
    cash: 'نقداً',
    card: 'بطاقة ائتمان',
    orderSummary: 'ملخص الطلب',
    subtotal: 'المجموع الفرعي',
    deliveryFee: 'رسوم التوصيل',
    total: 'المجموع الكلي',
    placeOrder: 'تأكيد الطلب',
    orderConfirmed: 'تم تأكيد الطلب',
    orderNumber: 'رقم الطلب',
    thankYou: 'شكراً لك! سيتم إشعارك بمجرد تأكيد طلبك.',
    continueShopping: 'متابعة التسوق',
    closeOrder: 'إغلاق',
    sar: 'ريال',
    free: 'مجاني',
    remove: 'حذف',
    quantity: 'الكمية',
    cancellationNotice: 'يمكن إلغاء الطلب خلال 60 ثانية فقط من وقت تأكيد الطلب',
    cancelOrder: 'إلغاء الطلب',
    timeRemaining: 'الوقت المتبقي للإلغاء',
    orderCancelled: 'تم إلغاء الطلب بنجاح'
  } : {
    title: 'Checkout',
    backToProducts: 'Back to Products',
    yourOrder: 'Your Order',
    emptyCart: 'Your cart is empty',
    shopNow: 'Shop Now',
    paymentMethod: 'Payment Method',
    choosePaymentMethod: 'Choose Payment Method',
    cash: 'Cash on Delivery',
    card: 'Card on Delivery',
    orderSummary: 'Order Summary',
    subtotal: 'Subtotal',
    deliveryFee: 'Delivery Fee',
    total: 'Total',
    placeOrder: 'Place Order',
    orderConfirmed: 'Order Placed',
    orderNumber: 'Order Number',
    thankYou: 'Thank you! We will notify you once we confirm your order.',
    continueShopping: 'Continue Shopping',
    closeOrder: 'Close',
    sar: 'SAR',
    free: 'Free',
    remove: 'Remove',
    quantity: 'Quantity',
    cancellationNotice: 'Order cancellation is only allowed within 60 seconds of placing the order',
    cancelOrder: 'Cancel Order',
    timeRemaining: 'Time remaining to cancel',
    orderCancelled: 'Order cancelled successfully'
  };

  // Load language and cart data
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }

    // Subscribe to cart store
    const unsubscribeCart = cartStore.subscribe(items => {
      cartItems = items;
    });

    const unsubscribeTotal = cartTotal.subscribe(value => {
      total = value;
    });

    const unsubscribeTiers = deliveryFeeTiers.subscribe(tiers => {
      currentTiers = tiers;
    });

    const unsubscribeCancellation = cancellationSettings.subscribe(settings => {
      currentCancellationSettings = settings;
      timeRemaining = settings.allowedTimeSeconds;
    });

    // Load cancellation settings
    cancellationActions.loadFromStorage();

    return () => {
      unsubscribeCart();
      unsubscribeTotal();
      unsubscribeTiers();
      unsubscribeCancellation();
    };
  });

  // Cleanup timer on component destroy
  onDestroy(() => {
    if (cancellationTimer) {
      clearInterval(cancellationTimer);
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

  // Cart management functions
  function updateQuantity(productId, newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      cartActions.updateQuantity(productId, newQuantity);
    }
  }

  function removeItem(productId) {
    cartActions.removeItem(productId);
  }

  function increaseQuantity(productId) {
    const item = cartItems.find(item => item.id === productId);
    if (item) {
      updateQuantity(productId, item.quantity + 1);
    }
  }

  function decreaseQuantity(productId) {
    const item = cartItems.find(item => item.id === productId);
    if (item && item.quantity > 1) {
      updateQuantity(productId, item.quantity - 1);
    }
  }

  // Update dynamic text based on settings
  $: dynamicTexts = currentLanguage === 'ar' ? {
    ...texts,
    cancellationNotice: currentCancellationSettings.warningMessage?.ar || 'يمكن إلغاء الطلب خلال 60 ثانية فقط من وقت تأكيد الطلب'
  } : {
    ...texts,
    cancellationNotice: currentCancellationSettings.warningMessage?.en || 'Order cancellation is only allowed within 60 seconds of placing the order'
  };

  // Order placement
  function placeOrder() {
    if (cartItems.length === 0) return;
    
    // Generate order number
    orderNumber = 'UE' + Date.now().toString().slice(-6);
    
    // Record order placed time
    orderPlacedTime = new Date();
    canCancelOrder = currentCancellationSettings.isEnabled;
    timeRemaining = currentCancellationSettings.allowedTimeSeconds || 60;
    
    // Save order to active orders for tracking
    const newOrder = {
      orderNumber: orderNumber,
      placedAt: orderPlacedTime.getTime(),
      total: finalTotal,
      items: cartItems.length,
      canCancel: canCancelOrder,
      timeRemaining: timeRemaining
    };
    
    // Load existing active orders and add new one
    const existingOrders = JSON.parse(localStorage.getItem('activeOrders') || '[]');
    existingOrders.unshift(newOrder); // Add to beginning
    localStorage.setItem('activeOrders', JSON.stringify(existingOrders));
    
    // Start cancellation timer if enabled
    if (canCancelOrder) {
      startCancellationTimer();
    }
    
    // Show confirmation popup
    showOrderConfirmation = true;
    
    // Clear cart after placing order
    setTimeout(() => {
      cartActions.clearCart();
    }, 500);
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
    
    // Show cancellation message (you can customize this)
    alert(texts.orderCancelled);
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
    
    goto('/products');
  }

  function goBackToProducts() {
    goto('/products');
  }

  function showPaymentMethodOptions() {
    showPaymentMethods = true;
  }

  // Calculate delivery fee with dynamic tiers
  $: deliveryFee = calculateDeliveryFee(total, currentTiers);
  $: finalTotal = total + deliveryFee;
  $: deliveryFeeDescription = getDeliveryFeeDescription(total, currentTiers, currentLanguage);
</script>

<svelte:head>
  <title>{texts.title} - Urban Express</title>
</svelte:head>

<div class="checkout-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Header -->
  <div class="header">
    <button class="back-button" on:click={goBackToProducts}>
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d={currentLanguage === 'ar' ? "M15 18L9 12L15 6" : "M9 18L15 12L9 6"} stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      {texts.backToProducts}
    </button>
    <h1>{texts.title}</h1>
  </div>

  <!-- Scrolling Cancellation Notice -->
  {#if currentCancellationSettings.isEnabled && cartItems.length > 0}
    <div class="scrolling-notice">
      <div class="scrolling-text">
        <span>⚠️ {dynamicTexts.cancellationNotice} ⚠️</span>
      </div>
    </div>
  {/if}

  {#if cartItems.length === 0}
    <!-- Empty Cart State -->
    <div class="empty-cart">
      <div class="empty-cart-icon">🛒</div>
      <h2>{texts.emptyCart}</h2>
      <Button on:click={goBackToProducts}>{texts.shopNow}</Button>
    </div>
  {:else}
    <!-- Cart Items -->
    <div class="cart-section">
      <h2>{texts.yourOrder}</h2>
      <div class="cart-items">
        {#each cartItems as item (item.id)}
          <div class="cart-item">
            <div class="item-image">
              <div class="item-icon">{item.icon}</div>
            </div>
            
            <div class="item-details">
              <h3>{currentLanguage === 'ar' ? item.nameAr : item.nameEn}</h3>
              <div class="item-price">
                {item.basePrice.toFixed(2)} {texts.sar}
                {#if item.originalPrice}
                  <span class="original-price">{item.originalPrice.toFixed(2)} {texts.sar}</span>
                {/if}
              </div>
              <div class="item-unit">/ {currentLanguage === 'ar' ? item.unit : item.unitEn}</div>
            </div>
            
            <div class="item-actions">
              <div class="quantity-controls">
                <button class="quantity-btn" on:click={() => decreaseQuantity(item.id)}>−</button>
                <span class="quantity-display">{item.quantity}</span>
                <button class="quantity-btn" on:click={() => increaseQuantity(item.id)}>+</button>
              </div>
              
              <div class="item-total">
                {(item.basePrice * item.quantity).toFixed(2)} {texts.sar}
              </div>
              
              <button class="remove-btn" on:click={() => removeItem(item.id)}>
                {texts.remove}
              </button>
            </div>
          </div>
        {/each}
      </div>
    </div>

    <!-- Order Summary -->
    <div class="summary-section">
      <h2>{texts.orderSummary}</h2>
      <div class="summary-row">
        <span>{texts.subtotal}</span>
        <span>{total.toFixed(2)} {texts.sar}</span>
      </div>
      <div class="summary-row">
        <span>{texts.deliveryFee}</span>
        <div class="delivery-fee-container">
          <span>{deliveryFee === 0 ? texts.free : `${deliveryFee.toFixed(2)} ${texts.sar}`}</span>
          {#if deliveryFeeDescription !== (deliveryFee === 0 ? texts.free : `${deliveryFee.toFixed(2)} ${texts.sar}`)}
            <small class="delivery-hint">{deliveryFeeDescription}</small>
          {/if}
        </div>
      </div>
      <div class="summary-row total-row">
        <span>{texts.total}</span>
        <span>{finalTotal.toFixed(2)} {texts.sar}</span>
      </div>
    </div>

    <!-- Choose Payment Method Button (Show first) -->
    {#if !showPaymentMethods}
      <div class="payment-button-section">
        <Button size="lg" variant="primary" on:click={showPaymentMethodOptions} fullWidth>
          {texts.choosePaymentMethod}
        </Button>
      </div>
    {/if}

    <!-- Payment Method Options (Show after button click) -->
    {#if showPaymentMethods}
      <div class="payment-section">
        <h2>{texts.paymentMethod}</h2>
        <div class="payment-options">
          <label class="payment-option" class:selected={selectedPaymentMethod === 'cash'}>
            <input type="radio" bind:group={selectedPaymentMethod} value="cash" />
            <div class="payment-icon">💵</div>
            <span>{texts.cash}</span>
          </label>
          
          <label class="payment-option" class:selected={selectedPaymentMethod === 'card'}>
            <input type="radio" bind:group={selectedPaymentMethod} value="card" />
            <div class="payment-icon">💳</div>
            <span>{texts.card}</span>
          </label>
        </div>
      </div>

      <!-- Place Order Button (Show only after payment method is selected) -->
      {#if selectedPaymentMethod !== ''}
        <div class="order-button-section">
          <Button size="lg" variant="primary" on:click={placeOrder} fullWidth>
            {texts.placeOrder}
          </Button>
        </div>
      {/if}
    {/if}
  {/if}
</div>

<!-- Order Confirmation Popup -->
{#if showOrderConfirmation}
  <div class="popup-overlay" on:click={closeOrderConfirmation}>
    <div class="popup-content" on:click|stopPropagation>
      <div class="popup-icon">✅</div>
      <h2>{texts.orderConfirmed}</h2>
      <p><strong>{texts.orderNumber}:</strong> {orderNumber}</p>
      <p>{texts.thankYou}</p>
      
      <!-- Cancellation Timer -->
      {#if canCancelOrder && timeRemaining > 0}
        <div class="cancellation-section">
          <div class="timer-display">
            <span class="timer-label">{texts.timeRemaining}:</span>
            <span class="timer-countdown">{formatTime(timeRemaining)}</span>
          </div>
          <Button variant="danger" on:click={cancelOrder}>
            {texts.cancelOrder}
          </Button>
        </div>
      {/if}
      
      <div class="popup-actions">
        <Button variant="primary" on:click={() => goto('/orders')}>
          {currentLanguage === 'ar' ? 'عرض الطلبات' : 'View Orders'}
        </Button>
        <Button variant="secondary" on:click={closeOrderConfirmation}>
          {texts.continueShopping}
        </Button>
      </div>
    </div>
  </div>
{/if}

<style>
  .checkout-container {
    min-height: 100vh;
    background: var(--color-background, #f8fafc);
    padding: 1rem;
    padding-bottom: 2rem; /* Reduced padding since buttons are now inline */
    max-width: 800px;
    margin: 0 auto;
  }

  .header {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid var(--color-border);
  }

  .back-button {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    background: none;
    border: none;
    color: var(--color-primary);
    font-size: 1rem;
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 8px;
    transition: background 0.2s ease;
  }

  .back-button:hover {
    background: var(--color-primary-light);
  }

  .header h1 {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--color-ink);
    margin: 0;
  }

  /* Scrolling Notice */
  .scrolling-notice {
    background: linear-gradient(90deg, #ff6b6b, #ffa500, #ff6b6b);
    color: white;
    padding: 0.5rem 0;
    margin: 1rem 0;
    border-radius: 8px;
    overflow: hidden;
    position: relative;
  }

  .scrolling-text {
    display: flex;
    animation: scroll 15s linear infinite;
    white-space: nowrap;
  }

  .scrolling-text span {
    font-weight: 600;
    font-size: 0.9rem;
    padding: 0 2rem;
  }

  @keyframes scroll {
    0% {
      transform: translateX(100%);
    }
    100% {
      transform: translateX(-100%);
    }
  }

  .empty-cart {
    text-align: center;
    padding: 3rem 1rem;
  }

  .empty-cart-icon {
    font-size: 4rem;
    margin-bottom: 1rem;
  }

  .empty-cart h2 {
    color: var(--color-ink-light);
    margin-bottom: 2rem;
  }

  .cart-section, .payment-section, .summary-section {
    background: white;
    border: 2px solid var(--color-border);
    border-radius: 16px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }

  .cart-section h2, .payment-section h2, .summary-section h2 {
    font-size: 1.2rem;
    font-weight: 600;
    color: var(--color-ink);
    margin: 0 0 1rem 0;
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

  .original-price {
    font-size: 0.9rem;
    color: var(--color-ink-light);
    text-decoration: line-through;
    font-weight: 400;
    margin-left: 0.5rem;
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

  .payment-options {
    display: flex;
    gap: 1rem;
  }

  .payment-option {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
    padding: 1rem;
    border: 2px solid var(--color-border);
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.2s ease;
    background: white;
  }

  .payment-option:hover {
    border-color: var(--color-primary);
  }

  .payment-option.selected {
    border-color: var(--color-primary);
    background: var(--color-primary-light);
  }

  .payment-option input {
    display: none;
  }

  .payment-icon {
    font-size: 2rem;
  }

  .payment-option span {
    font-weight: 500;
    color: var(--color-ink);
    text-align: center;
  }

  .summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 0;
    border-bottom: 1px solid var(--color-border);
  }

  .summary-row:last-child {
    border-bottom: none;
  }

  .total-row {
    font-size: 1.2rem;
    font-weight: 700;
    border-top: 2px solid var(--color-border);
    padding-top: 1rem;
    margin-top: 0.5rem;
  }

  .delivery-fee-container {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 0.25rem;
  }

  .delivery-hint {
    font-size: 0.75rem;
    color: var(--color-primary);
    font-weight: 500;
    text-align: right;
    line-height: 1.2;
  }

  .order-button-container, .payment-button-container {
    position: fixed;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 100%;
    max-width: 800px;
    background: white;
    border-top: 2px solid var(--color-border);
    padding: 1rem;
    z-index: 999; /* Increased z-index */
    box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
    /* Debug styles to ensure visibility */
    min-height: 60px;
    display: flex;
    align-items: center;
  }

  .payment-button-section, .order-button-section {
    background: white;
    border: 2px solid var(--color-border);
    border-radius: 16px;
    padding: 1.5rem;
    margin-top: 1.5rem;
  }

  .popup-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 1rem;
  }

  .popup-content {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    text-align: center;
    max-width: 400px;
    width: 100%;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  }

  .popup-icon {
    font-size: 3rem;
    margin-bottom: 1rem;
  }

  .popup-content h2 {
    color: var(--color-ink);
    margin-bottom: 1rem;
  }

  .popup-content p {
    color: var(--color-ink-light);
    margin-bottom: 1rem;
    line-height: 1.5;
  }

  /* Cancellation Timer */
  .cancellation-section {
    background: #fff3cd;
    border: 1px solid #ffeeba;
    border-radius: 8px;
    padding: 1rem;
    margin: 1.5rem 0;
    text-align: center;
  }

  .timer-display {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .timer-label {
    font-size: 0.9rem;
    color: var(--color-ink);
    font-weight: 600;
  }

  .timer-countdown {
    font-size: 1.5rem;
    font-weight: bold;
    color: #dc3545;
    background: white;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    border: 2px solid #dc3545;
    min-width: 60px;
    font-family: monospace;
  }

  .popup-actions {
    margin-top: 2rem;
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
  }

  /* Mobile optimizations */
  @media (max-width: 480px) {
    .checkout-container {
      padding: 0.5rem;
      padding-bottom: 1rem; /* Normal padding since buttons are inline */
    }

    .cart-item {
      flex-direction: column;
      gap: 1rem;
    }

    .item-actions {
      flex-direction: row;
      justify-content: space-between;
      align-items: center;
    }

    .payment-options {
      flex-direction: column;
    }
    
    .payment-button-section, .order-button-section {
      padding: 1rem;
      margin-top: 1rem;
    }
  }
</style>