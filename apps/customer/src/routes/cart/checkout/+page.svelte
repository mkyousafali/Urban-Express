<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  
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
  let selectedAddress = 'default';
  let selectedTimeSlot = '';
  let paymentMethod = 'cash';
  let deliveryNotes = '';
  let loading = false;

  const addresses = [
    { id: 'default', nameAr: 'المنزل', nameEn: 'Home', addressAr: 'حي الملز، الرياض', addressEn: 'Al-Malaz, Riyadh' }
  ];

  const timeSlots = [
    { id: 'asap', labelAr: 'في أقرب وقت', labelEn: 'ASAP' },
    { id: '1hour', labelAr: 'خلال ساعة', labelEn: 'Within 1 hour' },
    { id: '2hours', labelAr: 'خلال ساعتين', labelEn: 'Within 2 hours' }
  ];

  $: texts = currentLanguage === 'ar' ? {
    title: 'إنهاء الطلب',
    deliveryAddress: 'عنوان التسليم',
    deliveryTime: 'وقت التسليم',
    paymentMethod: 'طريقة الدفع',
    cashOnDelivery: 'الدفع عند التسليم (نقدي)',
    cardOnDelivery: 'الدفع عند التسليم (بطاقة)',
    deliveryNotes: 'ملاحظات التسليم',
    notesPlaceholder: 'ملاحظات إضافية...',
    placeOrder: 'تأكيد الطلب',
    placing: 'جاري تأكيد الطلب...',
    backToCart: 'العودة للسلة'
  } : {
    title: 'Checkout',
    deliveryAddress: 'Delivery Address',
    deliveryTime: 'Delivery Time',
    paymentMethod: 'Payment Method',
    cashOnDelivery: 'Cash on Delivery',
    cardOnDelivery: 'Card on Delivery',
    deliveryNotes: 'Delivery Notes',
    notesPlaceholder: 'Additional notes...',
    placeOrder: 'Place Order',
    placing: 'Placing order...',
    backToCart: 'Back to Cart'
  };

  async function handlePlaceOrder() {
    loading = true;
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000));
    goto('/orders/confirmation');
  }
</script>

<div class="checkout-container">
  <header class="page-header">
    <h1>{texts.title}</h1>
  </header>

  <form on:submit|preventDefault={handlePlaceOrder}>
    <!-- Delivery Address -->
    <Card>
      <div class="section">
        <h2>{texts.deliveryAddress}</h2>
        {#each addresses as address}
          <label class="radio-option">
            <input type="radio" bind:group={selectedAddress} value={address.id} />
            <div class="address-info">
              <strong>{currentLanguage === 'ar' ? address.nameAr : address.nameEn}</strong>
              <p>{currentLanguage === 'ar' ? address.addressAr : address.addressEn}</p>
            </div>
          </label>
        {/each}
      </div>
    </Card>

    <!-- Delivery Time -->
    <Card>
      <div class="section">
        <h2>{texts.deliveryTime}</h2>
        {#each timeSlots as slot}
          <label class="radio-option">
            <input type="radio" bind:group={selectedTimeSlot} value={slot.id} />
            <span>{currentLanguage === 'ar' ? slot.labelAr : slot.labelEn}</span>
          </label>
        {/each}
      </div>
    </Card>

    <!-- Payment Method -->
    <Card>
      <div class="section">
        <h2>{texts.paymentMethod}</h2>
        <label class="radio-option">
          <input type="radio" bind:group={paymentMethod} value="cash" />
          <span>{texts.cashOnDelivery}</span>
        </label>
        <label class="radio-option">
          <input type="radio" bind:group={paymentMethod} value="card" />
          <span>{texts.cardOnDelivery}</span>
        </label>
      </div>
    </Card>

    <!-- Delivery Notes -->
    <Card>
      <div class="section">
        <h2>{texts.deliveryNotes}</h2>
        <textarea 
          bind:value={deliveryNotes}
          placeholder={texts.notesPlaceholder}
          class="notes-input"
        ></textarea>
      </div>
    </Card>

    <!-- Actions -->
    <div class="actions">
      <Button variant="secondary" on:click={() => goto('/cart')}>
        {texts.backToCart}
      </Button>
      <Button type="submit" {loading}>
        {loading ? texts.placing : texts.placeOrder}
      </Button>
    </div>
  </form>
</div>

<style>
  .checkout-container {
    padding: var(--space-4);
    min-height: 100vh;
    background: var(--color-surface);
  }

  .page-header {
    text-align: center;
    margin-bottom: var(--space-6);
  }

  .section {
    padding: var(--space-4);
  }

  .section h2 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
    font-size: 1.1rem;
  }

  .radio-option {
    display: flex;
    align-items: flex-start;
    gap: var(--space-3);
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: 0.5rem;
    margin-bottom: var(--space-2);
    cursor: pointer;
  }

  .radio-option:hover {
    background: var(--color-surface);
  }

  .address-info p {
    margin: var(--space-1) 0 0 0;
    color: var(--color-ink-light);
    font-size: 0.875rem;
  }

  .notes-input {
    width: 100%;
    min-height: 80px;
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: 0.5rem;
    resize: vertical;
    font-family: inherit;
  }

  .actions {
    display: flex;
    gap: var(--space-3);
    margin-top: var(--space-6);
  }

  .actions > :global(button) {
    flex: 1;
  }
</style>