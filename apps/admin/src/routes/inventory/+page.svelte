<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import { branches, products, stock, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let selectedBranch = '';
  let selectedProduct = '';
  let selectedUnit = '';
  let stockQuantity = '';
  let stockOperation = 'add'; // 'add' or 'set'
  let saved = false;
  
  // Subscribe to stores
  $: currentBranches = $branches || [];
  $: currentProducts = $products || [];
  $: currentStock = $stock || {};
  
  // Computed values
  $: activeBranches = Array.isArray(currentBranches) ? currentBranches.filter(branch => branch.isActive) : [];
  $: activeProducts = Array.isArray(currentProducts) ? currentProducts.filter(product => product.isActive) : [];
  $: selectedProductData = activeProducts.find(p => p.id === parseInt(selectedProduct));
  $: availableUnits = selectedProductData ? [
    { ...selectedProductData.baseUnit, id: 'base', type: 'base' },
    ...(selectedProductData.additionalUnits || []).map(unit => ({ ...unit, type: 'additional' }))
  ] : [];
  
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
    title: 'إدارة المخزون',
    selectBranch: 'اختر الفرع',
    selectProduct: 'اختر المنتج',
    selectUnit: 'اختر الوحدة',
    currentStock: 'المخزون الحالي',
    operation: 'العملية',
    addStock: 'إضافة للمخزون',
    setStock: 'تحديد المخزون',
    quantity: 'الكمية',
    updateStock: 'تحديث المخزون',
    stockUpdated: 'تم تحديث المخزون بنجاح!',
    stockOverview: 'نظرة عامة على المخزون',
    product: 'المنتج',
    unit: 'الوحدة',
    stock: 'المخزون',
    lowStock: 'مخزون منخفض',
    outOfStock: 'نفد المخزون',
    available: 'متوفر',
    noProducts: 'لا توجد منتجات',
    branch: 'الفرع',
    allBranches: 'جميع الفروع',
    filter: 'تصفية',
    search: 'بحث...',
    pieces: 'قطعة',
    baseUnit: 'الوحدة الأساسية',
    additionalUnit: 'وحدة إضافية'
  } : {
    title: 'Inventory Management',
    selectBranch: 'Select Branch',
    selectProduct: 'Select Product',
    selectUnit: 'Select Unit',
    currentStock: 'Current Stock',
    operation: 'Operation',
    addStock: 'Add to Stock',
    setStock: 'Set Stock',
    quantity: 'Quantity',
    updateStock: 'Update Stock',
    stockUpdated: 'Stock updated successfully!',
    stockOverview: 'Stock Overview',
    product: 'Product',
    unit: 'Unit',
    stock: 'Stock',
    lowStock: 'Low Stock',
    outOfStock: 'Out of Stock',
    available: 'Available',
    noProducts: 'No products',
    branch: 'Branch',
    allBranches: 'All Branches',
    filter: 'Filter',
    search: 'Search...',
    pieces: 'pieces',
    baseUnit: 'Base Unit',
    additionalUnit: 'Additional Unit'
  };

  function getCurrentStock() {
    if (!selectedBranch || !selectedProduct || !selectedUnit) return 0;
    return adminActions.getStock(currentStock, parseInt(selectedBranch), parseInt(selectedProduct), selectedUnit);
  }

  function updateStock() {
    if (!selectedBranch || !selectedProduct || !selectedUnit || stockQuantity === '') {
      alert('Please fill all fields');
      return;
    }

    const currentStockValue = getCurrentStock();
    const quantity = parseInt(stockQuantity);
    let newStock;

    if (stockOperation === 'add') {
      newStock = currentStockValue + quantity;
    } else {
      newStock = quantity;
    }

    adminActions.updateStock(parseInt(selectedBranch), parseInt(selectedProduct), selectedUnit, Math.max(0, newStock));
    
    saved = true;
    setTimeout(() => saved = false, 3000);
    stockQuantity = '';
  }

  function getProductName(product) {
    return currentLanguage === 'ar' ? product.nameAr : product.nameEn;
  }

  function getBranchName(branch) {
    return currentLanguage === 'ar' ? branch.nameAr : branch.nameEn;
  }

  function getUnitName(product, unitId) {
    if (unitId === 'base') {
      const unit = units.find(u => u.id === product.baseUnit.unitId);
      return unit ? (currentLanguage === 'ar' ? unit.nameAr : unit.nameEn) : '';
    } else {
      const additionalUnit = product.additionalUnits?.find(u => u.id === unitId);
      if (additionalUnit) {
        const unit = units.find(u => u.id === additionalUnit.unitId);
        return unit ? (currentLanguage === 'ar' ? unit.nameAr : unit.nameEn) : '';
      }
    }
    return '';
  }

  function getStockStatus(stock) {
    if (stock === 0) return 'outOfStock';
    if (stock < 10) return 'lowStock';
    return 'available';
  }

  function getAllStockData() {
    const stockData = [];
    
    // Safety check to ensure arrays are available
    if (!Array.isArray(activeBranches) || !Array.isArray(activeProducts)) {
      return stockData;
    }
    
    for (const branch of activeBranches) {
      for (const product of activeProducts) {
        // Base unit
        const baseStock = adminActions.getStock(currentStock, branch.id, product.id, 'base');
        stockData.push({
          branchId: branch.id,
          branchName: getBranchName(branch),
          productId: product.id,
          productName: getProductName(product),
          unitId: 'base',
          unitType: texts.baseUnit,
          unitName: getUnitName(product, 'base'),
          stock: baseStock,
          status: getStockStatus(baseStock)
        });

        // Additional units
        if (product.additionalUnits) {
          for (const unit of product.additionalUnits) {
            const unitStock = adminActions.getStock(currentStock, branch.id, product.id, unit.id);
            stockData.push({
              branchId: branch.id,
              branchName: getBranchName(branch),
              productId: product.id,
              productName: getProductName(product),
              unitId: unit.id,
              unitType: texts.additionalUnit,
              unitName: getUnitName(product, unit.id),
              stock: unitStock,
              status: getStockStatus(unitStock)
            });
          }
        }
      }
    }
    
    return stockData;
  }

  $: allStockData = getAllStockData();
  $: filteredStockData = selectedBranch ? 
    allStockData.filter(item => item.branchId === parseInt(selectedBranch)) : 
    allStockData;
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <h1>{texts.title}</h1>

  {#if saved}
    <div class="saved-message">
      ✓ {texts.stockUpdated}
    </div>
  {/if}

  <!-- Stock Update Form -->
  <Card>
    <div class="form-container">
      <h2>{texts.updateStock}</h2>
      
      <div class="form-grid">
        <div class="form-group">
          <label>{texts.selectBranch}</label>
          <select bind:value={selectedBranch}>
            <option value="">{texts.selectBranch}</option>
            {#each activeBranches as branch}
              <option value={branch.id}>
                {getBranchName(branch)}
              </option>
            {/each}
          </select>
        </div>

        <div class="form-group">
          <label>{texts.selectProduct}</label>
          <select bind:value={selectedProduct} on:change={() => selectedUnit = ''}>
            <option value="">{texts.selectProduct}</option>
            {#each activeProducts as product}
              <option value={product.id}>
                {getProductName(product)}
              </option>
            {/each}
          </select>
        </div>

        <div class="form-group">
          <label>{texts.selectUnit}</label>
          <select bind:value={selectedUnit} disabled={!selectedProduct}>
            <option value="">{texts.selectUnit}</option>
            {#each availableUnits as unit}
              <option value={unit.id}>
                {unit.type === 'base' ? texts.baseUnit : texts.additionalUnit} - 
                {getUnitName(selectedProductData, unit.id)}
              </option>
            {/each}
          </select>
        </div>

        <div class="form-group">
          <label>{texts.currentStock}</label>
          <div class="stock-display">
            {getCurrentStock()} {texts.pieces}
          </div>
        </div>

        <div class="form-group">
          <label>{texts.operation}</label>
          <div class="radio-group">
            <label class="radio-option">
              <input type="radio" bind:group={stockOperation} value="add" />
              {texts.addStock}
            </label>
            <label class="radio-option">
              <input type="radio" bind:group={stockOperation} value="set" />
              {texts.setStock}
            </label>
          </div>
        </div>

        <div class="form-group">
          <Input
            label={texts.quantity}
            type="number"
            bind:value={stockQuantity}
            min="0"
          />
        </div>
      </div>

      <div class="form-actions">
        <Button 
          variant="primary" 
          on:click={updateStock}
          disabled={!selectedBranch || !selectedProduct || !selectedUnit || stockQuantity === ''}
        >
          {texts.updateStock}
        </Button>
      </div>
    </div>
  </Card>

  <!-- Stock Overview -->
  <Card>
    <div class="overview-container">
      <div class="overview-header">
        <h2>{texts.stockOverview}</h2>
        <div class="filter-controls">
          <select bind:value={selectedBranch}>
            <option value="">{texts.allBranches}</option>
            {#each activeBranches as branch}
              <option value={branch.id}>
                {getBranchName(branch)}
              </option>
            {/each}
          </select>
        </div>
      </div>

      <div class="stock-table-container">
        <table class="stock-table">
          <thead>
            <tr>
              <th>{texts.branch}</th>
              <th>{texts.product}</th>
              <th>{texts.unit}</th>
              <th>{texts.stock}</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {#each filteredStockData as item}
              <tr class="stock-row {item.status}">
                <td>{item.branchName}</td>
                <td>{item.productName}</td>
                <td>
                  <span class="unit-type">{item.unitType}</span>
                  <br>
                  <span class="unit-name">{item.unitName}</span>
                </td>
                <td class="stock-cell">
                  <span class="stock-number">{item.stock}</span>
                  <span class="stock-label">{texts.pieces}</span>
                </td>
                <td>
                  <span class="status-badge {item.status}">
                    {item.status === 'outOfStock' ? texts.outOfStock : 
                     item.status === 'lowStock' ? texts.lowStock : 
                     texts.available}
                  </span>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>

        {#if filteredStockData.length === 0}
          <div class="no-data">
            <p>{texts.noProducts}</p>
          </div>
        {/if}
      </div>
    </div>
  </Card>
</div>

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

  .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: var(--space-4);
    margin-bottom: var(--space-6);
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

  .stock-display {
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
    font-weight: 600;
    color: var(--color-ink);
  }

  .radio-group {
    display: flex;
    gap: var(--space-3);
  }

  .radio-option {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    cursor: pointer;
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
  }

  .overview-container {
    padding: var(--space-6);
  }

  .overview-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
  }

  .overview-header h2 {
    margin: 0;
    color: var(--color-ink);
  }

  .filter-controls select {
    padding: var(--space-2) var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
  }

  .stock-table-container {
    overflow-x: auto;
  }

  .stock-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: var(--space-4);
  }

  .stock-table th,
  .stock-table td {
    padding: var(--space-3);
    text-align: left;
    border-bottom: 1px solid var(--color-border);
  }

  .stock-table th {
    background: var(--color-surface-variant);
    font-weight: 600;
    color: var(--color-ink);
  }

  .stock-row.outOfStock {
    background: var(--color-error-light);
  }

  .stock-row.lowStock {
    background: #fef3c7;
  }

  .unit-type {
    font-size: 0.8rem;
    color: var(--color-ink-light);
    font-style: italic;
  }

  .unit-name {
    font-weight: 600;
  }

  .stock-cell {
    text-align: center;
  }

  .stock-number {
    font-weight: 700;
    font-size: 1.1rem;
  }

  .stock-label {
    font-size: 0.8rem;
    color: var(--color-ink-light);
  }

  .status-badge {
    padding: var(--space-1) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-badge.available {
    background: var(--color-success-light);
    color: var(--color-success-dark);
  }

  .status-badge.lowStock {
    background: #fef3c7;
    color: #d97706;
  }

  .status-badge.outOfStock {
    background: var(--color-error-light);
    color: var(--color-error-dark);
  }

  .no-data {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .form-grid {
      grid-template-columns: 1fr;
    }

    .overview-header {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .radio-group {
      flex-direction: column;
    }
  }
</style>