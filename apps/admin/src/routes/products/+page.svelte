<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import AdminNav from '$lib/components/AdminNav.svelte';
  import { categories, units, products, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let showForm = false;
  let editingProduct = null;
  let saved = false;
  
  // Form data
  let formData = {
    categoryId: '',
    nameAr: '',
    nameEn: '',
    baseUnit: {
      unitId: '',
      quantity: 1,
      price: '',
      barcode: '',
      photo: null
    },
    additionalUnits: []
  };
  
  // Subscribe to stores
  $: currentCategories = $categories;
  $: currentUnits = $units;
  $: currentProducts = $products;
  
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
    title: 'إدارة المنتجات',
    addProduct: 'إضافة منتج جديد',
    editProduct: 'تعديل المنتج',
    category: 'الفئة',
    selectCategory: 'اختر الفئة',
    arabicName: 'الاسم بالعربية',
    englishName: 'الاسم بالإنجليزية',
    baseUnit: 'الوحدة الأساسية',
    selectUnit: 'اختر الوحدة',
    quantity: 'الكمية',
    price: 'السعر',
    barcode: 'الباركود',
    photo: 'الصورة',
    additionalUnits: 'وحدات إضافية',
    addUnit: 'إضافة وحدة',
    removeUnit: 'إزالة الوحدة',
    save: 'حفظ',
    cancel: 'إلغاء',
    edit: 'تعديل',
    delete: 'حذف',
    active: 'مفعل',
    inactive: 'غير مفعل',
    saved: 'تم الحفظ بنجاح!',
    sar: 'ريال',
    required: 'مطلوب',
    uploadPhoto: 'رفع صورة',
    noProducts: 'لا توجد منتجات',
    confirmDelete: 'هل أنت متأكد من حذف هذا المنتج؟'
  } : {
    title: 'Product Management',
    addProduct: 'Add New Product',
    editProduct: 'Edit Product',
    category: 'Category',
    selectCategory: 'Select Category',
    arabicName: 'Arabic Name',
    englishName: 'English Name',
    baseUnit: 'Base Unit',
    selectUnit: 'Select Unit',
    quantity: 'Quantity',
    price: 'Price',
    barcode: 'Barcode',
    photo: 'Photo',
    additionalUnits: 'Additional Units',
    addUnit: 'Add Unit',
    removeUnit: 'Remove Unit',
    save: 'Save',
    cancel: 'Cancel',
    edit: 'Edit',
    delete: 'Delete',
    active: 'Active',
    inactive: 'Inactive',
    saved: 'Saved successfully!',
    sar: 'SAR',
    required: 'Required',
    uploadPhoto: 'Upload Photo',
    noProducts: 'No products',
    confirmDelete: 'Are you sure you want to delete this product?'
  };

  function resetForm() {
    formData = {
      categoryId: '',
      nameAr: '',
      nameEn: '',
      baseUnit: {
        unitId: '',
        quantity: 1,
        price: '',
        barcode: '',
        photo: null
      },
      additionalUnits: []
    };
    editingProduct = null;
  }

  function showAddForm() {
    resetForm();
    showForm = true;
  }

  function showEditForm(product) {
    editingProduct = product;
    formData = {
      categoryId: product.categoryId,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      baseUnit: { ...product.baseUnit },
      additionalUnits: [...(product.additionalUnits || [])]
    };
    showForm = true;
  }

  function cancelForm() {
    showForm = false;
    resetForm();
  }

  function addAdditionalUnit() {
    formData.additionalUnits = [...formData.additionalUnits, {
      id: Date.now(),
      unitId: '',
      quantity: 1,
      price: '',
      barcode: '',
      photo: null
    }];
  }

  function removeAdditionalUnit(index) {
    formData.additionalUnits = formData.additionalUnits.filter((_, i) => i !== index);
  }

  function handlePhotoUpload(event, type, index = null) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        if (type === 'base') {
          formData.baseUnit.photo = e.target.result;
        } else if (type === 'additional' && index !== null) {
          formData.additionalUnits[index].photo = e.target.result;
        }
      };
      reader.readAsDataURL(file);
    }
  }

  function saveProduct() {
    // Validation
    if (!formData.categoryId || !formData.nameAr || !formData.nameEn || 
        !formData.baseUnit.unitId || !formData.baseUnit.price || !formData.baseUnit.barcode) {
      alert(texts.required);
      return;
    }

    const productData = {
      ...formData,
      updatedAt: new Date().toISOString()
    };

    if (editingProduct) {
      adminActions.updateProduct(editingProduct.id, productData);
    } else {
      adminActions.addProduct(productData);
    }

    saved = true;
    setTimeout(() => saved = false, 3000);
    showForm = false;
    resetForm();
  }

  function deleteProduct(product) {
    if (confirm(texts.confirmDelete)) {
      adminActions.updateProduct(product.id, { isActive: false });
    }
  }

  function toggleProductStatus(product) {
    adminActions.updateProduct(product.id, { isActive: !product.isActive });
  }

  function getCategoryName(categoryId) {
    const category = currentCategories.find(cat => cat.id === parseInt(categoryId));
    return category ? (currentLanguage === 'ar' ? category.nameAr : category.nameEn) : '';
  }

  function getUnitName(unitId) {
    const unit = currentUnits.find(u => u.id === parseInt(unitId));
    return unit ? (currentLanguage === 'ar' ? unit.nameAr : unit.nameEn) : '';
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="header">
    <h1>{texts.title}</h1>
    <Button variant="primary" on:click={showAddForm}>
      {texts.addProduct}
    </Button>
  </div>

  {#if saved}
    <div class="saved-message">
      ✓ {texts.saved}
    </div>
  {/if}

  <!-- Product Form -->
  {#if showForm}
    <Card>
      <div class="form-container">
        <h2>{editingProduct ? texts.editProduct : texts.addProduct}</h2>
        
        <!-- Basic Info -->
        <div class="form-section">
          <div class="form-row">
            <div class="form-group">
              <label>{texts.category} *</label>
              <select bind:value={formData.categoryId} required>
                <option value="">{texts.selectCategory}</option>
                {#each currentCategories.filter(cat => cat.isActive) as category}
                  <option value={category.id}>
                    {currentLanguage === 'ar' ? category.nameAr : category.nameEn}
                  </option>
                {/each}
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <Input
                label="{texts.arabicName} *"
                bind:value={formData.nameAr}
                required
              />
            </div>
            <div class="form-group">
              <Input
                label="{texts.englishName} *"
                bind:value={formData.nameEn}
                required
              />
            </div>
          </div>
        </div>

        <!-- Base Unit -->
        <div class="form-section">
          <h3>{texts.baseUnit}</h3>
          
          <div class="form-row">
            <div class="form-group">
              <label>{texts.selectUnit} *</label>
              <select bind:value={formData.baseUnit.unitId} required>
                <option value="">{texts.selectUnit}</option>
                {#each currentUnits.filter(unit => unit.isActive) as unit}
                  <option value={unit.id}>
                    {currentLanguage === 'ar' ? unit.nameAr : unit.nameEn}
                  </option>
                {/each}
              </select>
            </div>
            <div class="form-group">
              <Input
                label="{texts.quantity} *"
                type="number"
                bind:value={formData.baseUnit.quantity}
                min="1"
                required
              />
            </div>
            <div class="form-group">
              <Input
                label="{texts.price} ({texts.sar}) *"
                type="number"
                step="0.01"
                bind:value={formData.baseUnit.price}
                min="0"
                required
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <Input
                label="{texts.barcode} *"
                bind:value={formData.baseUnit.barcode}
                required
              />
            </div>
            <div class="form-group">
              <label>{texts.photo}</label>
              <input
                type="file"
                accept="image/*"
                on:change={(e) => handlePhotoUpload(e, 'base')}
                class="file-input"
              />
              {#if formData.baseUnit.photo}
                <img src={formData.baseUnit.photo} alt="Base unit" class="photo-preview" />
              {/if}
            </div>
          </div>
        </div>

        <!-- Additional Units -->
        <div class="form-section">
          <div class="section-header">
            <h3>{texts.additionalUnits}</h3>
            <Button variant="outline" size="sm" on:click={addAdditionalUnit}>
              {texts.addUnit}
            </Button>
          </div>

          {#each formData.additionalUnits as unit, index}
            <div class="additional-unit">
              <div class="unit-header">
                <h4>{texts.selectUnit} {index + 1}</h4>
                <Button variant="outline" size="sm" on:click={() => removeAdditionalUnit(index)}>
                  {texts.removeUnit}
                </Button>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>{texts.selectUnit} *</label>
                  <select bind:value={unit.unitId} required>
                    <option value="">{texts.selectUnit}</option>
                    {#each currentUnits.filter(u => u.isActive) as unitOption}
                      <option value={unitOption.id}>
                        {currentLanguage === 'ar' ? unitOption.nameAr : unitOption.nameEn}
                      </option>
                    {/each}
                  </select>
                </div>
                <div class="form-group">
                  <Input
                    label="{texts.quantity} *"
                    type="number"
                    bind:value={unit.quantity}
                    min="1"
                    required
                  />
                </div>
                <div class="form-group">
                  <Input
                    label="{texts.price} ({texts.sar}) *"
                    type="number"
                    step="0.01"
                    bind:value={unit.price}
                    min="0"
                    required
                  />
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <Input
                    label="{texts.barcode} *"
                    bind:value={unit.barcode}
                    required
                  />
                </div>
                <div class="form-group">
                  <label>{texts.photo}</label>
                  <input
                    type="file"
                    accept="image/*"
                    on:change={(e) => handlePhotoUpload(e, 'additional', index)}
                    class="file-input"
                  />
                  {#if unit.photo}
                    <img src={unit.photo} alt="Unit" class="photo-preview" />
                  {/if}
                </div>
              </div>
            </div>
          {/each}
        </div>

        <!-- Form Actions -->
        <div class="form-actions">
          <Button variant="primary" on:click={saveProduct}>
            {texts.save}
          </Button>
          <Button variant="outline" on:click={cancelForm}>
            {texts.cancel}
          </Button>
        </div>
      </div>
    </Card>
  {/if}

  <!-- Products List -->
  <div class="products-list">
    {#if currentProducts.length === 0}
      <div class="no-products">
        <p>{texts.noProducts}</p>
      </div>
    {:else}
      {#each currentProducts as product}
        <Card>
          <div class="product-item">
            <div class="product-info">
              <div class="product-header">
                <h3>{currentLanguage === 'ar' ? product.nameAr : product.nameEn}</h3>
                <div class="product-status">
                  <span class="status-badge" class:active={product.isActive} class:inactive={!product.isActive}>
                    {product.isActive ? texts.active : texts.inactive}
                  </span>
                </div>
              </div>
              
              <p class="category">{getCategoryName(product.categoryId)}</p>
              
              <div class="product-units">
                <div class="base-unit">
                  <strong>{texts.baseUnit}:</strong>
                  {getUnitName(product.baseUnit.unitId)} - {product.baseUnit.price} {texts.sar}
                </div>
                {#if product.additionalUnits && product.additionalUnits.length > 0}
                  <div class="additional-units">
                    <strong>{texts.additionalUnits}:</strong>
                    {#each product.additionalUnits as unit}
                      <span class="unit-item">
                        {getUnitName(unit.unitId)} - {unit.price} {texts.sar}
                      </span>
                    {/each}
                  </div>
                {/if}
              </div>
            </div>

            <div class="product-actions">
              <Button variant="outline" size="sm" on:click={() => showEditForm(product)}>
                {texts.edit}
              </Button>
              <Button 
                variant={product.isActive ? 'outline' : 'primary'} 
                size="sm" 
                on:click={() => toggleProductStatus(product)}
              >
                {product.isActive ? texts.inactive : texts.active}
              </Button>
              <Button variant="error" size="sm" on:click={() => deleteProduct(product)}>
                {texts.delete}
              </Button>
            </div>
          </div>
        </Card>
      {/each}
    {/if}
  </div>
</div>

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 1200px;
    margin: 0 auto;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
  }

  .header h1 {
    margin: 0;
    color: var(--color-ink);
  }

  .saved-message {
    margin-bottom: var(--space-4);
    padding: var(--space-3);
    background: var(--color-success-light);
    color: var(--color-success-dark);
    border-radius: var(--radius-md);
    font-weight: 500;
    text-align: center;
  }

  .form-container {
    padding: var(--space-6);
  }

  .form-container h2 {
    margin: 0 0 var(--space-6) 0;
    color: var(--color-ink);
  }

  .form-section {
    margin-bottom: var(--space-6);
    padding-bottom: var(--space-4);
    border-bottom: 1px solid var(--color-border);
  }

  .form-section:last-child {
    border-bottom: none;
  }

  .form-section h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-4);
  }

  .section-header h3 {
    margin: 0;
  }

  .form-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: var(--space-4);
    margin-bottom: var(--space-4);
  }

  .form-group {
    display: flex;
    flex-direction: column;
  }

  .form-group label {
    font-weight: 600;
    margin-bottom: var(--space-2);
    color: var(--color-ink);
  }

  .form-group select {
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    font-size: 1rem;
  }

  .file-input {
    padding: var(--space-2);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
  }

  .photo-preview {
    width: 80px;
    height: 80px;
    object-fit: cover;
    border-radius: var(--radius-md);
    margin-top: var(--space-2);
  }

  .additional-unit {
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    padding: var(--space-4);
    margin-bottom: var(--space-4);
    background: var(--color-surface-variant);
  }

  .unit-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-4);
  }

  .unit-header h4 {
    margin: 0;
    color: var(--color-ink);
  }

  .form-actions {
    display: flex;
    gap: var(--space-3);
    justify-content: flex-end;
    margin-top: var(--space-6);
  }

  .products-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .no-products {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .product-item {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: var(--space-4);
  }

  .product-info {
    flex: 1;
  }

  .product-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-2);
  }

  .product-header h3 {
    margin: 0;
    color: var(--color-ink);
  }

  .status-badge {
    padding: var(--space-1) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-badge.active {
    background: var(--color-success-light);
    color: var(--color-success-dark);
  }

  .status-badge.inactive {
    background: var(--color-error-light);
    color: var(--color-error-dark);
  }

  .category {
    color: var(--color-ink-light);
    margin: 0 0 var(--space-3) 0;
  }

  .product-units {
    font-size: 0.9rem;
  }

  .base-unit, .additional-units {
    margin-bottom: var(--space-2);
  }

  .unit-item {
    display: inline-block;
    margin-right: var(--space-2);
    padding: var(--space-1) var(--space-2);
    background: var(--color-surface-variant);
    border-radius: var(--radius-sm);
  }

  .product-actions {
    display: flex;
    gap: var(--space-2);
    flex-shrink: 0;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .header {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .form-row {
      grid-template-columns: 1fr;
    }

    .product-item {
      flex-direction: column;
      gap: var(--space-3);
    }

    .product-actions {
      justify-content: flex-start;
    }

    .form-actions {
      flex-direction: column;
    }
  }
</style>