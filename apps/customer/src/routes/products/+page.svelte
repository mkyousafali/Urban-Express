<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { cartActions, cartStore } from '$lib/stores/cart.js';
  
  let currentLanguage = 'ar';
  let searchQuery = '';
  let selectedCategory = 'all';
  let categoryTabsContainer;
  
  // Subscribe to cart store reactively
    // Reactive cart items for quantity display - force reactivity
  $: cartItems = $cartStore;
  $: cartItemsMap = new Map(cartItems.map(item => [String(item.id), item.quantity]));

  // Touch gesture variables
  let touchStartX = 0;
  let touchEndX = 0;
  let isScrolling = false;

  // Load language from localStorage
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }

    // Check for category parameter in URL
    const urlParams = new URLSearchParams(window.location.search);
    const categoryParam = urlParams.get('category');
    if (categoryParam) {
      selectedCategory = categoryParam;
    }

    // Add touch event listeners for category tabs
    if (categoryTabsContainer) {
      categoryTabsContainer.addEventListener('touchstart', handleTouchStart, { passive: true });
      categoryTabsContainer.addEventListener('touchmove', handleTouchMove, { passive: true });
      categoryTabsContainer.addEventListener('touchend', handleTouchEnd, { passive: true });
    }
  });

  // Touch gesture handlers
  function handleTouchStart(e) {
    touchStartX = e.touches[0].clientX;
    isScrolling = false;
  }

  function handleTouchMove(e) {
    if (!isScrolling) {
      const currentX = e.touches[0].clientX;
      const diffX = touchStartX - currentX;
      
      // Scroll the category tabs horizontally
      categoryTabsContainer.scrollLeft += diffX * 0.5;
      touchStartX = currentX;
      isScrolling = true;
    }
  }

  function handleTouchEnd(e) {
    touchEndX = e.changedTouches[0].clientX;
    isScrolling = false;
  }

  // Smooth scroll to category when selected
  function scrollToCategory(categoryElement) {
    if (categoryElement && categoryTabsContainer) {
      const containerRect = categoryTabsContainer.getBoundingClientRect();
      const elementRect = categoryElement.getBoundingClientRect();
      const scrollPosition = categoryTabsContainer.scrollLeft + elementRect.left - containerRect.left - (containerRect.width / 2) + (elementRect.width / 2);
      
      categoryTabsContainer.scrollTo({
        left: scrollPosition,
        behavior: 'smooth'
      });
    }
  }

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
  
  const categories = [
    { id: 'fresh-produce', nameAr: 'الخضار والفواكه الطازجة', nameEn: 'Fresh Produce', icon: '🥬' },
    { id: 'dairy', nameAr: 'منتجات الألبان', nameEn: 'Dairy Products', icon: '🥛' },
    { id: 'bakery', nameAr: 'المخبوزات', nameEn: 'Bakery', icon: '🍞' },
    { id: 'snacks-beverages', nameAr: 'الوجبات الخفيفة والمشروبات', nameEn: 'Snacks & Beverages', icon: '🍪' },
    { id: 'frozen-foods', nameAr: 'الأطعمة المجمدة', nameEn: 'Frozen Foods', icon: '🧊' },
    { id: 'canned-foods', nameAr: 'الأطعمة المعلبة', nameEn: 'Canned Foods', icon: '🥫' },
    { id: 'condiments-spices', nameAr: 'البهارات والتوابل', nameEn: 'Condiments & Spices', icon: '🧂' },
    { id: 'household-essentials', nameAr: 'الضروريات المنزلية', nameEn: 'Household Essentials', icon: '🧽' },
    { id: 'personal-care', nameAr: 'العناية الشخصية', nameEn: 'Personal Care', icon: '🧴' },
    { id: 'baby-products', nameAr: 'منتجات الأطفال', nameEn: 'Baby Products', icon: '🍼' },
    { id: 'cat-food', nameAr: 'طعام القطط', nameEn: 'Cat Food', icon: '🐱' },
    { id: 'health-foods', nameAr: 'الأطعمة الصحية', nameEn: 'Health Foods', icon: '🥗' },
    { id: 'organic-foods', nameAr: 'الأطعمة العضوية', nameEn: 'Organic Foods', icon: '🌱' },
    { id: 'gluten-free', nameAr: 'المنتجات الخالية من الغلوتين', nameEn: 'Gluten-Free Products', icon: '🌾' },
    { id: 'sugar-free', nameAr: 'المنتجات الخالية من السكر', nameEn: 'Sugar-Free Products', icon: '🚫' },
    { id: 'healthy-meals', nameAr: 'الوجبات الصحية الجاهزة', nameEn: 'Healthy Ready-to-Eat Meals', icon: '🥘' },
    { id: 'international-foods', nameAr: 'الأطعمة العالمية', nameEn: 'International Foods', icon: '🌍' },
    { id: 'toys-games', nameAr: 'الألعاب والتسلية', nameEn: 'Toys & Games', icon: '🎲' }
  ];

  // Example grocery products for each category
  const products = [
    // Fresh Produce
    {
      id: 1,
      category: 'fresh-produce',
      nameAr: 'طماطم طازجة محلية',
      nameEn: 'Fresh Local Tomatoes',
      size: '1',
      sizeUnit: 'كيلو',
      sizeUnitEn: 'kg',
      descriptionAr: 'طماطم طازجة عالية الجودة',
      descriptionEn: 'Fresh high-quality tomatoes',
      basePrice: 8.50,
      originalPrice: 12.00, // 29% off
      unit: 'كيلو',
      unitEn: 'kilogram',
      icon: '🍅'
    },
    {
      id: 2,
      category: 'fresh-produce',
      nameAr: 'موز طازج',
      nameEn: 'Fresh Bananas',
      size: '1',
      sizeUnit: 'كيلو',
      sizeUnitEn: 'kg',
      descriptionAr: 'موز طازج وحلو المذاق',
      descriptionEn: 'Fresh sweet bananas',
      basePrice: 12.75,
      originalPrice: null,
      unit: 'كيلو',
      unitEn: 'kilogram',
      icon: '🍌'
    },
    // Dairy Products
    {
      id: 3,
      category: 'dairy',
      nameAr: 'المراعي كريمة طبخ كاملة الدسم',
      nameEn: 'Almarai Cooking Cream Full Fat',
      size: '500',
      sizeUnit: 'مل',
      sizeUnitEn: 'ml',
      descriptionAr: 'كريمة طبخ فاخرة من المراعي',
      descriptionEn: 'Premium cooking cream from Almarai',
      basePrice: 13.25,
      originalPrice: 17.50, // 24% off
      unit: 'حبة',
      unitEn: 'pieces',
      icon: '🥛'
    },
    {
      id: 4,
      category: 'dairy',
      nameAr: 'المراعي لبنة فاخرة كاملة الدسم',
      nameEn: 'Almarai Premium Labneh Full Fat',
      size: '700',
      sizeUnit: 'جرام',
      sizeUnitEn: 'g',
      descriptionAr: 'لبنة فاخرة طازجة من المراعي',
      descriptionEn: 'Fresh premium labneh from Almarai',
      basePrice: 18.50,
      originalPrice: 25.25, // 27% off
      unit: 'علبة',
      unitEn: 'container',
      icon: '🧀'
    },
    // Bakery
    {
      id: 5,
      category: 'bakery',
      nameAr: 'خبز التوست الأبيض',
      nameEn: 'White Toast Bread',
      size: '1',
      sizeUnit: 'رغيف',
      sizeUnitEn: 'loaf',
      descriptionAr: 'خبز توست طازج ناعم',
      descriptionEn: 'Fresh soft toast bread',
      basePrice: 6.25,
      originalPrice: 8.50, // 26% off
      unit: 'رغيف',
      unitEn: 'loaf',
      icon: '🍞'
    },
    {
      id: 6,
      category: 'bakery',
      nameAr: 'كرواسون بالزبدة',
      nameEn: 'Butter Croissant',
      size: '6',
      sizeUnit: 'قطع',
      sizeUnitEn: 'pieces',
      descriptionAr: 'كرواسون طازج بالزبدة الفرنسية',
      descriptionEn: 'Fresh croissant with French butter',
      basePrice: 15.00,
      originalPrice: null,
      unit: 'علبة',
      unitEn: 'box',
      icon: '🥐'
    },
    // Snacks & Beverages
    {
      id: 7,
      category: 'snacks-beverages',
      nameAr: 'شيبس ليز بطعم الجبن',
      nameEn: 'Lays Cheese Flavor Chips',
      size: '150',
      sizeUnit: 'جرام',
      sizeUnitEn: 'g',
      descriptionAr: 'رقائق البطاطس المقرمشة بطعم الجبن',
      descriptionEn: 'Crispy potato chips with cheese flavor',
      basePrice: 8.75,
      originalPrice: 12.00, // 27% off
      unit: 'كيس',
      unitEn: 'bag',
      icon: '🍟'
    },
    {
      id: 8,
      category: 'snacks-beverages',
      nameAr: 'كوكا كولا 330 مل',
      nameEn: 'Coca Cola 330ml',
      descriptionAr: 'مشروب غازي منعش بطعم الكولا الأصلي',
      descriptionEn: 'Refreshing cola soft drink',
      basePrice: 3.75,
      originalPrice: 5.00, // 25% off
      unit: 'علبة',
      unitEn: 'can',
      icon: '🥤'
    },
    // Frozen Foods
    {
      id: 9,
      category: 'frozen-foods',
      nameAr: 'ناجتس الدجاج المجمد 1 كيلو',
      nameEn: 'Frozen Chicken Nuggets 1kg',
      descriptionAr: 'قطع دجاج مجمدة جاهزة للطبخ',
      descriptionEn: 'Frozen chicken pieces ready to cook',
      basePrice: 35.00,
      originalPrice: 42.50, // 18% off
      unit: 'كيس',
      unitEn: 'bag',
      icon: '🧊'
    },
    // Household Essentials
    {
      id: 10,
      category: 'household-essentials',
      nameAr: 'سائل تنظيف الأطباق 1 لتر',
      nameEn: 'Dishwashing Liquid 1L',
      descriptionAr: 'سائل تنظيف فعال للأطباق',
      descriptionEn: 'Effective dishwashing liquid',
      basePrice: 12.50,
      originalPrice: null,
      unit: 'زجاجة',
      unitEn: 'bottle',
      icon: '🧽'
    },
    // Personal Care
    {
      id: 11,
      category: 'personal-care',
      nameAr: 'شامبو للشعر الجاف 400 مل',
      nameEn: 'Dry Hair Shampoo 400ml',
      descriptionAr: 'شامبو مغذي للشعر الجاف',
      descriptionEn: 'Nourishing shampoo for dry hair',
      basePrice: 28.00,
      originalPrice: 35.00, // 20% off
      unit: 'زجاجة',
      unitEn: 'bottle',
      icon: '🧴'
    }
  ];

  $: filteredProducts = selectedCategory === 'all' 
    ? products.filter(product => 
        searchQuery === '' || 
        (currentLanguage === 'ar' ? product.nameAr : product.nameEn)
          .toLowerCase().includes(searchQuery.toLowerCase())
      )
    : products.filter(product => 
        product.category === selectedCategory &&
        (searchQuery === '' || 
         (currentLanguage === 'ar' ? product.nameAr : product.nameEn)
           .toLowerCase().includes(searchQuery.toLowerCase()))
      );

  $: texts = currentLanguage === 'ar' ? {
    title: 'منتجات البقالة',
    searchPlaceholder: 'ابحث عن منتج...',
    selectCategory: 'اختر فئة المنتج',
    allCategories: 'جميع المنتجات',
    sar: 'ر.س'
  } : {
    title: 'Grocery Products',
    searchPlaceholder: 'Search for product...',
    selectCategory: 'Select product category',
    allCategories: 'All Products',
    sar: 'SAR'
  };

  function handleCategorySelect(categoryId, event) {
    selectedCategory = categoryId;
    
    // Scroll to the selected category tab
    if (event && event.target) {
      setTimeout(() => {
        scrollToCategory(event.target);
      }, 100);
    }
  }

  // Navigation functions
  function scrollLeft() {
    if (categoryTabsContainer) {
      categoryTabsContainer.scrollBy({
        left: -200,
        behavior: 'smooth'
      });
    }
  }

  function scrollRight() {
    if (categoryTabsContainer) {
      categoryTabsContainer.scrollBy({
        left: 200,
        behavior: 'smooth'
      });
    }
  }

  // Get current quantity of a product in cart (reactive)
  function getCartQuantity(productId) {
    return cartItemsMap.get(String(productId)) || 0;
  }

  function handleAddToCart(product) {
    // Add item with quantity 1 to cart
    cartActions.addItem(product, 1);
  }

  function handleAddToCartClick(event, product) {
    event.stopPropagation();
    handleAddToCart(product);
  }

  function increaseQuantity(productId, event) {
    event.stopPropagation();
    const currentQuantity = getCartQuantity(productId);
    const newQuantity = currentQuantity + 1;
    
    // Update cart directly
    const product = filteredProducts.find(p => p.id === productId);
    if (product) {
      cartActions.setItemQuantity(product, newQuantity);
    }
  }

  function decreaseQuantity(productId, event) {
    event.stopPropagation();
    const currentQuantity = getCartQuantity(productId);
    
    if (currentQuantity > 0) {
      const newQuantity = currentQuantity - 1;
      
      if (newQuantity === 0) {
        // Remove from cart when quantity becomes 0
        cartActions.removeItem(productId);
      } else {
        // Update cart with new quantity
        const product = filteredProducts.find(p => p.id === productId);
        if (product) {
          cartActions.setItemQuantity(product, newQuantity);
        }
      }
    }
  }

  function goToProductDetail(productId) {
    goto(`/products/${productId}`);
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="products-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Search Bar -->
  <div class="search-section">
    <div class="search-bar">
      <svg class="search-icon" width="20" height="20" viewBox="0 0 20 20" fill="none">
        <path d="M19 19L13 13L19 19ZM15 8A7 7 0 1 1 1 8A7 7 0 0 1 15 8Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      <input 
        type="text" 
        placeholder={texts.searchPlaceholder}
        bind:value={searchQuery}
      />
    </div>
  </div>

  <!-- Category Filter -->
  <div class="category-filter">
    <h3>{texts.selectCategory}</h3>
    <div class="category-container">
      <button class="nav-button nav-left" on:click={scrollLeft} aria-label="Scroll left">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M12 16L6 10L12 4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </button>
      
      <div class="category-tabs" bind:this={categoryTabsContainer}>
        <button 
          class="category-tab" 
          class:active={selectedCategory === 'all'}
          on:click={(event) => handleCategorySelect('all', event)}
        >
          {texts.allCategories}
        </button>
        {#each categories as category}
          <button 
            class="category-tab" 
            class:active={selectedCategory === category.id}
            on:click={(event) => handleCategorySelect(category.id, event)}
          >
            <span class="category-emoji">{category.icon}</span>
            {currentLanguage === 'ar' ? category.nameAr : category.nameEn}
          </button>
        {/each}
      </div>
      
      <button class="nav-button nav-right" on:click={scrollRight} aria-label="Scroll right">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M8 4L14 10L8 16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </button>
    </div>
  </div>

  <!-- Products Grid -->
  <div class="products-grid">
    {#each filteredProducts as product (product.id)}
      <div class="product-card" on:click={() => goToProductDetail(product.id)}>
        <div class="product-image">
          <div class="product-icon">{product.icon}</div>
        </div>
        
        <div class="product-details">
          <div class="product-info">
            <h3>{currentLanguage === 'ar' ? product.nameAr : product.nameEn}</h3>
            
            <div class="product-size">
              {product.size} {currentLanguage === 'ar' ? product.sizeUnit : product.sizeUnitEn}
            </div>
            
            <div class="product-pricing">
              <div class="current-price">
                {product.basePrice.toFixed(2)} {texts.sar}
              </div>
              {#if product.originalPrice}
                <div class="original-price">{product.originalPrice.toFixed(2)} {texts.sar}</div>
              {/if}
            </div>
            
            <div class="unit-info">
              / {currentLanguage === 'ar' ? product.unit : product.unitEn}
            </div>
          </div>
          
          <div class="product-actions">
            <!-- Quantity Controls -->
            <div class="quantity-controls">
              <button 
                class="quantity-btn" 
                on:click={(event) => decreaseQuantity(product.id, event)}
                disabled={(cartItemsMap.get(String(product.id)) || 0) === 0}
              >
                −
              </button>
              <span class="quantity-display">
                {cartItemsMap.get(String(product.id)) || 0}
              </span>
              <button 
                class="quantity-btn" 
                on:click={(event) => increaseQuantity(product.id, event)}
              >
                +
              </button>
            </div>
          </div>
        </div>
      </div>
    {/each}
  </div>
</div>

<style>
  .products-container {
    padding: 0.75rem;
    max-width: 1200px;
    margin: 0 auto;
    width: 100%;
    box-sizing: border-box;
  }

  .search-section {
    margin-bottom: 1.5rem;
  }

  .search-bar {
    position: relative;
    display: flex;
    align-items: center;
  }

  .search-icon {
    position: absolute;
    left: 1rem;
    color: var(--color-ink-light);
    z-index: 1;
  }

  [dir="rtl"] .search-icon {
    left: auto;
    right: 1rem;
  }

  .search-bar input {
    width: 100%;
    padding: 0.75rem 1rem 0.75rem 3rem;
    border: 2px solid var(--color-border);
    border-radius: 12px;
    font-size: 1rem;
    background: white;
    transition: border-color 0.2s ease;
    box-sizing: border-box;
    min-height: 44px; /* Touch-friendly minimum */
  }

  [dir="rtl"] .search-bar input {
    padding: 0.75rem 3rem 0.75rem 1rem;
  }

  .search-bar input:focus {
    outline: none;
    border-color: var(--color-primary);
  }

  .category-filter {
    margin-bottom: 2rem;
  }

  .category-filter h3 {
    font-size: 1.1rem;
    font-weight: 600;
    color: var(--color-ink);
    margin-bottom: 1rem;
  }

  .category-container {
    position: relative;
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .nav-button {
    flex-shrink: 0;
    width: 40px;
    height: 40px;
    border: 2px solid var(--color-border);
    background: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s ease;
    color: var(--color-ink);
    z-index: 10;
  }

  .nav-button:hover {
    border-color: var(--color-primary);
    background: var(--color-primary-light);
  }

  .nav-button:active {
    transform: scale(0.95);
  }

  .category-tabs {
    display: flex;
    gap: 0.5rem;
    overflow-x: auto;
    padding: 0.5rem 0;
    scrollbar-width: none; /* Firefox */
    -ms-overflow-style: none; /* IE and Edge */
    scroll-behavior: smooth;
    flex: 1;
    touch-action: pan-x; /* Enable horizontal touch scrolling */
    -webkit-overflow-scrolling: touch; /* Smooth scrolling on iOS */
  }

  .category-tabs::-webkit-scrollbar {
    display: none; /* Chrome, Safari, Opera */
  }

  .category-tab {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    background: white;
    border: 2px solid var(--color-border);
    border-radius: 20px;
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--color-ink);
    cursor: pointer;
    transition: all 0.2s ease;
    white-space: nowrap;
    flex-shrink: 0;
    min-height: 44px; /* Touch-friendly minimum */
    box-sizing: border-box;
  }

  .category-tab:hover {
    border-color: var(--color-primary);
  }

  .category-tab.active {
    background: var(--color-primary);
    border-color: var(--color-primary);
    color: white;
  }

  .category-emoji {
    font-size: 1.1rem;
  }

  .products-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .product-card {
    background: white;
    border: 2px solid var(--color-border);
    border-radius: 16px;
    padding: 1rem;
    display: flex;
    flex-direction: row;
    gap: 1rem;
    transition: all 0.2s ease;
    cursor: pointer;
    align-items: center;
  }

  .product-card:hover {
    border-color: var(--color-primary);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .product-image {
    flex-shrink: 0;
    width: 150px;
    height: 150px;
    background: var(--color-surface);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--color-border);
  }

  .product-icon {
    font-size: 4rem;
  }

  .product-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .product-info {
    flex: 1;
  }

  .product-actions {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .quantity-controls {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    justify-content: center;
  }

  .quantity-btn {
    width: 35px;
    height: 35px;
    border: 2px solid var(--color-border);
    background: white;
    border-radius: 8px;
    font-size: 1.2rem;
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

  .quantity-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    border-color: var(--color-border);
    background: #f5f5f5;
  }

  .quantity-btn:disabled:hover {
    border-color: var(--color-border);
    background: #f5f5f5;
  }

  .quantity-display {
    font-size: 1.1rem;
    font-weight: bold;
    color: var(--color-ink);
    min-width: 30px;
    text-align: center;
    padding: 0.5rem;
    border: 2px solid var(--color-border);
    border-radius: 8px;
    background: white;
  }

  .product-info h3 {
    font-size: 1rem;
    font-weight: 600;
    color: var(--color-ink);
    line-height: 1.3;
    margin: 0 0 0.5rem 0;
  }

  .product-size {
    font-size: 0.85rem;
    font-weight: 500;
    color: var(--color-ink-light);
    background: var(--color-surface-secondary);
    padding: 0.25rem 0.5rem;
    border-radius: 6px;
    display: inline-block;
    margin-bottom: 0.5rem;
  }

  .product-pricing {
    display: flex;
    align-items: baseline;
    gap: 0.5rem;
    margin-bottom: 0.25rem;
  }

  .current-price {
    font-size: 1.2rem;
    font-weight: 700;
    color: var(--color-primary);
  }

  .original-price {
    font-size: 0.9rem;
    color: var(--color-ink-light);
    text-decoration: line-through;
  }

  .unit-info {
    font-size: 0.85rem;
    color: var(--color-ink-light);
    font-style: italic;
  }

  /* Small mobile screens */
  @media (max-width: 480px) {
    .products-container {
      padding: 0.5rem;
    }
    
    .nav-button {
      width: 35px;
      height: 35px;
    }
    
    .nav-button svg {
      width: 16px;
      height: 16px;
    }
    
    .product-card {
      padding: 0.75rem;
      gap: 0.75rem;
    }
    
    .product-image {
      width: 120px;
      height: 120px;
    }
    
    .product-icon {
      font-size: 3.5rem;
    }
    
    .product-info h3 {
      font-size: 0.9rem;
    }
    
    .current-price {
      font-size: 1.1rem;
    }
    
    .category-tab {
      font-size: 0.8rem;
      padding: 0.6rem 0.8rem;
    }
    
    .quantity-btn {
      width: 30px;
      height: 30px;
      font-size: 1rem;
    }
    
    .quantity-display {
      font-size: 1rem;
      min-width: 25px;
      padding: 0.4rem;
    }
    
    .product-actions {
      gap: 0.5rem;
    }
  }

  /* Tablet and larger mobile screens */
  @media (min-width: 481px) and (max-width: 767px) {
    .products-container {
      padding: 1rem;
    }
    
    .product-card {
      padding: 1.25rem;
    }
    
    .product-image {
      width: 160px;
      height: 160px;
    }
    
    .product-icon {
      font-size: 4.5rem;
    }
  }

  /* Tablet screens */
  @media (min-width: 768px) {
    .products-container {
      padding: 1.5rem;
    }
    
    .products-grid {
      grid-template-columns: 1fr;
    }
    
    .product-card {
      padding: 1.5rem;
    }
    
    .product-image {
      width: 170px;
      height: 170px;
    }
    
    .product-icon {
      font-size: 5rem;
    }
    
    .product-info h3 {
      font-size: 1.1rem;
    }
    
    .current-price {
      font-size: 1.4rem;
    }
    
    .search-bar input {
      font-size: 1.1rem;
    }
  }

  /* Desktop screens */
  @media (min-width: 1024px) {
    .products-grid {
      grid-template-columns: 1fr 1fr;
      gap: 1.5rem;
    }
    
    .product-card {
      padding: 2rem;
    }
    
    .product-image {
      width: 180px;
      height: 180px;
    }
    
    .product-icon {
      font-size: 5.5rem;
    }
  }

  /* Large desktop screens */
  @media (min-width: 1200px) {
    .products-container {
      padding: 2rem;
    }
    
    .products-grid {
      grid-template-columns: 1fr 1fr;
      gap: 2rem;
    }
    
    .product-card {
      padding: 2.5rem;
    }
  }
</style>