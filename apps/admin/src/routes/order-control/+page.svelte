<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import AdminNav from '$lib/components/AdminNav.svelte';
  import { orders, branches, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let selectedOrder = null;
  let showOrderDetails = false;
  let filterStatus = 'all';
  let filterBranch = 'all';
  let searchQuery = '';
  let showAssignModal = false;
  let assignmentType = ''; // 'pickup' or 'delivery'
  let selectedStaff = '';
  let estimatedTime = '';
  
  // Subscribe to stores
  $: currentOrders = $orders;
  $: currentBranches = $branches;
  
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
    title: 'مركز التحكم في الطلبات',
    allOrders: 'جميع الطلبات',
    pending: 'في الانتظار',
    confirmed: 'مؤكد',
    preparing: 'قيد التحضير',
    ready: 'جاهز للاستلام',
    outForDelivery: 'في الطريق',
    delivered: 'تم التوصيل',
    cancelled: 'ملغي',
    orderDetails: 'تفاصيل الطلب',
    customer: 'العميل',
    branch: 'الفرع',
    orderType: 'نوع الطلب',
    pickup: 'استلام',
    delivery: 'توصيل',
    items: 'الأصناف',
    total: 'الإجمالي',
    paymentMethod: 'طريقة الدفع',
    orderTime: 'وقت الطلب',
    assignPickupStaff: 'تعيين موظف الاستلام',
    assignDeliveryBoy: 'تعيين مندوب التوصيل',
    pickupStaff: 'موظف الاستلام',
    deliveryBoy: 'مندوب التوصيل',
    estimatedTime: 'الوقت المقدر',
    minutes: 'دقيقة',
    assign: 'تعيين',
    cancel: 'إلغاء',
    updateStatus: 'تحديث الحالة',
    contactCustomer: 'التواصل مع العميل',
    whatsappOrder: 'مشاركة عبر واتساب',
    search: 'البحث',
    searchPlaceholder: 'البحث في الطلبات...',
    filter: 'تصفية',
    allBranches: 'جميع الفروع',
    noOrders: 'لا توجد طلبات',
    orderNumber: 'رقم الطلب',
    estimatedDeliveryTime: 'وقت التوصيل المقدر',
    close: 'إغلاق',
    save: 'حفظ',
    phone: 'الهاتف',
    address: 'العنوان',
    notes: 'ملاحظات',
    noNotes: 'لا توجد ملاحظات',
    cash: 'نقدي',
    card: 'بطاقة',
    sar: 'ريال',
    assigned: 'مُعين',
    notAssigned: 'غير مُعين',
    selectStaff: 'اختر الموظف',
    orderUpdated: 'تم تحديث الطلب',
    staffAssigned: 'تم تعيين الموظف',
    processingOrder: 'معالجة الطلب...'
  } : {
    title: 'Order Control Center',
    allOrders: 'All Orders',
    pending: 'Pending',
    confirmed: 'Confirmed',
    preparing: 'Preparing',
    ready: 'Ready for Pickup',
    outForDelivery: 'Out for Delivery',
    delivered: 'Delivered',
    cancelled: 'Cancelled',
    orderDetails: 'Order Details',
    customer: 'Customer',
    branch: 'Branch',
    orderType: 'Order Type',
    pickup: 'Pickup',
    delivery: 'Delivery',
    items: 'Items',
    total: 'Total',
    paymentMethod: 'Payment Method',
    orderTime: 'Order Time',
    assignPickupStaff: 'Assign Pickup Staff',
    assignDeliveryBoy: 'Assign Delivery Boy',
    pickupStaff: 'Pickup Staff',
    deliveryBoy: 'Delivery Boy',
    estimatedTime: 'Estimated Time',
    minutes: 'minutes',
    assign: 'Assign',
    cancel: 'Cancel',
    updateStatus: 'Update Status',
    contactCustomer: 'Contact Customer',
    whatsappOrder: 'Share via WhatsApp',
    search: 'Search',
    searchPlaceholder: 'Search orders...',
    filter: 'Filter',
    allBranches: 'All Branches',
    noOrders: 'No orders',
    orderNumber: 'Order Number',
    estimatedDeliveryTime: 'Estimated Delivery Time',
    close: 'Close',
    save: 'Save',
    phone: 'Phone',
    address: 'Address',
    notes: 'Notes',
    noNotes: 'No notes',
    cash: 'Cash',
    card: 'Card',
    sar: 'SAR',
    assigned: 'Assigned',
    notAssigned: 'Not Assigned',
    selectStaff: 'Select Staff',
    orderUpdated: 'Order updated',
    staffAssigned: 'Staff assigned',
    processingOrder: 'Processing order...'
  };

  // Status configurations
  $: statusConfig = {
    pending: { color: 'orange', label: texts.pending },
    confirmed: { color: 'blue', label: texts.confirmed },
    preparing: { color: 'purple', label: texts.preparing },
    ready: { color: 'green', label: texts.ready },
    outForDelivery: { color: 'teal', label: texts.outForDelivery },
    delivered: { color: 'success', label: texts.delivered },
    cancelled: { color: 'error', label: texts.cancelled }
  };

  // Filtered orders
  $: filteredOrders = currentOrders.filter(order => {
    // Status filter
    if (filterStatus !== 'all' && order.status !== filterStatus) {
      return false;
    }
    
    // Branch filter
    if (filterBranch !== 'all' && order.branchId !== filterBranch) {
      return false;
    }
    
    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      return (
        order.orderNumber.toLowerCase().includes(query) ||
        order.customer.name.toLowerCase().includes(query) ||
        order.customer.phone.includes(query) ||
        (order.customer.address && order.customer.address.toLowerCase().includes(query))
      );
    }
    
    return true;
  });

  function showOrderDetailsModal(order) {
    selectedOrder = order;
    showOrderDetails = true;
  }

  function closeOrderDetails() {
    showOrderDetails = false;
    selectedOrder = null;
  }

  function showAssignmentModal(order, type) {
    selectedOrder = order;
    assignmentType = type;
    selectedStaff = '';
    estimatedTime = '';
    showAssignModal = true;
  }

  function closeAssignModal() {
    showAssignModal = false;
    selectedOrder = null;
    assignmentType = '';
    selectedStaff = '';
    estimatedTime = '';
  }

  function getAvailableStaff(branchId, type) {
    const branch = currentBranches.find(b => b.id === branchId);
    if (!branch || !branch.staff) return [];
    
    return type === 'pickup' ? 
      (branch.staff.pickupStaff || []).filter(s => s.isActive) :
      (branch.staff.deliveryBoys || []).filter(s => s.isActive);
  }

  function assignStaff() {
    if (!selectedStaff || !selectedOrder) return;
    
    const updateData = {
      updatedAt: new Date().toISOString()
    };
    
    if (assignmentType === 'pickup') {
      const staff = getAvailableStaff(selectedOrder.branchId, 'pickup').find(s => s.id === parseInt(selectedStaff));
      updateData.pickupStaff = {
        id: staff.id,
        name: staff.name,
        phone: staff.phone,
        assignedAt: new Date().toISOString(),
        estimatedTime: estimatedTime ? parseInt(estimatedTime) : null
      };
    } else {
      const staff = getAvailableStaff(selectedOrder.branchId, 'delivery').find(s => s.id === parseInt(selectedStaff));
      updateData.deliveryBoy = {
        id: staff.id,
        name: staff.name,
        phone: staff.phone,
        assignedAt: new Date().toISOString(),
        estimatedTime: estimatedTime ? parseInt(estimatedTime) : null
      };
    }
    
    adminActions.updateOrder(selectedOrder.id, updateData);
    alert(texts.staffAssigned);
    closeAssignModal();
  }

  function updateOrderStatus(order, newStatus) {
    adminActions.updateOrder(order.id, {
      status: newStatus,
      updatedAt: new Date().toISOString()
    });
    alert(texts.orderUpdated);
  }



  function contactCustomer(order) {
    const phone = order.customer.phone.replace(/[^\d]/g, '');
    window.open(`tel:${phone}`, '_self');
  }

  function shareOrderWhatsApp(order) {
    const branch = currentBranches.find(b => b.id === order.branchId);
    const branchName = branch ? (currentLanguage === 'ar' ? branch.nameAr : branch.nameEn) : '';
    
    let message = currentLanguage === 'ar' ? 
      `🚛 طلب جديد - ${order.orderNumber}\n\n` +
      `📍 الفرع: ${branchName}\n` +
      `👤 العميل: ${order.customer.name}\n` +
      `📞 الهاتف: ${order.customer.phone}\n` +
      `🏠 العنوان: ${order.customer.address || 'غير محدد'}\n` +
      `💰 الإجمالي: ${order.total} ريال\n` +
      `⏰ وقت الطلب: ${new Date(order.createdAt).toLocaleString('ar-SA')}\n\n` +
      `الأصناف:\n${order.items.map(item => `• ${item.nameAr} × ${item.quantity}`).join('\n')}`
      :
      `🚛 New Order - ${order.orderNumber}\n\n` +
      `📍 Branch: ${branchName}\n` +
      `👤 Customer: ${order.customer.name}\n` +
      `📞 Phone: ${order.customer.phone}\n` +
      `🏠 Address: ${order.customer.address || 'Not specified'}\n` +
      `💰 Total: ${order.total} SAR\n` +
      `⏰ Order Time: ${new Date(order.createdAt).toLocaleString('en-US')}\n\n` +
      `Items:\n${order.items.map(item => `• ${item.nameEn} × ${item.quantity}`).join('\n')}`;
    
    const encodedMessage = encodeURIComponent(message);
    window.open(`https://wa.me/?text=${encodedMessage}`, '_blank');
  }

  function getBranchName(branchId) {
    const branch = currentBranches.find(b => b.id === branchId);
    return branch ? (currentLanguage === 'ar' ? branch.nameAr : branch.nameEn) : '';
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

  function getStatusSteps(orderType) {
    if (orderType === 'pickup') {
      return ['pending', 'confirmed', 'preparing', 'ready'];
    } else {
      return ['pending', 'confirmed', 'preparing', 'outForDelivery', 'delivered'];
    }
  }

  function getNextStatus(currentStatus, orderType) {
    const steps = getStatusSteps(orderType);
    const currentIndex = steps.indexOf(currentStatus);
    return currentIndex < steps.length - 1 ? steps[currentIndex + 1] : null;
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
            <option value="all">{texts.allOrders}</option>
            <option value="pending">{texts.pending}</option>
            <option value="confirmed">{texts.confirmed}</option>
            <option value="preparing">{texts.preparing}</option>
            <option value="ready">{texts.ready}</option>
            <option value="outForDelivery">{texts.outForDelivery}</option>
            <option value="delivered">{texts.delivered}</option>
            <option value="cancelled">{texts.cancelled}</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>{texts.branch}:</label>
          <select bind:value={filterBranch}>
            <option value="all">{texts.allBranches}</option>
            {#each currentBranches as branch}
              <option value={branch.id}>{currentLanguage === 'ar' ? branch.nameAr : branch.nameEn}</option>
            {/each}
          </select>
        </div>
      </div>
    </div>
  </Card>

  <!-- Orders List -->
  <div class="orders-list">
    {#if filteredOrders.length === 0}
      <div class="no-orders">
        <p>{texts.noOrders}</p>
      </div>
    {:else}
      {#each filteredOrders as order}
        <Card>
          <div class="order-item">
            <div class="order-header">
              <div class="order-info">
                <h3>{texts.orderNumber}: {order.orderNumber}</h3>
                <span class="order-time">{formatTime(order.createdAt)}</span>
              </div>
              <div class="order-status">
                <span class="status-badge" style="background: var(--color-{statusConfig[order.status].color}-light); color: var(--color-{statusConfig[order.status].color}-dark)">
                  {statusConfig[order.status].label}
                </span>
              </div>
            </div>

            <div class="order-content">
              <div class="order-details">
                <div class="detail-item">
                  <strong>{texts.customer}:</strong> {order.customer.name}
                </div>
                <div class="detail-item">
                  <strong>{texts.phone}:</strong> {order.customer.phone}
                </div>
                <div class="detail-item">
                  <strong>{texts.branch}:</strong> {getBranchName(order.branchId)}
                </div>
                <div class="detail-item">
                  <strong>{texts.orderType}:</strong> {order.type === 'pickup' ? texts.pickup : texts.delivery}
                </div>
                <div class="detail-item">
                  <strong>{texts.total}:</strong> {order.total} {texts.sar}
                </div>
              </div>

              <div class="assignment-info">
                {#if order.type === 'pickup'}
                  <div class="assignment-item">
                    <strong>{texts.pickupStaff}:</strong>
                    {#if order.pickupStaff}
                      <span class="assigned">{order.pickupStaff.name}</span>
                    {:else}
                      <span class="not-assigned">{texts.notAssigned}</span>
                    {/if}
                  </div>
                {:else}
                  <div class="assignment-item">
                    <strong>{texts.deliveryBoy}:</strong>
                    {#if order.deliveryBoy}
                      <span class="assigned">{order.deliveryBoy.name}</span>
                    {:else}
                      <span class="not-assigned">{texts.notAssigned}</span>
                    {/if}
                  </div>
                {/if}
              </div>
            </div>

            <div class="order-actions">
              <Button variant="outline" size="sm" on:click={() => showOrderDetailsModal(order)}>
                {texts.orderDetails}
              </Button>
              
              {#if order.type === 'pickup' && !order.pickupStaff}
                <Button variant="primary" size="sm" on:click={() => showAssignmentModal(order, 'pickup')}>
                  {texts.assignPickupStaff}
                </Button>
              {/if}
              
              {#if order.type === 'delivery' && !order.deliveryBoy}
                <Button variant="primary" size="sm" on:click={() => showAssignmentModal(order, 'delivery')}>
                  {texts.assignDeliveryBoy}
                </Button>
              {/if}

              {#if getNextStatus(order.status, order.type)}
                <Button 
                  variant="success" 
                  size="sm" 
                  on:click={() => updateOrderStatus(order, getNextStatus(order.status, order.type))}
                >
                  {statusConfig[getNextStatus(order.status, order.type)].label}
                </Button>
              {/if}

              <Button variant="outline" size="sm" on:click={() => contactCustomer(order)}>
                {texts.contactCustomer}
              </Button>
              
              <Button variant="outline" size="sm" on:click={() => shareOrderWhatsApp(order)}>
                {texts.whatsappOrder}
              </Button>
            </div>
          </div>
        </Card>
      {/each}
    {/if}
  </div>
</div>

<!-- Order Details Modal -->
{#if showOrderDetails && selectedOrder}
  <div class="modal-overlay" on:click={closeOrderDetails}>
    <div class="modal-content" on:click|stopPropagation>
      <div class="modal-header">
        <h2>{texts.orderDetails} - {selectedOrder.orderNumber}</h2>
        <button class="close-btn" on:click={closeOrderDetails}>&times;</button>
      </div>
      
      <div class="modal-body">
        <div class="details-grid">
          <div class="detail-section">
            <h3>{texts.customer}</h3>
            <p><strong>{texts.phone}:</strong> {selectedOrder.customer.name}</p>
            <p><strong>{texts.phone}:</strong> {selectedOrder.customer.phone}</p>
            {#if selectedOrder.customer.address}
              <p><strong>{texts.address}:</strong> {selectedOrder.customer.address}</p>
            {/if}
          </div>

          <div class="detail-section">
            <h3>{texts.branch}</h3>
            <p>{getBranchName(selectedOrder.branchId)}</p>
          </div>

          <div class="detail-section">
            <h3>{texts.orderType}</h3>
            <p>{selectedOrder.type === 'pickup' ? texts.pickup : texts.delivery}</p>
          </div>

          <div class="detail-section">
            <h3>{texts.paymentMethod}</h3>
            <p>{selectedOrder.paymentMethod === 'cash' ? texts.cash : texts.card}</p>
          </div>
        </div>

        <div class="items-section">
          <h3>{texts.items}</h3>
          <div class="items-list">
            {#each selectedOrder.items as item}
              <div class="item-row">
                <span class="item-name">{currentLanguage === 'ar' ? item.nameAr : item.nameEn}</span>
                <span class="item-quantity">× {item.quantity}</span>
                <span class="item-price">{item.price * item.quantity} {texts.sar}</span>
              </div>
            {/each}
          </div>
          <div class="total-row">
            <strong>{texts.total}: {selectedOrder.total} {texts.sar}</strong>
          </div>
        </div>

        {#if selectedOrder.notes}
          <div class="notes-section">
            <h3>{texts.notes}</h3>
            <p>{selectedOrder.notes}</p>
          </div>
        {/if}

        <div class="contact-actions">
          <Button variant="outline" on:click={() => contactCustomer(selectedOrder)}>
            {texts.contactCustomer}
          </Button>
          <Button variant="primary" on:click={() => shareOrderWhatsApp(selectedOrder)}>
            {texts.whatsappOrder}
          </Button>
        </div>
      </div>
    </div>
  </div>
{/if}

<!-- Assignment Modal -->
{#if showAssignModal && selectedOrder}
  <div class="modal-overlay" on:click={closeAssignModal}>
    <div class="modal-content" on:click|stopPropagation>
      <div class="modal-header">
        <h2>{assignmentType === 'pickup' ? texts.assignPickupStaff : texts.assignDeliveryBoy}</h2>
        <button class="close-btn" on:click={closeAssignModal}>&times;</button>
      </div>
      
      <div class="modal-body">
        <div class="assignment-form">
          <div class="form-group">
            <label>{assignmentType === 'pickup' ? texts.pickupStaff : texts.deliveryBoy}:</label>
            <select bind:value={selectedStaff}>
              <option value="">{texts.selectStaff}</option>
              {#each getAvailableStaff(selectedOrder.branchId, assignmentType) as staff}
                <option value={staff.id}>{staff.name} - {staff.phone}</option>
              {/each}
            </select>
          </div>
          
          <div class="form-group">
            <label>{texts.estimatedTime} ({texts.minutes}):</label>
            <input type="number" bind:value={estimatedTime} min="1" max="120" />
          </div>
        </div>

        <div class="modal-actions">
          <Button variant="primary" on:click={assignStaff} disabled={!selectedStaff}>
            {texts.assign}
          </Button>
          <Button variant="outline" on:click={closeAssignModal}>
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

  .orders-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .no-orders {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .order-item {
    padding: var(--space-4);
  }

  .order-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: var(--space-4);
  }

  .order-info h3 {
    margin: 0;
    color: var(--color-ink);
  }

  .order-time {
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

  .order-content {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: var(--space-4);
    margin-bottom: var(--space-4);
  }

  .order-details, .assignment-info {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .detail-item, .assignment-item {
    font-size: 0.9rem;
  }

  .assigned {
    color: var(--color-success-dark);
    font-weight: 500;
  }

  .not-assigned {
    color: var(--color-error-dark);
    font-weight: 500;
  }

  .order-actions {
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
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink-light);
  }

  .items-section {
    margin-bottom: var(--space-6);
  }

  .items-section h3 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
  }

  .items-list {
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    overflow: hidden;
  }

  .item-row {
    display: grid;
    grid-template-columns: 1fr auto auto;
    gap: var(--space-3);
    padding: var(--space-3);
    border-bottom: 1px solid var(--color-border);
    align-items: center;
  }

  .item-row:last-child {
    border-bottom: none;
  }

  .item-name {
    font-weight: 500;
  }

  .item-quantity {
    color: var(--color-ink-light);
  }

  .item-price {
    font-weight: 600;
    color: var(--color-primary);
  }

  .total-row {
    padding: var(--space-3);
    background: var(--color-surface-variant);
    text-align: right;
    font-size: 1.1rem;
  }

  .notes-section {
    margin-bottom: var(--space-6);
  }

  .notes-section h3 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
  }

  .notes-section p {
    margin: 0;
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
    color: var(--color-ink-light);
  }

  .contact-actions {
    display: flex;
    gap: var(--space-3);
    flex-wrap: wrap;
  }

  .assignment-form {
    margin-bottom: var(--space-6);
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

  .form-group select,
  .form-group input {
    width: 100%;
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: white;
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

    .order-content {
      grid-template-columns: 1fr;
    }

    .order-actions {
      flex-direction: column;
    }

    .details-grid {
      grid-template-columns: 1fr;
    }

    .item-row {
      grid-template-columns: 1fr;
      gap: var(--space-1);
    }

    .contact-actions {
      flex-direction: column;
    }

    .modal-actions {
      flex-direction: column;
    }
  }
</style>