<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';
  let adminWhatsAppNumber = '+966501234567'; // This will be loaded from admin settings
  
  // Load language from localStorage and listen for changes
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Load admin WhatsApp number
    const savedNumber = localStorage.getItem('adminWhatsAppNumber');
    if (savedNumber) {
      adminWhatsAppNumber = savedNumber;
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

  // Mock addresses data - this would come from user account
  const addresses = [
    {
      id: 1,
      name: 'المنزل',
      nameEn: 'Home',
      address: 'الرياض، حي العليا، شارع الملك فهد، مبنى رقم 123',
      addressEn: 'Riyadh, Al Olaya District, King Fahd Street, Building 123',
      isDefault: true,
      isActive: true
    },
    {
      id: 2,
      name: 'العمل',
      nameEn: 'Work',
      address: 'الرياض، حي الملز، طريق الملك عبدالله، برج الأعمال، الطابق 15',
      addressEn: 'Riyadh, Al Malaz District, King Abdullah Road, Business Tower, 15th Floor',
      isDefault: false,
      isActive: true
    },
    {
      id: 3,
      name: 'منزل الوالدين',
      nameEn: 'Parents House',
      address: 'الرياض، حي النخيل، شارع الأمير محمد بن عبدالعزيز، فيلا رقم 45',
      addressEn: 'Riyadh, Al Nakheel District, Prince Mohammed bin Abdulaziz Street, Villa 45',
      isDefault: false,
      isActive: false
    }
  ];

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة العناوين',
    backToProfile: 'العودة إلى الملف الشخصي',
    addNewAddress: 'إضافة عنوان جديد',
    defaultAddress: 'العنوان الافتراضي',
    activeAddress: 'عنوان نشط',
    inactiveAddress: 'عنوان غير نشط',
    setAsDefault: 'تعيين كافتراضي',
    activateAddress: 'تفعيل العنوان',
    deactivateAddress: 'إلغاء التفعيل',
    editAddress: 'تعديل العنوان',
    deleteAddress: 'حذف العنوان',
    changeLocationViaWhatsapp: 'تغيير الموقع عبر الواتساب',
    noAddresses: 'لا توجد عناوين محفوظة',
    addFirstAddress: 'أضف عنوانك الأول',
    addressChangeNote: 'لتغيير أو إضافة عنوان جديد، يرجى إرسال طلب عبر الواتساب. سيتم مراجعة طلبك خلال 24 ساعة.',
    requestLocationChange: 'طلب تغيير العنوان',
    requestNewAddress: 'طلب إضافة عنوان جديد'
  } : {
    title: 'Manage Addresses',
    backToProfile: 'Back to Profile',
    addNewAddress: 'Add New Address',
    defaultAddress: 'Default Address',
    activeAddress: 'Active Address',
    inactiveAddress: 'Inactive Address',
    setAsDefault: 'Set as Default',
    activateAddress: 'Activate Address',
    deactivateAddress: 'Deactivate',
    editAddress: 'Edit Address',
    deleteAddress: 'Delete Address',
    changeLocationViaWhatsapp: 'Change Location via WhatsApp',
    noAddresses: 'No saved addresses',
    addFirstAddress: 'Add your first address',
    addressChangeNote: 'To change or add a new address, please send a request via WhatsApp. Your request will be reviewed within 24 hours.',
    requestLocationChange: 'Request Address Change',
    requestNewAddress: 'Request New Address'
  };

  function goBack() {
    goto('/profile');
  }

  function requestAddressChange(address) {
    const message = currentLanguage === 'ar' 
      ? `مرحباً، أريد تغيير العنوان التالي في حساب Urban Express:\n\nالعنوان الحالي: ${address.name} - ${address.address}\n\nيرجى مساعدتي في تحديث هذا العنوان.`
      : `Hello, I want to change the following address in my Urban Express account:\n\nCurrent Address: ${address.nameEn} - ${address.addressEn}\n\nPlease help me update this address.`;
    
    const encodedMessage = encodeURIComponent(message);
    const whatsappUrl = `https://wa.me/${adminWhatsAppNumber.replace(/[^0-9]/g, '')}?text=${encodedMessage}`;
    
    window.open(whatsappUrl, '_blank');
  }

  function requestNewAddress() {
    const message = currentLanguage === 'ar' 
      ? 'مرحباً، أريد إضافة عنوان جديد إلى حساب Urban Express الخاص بي. يرجى مساعدتي في إضافة عنوان توصيل جديد.'
      : 'Hello, I want to add a new address to my Urban Express account. Please help me add a new delivery address.';
    
    const encodedMessage = encodeURIComponent(message);
    const whatsappUrl = `https://wa.me/${adminWhatsAppNumber.replace(/[^0-9]/g, '')}?text=${encodedMessage}`;
    
    window.open(whatsappUrl, '_blank');
  }

  function setAsDefault(addressId) {
    // This would typically make an API call
    console.log('Set address as default:', addressId);
  }

  function toggleAddressStatus(addressId) {
    // This would typically make an API call
    console.log('Toggle address status:', addressId);
  }

  function deleteAddress(addressId) {
    // This would typically make an API call
    const message = currentLanguage === 'ar' 
      ? `مرحباً، أريد حذف العنوان رقم ${addressId} من حساب Urban Express الخاص بي.`
      : `Hello, I want to delete address #${addressId} from my Urban Express account.`;
    
    const encodedMessage = encodeURIComponent(message);
    const whatsappUrl = `https://wa.me/${adminWhatsAppNumber.replace(/[^0-9]/g, '')}?text=${encodedMessage}`;
    
    window.open(whatsappUrl, '_blank');
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="addresses-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Header -->
  <header class="page-header">
    <Button variant="outline" size="sm" on:click={goBack}>
      ← {texts.backToProfile}
    </Button>
    <h1>{texts.title}</h1>
    <div></div> <!-- Spacer for flexbox -->
  </header>

  <!-- Address Change Note -->
  <Card>
    <div class="info-section">
      <div class="info-icon">ℹ️</div>
      <p>{texts.addressChangeNote}</p>
    </div>
  </Card>

  <!-- Add New Address -->
  <Card>
    <div class="add-address-section">
      <h2>{texts.addNewAddress}</h2>
      <Button variant="primary" fullWidth on:click={requestNewAddress}>
        <span class="whatsapp-icon">📱</span>
        {texts.requestNewAddress}
      </Button>
    </div>
  </Card>

  <!-- Addresses List -->
  {#if addresses.length === 0}
    <Card>
      <div class="no-addresses">
        <div class="empty-icon">📍</div>
        <h3>{texts.noAddresses}</h3>
        <p>{texts.addFirstAddress}</p>
        <Button variant="primary" on:click={requestNewAddress}>
          {texts.addNewAddress}
        </Button>
      </div>
    </Card>
  {:else}
    {#each addresses as address}
      <Card>
        <div class="address-item" class:default={address.isDefault} class:inactive={!address.isActive}>
          <!-- Address Header -->
          <div class="address-header">
            <div class="address-title">
              <h3>{currentLanguage === 'ar' ? address.name : address.nameEn}</h3>
              <div class="address-badges">
                {#if address.isDefault}
                  <span class="badge default">{texts.defaultAddress}</span>
                {/if}
                <span class="badge" class:active={address.isActive} class:inactive={!address.isActive}>
                  {address.isActive ? texts.activeAddress : texts.inactiveAddress}
                </span>
              </div>
            </div>
          </div>

          <!-- Address Details -->
          <div class="address-details">
            <p>{currentLanguage === 'ar' ? address.address : address.addressEn}</p>
          </div>

          <!-- Address Actions -->
          <div class="address-actions">
            <Button 
              variant="outline" 
              size="sm" 
              on:click={() => requestAddressChange(address)}
            >
              <span class="whatsapp-icon">📱</span>
              {texts.changeLocationViaWhatsapp}
            </Button>
            
            {#if !address.isDefault}
              <Button 
                variant="outline" 
                size="sm" 
                on:click={() => setAsDefault(address.id)}
              >
                {texts.setAsDefault}
              </Button>
            {/if}
            
            <Button 
              variant="outline" 
              size="sm" 
              on:click={() => toggleAddressStatus(address.id)}
            >
              {address.isActive ? texts.deactivateAddress : texts.activateAddress}
            </Button>
            
            <Button 
              variant="outline" 
              size="sm" 
              class="danger"
              on:click={() => deleteAddress(address.id)}
            >
              {texts.deleteAddress}
            </Button>
          </div>
        </div>
      </Card>
    {/each}
  {/if}
</div>

<style>
  .addresses-container {
    min-height: 100vh;
    background: var(--color-surface);
    padding: var(--space-4);
    max-width: 800px;
    margin: 0 auto;
    padding-top: calc(60px + 1rem);
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
  }

  .page-header h1 {
    margin: 0;
    color: var(--color-ink);
    font-size: 1.5rem;
  }

  .info-section {
    display: flex;
    gap: var(--space-3);
    align-items: flex-start;
    padding: var(--space-4);
    background: #f0f9ff;
    border: 1px solid #7dd3fc;
    border-radius: var(--radius-lg);
  }

  .info-icon {
    font-size: 1.5rem;
    flex-shrink: 0;
  }

  .info-section p {
    margin: 0;
    color: #0c4a6e;
    line-height: 1.5;
  }

  .add-address-section {
    padding: var(--space-4);
    text-align: center;
  }

  .add-address-section h2 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .whatsapp-icon {
    margin-right: var(--space-1);
  }

  .no-addresses {
    text-align: center;
    padding: var(--space-8);
  }

  .empty-icon {
    font-size: 4rem;
    margin-bottom: var(--space-4);
    opacity: 0.5;
  }

  .no-addresses h3 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
  }

  .no-addresses p {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink-light);
  }

  .address-item {
    padding: var(--space-4);
  }

  .address-item.default {
    border: 2px solid var(--color-primary);
    background: linear-gradient(135deg, #f0f9ff 0%, #ffffff 100%);
  }

  .address-item.inactive {
    opacity: 0.7;
    background: #f9fafb;
  }

  .address-header {
    margin-bottom: var(--space-3);
  }

  .address-title {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: var(--space-3);
  }

  .address-title h3 {
    margin: 0;
    color: var(--color-ink);
    font-size: 1.1rem;
  }

  .address-badges {
    display: flex;
    gap: var(--space-2);
    flex-wrap: wrap;
  }

  .badge {
    padding: var(--space-1) var(--space-2);
    border-radius: var(--radius-full);
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    white-space: nowrap;
  }

  .badge.default {
    background: var(--color-primary);
    color: white;
  }

  .badge.active {
    background: var(--color-success-light);
    color: var(--color-success-dark);
  }

  .badge.inactive {
    background: var(--color-border);
    color: var(--color-ink-light);
  }

  .address-details {
    margin-bottom: var(--space-4);
  }

  .address-details p {
    margin: 0;
    color: var(--color-ink-light);
    line-height: 1.5;
    padding: var(--space-2);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
  }

  .address-actions {
    display: flex;
    gap: var(--space-2);
    flex-wrap: wrap;
  }

  :global(.address-actions .button.danger) {
    color: var(--color-error);
    border-color: var(--color-error);
  }

  :global(.address-actions .button.danger:hover) {
    background: var(--color-error-light);
    color: var(--color-error-dark);
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .addresses-container {
      padding: var(--space-2);
      padding-top: calc(60px + 0.5rem);
    }

    .page-header {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .page-header h1 {
      text-align: center;
    }

    .address-title {
      flex-direction: column;
      gap: var(--space-2);
    }

    .address-actions {
      flex-direction: column;
    }

    .info-section {
      flex-direction: column;
      text-align: center;
    }
  }
</style>