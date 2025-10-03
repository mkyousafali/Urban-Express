<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { orders, products, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let selectedStatus = 'all';
  let deliveryBoyPhone = '+966501234567'; // Default delivery boy phone
  let viewingOrder = null;
  
  // Subscribe to stores
  $: currentOrders = $orders;
  $: currentProducts = $products;
  
  // Filter orders by status
  $: filteredOrders = selectedStatus === 'all' ? 
    currentOrders : 
    currentOrders.filter(order => order.status === selectedStatus);
  
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Load saved delivery boy phone
    const savedPhone = localStorage.getItem('deliveryBoyPhone');
    if (savedPhone) {
      deliveryBoyPhone = savedPhone;
    }
  });

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة الطلبات',
    allOrders: 'جميع الطلبات',
    pending: 'قيد الانتظار',
    confirmed: 'مؤكد',
    preparing: 'قيد التحضير',
    ready: 'جاهز',
    delivered: 'تم التوصيل',
    cancelled: 'ملغي',
    orderNumber: 'رقم الطلب',
    customer: 'العميل',
    phone: 'الهاتف',
    type: 'النوع',
    delivery: 'توصيل',
    pickup: 'استلام',
    status: 'الحالة',
    total: 'المجموع',
    date: 'التاريخ',
    actions: 'الإجراءات',
    viewDetails: 'عرض التفاصيل',
    shareOrder: 'مشاركة الطلب',
    updateStatus: 'تحديث الحالة',
    orderDetails: 'تفاصيل الطلب',
    customerDetails: 'بيانات العميل',
    orderItems: 'عناصر الطلب',
    product: 'المنتج',
    barcode: 'الباركود',
    price: 'السعر',
    quantity: 'الكمية',
    subtotal: 'المجموع الفرعي',
    address: 'العنوان',
    paymentMethod: 'طريقة الدفع',
    cash: 'نقدي',
    card: 'بطاقة',
    notes: 'ملاحظات',
    close: 'إغلاق',
    sar: 'ريال',
    deliveryBoyPhone: 'هاتف مندوب التوصيل',
    save: 'حفظ',
    noOrders: 'لا توجد طلبات',
    orderTime: 'وقت الطلب'
  } : {
    title: 'Order Management',
    allOrders: 'All Orders',
    pending: 'Pending',
    confirmed: 'Confirmed',
    preparing: 'Preparing',
    ready: 'Ready',
    delivered: 'Delivered',
    cancelled: 'Cancelled',
    orderNumber: 'Order #',
    customer: 'Customer',
    phone: 'Phone',
    type: 'Type',
    delivery: 'Delivery',
    pickup: 'Pickup',
    status: 'Status',
    total: 'Total',
    date: 'Date',
    actions: 'Actions',
    viewDetails: 'View Details',
    shareOrder: 'Share Order',
    updateStatus: 'Update Status',
    orderDetails: 'Order Details',
    customerDetails: 'Customer Details',
    orderItems: 'Order Items',
    product: 'Product',
    barcode: 'Barcode',
    price: 'Price',
    quantity: 'Quantity',
    subtotal: 'Subtotal',
    address: 'Address',
    paymentMethod: 'Payment Method',
    cash: 'Cash',
    card: 'Card',
    notes: 'Notes',
    close: 'Close',
    sar: 'SAR',
    deliveryBoyPhone: 'Delivery Boy Phone',
    save: 'Save',
    noOrders: 'No orders',
    orderTime: 'Order Time'
  };

  const orderStatuses = [
    { value: 'all', label: texts.allOrders },
    { value: 'pending', label: texts.pending },
    { value: 'confirmed', label: texts.confirmed },
    { value: 'preparing', label: texts.preparing },
    { value: 'ready', label: texts.ready },
    { value: 'delivered', label: texts.delivered },
    { value: 'cancelled', label: texts.cancelled }
  ];

  function viewOrderDetails(order) {
    viewingOrder = order;
  }

  function closeOrderDetails() {
    viewingOrder = null;
  }

  function updateOrderStatus(orderId, newStatus) {
    adminActions.updateOrderStatus(orderId, newStatus);
  }

  function shareOrderToWhatsApp(order) {
    adminActions.shareOrderToWhatsApp(order, deliveryBoyPhone);
  }

  function saveDeliveryBoyPhone() {
    localStorage.setItem('deliveryBoyPhone', deliveryBoyPhone);
  }

  function getStatusBadgeClass(status) {
    switch (status) {
      case 'pending': return 'status-pending';
      case 'confirmed': return 'status-confirmed';
      case 'preparing': return 'status-preparing';
      case 'ready': return 'status-ready';
      case 'delivered': return 'status-delivered';
      case 'cancelled': return 'status-cancelled';
      default: return 'status-pending';
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

  function getProductDetails(productId) {
    return currentProducts.find(p => p.id === productId);
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <h1>{texts.title}</h1>

  <!-- Delivery Boy Phone Setting -->
  <Card>
    <div class="phone-setting">
      <label>{texts.deliveryBoyPhone}</label>
      <div class="phone-input-group">
        <input 
          type="tel" 
          bind:value={deliveryBoyPhone} 
          placeholder="+966501234567"
          class="phone-input"
        />
        <Button variant="outline" size="sm" on:click={saveDeliveryBoyPhone}>
          {texts.save}
        </Button>
      </div>
    </div>
  </Card>

  <!-- Status Filter -->
  <div class="filters">
    <div class="status-tabs">
      {#each orderStatuses as statusOption}
        <button 
          class="status-tab" 
          class:active={selectedStatus === statusOption.value}
          on:click={() => selectedStatus = statusOption.value}
        >
          {statusOption.label}
        </button>
      {/each}
    </div>
  </div>

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
                <h3>{texts.orderNumber}{order.id}</h3>
                <p class="order-customer">{order.customerName}</p>
                <p class="order-phone">{order.customerPhone}</p>
              </div>
              <div class="order-meta">
                <span class="order-type {order.type}">
                  {order.type === 'delivery' ? texts.delivery : texts.pickup}
                </span>
                <span class="status-badge {getStatusBadgeClass(order.status)}">
                  {texts[order.status]}
                </span>
              </div>
            </div>

            <div class="order-details">
              <div class="order-summary">
                <p><strong>{texts.total}:</strong> {order.total} {texts.sar}</p>
                <p><strong>{texts.orderTime}:</strong> {formatDate(order.createdAt)}</p>
                {#if order.address}
                  <p><strong>{texts.address}:</strong> {order.address}</p>
                {/if}
              </div>
            </div>

            <div class="order-actions">
              <Button variant="outline" size="sm" on:click={() => viewOrderDetails(order)}>
                {texts.viewDetails}
              </Button>
              
              <div class="status-update">
                <select 
                  value={order.status} 
                  on:change={(e) => updateOrderStatus(order.id, e.target.value)}
                  class="status-select"
                >
                  <option value="pending">{texts.pending}</option>
                  <option value="confirmed">{texts.confirmed}</option>
                  <option value="preparing">{texts.preparing}</option>
                  <option value="ready">{texts.ready}</option>
                  <option value="delivered">{texts.delivered}</option>
                  <option value="cancelled">{texts.cancelled}</option>
                </select>
              </div>

              <Button variant="primary" size="sm" on:click={() => shareOrderToWhatsApp(order)}>
                {texts.shareOrder}
              </Button>
            </div>
          </div>
        </Card>
      {/each}
    {/if}
  </div>
</div>

<!-- Order Details Modal -->
{#if viewingOrder}
  <div class="modal-overlay" on:click={closeOrderDetails}>
    <div class="modal-content" on:click|stopPropagation>
      <div class="modal-header">
        <h2>{texts.orderDetails} #{viewingOrder.id}</h2>
        <button class="close-btn" on:click={closeOrderDetails}>×</button>
      </div>

      <div class="modal-body">
        <!-- Customer Details -->
        <div class="details-section">
          <h3>{texts.customerDetails}</h3>
          <div class="details-grid">
            <div class="detail-item">
              <strong>{texts.customer}:</strong> {viewingOrder.customerName}
            </div>
            <div class="detail-item">
              <strong>{texts.phone}:</strong> {viewingOrder.customerPhone}
            </div>
            <div class="detail-item">
              <strong>{texts.type}:</strong> 
              {viewingOrder.type === 'delivery' ? texts.delivery : texts.pickup}
            </div>
            {#if viewingOrder.address}
              <div class="detail-item">
                <strong>{texts.address}:</strong> {viewingOrder.address}
              </div>
            {/if}
            <div class="detail-item">
              <strong>{texts.paymentMethod}:</strong> 
              {viewingOrder.paymentMethod === 'cash' ? texts.cash : texts.card}
            </div>
            <div class="detail-item">
              <strong>{texts.orderTime}:</strong> {formatDate(viewingOrder.createdAt)}
            </div>
          </div>
        </div>

        <!-- Order Items -->
        <div class="details-section">
          <h3>{texts.orderItems}</h3>
          <div class="items-table">
            <table>
              <thead>
                <tr>
                  <th>{texts.product}</th>
                  <th>{texts.barcode}</th>
                  <th>{texts.price}</th>
                  <th>{texts.quantity}</th>
                  <th>{texts.subtotal}</th>
                </tr>
              </thead>
              <tbody>
                {#each viewingOrder.items as item}
                  {@const productDetails = getProductDetails(item.productId)}
                  <tr>
                    <td>
                      <div class="product-cell">
                        {#if item.photo}
                          <img src={item.photo} alt={item.name} class="product-photo" />
                        {/if}
                        <div class="product-info">
                          <div class="product-name">{item.name}</div>
                          <div class="product-unit">{item.unit}</div>
                        </div>
                      </div>
                    </td>
                    <td class="barcode-cell">{item.barcode || 'N/A'}</td>
                    <td>{item.price} {texts.sar}</td>
                    <td>{item.quantity}</td>
                    <td>{(item.price * item.quantity).toFixed(2)} {texts.sar}</td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
          
          <div class="order-total">
            <strong>{texts.total}: {viewingOrder.total} {texts.sar}</strong>
          </div>
        </div>

        {#if viewingOrder.notes}
          <div class="details-section">
            <h3>{texts.notes}</h3>
            <p>{viewingOrder.notes}</p>
          </div>
        {/if}
      </div>

      <div class="modal-actions">
        <Button variant="primary" on:click={() => shareOrderToWhatsApp(viewingOrder)}>
          {texts.shareOrder}
        </Button>
        <Button variant="outline" on:click={closeOrderDetails}>
          {texts.close}
        </Button>
      </div>
    </div>
  </div>
{/if}

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 1200px;
    margin: 0 auto;
  }

  h1 {
    text-align: center;
    margin-bottom: var(--space-6);
    color: var(--color-ink);
  }

  .phone-setting {
    padding: var(--space-4);
  }

  .phone-setting label {
    display: block;
    font-weight: 600;
    margin-bottom: var(--space-2);
    color: var(--color-ink);
  }

  .phone-input-group {
    display: flex;
    gap: var(--space-2);
    align-items: center;
  }

  .phone-input {
    flex: 1;
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    font-size: 1rem;
  }

  .filters {
    margin-bottom: var(--space-6);
  }

  .status-tabs {
    display: flex;
    gap: var(--space-2);
    overflow-x: auto;
    padding-bottom: var(--space-2);
  }

  .status-tab {
    padding: var(--space-2) var(--space-4);
    border: 2px solid var(--color-border);
    background: white;
    border-radius: var(--radius-md);
    cursor: pointer;
    transition: all 0.2s ease;
    white-space: nowrap;
    font-weight: 500;
  }

  .status-tab.active {
    border-color: var(--color-primary);
    background: var(--color-primary);
    color: white;
  }

  .status-tab:hover:not(.active) {
    border-color: var(--color-primary);
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
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
  }

  .order-customer {
    margin: 0 0 var(--space-1) 0;
    font-weight: 600;
    color: var(--color-ink-light);
  }

  .order-phone {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.9rem;
  }

  .order-meta {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
    align-items: flex-end;
  }

  .order-type {
    padding: var(--space-1) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .order-type.delivery {
    background: #dbeafe;
    color: #1d4ed8;
  }

  .order-type.pickup {
    background: #f3e8ff;
    color: #7c3aed;
  }

  .status-badge {
    padding: var(--space-1) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-pending { background: #fef3c7; color: #d97706; }
  .status-confirmed { background: #dbeafe; color: #1d4ed8; }
  .status-preparing { background: #fde68a; color: #d97706; }
  .status-ready { background: #bbf7d0; color: #059669; }
  .status-delivered { background: var(--color-success-light); color: var(--color-success-dark); }
  .status-cancelled { background: var(--color-error-light); color: var(--color-error-dark); }

  .order-details {
    margin-bottom: var(--space-4);
  }

  .order-summary p {
    margin: 0 0 var(--space-1) 0;
    font-size: 0.9rem;
  }

  .order-actions {
    display: flex;
    gap: var(--space-3);
    align-items: center;
    flex-wrap: wrap;
  }

  .status-select {
    padding: var(--space-2);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    font-size: 0.9rem;
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
    width: 100%;
    max-width: 800px;
    max-height: 90vh;
    overflow: hidden;
    display: flex;
    flex-direction: column;
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
    padding: var(--space-2);
    border-radius: var(--radius-md);
    color: var(--color-ink-light);
  }

  .close-btn:hover {
    background: var(--color-surface-variant);
  }

  .modal-body {
    padding: var(--space-4);
    overflow-y: auto;
    flex: 1;
  }

  .details-section {
    margin-bottom: var(--space-6);
  }

  .details-section h3 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
    border-bottom: 1px solid var(--color-border);
    padding-bottom: var(--space-2);
  }

  .details-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: var(--space-3);
  }

  .detail-item {
    padding: var(--space-2);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
  }

  .items-table {
    overflow-x: auto;
  }

  .items-table table {
    width: 100%;
    border-collapse: collapse;
  }

  .items-table th,
  .items-table td {
    padding: var(--space-3);
    text-align: left;
    border-bottom: 1px solid var(--color-border);
  }

  .items-table th {
    background: var(--color-surface-variant);
    font-weight: 600;
  }

  .product-cell {
    display: flex;
    align-items: center;
    gap: var(--space-2);
  }

  .product-photo {
    width: 40px;
    height: 40px;
    object-fit: cover;
    border-radius: var(--radius-md);
  }

  .product-name {
    font-weight: 600;
  }

  .product-unit {
    font-size: 0.8rem;
    color: var(--color-ink-light);
  }

  .barcode-cell {
    font-family: monospace;
    font-size: 0.8rem;
  }

  .order-total {
    text-align: right;
    margin-top: var(--space-4);
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
    font-size: 1.1rem;
  }

  .modal-actions {
    padding: var(--space-4);
    border-top: 1px solid var(--color-border);
    display: flex;
    gap: var(--space-3);
    justify-content: flex-end;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .order-header {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .order-meta {
      flex-direction: row;
      justify-content: space-between;
      align-items: center;
    }

    .order-actions {
      flex-direction: column;
      align-items: stretch;
    }

    .details-grid {
      grid-template-columns: 1fr;
    }

    .modal-content {
      margin: var(--space-2);
      max-height: calc(100vh - var(--space-4));
    }

    .modal-actions {
      flex-direction: column;
    }
  }
</style>