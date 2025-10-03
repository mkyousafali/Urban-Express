<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let adminWhatsAppNumber = '+966501234567';
  let newLocationRequests = [];
  let currentLanguage = 'ar';
  let saved = false;
  
  // Mock location change requests
  const locationRequests = [
    {
      id: 1,
      customerName: 'أحمد محمد الأحمد',
      customerNameEn: 'Ahmed Mohammed Al-Ahmed',
      whatsapp: '0501234567',
      currentLocation: 'الرياض، حي العليا، شارع الملك فهد',
      newLocationLink: '',
      requestDate: '2024-10-03T10:30:00',
      status: 'pending' // pending, approved, rejected
    },
    {
      id: 2,
      customerName: 'فاطمة أحمد السالم',
      customerNameEn: 'Fatima Ahmed Al-Salem',
      whatsapp: '0509876543',
      currentLocation: 'جدة، حي الصفا، شارع الأمير سلطان',
      newLocationLink: 'https://maps.google.com/...',
      requestDate: '2024-10-02T14:15:00',
      status: 'pending'
    }
  ];
  
  // Load settings
  onMount(() => {
    const savedNumber = localStorage.getItem('adminWhatsAppNumber');
    if (savedNumber) {
      adminWhatsAppNumber = savedNumber;
    }
    
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }
    
    newLocationRequests = locationRequests;
  });

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة طلبات تغيير الموقع',
    settings: 'الإعدادات',
    whatsappLabel: 'رقم الواتساب لاستقبال طلبات تغيير الموقع',
    whatsappHelp: 'سيتم توجيه العملاء لإرسال طلبات تغيير المواقع إلى هذا الرقم',
    saveButton: 'حفظ الإعدادات',
    saved: 'تم الحفظ بنجاح!',
    testWhatsAppButton: 'اختبار الواتساب',
    locationRequests: 'طلبات تغيير الموقع',
    customerName: 'اسم العميل',
    customerWhatsapp: 'واتساب العميل',
    currentLocation: 'الموقع الحالي',
    newLocationLink: 'رابط الموقع الجديد',
    newLocationPlaceholder: 'الصق رابط الموقع الجديد هنا...',
    requestDate: 'تاريخ الطلب',
    status: 'الحالة',
    pending: 'قيد الانتظار',
    approved: 'تم الموافقة',
    rejected: 'مرفوض',
    approve: 'موافقة',
    reject: 'رفض',
    copyLink: 'نسخ الرابط',
    noRequests: 'لا توجد طلبات تغيير موقع'
  } : {
    title: 'Location Change Requests Management',
    settings: 'Settings',
    whatsappLabel: 'WhatsApp Number for Location Change Requests',
    whatsappHelp: 'Customers will be directed to send location change requests to this number',
    saveButton: 'Save Settings',
    saved: 'Saved successfully!',
    testWhatsAppButton: 'Test WhatsApp',
    locationRequests: 'Location Change Requests',
    customerName: 'Customer Name',
    customerWhatsapp: 'Customer WhatsApp',
    currentLocation: 'Current Location',
    newLocationLink: 'New Location Link',
    newLocationPlaceholder: 'Paste new location link here...',
    requestDate: 'Request Date',
    status: 'Status',
    pending: 'Pending',
    approved: 'Approved',
    rejected: 'Rejected',
    approve: 'Approve',
    reject: 'Reject',
    copyLink: 'Copy Link',
    noRequests: 'No location change requests'
  };

  function saveSettings() {
    localStorage.setItem('adminWhatsAppNumber', adminWhatsAppNumber);
    saved = true;
    setTimeout(() => saved = false, 3000);
  }

  function testWhatsApp() {
    const testMessage = encodeURIComponent('Test message from Urban Express admin panel - Location change requests');
    const whatsappUrl = `https://wa.me/${adminWhatsAppNumber.replace(/[^0-9]/g, '')}?text=${testMessage}`;
    window.open(whatsappUrl, '_blank');
  }

  function updateLocationLink(requestId, link) {
    const requestIndex = newLocationRequests.findIndex(req => req.id === requestId);
    if (requestIndex !== -1) {
      newLocationRequests[requestIndex].newLocationLink = link;
      newLocationRequests = [...newLocationRequests]; // Trigger reactivity
    }
  }

  function approveRequest(requestId) {
    const requestIndex = newLocationRequests.findIndex(req => req.id === requestId);
    if (requestIndex !== -1) {
      newLocationRequests[requestIndex].status = 'approved';
      newLocationRequests = [...newLocationRequests];
      // Here you would typically save to database
    }
  }

  function rejectRequest(requestId) {
    const requestIndex = newLocationRequests.findIndex(req => req.id === requestId);
    if (requestIndex !== -1) {
      newLocationRequests[requestIndex].status = 'rejected';
      newLocationRequests = [...newLocationRequests];
      // Here you would typically save to database
    }
  }

  function copyLocationLink(link) {
    if (link) {
      navigator.clipboard.writeText(link);
    }
  }

  function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString(currentLanguage === 'ar' ? 'ar-SA' : 'en-US') + ' ' + 
           date.toLocaleTimeString(currentLanguage === 'ar' ? 'ar-SA' : 'en-US', { 
             hour: '2-digit', 
             minute: '2-digit' 
           });
  }
</script>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <h1>{texts.title}</h1>
  
  <!-- Settings Section -->
  <Card>
    <div class="admin-content">
      <h2>{texts.settings}</h2>
      
      <div class="setting-group">
        <Input 
          label={texts.whatsappLabel} 
          bind:value={adminWhatsAppNumber} 
          type="tel" 
          required 
        />
        <p class="help-text">{texts.whatsappHelp}</p>
        <div class="button-row">
          <Button variant="outline" on:click={testWhatsApp}>
            {texts.testWhatsAppButton}
          </Button>
          <Button variant="primary" on:click={saveSettings}>
            {texts.saveButton}
          </Button>
        </div>
        
        {#if saved}
          <div class="saved-message">
            ✓ {texts.saved}
          </div>
        {/if}
      </div>
    </div>
  </Card>

  <!-- Location Change Requests -->
  <Card>
    <div class="admin-content">
      <h2>{texts.locationRequests}</h2>
      
      {#if newLocationRequests.length === 0}
        <div class="no-requests">
          <p>{texts.noRequests}</p>
        </div>
      {:else}
        <div class="requests-list">
          {#each newLocationRequests as request}
            <div class="request-item" class:approved={request.status === 'approved'} class:rejected={request.status === 'rejected'}>
              <div class="request-header">
                <div class="customer-info">
                  <h3>{currentLanguage === 'ar' ? request.customerName : request.customerNameEn}</h3>
                  <p class="whatsapp">{request.whatsapp}</p>
                  <p class="date">{formatDate(request.requestDate)}</p>
                </div>
                <div class="status-badge" class:pending={request.status === 'pending'} 
                     class:approved={request.status === 'approved'} class:rejected={request.status === 'rejected'}>
                  {texts[request.status]}
                </div>
              </div>
              
              <div class="location-info">
                <div class="current-location">
                  <label>{texts.currentLocation}:</label>
                  <p>{request.currentLocation}</p>
                </div>
                
                <div class="new-location">
                  <label>{texts.newLocationLink}:</label>
                  <div class="location-input-group">
                    <input 
                      type="url" 
                      placeholder={texts.newLocationPlaceholder}
                      value={request.newLocationLink}
                      on:input={(e) => updateLocationLink(request.id, e.target.value)}
                    />
                    <Button 
                      variant="outline" 
                      size="sm" 
                      on:click={() => copyLocationLink(request.newLocationLink)}
                      disabled={!request.newLocationLink}
                    >
                      {texts.copyLink}
                    </Button>
                  </div>
                </div>
              </div>
              
              {#if request.status === 'pending'}
                <div class="action-buttons">
                  <Button 
                    variant="primary" 
                    size="sm" 
                    on:click={() => approveRequest(request.id)}
                    disabled={!request.newLocationLink}
                  >
                    {texts.approve}
                  </Button>
                  <Button 
                    variant="outline" 
                    size="sm" 
                    on:click={() => rejectRequest(request.id)}
                  >
                    {texts.reject}
                  </Button>
                </div>
              {/if}
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </Card>
</div>

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 1000px;
    margin: 0 auto;
  }

  h1 {
    text-align: center;
    margin-bottom: var(--space-6);
    color: var(--color-ink);
  }

  .admin-content {
    padding: var(--space-6);
  }

  h2 {
    margin-bottom: var(--space-4);
    color: var(--color-ink);
    border-bottom: 2px solid var(--color-border);
    padding-bottom: var(--space-2);
  }

  .setting-group {
    margin-bottom: var(--space-6);
  }

  .help-text {
    font-size: 0.875rem;
    color: var(--color-ink-light);
    margin: var(--space-2) 0 var(--space-3) 0;
  }

  .button-row {
    display: flex;
    gap: var(--space-3);
    align-items: center;
  }

  .saved-message {
    margin-top: var(--space-3);
    padding: var(--space-2);
    background: var(--color-success-light);
    color: var(--color-success-dark);
    border-radius: var(--radius-md);
    font-weight: 500;
  }

  .no-requests {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .requests-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .request-item {
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    padding: var(--space-4);
    background: var(--color-surface);
  }

  .request-item.approved {
    border-color: var(--color-success);
    background: var(--color-success-light);
  }

  .request-item.rejected {
    border-color: var(--color-error);
    background: var(--color-error-light);
  }

  .request-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: var(--space-4);
  }

  .customer-info h3 {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
  }

  .customer-info .whatsapp {
    color: var(--color-ink-light);
    font-weight: 500;
    margin: 0 0 var(--space-1) 0;
  }

  .customer-info .date {
    color: var(--color-ink-light);
    font-size: 0.85rem;
    margin: 0;
  }

  .status-badge {
    padding: var(--space-1) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-badge.pending {
    background: #fef3c7;
    color: #d97706;
  }

  .status-badge.approved {
    background: var(--color-success-light);
    color: var(--color-success-dark);
  }

  .status-badge.rejected {
    background: var(--color-error-light);
    color: var(--color-error-dark);
  }

  .location-info {
    margin-bottom: var(--space-4);
  }

  .current-location, .new-location {
    margin-bottom: var(--space-3);
  }

  .current-location label, .new-location label {
    display: block;
    font-weight: 600;
    color: var(--color-ink);
    margin-bottom: var(--space-1);
  }

  .current-location p {
    background: var(--color-surface-variant);
    padding: var(--space-2);
    border-radius: var(--radius-md);
    margin: 0;
    color: var(--color-ink-light);
  }

  .location-input-group {
    display: flex;
    gap: var(--space-2);
    align-items: center;
  }

  .location-input-group input {
    flex: 1;
    padding: var(--space-2);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    font-size: 0.9rem;
  }

  .action-buttons {
    display: flex;
    gap: var(--space-3);
    justify-content: flex-end;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .admin-content {
      padding: var(--space-4);
    }

    .request-header {
      flex-direction: column;
      gap: var(--space-2);
    }

    .button-row {
      flex-direction: column;
      align-items: stretch;
    }

    .location-input-group {
      flex-direction: column;
    }

    .action-buttons {
      flex-direction: column;
    }
  }
</style>