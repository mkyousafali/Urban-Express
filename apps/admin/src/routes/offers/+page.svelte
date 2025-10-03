<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import AdminNav from '$lib/components/AdminNav.svelte';
  import { products, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let activeTab = 'create'; // 'create' or 'running'
  let scannedProduct = null;
  let barcodeInput = '';
  let offerData = {
    productId: '',
    unitId: '',
    originalPrice: 0,
    offerPrice: 0,
    startDate: '',
    endDate: '',
    discount: 0
  };
  
  // Running offers data
  let runningOffers = [
    {
      id: 1,
      barcode: '123456789012',
      productName: { ar: 'تفاح أحمر', en: 'Red Apple' },
      unitName: { ar: 'كيلو', en: 'KG' },
      originalPrice: 8.50,
      offerPrice: 6.99,
      discount: 18,
      startDate: '2025-10-01',
      endDate: '2025-10-15',
      status: 'active'
    },
    {
      id: 2,
      barcode: '123456789013',
      productName: { ar: 'موز', en: 'Banana' },
      unitName: { ar: 'كيلو', en: 'KG' },
      originalPrice: 5.00,
      offerPrice: 3.99,
      discount: 20,
      startDate: '2025-10-02',
      endDate: '2025-10-20',
      status: 'active'
    }
  ];
  
  let searchQuery = '';
  let filteredOffers = runningOffers;
  
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }
    filterOffers();
  });
  
  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة العروض',
    createOffer: 'إنشاء عرض جديد',
    runningOffers: 'العروض الجارية',
    scanBarcode: 'مسح الباركود',
    enterBarcode: 'أدخل الباركود',
    searchProduct: 'البحث عن المنتج',
    productDetails: 'تفاصيل المنتج',
    noProductFound: 'لم يتم العثور على المنتج',
    productName: 'اسم المنتج',
    unit: 'الوحدة',
    originalPrice: 'السعر الأصلي',
    offerPrice: 'سعر العرض',
    discount: 'الخصم',
    startDate: 'تاريخ البداية',
    endDate: 'تاريخ النهاية',
    createOfferBtn: 'إنشاء العرض',
    save: 'حفظ',
    cancel: 'إلغاء',
    search: 'بحث',
    barcode: 'الباركود',
    priceBefore: 'السعر قبل',
    priceAfter: 'السعر بعد',
    status: 'الحالة',
    active: 'نشط',
    expired: 'منتهي',
    actions: 'الإجراءات',
    edit: 'تعديل',
    delete: 'حذف',
    sar: 'ريال',
    discountPercent: '% خصم',
    from: 'من',
    to: 'إلى'
  } : {
    title: 'Offers Management',
    createOffer: 'Create New Offer',
    runningOffers: 'Running Offers',
    scanBarcode: 'Scan Barcode',
    enterBarcode: 'Enter Barcode',
    searchProduct: 'Search Product',
    productDetails: 'Product Details',
    noProductFound: 'Product not found',
    productName: 'Product Name',
    unit: 'Unit',
    originalPrice: 'Original Price',
    offerPrice: 'Offer Price',
    discount: 'Discount',
    startDate: 'Start Date',
    endDate: 'End Date',
    createOfferBtn: 'Create Offer',
    save: 'Save',
    cancel: 'Cancel',
    search: 'Search',
    barcode: 'Barcode',
    priceBefore: 'Price Before',
    priceAfter: 'Price After',
    status: 'Status',
    active: 'Active',
    expired: 'Expired',
    actions: 'Actions',
    edit: 'Edit',
    delete: 'Delete',
    sar: 'SAR',
    discountPercent: '% OFF',
    from: 'From',
    to: 'To'
  };
  
  function switchLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
    localStorage.setItem('language', currentLanguage);
    document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = currentLanguage;
  }
  
  function searchProduct() {
    if (!barcodeInput.trim()) return;
    
    // Mock product search - in real app this would call an API
    const mockProduct = {
      id: 'prod_001',
      barcode: barcodeInput,
      name: { ar: 'تفاح أحمر فاخر', en: 'Premium Red Apple' },
      category: { ar: 'فواكه', en: 'Fruits' },
      units: [
        { id: 'unit_kg', name: { ar: 'كيلو', en: 'KG' }, price: 8.50, isBase: true },
        { id: 'unit_piece', name: { ar: 'حبة', en: 'Piece' }, price: 1.25, isBase: false },
        { id: 'unit_box', name: { ar: 'صندوق (5 كيلو)', en: 'Box (5 KG)' }, price: 40.00, isBase: false }
      ],
      description: { ar: 'تفاح أحمر طازج عالي الجودة', en: 'Fresh high-quality red apples' },
      stock: 150,
      image: '/api/placeholder/200/200'
    };
    
    scannedProduct = mockProduct;
    offerData.productId = mockProduct.id;
    
    // Set default unit and price
    if (mockProduct.units.length > 0) {
      const baseUnit = mockProduct.units.find(u => u.isBase) || mockProduct.units[0];
      offerData.unitId = baseUnit.id;
      offerData.originalPrice = baseUnit.price;
    }
  }
  
  function selectUnit(unit) {
    offerData.unitId = unit.id;
    offerData.originalPrice = unit.price;
    calculateDiscount();
  }
  
  function calculateDiscount() {
    if (offerData.originalPrice > 0 && offerData.offerPrice > 0) {
      offerData.discount = Math.round(((offerData.originalPrice - offerData.offerPrice) / offerData.originalPrice) * 100);
    }
  }
  
  function calculateOfferPrice() {
    if (offerData.originalPrice > 0 && offerData.discount > 0) {
      offerData.offerPrice = parseFloat((offerData.originalPrice * (1 - offerData.discount / 100)).toFixed(2));
    }
  }
  
  function createOffer() {
    if (!scannedProduct || !offerData.unitId || !offerData.offerPrice || !offerData.startDate || !offerData.endDate) {
      alert(currentLanguage === 'ar' ? 'يرجى ملء جميع الحقول المطلوبة' : 'Please fill all required fields');
      return;
    }
    
    const newOffer = {
      id: Date.now(),
      barcode: scannedProduct.barcode,
      productName: scannedProduct.name,
      unitName: scannedProduct.units.find(u => u.id === offerData.unitId)?.name,
      originalPrice: offerData.originalPrice,
      offerPrice: offerData.offerPrice,
      discount: offerData.discount,
      startDate: offerData.startDate,
      endDate: offerData.endDate,
      status: 'active'
    };
    
    runningOffers = [newOffer, ...runningOffers];
    resetForm();
    activeTab = 'running';
    filterOffers();
    
    alert(currentLanguage === 'ar' ? 'تم إنشاء العرض بنجاح' : 'Offer created successfully');
  }
  
  function resetForm() {
    scannedProduct = null;
    barcodeInput = '';
    offerData = {
      productId: '',
      unitId: '',
      originalPrice: 0,
      offerPrice: 0,
      startDate: '',
      endDate: '',
      discount: 0
    };
  }
  
  function filterOffers() {
    filteredOffers = runningOffers.filter(offer => {
      const productName = offer.productName[currentLanguage].toLowerCase();
      const barcode = offer.barcode.toLowerCase();
      const query = searchQuery.toLowerCase();
      return productName.includes(query) || barcode.includes(query);
    });
  }
  
  function deleteOffer(offerId) {
    if (confirm(currentLanguage === 'ar' ? 'هل أنت متأكد من حذف هذا العرض؟' : 'Are you sure you want to delete this offer?')) {
      runningOffers = runningOffers.filter(offer => offer.id !== offerId);
      filterOffers();
    }
  }
  
  function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString(currentLanguage === 'ar' ? 'ar-SA' : 'en-US');
  }
  
  // Handle barcode scanner input
  function handleBarcodeKeydown(event) {
    if (event.key === 'Enter') {
      searchProduct();
    }
  }
  
  $: {
    searchQuery;
    filterOffers();
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<AdminNav title={texts.title} />

<div class="offers-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="header">
    <h1>{texts.title}</h1>
    <button class="lang-toggle" on:click={switchLanguage}>
      {currentLanguage === 'ar' ? 'EN' : 'عربي'}
    </button>
  </div>

  <!-- Tabs -->
  <div class="tabs">
    <button 
      class="tab" 
      class:active={activeTab === 'create'}
      on:click={() => activeTab = 'create'}
    >
      ➕ {texts.createOffer}
    </button>
    <button 
      class="tab" 
      class:active={activeTab === 'running'}
      on:click={() => activeTab = 'running'}
    >
      📊 {texts.runningOffers}
    </button>
  </div>

  {#if activeTab === 'create'}
    <!-- Create Offer Tab -->
    <div class="create-offer-section">
      <!-- Barcode Scanner Section -->
      <Card>
        <div class="barcode-section">
          <h3>🔍 {texts.scanBarcode}</h3>
          <div class="barcode-input-group">
            <Input
              label={texts.enterBarcode}
              bind:value={barcodeInput}
              placeholder="123456789012"
              on:keydown={handleBarcodeKeydown}
            />
            <Button variant="primary" on:click={searchProduct}>
              {texts.searchProduct}
            </Button>
          </div>
        </div>
      </Card>

      {#if scannedProduct}
        <!-- Product Details Section -->
        <Card>
          <div class="product-details">
            <h3>📦 {texts.productDetails}</h3>
            <div class="product-info">
              <div class="product-image">
                <img src={scannedProduct.image} alt={scannedProduct.name[currentLanguage]} />
              </div>
              <div class="product-data">
                <h4>{scannedProduct.name[currentLanguage]}</h4>
                <p><strong>{texts.barcode}:</strong> {scannedProduct.barcode}</p>
                <p><strong>{currentLanguage === 'ar' ? 'الفئة' : 'Category'}:</strong> {scannedProduct.category[currentLanguage]}</p>
                <p><strong>{currentLanguage === 'ar' ? 'المخزون' : 'Stock'}:</strong> {scannedProduct.stock}</p>
              </div>
            </div>

            <!-- Units Selection -->
            <div class="units-section">
              <h5>{currentLanguage === 'ar' ? 'اختر الوحدة' : 'Select Unit'}</h5>
              <div class="units-grid">
                {#each scannedProduct.units as unit}
                  <button 
                    class="unit-card"
                    class:selected={offerData.unitId === unit.id}
                    on:click={() => selectUnit(unit)}
                  >
                    <div class="unit-name">{unit.name[currentLanguage]}</div>
                    <div class="unit-price">{unit.price} {texts.sar}</div>
                    {#if unit.isBase}
                      <div class="base-unit">{currentLanguage === 'ar' ? 'وحدة أساسية' : 'Base Unit'}</div>
                    {/if}
                  </button>
                {/each}
              </div>
            </div>
          </div>
        </Card>

        <!-- Offer Configuration Section -->
        <Card>
          <div class="offer-config">
            <h3>💰 {currentLanguage === 'ar' ? 'إعداد العرض' : 'Offer Configuration'}</h3>
            
            <div class="price-section">
              <div class="price-input-group">
                <Input
                  label={texts.originalPrice}
                  type="number"
                  bind:value={offerData.originalPrice}
                  disabled={true}
                />
                <span class="currency">{texts.sar}</span>
              </div>
              
              <div class="price-input-group">
                <Input
                  label={texts.offerPrice}
                  type="number"
                  bind:value={offerData.offerPrice}
                  on:input={calculateDiscount}
                  step="0.01"
                  min="0"
                />
                <span class="currency">{texts.sar}</span>
              </div>
              
              <div class="price-input-group">
                <Input
                  label={texts.discount + ' (%)'}
                  type="number"
                  bind:value={offerData.discount}
                  on:input={calculateOfferPrice}
                  min="0"
                  max="100"
                />
                <span class="currency">%</span>
              </div>
            </div>

            <div class="dates-section">
              <Input
                label={texts.startDate}
                type="date"
                bind:value={offerData.startDate}
              />
              <Input
                label={texts.endDate}
                type="date"
                bind:value={offerData.endDate}
              />
            </div>

            {#if offerData.offerPrice > 0 && offerData.originalPrice > 0}
              <div class="offer-preview">
                <div class="preview-card">
                  <h4>{currentLanguage === 'ar' ? 'معاينة العرض' : 'Offer Preview'}</h4>
                  <div class="price-comparison">
                    <span class="original-price">{offerData.originalPrice} {texts.sar}</span>
                    <span class="offer-price">{offerData.offerPrice} {texts.sar}</span>
                    <span class="discount-badge">{offerData.discount}{texts.discountPercent}</span>
                  </div>
                </div>
              </div>
            {/if}

            <div class="action-buttons">
              <Button variant="primary" on:click={createOffer}>
                ✅ {texts.createOfferBtn}
              </Button>
              <Button variant="outline" on:click={resetForm}>
                🔄 {texts.cancel}
              </Button>
            </div>
          </div>
        </Card>
      {:else if barcodeInput}
        <Card>
          <div class="no-product">
            <p>❌ {texts.noProductFound}</p>
          </div>
        </Card>
      {/if}
    </div>

  {:else if activeTab === 'running'}
    <!-- Running Offers Tab -->
    <div class="running-offers-section">
      <Card>
        <div class="offers-header">
          <h3>📊 {texts.runningOffers}</h3>
          <Input
            placeholder={texts.search + '...'}
            bind:value={searchQuery}
          />
        </div>

        <div class="offers-table">
          <div class="table-header">
            <div class="th">{texts.barcode}</div>
            <div class="th">{texts.productName}</div>
            <div class="th">{texts.unit}</div>
            <div class="th">{texts.priceBefore}</div>
            <div class="th">{texts.priceAfter}</div>
            <div class="th">{texts.discount}</div>
            <div class="th">{currentLanguage === 'ar' ? 'الفترة' : 'Period'}</div>
            <div class="th">{texts.status}</div>
            <div class="th">{texts.actions}</div>
          </div>

          {#each filteredOffers as offer (offer.id)}
            <div class="table-row">
              <div class="td">{offer.barcode}</div>
              <div class="td">{offer.productName[currentLanguage]}</div>
              <div class="td">{offer.unitName[currentLanguage]}</div>
              <div class="td">
                <span class="original-price">{offer.originalPrice} {texts.sar}</span>
              </div>
              <div class="td">
                <span class="offer-price">{offer.offerPrice} {texts.sar}</span>
              </div>
              <div class="td">
                <span class="discount-badge">{offer.discount}%</span>
              </div>
              <div class="td">
                <small>{formatDate(offer.startDate)} - {formatDate(offer.endDate)}</small>
              </div>
              <div class="td">
                <span class="status-badge" class:active={offer.status === 'active'}>
                  {offer.status === 'active' ? texts.active : texts.expired}
                </span>
              </div>
              <div class="td">
                <Button variant="outline" size="sm" on:click={() => deleteOffer(offer.id)}>
                  🗑️ {texts.delete}
                </Button>
              </div>
            </div>
          {/each}

          {#if filteredOffers.length === 0}
            <div class="empty-state">
              <p>{currentLanguage === 'ar' ? 'لا توجد عروض' : 'No offers found'}</p>
            </div>
          {/if}
        </div>
      </Card>
    </div>
  {/if}
</div>

<style>
  .offers-container {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
  }

  .header h1 {
    margin: 0;
    color: #2c3e50;
    font-size: 2rem;
  }

  .lang-toggle {
    background: #3498db;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    transition: background 0.2s;
  }

  .lang-toggle:hover {
    background: #2980b9;
  }

  .tabs {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    border-bottom: 2px solid #ecf0f1;
  }

  .tab {
    background: none;
    border: none;
    padding: 1rem 2rem;
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    border-bottom: 3px solid transparent;
    transition: all 0.2s;
    color: #7f8c8d;
  }

  .tab:hover {
    color: #3498db;
  }

  .tab.active {
    color: #3498db;
    border-bottom-color: #3498db;
  }

  .barcode-section {
    padding: 1.5rem;
  }

  .barcode-section h3 {
    margin-top: 0;
    color: #2c3e50;
  }

  .barcode-input-group {
    display: flex;
    gap: 1rem;
    align-items: end;
  }

  .barcode-input-group :global(.input-group) {
    flex: 1;
  }

  .product-details {
    padding: 1.5rem;
  }

  .product-details h3 {
    margin-top: 0;
    color: #2c3e50;
  }

  .product-info {
    display: flex;
    gap: 1.5rem;
    margin-bottom: 2rem;
  }

  .product-image {
    width: 120px;
    height: 120px;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #ddd;
  }

  .product-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .product-data h4 {
    margin: 0 0 1rem 0;
    color: #2c3e50;
    font-size: 1.25rem;
  }

  .product-data p {
    margin: 0.5rem 0;
    color: #7f8c8d;
  }

  .units-section h5 {
    margin: 0 0 1rem 0;
    color: #2c3e50;
  }

  .units-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  .unit-card {
    background: white;
    border: 2px solid #ecf0f1;
    border-radius: 8px;
    padding: 1rem;
    cursor: pointer;
    transition: all 0.2s;
    text-align: center;
  }

  .unit-card:hover {
    border-color: #3498db;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(52, 152, 219, 0.15);
  }

  .unit-card.selected {
    border-color: #3498db;
    background: #ebf3fd;
  }

  .unit-name {
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 0.5rem;
  }

  .unit-price {
    font-size: 1.25rem;
    color: #27ae60;
    font-weight: bold;
    margin-bottom: 0.5rem;
  }

  .base-unit {
    font-size: 0.75rem;
    color: #3498db;
    background: #ebf3fd;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    display: inline-block;
  }

  .offer-config {
    padding: 1.5rem;
  }

  .offer-config h3 {
    margin-top: 0;
    color: #2c3e50;
  }

  .price-section {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .price-input-group {
    position: relative;
  }

  .currency {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #7f8c8d;
    font-weight: 500;
    pointer-events: none;
  }

  .dates-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .offer-preview {
    margin-bottom: 2rem;
  }

  .preview-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1.5rem;
    border-radius: 12px;
    text-align: center;
  }

  .preview-card h4 {
    margin: 0 0 1rem 0;
    font-size: 1.25rem;
  }

  .price-comparison {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 1rem;
    flex-wrap: wrap;
  }

  .original-price {
    text-decoration: line-through;
    color: #ecf0f1;
    font-size: 1.125rem;
  }

  .offer-price {
    font-size: 1.5rem;
    font-weight: bold;
    color: #2ecc71;
  }

  .discount-badge {
    background: #e74c3c;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 20px;
    font-weight: bold;
    font-size: 0.875rem;
  }

  .action-buttons {
    display: flex;
    gap: 1rem;
    justify-content: center;
  }

  .no-product {
    padding: 2rem;
    text-align: center;
    color: #7f8c8d;
    font-size: 1.125rem;
  }

  .offers-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding: 1.5rem;
  }

  .offers-header h3 {
    margin: 0;
    color: #2c3e50;
  }

  .offers-header :global(.input-group) {
    width: 300px;
  }

  .offers-table {
    padding: 0 1.5rem 1.5rem;
  }

  .table-header, .table-row {
    display: grid;
    grid-template-columns: 1fr 2fr 1fr 1fr 1fr 1fr 1.5fr 1fr 1fr;
    gap: 1rem;
    align-items: center;
    padding: 1rem;
    border-bottom: 1px solid #ecf0f1;
  }

  .table-header {
    background: #f8f9fa;
    font-weight: 600;
    color: #2c3e50;
    border-radius: 8px 8px 0 0;
  }

  .table-row:hover {
    background: #f8f9fa;
  }

  .th, .td {
    text-align: center;
  }

  .status-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 500;
    background: #95a5a6;
    color: white;
  }

  .status-badge.active {
    background: #27ae60;
  }

  .empty-state {
    padding: 3rem;
    text-align: center;
    color: #7f8c8d;
  }

  @media (max-width: 768px) {
    .offers-container {
      padding: 1rem;
    }

    .header {
      flex-direction: column;
      gap: 1rem;
      text-align: center;
    }

    .tabs {
      flex-direction: column;
    }

    .barcode-input-group {
      flex-direction: column;
    }

    .product-info {
      flex-direction: column;
      text-align: center;
    }

    .units-grid {
      grid-template-columns: 1fr;
    }

    .price-section {
      grid-template-columns: 1fr;
    }

    .dates-section {
      grid-template-columns: 1fr;
    }

    .offers-header {
      flex-direction: column;
      gap: 1rem;
    }

    .offers-header :global(.input-group) {
      width: 100%;
    }

    .table-header, .table-row {
      grid-template-columns: 1fr;
      gap: 0.5rem;
    }

    .th, .td {
      text-align: left;
      padding: 0.5rem;
    }

    .th::before {
      content: attr(data-label) ': ';
      font-weight: bold;
    }
  }

  /* RTL Support */
  [dir="rtl"] .currency {
    right: auto;
    left: 12px;
  }

  [dir="rtl"] .price-comparison {
    direction: rtl;
  }

  [dir="rtl"] .offers-header {
    direction: rtl;
  }
</style>