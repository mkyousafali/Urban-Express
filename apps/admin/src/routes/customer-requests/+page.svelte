<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import AdminNav from '$lib/components/AdminNav.svelte';
  import { writable } from 'svelte/store';
  
  let currentLanguage = 'ar';
  let selectedRequest = null;
  let showDetails = false;
  let filterStatus = 'all';
  let searchQuery = '';
  let whatsappMessage = '';
  let showWhatsAppDialog = false;
  
  // Sample customer registration requests
  const sampleRequests = [
    {
      id: 1,
      type: 'new_registration',
      customer: {
        name: 'أحمد محمد السالم',
        phone: '+966501234567',
        whatsappPhone: '+966501234567',
        requestedLocation: {
          address: 'شارع الملك فهد، حي العليا، الرياض',
          coordinates: '', // Will be filled by admin
          description: 'بجانب مطعم الطازج، العمارة الزرقاء'
        }
      },
      status: 'pending',
      submittedAt: new Date(Date.now() - 3600000).toISOString(),
      notes: 'عميل جديد - طلب تسجيل عبر واتساب'
    },
    {
      id: 2,
      type: 'additional_location',
      customer: {
        name: 'فاطمة عبدالله',
        phone: '+966507654321',
        whatsappPhone: '+966507654321',
        existingLocations: [
          { address: 'حي النرجس، الرياض', isDefault: true }
        ],
        requestedLocation: {
          address: 'مكتب العمل - برج المملكة، الرياض',
          coordinates: '',
          description: 'الطابق الخامس، مكتب رقم 502'
        }
      },
      status: 'pending',
      submittedAt: new Date(Date.now() - 7200000).toISOString(),
      notes: 'عميل موجود - طلب إضافة موقع عمل'
    },
    {
      id: 3,
      type: 'new_registration',
      customer: {
        name: 'خالد أحمد',
        phone: '+966503456789',
        whatsappPhone: '+966503456789',
        requestedLocation: {
          address: 'حي الملز، شارع الأمير محمد، الرياض',
          coordinates: '24.6877,46.7219',
          description: 'فيلا بيضاء مع بوابة سوداء'
        }
      },
      status: 'approved',
      submittedAt: new Date(Date.now() - 86400000).toISOString(),
      approvedAt: new Date(Date.now() - 43200000).toISOString(),
      approvedBy: 'Admin',
      notes: 'تم التحقق من الموقع وإنشاء الحساب'
    },
    {
      id: 4,
      type: 'location_verification',
      customer: {
        name: 'نورا سالم',
        phone: '+966509876543',
        whatsappPhone: '+966509876543',
        requestedLocation: {
          address: 'مجمع العثيم مول، طريق الملك عبدالعزيز',
          coordinates: '',
          description: 'مدخل رقم 3، بجانب مقهى ستاربكس'
        }
      },
      status: 'needs_verification',
      submittedAt: new Date(Date.now() - 1800000).toISOString(),
      notes: 'الموقع غير واضح - يحتاج تأكيد'
    }
  ];
  
  // Customer requests store
  const customerRequests = writable(
    typeof window !== 'undefined' ? 
    JSON.parse(localStorage.getItem('customer_requests') || JSON.stringify(sampleRequests)) :
    sampleRequests
  );
  
  // Subscribe to store changes
  $: currentRequests = $customerRequests;
  
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }
  });

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة طلبات العملاء',
    newRegistration: 'تسجيل جديد',
    additionalLocation: 'موقع إضافي',
    locationVerification: 'تحقق من الموقع',
    pending: 'في الانتظار',
    approved: 'موافق عليه',
    rejected: 'مرفوض',
    needsVerification: 'يحتاج تحقق',
    allRequests: 'جميع الطلبات',
    customerName: 'اسم العميل',
    phone: 'رقم الهاتف',
    requestType: 'نوع الطلب',
    location: 'الموقع',
    status: 'الحالة',
    submittedAt: 'تاريخ الطلب',
    actions: 'الإجراءات',
    viewDetails: 'عرض التفاصيل',
    approve: 'موافقة',
    reject: 'رفض',
    needVerification: 'يحتاج تحقق',
    whatsappCustomer: 'راسل العميل',
    copyLocation: 'نسخ الموقع',
    search: 'البحث',
    searchPlaceholder: 'البحث في الطلبات...',
    filter: 'تصفية',
    requestDetails: 'تفاصيل الطلب',
    address: 'العنوان',
    coordinates: 'الإحداثيات',
    description: 'الوصف',
    notes: 'ملاحظات',
    existingLocations: 'المواقع الحالية',
    defaultLocation: 'الموقع الافتراضي',
    close: 'إغلاق',
    save: 'حفظ',
    locationCopied: 'تم نسخ الموقع',
    requestUpdated: 'تم تحديث الطلب',
    whatsappMessage: 'رسالة واتساب',
    sendMessage: 'إرسال الرسالة',
    cancel: 'إلغاء',
    pasteCoordinates: 'لصق الإحداثيات',
    coordinatesFormat: 'تنسيق: latitude,longitude',
    noRequests: 'لا توجد طلبات',
    approvedBy: 'تمت الموافقة من',
    approvedAt: 'تاريخ الموافقة'
  } : {
    title: 'Customer Request Management',
    newRegistration: 'New Registration',
    additionalLocation: 'Additional Location',
    locationVerification: 'Location Verification',
    pending: 'Pending',
    approved: 'Approved',
    rejected: 'Rejected',
    needsVerification: 'Needs Verification',
    allRequests: 'All Requests',
    customerName: 'Customer Name',
    phone: 'Phone Number',
    requestType: 'Request Type',
    location: 'Location',
    status: 'Status',
    submittedAt: 'Submitted At',
    actions: 'Actions',
    viewDetails: 'View Details',
    approve: 'Approve',
    reject: 'Reject',
    needVerification: 'Need Verification',
    whatsappCustomer: 'WhatsApp Customer',
    copyLocation: 'Copy Location',
    search: 'Search',
    searchPlaceholder: 'Search requests...',
    filter: 'Filter',
    requestDetails: 'Request Details',
    address: 'Address',
    coordinates: 'Coordinates',
    description: 'Description',
    notes: 'Notes',
    existingLocations: 'Existing Locations',
    defaultLocation: 'Default Location',
    close: 'Close',
    save: 'Save',
    locationCopied: 'Location copied',
    requestUpdated: 'Request updated',
    whatsappMessage: 'WhatsApp Message',
    sendMessage: 'Send Message',
    cancel: 'Cancel',
    pasteCoordinates: 'Paste Coordinates',
    coordinatesFormat: 'Format: latitude,longitude',
    noRequests: 'No requests',
    approvedBy: 'Approved By',
    approvedAt: 'Approved At'
  };

  // Status configurations
  $: statusConfig = {
    pending: { color: 'orange', label: texts.pending },
    approved: { color: 'success', label: texts.approved },
    rejected: { color: 'error', label: texts.rejected },
    needs_verification: { color: 'purple', label: texts.needsVerification }
  };

  // Request type configurations
  $: typeConfig = {
    new_registration: { icon: '👤', label: texts.newRegistration },
    additional_location: { icon: '📍', label: texts.additionalLocation },
    location_verification: { icon: '🔍', label: texts.locationVerification }
  };

  // Filtered requests
  $: filteredRequests = currentRequests.filter(request => {
    // Status filter
    if (filterStatus !== 'all' && request.status !== filterStatus) {
      return false;
    }
    
    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      return (
        request.customer.name.toLowerCase().includes(query) ||
        request.customer.phone.includes(query) ||
        request.customer.requestedLocation.address.toLowerCase().includes(query) ||
        request.notes.toLowerCase().includes(query)
      );
    }
    
    return true;
  });

  function showRequestDetails(request) {
    selectedRequest = { ...request };
    showDetails = true;
  }

  function closeDetails() {
    showDetails = false;
    selectedRequest = null;
  }

  function updateRequestStatus(request, newStatus) {
    customerRequests.update(requests => {
      const updated = requests.map(req => {
        if (req.id === request.id) {
          const updatedReq = { 
            ...req, 
            status: newStatus,
            updatedAt: new Date().toISOString()
          };
          
          if (newStatus === 'approved') {
            updatedReq.approvedAt = new Date().toISOString();
            updatedReq.approvedBy = 'Admin';
          }
          
          return updatedReq;
        }
        return req;
      });
      
      // Save to localStorage
      localStorage.setItem('customer_requests', JSON.stringify(updated));
      return updated;
    });
    
    alert(texts.requestUpdated);
  }

  function updateRequestCoordinates() {
    if (!selectedRequest) return;
    
    customerRequests.update(requests => {
      const updated = requests.map(req => {
        if (req.id === selectedRequest.id) {
          return {
            ...req,
            customer: {
              ...req.customer,
              requestedLocation: {
                ...req.customer.requestedLocation,
                coordinates: selectedRequest.customer.requestedLocation.coordinates
              }
            },
            updatedAt: new Date().toISOString()
          };
        }
        return req;
      });
      
      localStorage.setItem('customer_requests', JSON.stringify(updated));
      return updated;
    });
    
    alert(texts.requestUpdated);
    closeDetails();
  }

  function copyLocationToClipboard(location) {
    const locationText = `${location.address}\n${location.description || ''}\n${location.coordinates || ''}`;
    navigator.clipboard.writeText(locationText).then(() => {
      alert(texts.locationCopied);
    });
  }

  function showWhatsAppModal(request) {
    selectedRequest = request;
    
    // Generate appropriate message based on request type
    if (request.type === 'new_registration') {
      whatsappMessage = currentLanguage === 'ar' ? 
        `مرحباً ${request.customer.name}،\n\nشكراً لك على طلب التسجيل في Urban Express.\n\nيرجى تأكيد موقعك المطلوب:\n${request.customer.requestedLocation.address}\n\nسنقوم بمراجعة طلبك والموافقة عليه قريباً.` :
        `Hello ${request.customer.name},\n\nThank you for registering with Urban Express.\n\nPlease confirm your requested location:\n${request.customer.requestedLocation.address}\n\nWe will review and approve your request soon.`;
    } else if (request.type === 'additional_location') {
      whatsappMessage = currentLanguage === 'ar' ? 
        `مرحباً ${request.customer.name}،\n\nتم استلام طلبك لإضافة موقع جديد:\n${request.customer.requestedLocation.address}\n\nسنقوم بإضافته لحسابك قريباً.` :
        `Hello ${request.customer.name},\n\nWe received your request to add a new location:\n${request.customer.requestedLocation.address}\n\nWe will add it to your account soon.`;
    } else {
      whatsappMessage = currentLanguage === 'ar' ? 
        `مرحباً ${request.customer.name}،\n\nيرجى تأكيد تفاصيل موقعك:\n${request.customer.requestedLocation.address}\n\nنحتاج توضيح أكثر للوصول بسهولة.` :
        `Hello ${request.customer.name},\n\nPlease confirm your location details:\n${request.customer.requestedLocation.address}\n\nWe need more clarification for easy access.`;
    }
    
    showWhatsAppDialog = true;
  }

  function sendWhatsAppMessage() {
    if (!selectedRequest || !whatsappMessage) return;
    
    const phone = selectedRequest.customer.whatsappPhone.replace(/[^\d]/g, '');
    const encodedMessage = encodeURIComponent(whatsappMessage);
    window.open(`https://wa.me/${phone}?text=${encodedMessage}`, '_blank');
    
    showWhatsAppDialog = false;
    whatsappMessage = '';
  }

  function closeWhatsAppModal() {
    showWhatsAppDialog = false;
    whatsappMessage = '';
    selectedRequest = null;
  }

  function formatTime(dateString) {
    return new Date(dateString).toLocaleString(
      currentLanguage === 'ar' ? 'ar-SA' : 'en-US',
      {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }
    );
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="header">
    <h1>{texts.title}</h1>
  </div>

  <!-- Filters and Search -->
  <Card>
    <div class="filters-container">
      <div class="search-section">
        <Input
          label={texts.search}
          placeholder={texts.searchPlaceholder}
          bind:value={searchQuery}
        />
      </div>
      
      <div class="filter-section">
        <div class="filter-group">
          <label>{texts.filter}:</label>
          <select bind:value={filterStatus}>
            <option value="all">{texts.allRequests}</option>
            <option value="pending">{texts.pending}</option>
            <option value="approved">{texts.approved}</option>
            <option value="rejected">{texts.rejected}</option>
            <option value="needs_verification">{texts.needsVerification}</option>
          </select>
        </div>
      </div>
    </div>
  </Card>

  <!-- Requests List -->
  <div class="requests-list">
    {#if filteredRequests.length === 0}
      <div class="no-requests">
        <p>{texts.noRequests}</p>
      </div>
    {:else}
      {#each filteredRequests as request}
        <Card>
          <div class="request-item">
            <div class="request-header">
              <div class="request-info">
                <div class="request-type">
                  <span class="type-icon">{typeConfig[request.type].icon}</span>
                  <span class="type-label">{typeConfig[request.type].label}</span>
                </div>
                <h3>{request.customer.name}</h3>
                <span class="request-time">{formatTime(request.submittedAt)}</span>
              </div>
              <div class="request-status">
                <span class="status-badge" style="background: var(--color-{statusConfig[request.status].color}-light); color: var(--color-{statusConfig[request.status].color}-dark)">
                  {statusConfig[request.status].label}
                </span>
              </div>
            </div>

            <div class="request-content">
              <div class="request-details">
                <div class="detail-item">
                  <strong>{texts.phone}:</strong> {request.customer.phone}
                </div>
                <div class="detail-item">
                  <strong>{texts.address}:</strong> {request.customer.requestedLocation.address}
                </div>
                {#if request.customer.requestedLocation.description}
                  <div class="detail-item">
                    <strong>{texts.description}:</strong> {request.customer.requestedLocation.description}
                  </div>
                {/if}
                {#if request.customer.requestedLocation.coordinates}
                  <div class="detail-item">
                    <strong>{texts.coordinates}:</strong> {request.customer.requestedLocation.coordinates}
                  </div>
                {/if}
                {#if request.notes}
                  <div class="detail-item">
                    <strong>{texts.notes}:</strong> {request.notes}
                  </div>
                {/if}
              </div>
            </div>

            <div class="request-actions">
              <Button variant="outline" size="sm" on:click={() => showRequestDetails(request)}>
                {texts.viewDetails}
              </Button>
              
              {#if request.status === 'pending' || request.status === 'needs_verification'}
                <Button variant="success" size="sm" on:click={() => updateRequestStatus(request, 'approved')}>
                  {texts.approve}
                </Button>
                <Button variant="error" size="sm" on:click={() => updateRequestStatus(request, 'rejected')}>
                  {texts.reject}
                </Button>
                <Button variant="outline" size="sm" on:click={() => updateRequestStatus(request, 'needs_verification')}>
                  {texts.needVerification}
                </Button>
              {/if}

              <Button variant="outline" size="sm" on:click={() => showWhatsAppModal(request)}>
                {texts.whatsappCustomer}
              </Button>
              
              <Button variant="outline" size="sm" on:click={() => copyLocationToClipboard(request.customer.requestedLocation)}>
                {texts.copyLocation}
              </Button>
            </div>
          </div>
        </Card>
      {/each}
    {/if}
  </div>
</div>

<!-- Request Details Modal -->
{#if showDetails && selectedRequest}
  <div class="modal-overlay" on:click={closeDetails}>
    <div class="modal-content" on:click|stopPropagation>
      <div class="modal-header">
        <h2>{texts.requestDetails}</h2>
        <button class="close-btn" on:click={closeDetails}>&times;</button>
      </div>
      
      <div class="modal-body">
        <div class="details-grid">
          <div class="detail-section">
            <h3>{texts.customerName}</h3>
            <p>{selectedRequest.customer.name}</p>
          </div>

          <div class="detail-section">
            <h3>{texts.phone}</h3>
            <p>{selectedRequest.customer.phone}</p>
          </div>

          <div class="detail-section">
            <h3>{texts.requestType}</h3>
            <p>{typeConfig[selectedRequest.type].label}</p>
          </div>

          <div class="detail-section">
            <h3>{texts.status}</h3>
            <p>{statusConfig[selectedRequest.status].label}</p>
          </div>
        </div>

        <div class="location-section">
          <h3>{texts.location}</h3>
          <div class="location-details">
            <div class="form-group">
              <label>{texts.address}</label>
              <p>{selectedRequest.customer.requestedLocation.address}</p>
            </div>
            
            <div class="form-group">
              <label>{texts.description}</label>
              <p>{selectedRequest.customer.requestedLocation.description || '-'}</p>
            </div>
            
            <div class="form-group">
              <label>{texts.coordinates}</label>
              <Input
                placeholder={texts.coordinatesFormat}
                bind:value={selectedRequest.customer.requestedLocation.coordinates}
              />
              <small>{texts.pasteCoordinates}</small>
            </div>
          </div>
        </div>

        {#if selectedRequest.type === 'additional_location' && selectedRequest.customer.existingLocations}
          <div class="existing-locations">
            <h3>{texts.existingLocations}</h3>
            {#each selectedRequest.customer.existingLocations as location}
              <div class="existing-location">
                <span>{location.address}</span>
                {#if location.isDefault}
                  <span class="default-badge">{texts.defaultLocation}</span>
                {/if}
              </div>
            {/each}
          </div>
        {/if}

        {#if selectedRequest.status === 'approved'}
          <div class="approval-info">
            <p><strong>{texts.approvedBy}:</strong> {selectedRequest.approvedBy}</p>
            <p><strong>{texts.approvedAt}:</strong> {formatTime(selectedRequest.approvedAt)}</p>
          </div>
        {/if}

        <div class="modal-actions">
          <Button variant="primary" on:click={updateRequestCoordinates}>
            {texts.save}
          </Button>
          <Button variant="outline" on:click={closeDetails}>
            {texts.close}
          </Button>
        </div>
      </div>
    </div>
  </div>
{/if}

<!-- WhatsApp Modal -->
{#if showWhatsAppDialog && selectedRequest}
  <div class="modal-overlay" on:click={closeWhatsAppModal}>
    <div class="modal-content" on:click|stopPropagation>
      <div class="modal-header">
        <h2>{texts.whatsappMessage}</h2>
        <button class="close-btn" on:click={closeWhatsAppModal}>&times;</button>
      </div>
      
      <div class="modal-body">
        <div class="form-group">
          <label>{texts.phone}: {selectedRequest.customer.whatsappPhone}</label>
        </div>
        
        <div class="form-group">
          <label>{texts.whatsappMessage}</label>
          <textarea 
            bind:value={whatsappMessage}
            rows="8"
            placeholder="Enter your message..."
          ></textarea>
        </div>

        <div class="modal-actions">
          <Button variant="success" on:click={sendWhatsAppMessage}>
            {texts.sendMessage}
          </Button>
          <Button variant="outline" on:click={closeWhatsAppModal}>
            {texts.cancel}
          </Button>
        </div>
      </div>
    </div>
  </div>
{/if}

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 1400px;
    margin: 0 auto;
  }

  .header {
    margin-bottom: var(--space-6);
  }

  .header h1 {
    margin: 0;
    color: var(--color-ink);
  }

  .filters-container {
    padding: var(--space-4);
  }

  .search-section {
    margin-bottom: var(--space-4);
  }

  .filter-section {
    display: flex;
    gap: var(--space-4);
    flex-wrap: wrap;
  }

  .filter-group {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .filter-group label {
    font-weight: 500;
    color: var(--color-ink);
  }

  .filter-group select {
    padding: var(--space-2) var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: white;
    min-width: 150px;
  }

  .requests-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .no-requests {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .request-item {
    padding: var(--space-4);
  }

  .request-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: var(--space-4);
  }

  .request-type {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    margin-bottom: var(--space-2);
  }

  .type-icon {
    font-size: 1.2rem;
  }

  .type-label {
    font-size: 0.85rem;
    color: var(--color-ink-light);
    font-weight: 500;
  }

  .request-info h3 {
    margin: 0;
    color: var(--color-ink);
  }

  .request-time {
    color: var(--color-ink-light);
    font-size: 0.9rem;
  }

  .status-badge {
    padding: var(--space-2) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .request-content {
    margin-bottom: var(--space-4);
  }

  .request-details {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .detail-item {
    font-size: 0.9rem;
  }

  .request-actions {
    display: flex;
    gap: var(--space-2);
    flex-wrap: wrap;
  }

  /* Modal Styles */
  .modal-overlay {
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
    padding: var(--space-4);
  }

  .modal-content {
    background: white;
    border-radius: var(--radius-lg);
    max-width: 800px;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-4);
    border-bottom: 1px solid var(--color-border);
  }

  .modal-header h2 {
    margin: 0;
    color: var(--color-ink);
  }

  .close-btn {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: var(--color-ink-light);
    padding: 0;
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .close-btn:hover {
    color: var(--color-ink);
  }

  .modal-body {
    padding: var(--space-6);
  }

  .details-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: var(--space-4);
    margin-bottom: var(--space-6);
  }

  .detail-section h3 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
    font-size: 1rem;
  }

  .detail-section p {
    margin: 0;
    color: var(--color-ink-light);
  }

  .location-section {
    margin-bottom: var(--space-6);
  }

  .location-section h3 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
  }

  .form-group {
    margin-bottom: var(--space-4);
  }

  .form-group label {
    display: block;
    margin-bottom: var(--space-2);
    font-weight: 500;
    color: var(--color-ink);
  }

  .form-group p {
    margin: 0;
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
    color: var(--color-ink-light);
  }

  .form-group small {
    display: block;
    margin-top: var(--space-1);
    color: var(--color-ink-light);
    font-size: 0.8rem;
  }

  .form-group textarea {
    width: 100%;
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    resize: vertical;
    font-family: inherit;
  }

  .existing-locations {
    margin-bottom: var(--space-6);
  }

  .existing-locations h3 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
  }

  .existing-location {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
    margin-bottom: var(--space-2);
  }

  .default-badge {
    background: var(--color-primary);
    color: white;
    padding: var(--space-1) var(--space-2);
    border-radius: var(--radius-sm);
    font-size: 0.75rem;
    font-weight: 600;
  }

  .approval-info {
    margin-bottom: var(--space-6);
    padding: var(--space-3);
    background: var(--color-success-light);
    border-radius: var(--radius-md);
  }

  .approval-info p {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-success-dark);
  }

  .modal-actions {
    display: flex;
    gap: var(--space-3);
    justify-content: flex-end;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .filter-section {
      flex-direction: column;
    }

    .request-header {
      flex-direction: column;
      gap: var(--space-2);
    }

    .request-actions {
      flex-direction: column;
    }

    .details-grid {
      grid-template-columns: 1fr;
    }

    .modal-actions {
      flex-direction: column;
    }
  }
</style>