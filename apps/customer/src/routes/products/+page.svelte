<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { cartActions, cartStore } from '$lib/stores/cart.js';
  import { scrollingContent, scrollingContentActions } from '$lib/stores/scrollingContent.js';
  
  let currentLanguage = 'ar';
  let searchQuery = '';
  let selectedCategory = 'all';
  let categoryTabsContainer;
  let selectedUnits = new Map(); // Track selected unit for each product
  
  // Subscribe to cart store reactively
    // Reactive cart items for quantity display - force reactivity
  $: cartItems = $cartStore;
  $: cartItemsMap = new Map(cartItems.map(item => [String(item.id), item.quantity]));

  // Subscribe to scrolling content store
  $: currentScrollingContent = $scrollingContent;
  $: activeScrollingTexts = scrollingContentActions.getActiveContent(currentScrollingContent, currentLanguage);

  // Touch gesture variables
  let touchStartX = 0;
  let touchEndX = 0;
  let isScrolling = false;

  // Initialize selected units with first unit of each product
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

    // Initialize selected units
    products.forEach(product => {
      if (product.units && product.units.length > 0) {
        selectedUnits.set(product.id, product.units[0]);
      }
    });
    selectedUnits = selectedUnits; // Trigger reactivity

    // Add touch event listeners for category tabs
    if (categoryTabsContainer) {
      categoryTabsContainer.addEventListener('touchstart', handleTouchStart, { passive: true });
      categoryTabsContainer.addEventListener('touchmove', handleTouchMove, { passive: true });
      categoryTabsContainer.addEventListener('touchend', handleTouchEnd, { passive: true });
    }
  });

  // Get selected unit for a product
  function getSelectedUnit(product) {
    // New structure with baseUnit + additionalUnits
    if (product.baseUnit) {
      const selectedUnitId = selectedUnits.get(product.id);
      
      // Check if base unit is selected
      if (!selectedUnitId || selectedUnitId === 'base') {
        return product.baseUnit;
      }
      
      // Check additional units
      if (product.additionalUnits) {
        const foundUnit = product.additionalUnits.find(unit => unit.id === selectedUnitId);
        if (foundUnit) return foundUnit;
      }
      
      // Default to base unit
      return product.baseUnit;
    }
    
    // Legacy support for old units array structure
    if (product.units && product.units.length > 0) {
      const selectedUnitId = selectedUnits.get(product.id);
      return product.units.find(unit => unit.id === selectedUnitId) || product.units[0];
    }
    
    // Fallback for very old format products
    return {
      id: 'legacy',
      nameAr: `${product.size || ''} ${product.sizeUnit || 'حبة'}`,
      nameEn: `${product.size || ''} ${product.sizeUnitEn || 'piece'}`,
      unitAr: product.unit || 'حبة',
      unitEn: product.unitEn || 'piece',
      basePrice: product.basePrice || 0,
      originalPrice: product.originalPrice,
      stock: product.stock || 0,
      lowStockThreshold: product.lowStockThreshold || 5,
      barcode: product.barcode || '',
      photo: null
    };
  }

  // Select a unit for a product
  function selectUnit(productId, unit) {
    selectedUnits.set(productId, unit.id);
    selectedUnits = selectedUnits; // Trigger reactivity
  }

  // Get all available units for a product (base + additional)
  function getAllUnits(product) {
    if (product.baseUnit) {
      const units = [product.baseUnit];
      if (product.additionalUnits && product.additionalUnits.length > 0) {
        units.push(...product.additionalUnits);
      }
      return units;
    }
    // Legacy support
    return product.units || [];
  }

  // Check if product has multiple units (should show selection)
  function hasMultipleUnits(product) {
    return getAllUnits(product).length > 1;
  }

  // Get stock for current selected unit
  function getSelectedUnitStock(product) {
    const selectedUnit = getSelectedUnit(product);
    return selectedUnit.stock || 0;
  }

  // Check if selected unit is out of stock
  function isOutOfStock(product) {
    return getSelectedUnitStock(product) === 0;
  }

  // Check if selected unit has low stock
  function isLowStock(product) {
    const selectedUnit = getSelectedUnit(product);
    const stock = selectedUnit.stock || 0;
    const threshold = selectedUnit.lowStockThreshold || 5;
    return stock > 0 && stock <= threshold;
  }

  // Get stock status text
  function getStockStatusText(product) {
    const selectedUnit = getSelectedUnit(product);
    const stock = selectedUnit.stock || 0;
    const unitName = currentLanguage === 'ar' ? selectedUnit.nameAr : selectedUnit.nameEn;
    
    if (stock === 0) {
      return currentLanguage === 'ar' ? 'نفد المخزون' : 'Out of Stock';
    }
    if (isLowStock(product)) {
      return currentLanguage === 'ar' ? `${stock} x ${unitName} فقط متبقي` : `Only ${stock} x ${unitName} left`;
    }
    return currentLanguage === 'ar' ? `${stock} x ${unitName} متوفر` : `${stock} x ${unitName} available`;
  }

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
      descriptionAr: 'طماطم طازجة عالية الجودة',
      descriptionEn: 'Fresh high-quality tomatoes',
      icon: '🍅',
      // Base unit - always exists
      baseUnit: {
        id: 'base',
        nameAr: '1 كيلو',
        nameEn: '1 kg',
        unitAr: 'كيلو',
        unitEn: 'kilogram',
        basePrice: 8.50,
        originalPrice: 12.00,
        stock: 25, // Admin can set stock for each unit
        lowStockThreshold: 5, // When to show low stock warning
        barcode: '123456789001',
        photo: null,
        isBase: true
      },
      // Additional units - admin can create up to 3 more
      additionalUnits: [
        {
          id: 'unit_2',
          nameAr: '500 جرام',
          nameEn: '500 g',
          unitAr: 'علبة',
          unitEn: 'pack',
          basePrice: 4.75,
          originalPrice: 6.00,
          stock: 50, // Different stock for each unit
          lowStockThreshold: 10,
          barcode: '123456789002',
          photo: null
        },
        {
          id: 'unit_3',
          nameAr: '2 كيلو',
          nameEn: '2 kg',
          unitAr: 'كيس',
          unitEn: 'bag',
          basePrice: 15.00,
          originalPrice: 20.00,
          stock: 8, // Low stock example
          lowStockThreshold: 5,
          barcode: '123456789003',
          photo: null
        }
      ]
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
      stock: 15, // Add stock for legacy products
      lowStockThreshold: 3,
      icon: '🍌'
    },
    {
      id: 3,
      category: 'fresh-produce',
      nameAr: 'تفاح أحمر طازج',
      nameEn: 'Fresh Red Apples',
      descriptionAr: 'تفاح أحمر حلو ومقرمش',
      descriptionEn: 'Sweet and crispy red apples',
      icon: '🍎',
      // Single unit product (no selection needed)
      baseUnit: {
        id: 'base',
        nameAr: '1 كيلو',
        nameEn: '1 kg',
        unitAr: 'كيلو',
        unitEn: 'kilogram',
        basePrice: 14.50,
        originalPrice: null,
        stock: 12,
        lowStockThreshold: 5,
        barcode: '123456789004',
        photo: null,
        isBase: true
      }
      // No additional units - shows only base unit
    },
    {
      id: 4,
      category: 'dairy',
      nameAr: 'حليب طازج',
      nameEn: 'Fresh Milk',
      descriptionAr: 'حليب طازج كامل الدسم',
      descriptionEn: 'Fresh full-fat milk',
      icon: '🥛',
      baseUnit: {
        id: 'base',
        nameAr: '1 لتر',
        nameEn: '1 liter',
        unitAr: 'لتر',
        unitEn: 'liter',
        basePrice: 6.75,
        originalPrice: 8.00,
        stock: 0, // Out of stock
        lowStockThreshold: 3,
        barcode: '123456789005',
        photo: null,
        isBase: true
      },
      additionalUnits: [
        {
          id: 'unit_2',
          nameAr: '500 مل',
          nameEn: '500 ml',
          unitAr: 'زجاجة',
          unitEn: 'bottle',
          basePrice: 3.50,
          originalPrice: null,
          stock: 18,
          lowStockThreshold: 5,
          barcode: '123456789006',
          photo: null
        },
        {
          id: 'unit_3',
          nameAr: '2 لتر',
          nameEn: '2 liter',
          unitAr: 'علبة',
          unitEn: 'carton',
          basePrice: 12.00,
          originalPrice: 15.00,
          stock: 3, // Low stock
          lowStockThreshold: 5,
          barcode: '123456789007',
          photo: null
        }
      ]
    },
    {
      id: 5,
      category: 'bakery',
      nameAr: 'خبز أبيض طازج',
      nameEn: 'Fresh White Bread',
      descriptionAr: 'خبز أبيض طازج مخبوز يومياً',
      descriptionEn: 'Fresh white bread baked daily',
      icon: '🍞',
      baseUnit: {
        id: 'base',
        nameAr: '1 رغيف',
        nameEn: '1 loaf',
        unitAr: 'رغيف',
        unitEn: 'loaf',
        basePrice: 2.50,
        originalPrice: null,
        stock: 45,
        lowStockThreshold: 10,
        barcode: '123456789008',
        photo: null,
        isBase: true
      },
      additionalUnits: [
        {
          id: 'unit_2',
          nameAr: '6 أرغفة',
          nameEn: '6 loaves',
          unitAr: 'كيس',
          unitEn: 'pack',
          basePrice: 13.50,
          originalPrice: 15.00,
          stock: 8,
          lowStockThreshold: 5,
          barcode: '123456789009',
          photo: null
        }
      ]
    },
    {
      id: 6,
      category: 'meat',
      nameAr: 'لحم بقري طازج',
      nameEn: 'Fresh Beef',
      descriptionAr: 'لحم بقري طازج عالي الجودة',
      descriptionEn: 'High quality fresh beef',
      icon: '🥩',
      baseUnit: {
        id: 'base',
        nameAr: '500 جرام',
        nameEn: '500 g',
        unitAr: 'جرام',
        unitEn: 'gram',
        basePrice: 45.00,
        originalPrice: 50.00,
        stock: 15,
        lowStockThreshold: 5,
        barcode: '123456789010',
        photo: null,
        isBase: true
      },
      additionalUnits: [
        {
          id: 'unit_2',
          nameAr: '1 كيلو',
          nameEn: '1 kg',
          unitAr: 'كيلو',
          unitEn: 'kilogram',
          basePrice: 85.00,
          originalPrice: 95.00,
          stock: 6,
          lowStockThreshold: 3,
          barcode: '123456789011',
          photo: null
        },
        {
          id: 'unit_3',
          nameAr: '250 جرام',
          nameEn: '250 g',
          unitAr: 'علبة',
          unitEn: 'pack',
          basePrice: 24.00,
          originalPrice: null,
          stock: 0, // Out of stock
          lowStockThreshold: 5,
          barcode: '123456789012',
          photo: null
        }
      ]
    },
    {
      id: 7,
      category: 'snacks',
      nameAr: 'شيبس بطاطس',
      nameEn: 'Potato Chips',
      descriptionAr: 'شيبس بطاطس مقرمش بنكهة الملح',
      descriptionEn: 'Crispy potato chips with salt flavor',
      icon: '🍟',
      baseUnit: {
        id: 'base',
        nameAr: '150 جرام',
        nameEn: '150 g',
        unitAr: 'كيس',
        unitEn: 'bag',
        basePrice: 4.75,
        originalPrice: null,
        stock: 2, // Low stock
        lowStockThreshold: 5,
        barcode: '123456789013',
        photo: null,
        isBase: true
      },
      additionalUnits: [
        {
          id: 'unit_2',
          nameAr: '75 جرام',
          nameEn: '75 g',
          unitAr: 'كيس صغير',
          unitEn: 'small bag',
          basePrice: 2.50,
          originalPrice: null,
          stock: 25,
          lowStockThreshold: 8,
          barcode: '123456789014',
          photo: null
        },
        {
          id: 'unit_3',
          nameAr: '300 جرام',
          nameEn: '300 g',
          unitAr: 'كيس عائلي',
          unitEn: 'family pack',
          basePrice: 8.50,
          originalPrice: 10.00,
          stock: 12,
          lowStockThreshold: 4,
          barcode: '123456789015',
          photo: null
        }
      ]
    },
    // Dairy Products
    {
      id: 8,
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
      id: 12,
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
      id: 13,
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
      id: 14,
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
      id: 15,
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
      id: 16,
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
      id: 17,
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
      id: 18,
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
      id: 19,
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
    // Get the currently selected unit with price info
    const selectedUnit = getSelectedUnit(product);
    
    // Create a cart-compatible item with standardized price fields
    const cartItem = {
      ...product,
      basePrice: selectedUnit.basePrice || product.basePrice || 0,
      originalPrice: selectedUnit.originalPrice || product.originalPrice,
      selectedUnitId: selectedUnit.id,
      selectedUnitName: currentLanguage === 'ar' ? selectedUnit.nameAr : selectedUnit.nameEn,
      unit: currentLanguage === 'ar' ? selectedUnit.unitAr : selectedUnit.unitEn,
      unitEn: selectedUnit.unitEn,
      stock: selectedUnit.stock || product.stock || 0
    };
    
    // Add item with quantity 1 to cart
    cartActions.addItem(cartItem, 1);
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
      // Get the currently selected unit with price info
      const selectedUnit = getSelectedUnit(product);
      
      // Create a cart-compatible item with standardized price fields
      const cartItem = {
        ...product,
        basePrice: selectedUnit.basePrice || product.basePrice || 0,
        originalPrice: selectedUnit.originalPrice || product.originalPrice,
        selectedUnitId: selectedUnit.id,
        selectedUnitName: currentLanguage === 'ar' ? selectedUnit.nameAr : selectedUnit.nameEn,
        unit: currentLanguage === 'ar' ? selectedUnit.unitAr : selectedUnit.unitEn,
        unitEn: selectedUnit.unitEn,
        stock: selectedUnit.stock || product.stock || 0
      };
      
      cartActions.setItemQuantity(cartItem, newQuantity);
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
          // Get the currently selected unit with price info
          const selectedUnit = getSelectedUnit(product);
          
          // Create a cart-compatible item with standardized price fields
          const cartItem = {
            ...product,
            basePrice: selectedUnit.basePrice || product.basePrice || 0,
            originalPrice: selectedUnit.originalPrice || product.originalPrice,
            selectedUnitId: selectedUnit.id,
            selectedUnitName: currentLanguage === 'ar' ? selectedUnit.nameAr : selectedUnit.nameEn,
            unit: currentLanguage === 'ar' ? selectedUnit.unitAr : selectedUnit.unitEn,
            unitEn: selectedUnit.unitEn,
            stock: selectedUnit.stock || product.stock || 0
          };
          
          cartActions.setItemQuantity(cartItem, newQuantity);
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

  <!-- VAT Notice Scrolling Bar -->
  {#if activeScrollingTexts.length > 0}
    <div class="vat-notice-container">
      <div class="vat-notice-scrolling">
        {#each activeScrollingTexts as text}
          <span class="vat-notice-text">{text}</span>
        {/each}
        {#each activeScrollingTexts as text}
          <span class="vat-notice-text">{text}</span>
        {/each}
        {#each activeScrollingTexts as text}
          <span class="vat-notice-text">{text}</span>
        {/each}
      </div>
    </div>
  {/if}

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
      {@const selectedUnit = getSelectedUnit(product)}
      <div class="product-card {isOutOfStock(product) ? 'out-of-stock' : ''}" on:click={() => !isOutOfStock(product) && goToProductDetail(product.id)}>
        <div class="product-image">
          <div class="product-icon">{product.icon}</div>
        </div>
        
        <div class="product-details">
          <div class="product-info">
            <h3>{currentLanguage === 'ar' ? product.nameAr : product.nameEn}</h3>
            
            <!-- Show selected unit size -->
            <div class="product-size">
              {currentLanguage === 'ar' ? selectedUnit.nameAr : selectedUnit.nameEn}
            </div>
            
            <div class="product-pricing">
              <div class="current-price">
                {selectedUnit.basePrice.toFixed(2)} {texts.sar}
              </div>
              {#if selectedUnit.originalPrice && selectedUnit.originalPrice > selectedUnit.basePrice}
                <div class="original-price">{selectedUnit.originalPrice.toFixed(2)} {texts.sar}</div>
              {/if}
            </div>
            
            <!-- Stock Status -->
            <div class="stock-info {isOutOfStock(product) ? 'out-of-stock' : isLowStock(product) ? 'low-stock' : 'in-stock'}">
              {getStockStatusText(product)}
            </div>
            
            <!-- Unit selection buttons - only show if multiple units available -->
            {#if hasMultipleUnits(product)}
              <div class="unit-buttons-container">
                <div class="unit-buttons">
                  {#each getAllUnits(product) as unit}
                    {@const unitStock = unit.stock || 0}
                    {@const isUnitOutOfStock = unitStock === 0}
                    {@const isUnitLowStock = unitStock > 0 && unitStock <= (unit.lowStockThreshold || 5)}
                    <button 
                      class="unit-button {selectedUnit.id === unit.id ? 'active' : ''} {isUnitOutOfStock ? 'out-of-stock' : ''}"
                      disabled={isUnitOutOfStock}
                      on:click={(e) => {
                        e.stopPropagation();
                        if (!isUnitOutOfStock) {
                          selectUnit(product.id, unit);
                        }
                      }}
                    >
                      <span class="unit-name">
                        {currentLanguage === 'ar' ? unit.nameAr : unit.nameEn}
                      </span>
                      <span class="unit-price">
                        {unit.basePrice.toFixed(2)} {texts.sar}
                      </span>
                      <span class="unit-stock {isUnitOutOfStock ? 'out-of-stock' : isUnitLowStock ? 'low-stock' : 'in-stock'}">
                        {#if isUnitOutOfStock}
                          {currentLanguage === 'ar' ? 'نفد' : 'Out'}
                        {:else if isUnitLowStock}
                          {unitStock}
                        {:else}
                          ✓
                        {/if}
                      </span>
                    </button>
                  {/each}
                </div>
              </div>
            {:else}
              <!-- Show unit type when only one unit available -->
              <div class="unit-info">
                / {currentLanguage === 'ar' ? selectedUnit.unitAr : selectedUnit.unitEn}
              </div>
            {/if}
          </div>
          
          <div class="product-actions">
            <!-- Quantity Controls -->
            <div class="quantity-controls">
              <button 
                class="quantity-btn" 
                on:click={(event) => decreaseQuantity(product.id, event)}
                disabled={(cartItemsMap.get(String(product.id)) || 0) === 0 || isOutOfStock(product)}
              >
                −
              </button>
              <span class="quantity-display">
                {cartItemsMap.get(String(product.id)) || 0}
              </span>
              <button 
                class="quantity-btn" 
                on:click={(event) => increaseQuantity(product.id, event)}
                disabled={isOutOfStock(product) || (cartItemsMap.get(String(product.id)) || 0) >= getSelectedUnitStock(product)}
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

  /* VAT Notice Scrolling Bar */
  .vat-notice-container {
    background: linear-gradient(90deg, #22c55e, #16a34a);
    padding: 0.5rem 0;
    margin-bottom: 1.5rem;
    overflow: hidden;
    border-radius: 8px;
    position: relative;
  }

  .vat-notice-scrolling {
    display: flex;
    white-space: nowrap;
    animation: scrollLeft 15s linear infinite;
  }

  .vat-notice-text {
    color: white;
    font-weight: 600;
    font-size: 0.9rem;
    margin-right: 4rem;
    flex-shrink: 0;
  }

  [dir="rtl"] .vat-notice-text {
    margin-right: 0;
    margin-left: 4rem;
  }

  [dir="rtl"] .vat-notice-scrolling {
    animation: scrollRight 15s linear infinite;
  }

  @keyframes scrollLeft {
    0% {
      transform: translateX(100%);
    }
    100% {
      transform: translateX(-100%);
    }
  }

  @keyframes scrollRight {
    0% {
      transform: translateX(-100%);
    }
    100% {
      transform: translateX(100%);
    }
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

  .unit-selector {
    margin-bottom: 0.5rem;
  }

  .unit-buttons-container {
    margin-top: 0.5rem;
  }

  .unit-buttons {
    display: flex;
    gap: 0.4rem;
    flex-wrap: wrap;
  }

  .unit-button {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 0.5rem 0.7rem;
    border: 2px solid var(--color-border);
    background: white;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    min-width: 60px;
    font-size: 0.8rem;
    position: relative;
  }

  .unit-button:hover {
    border-color: var(--color-primary);
    background: var(--color-primary-light);
    transform: translateY(-1px);
  }

  .unit-button.active {
    border-color: var(--color-primary);
    background: var(--color-primary);
    color: white;
  }

  .unit-button .unit-name {
    font-weight: 600;
    font-size: 0.85rem;
    margin-bottom: 0.2rem;
  }

  .unit-button .unit-price {
    font-size: 0.75rem;
    font-weight: 500;
    opacity: 0.8;
    margin-bottom: 0.2rem;
  }

  .unit-button .unit-stock {
    font-size: 0.7rem;
    font-weight: 600;
    padding: 0.1rem 0.3rem;
    border-radius: 4px;
    min-width: 20px;
    text-align: center;
  }

  .unit-stock.in-stock {
    background: rgba(45, 125, 50, 0.1);
    color: #2d7d32;
  }

  .unit-stock.low-stock {
    background: rgba(245, 124, 0, 0.1);
    color: #f57c00;
  }

  .unit-stock.out-of-stock {
    background: rgba(211, 47, 47, 0.1);
    color: #d32f2f;
  }

  .unit-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    background: #f5f5f5;
  }

  .unit-button:disabled:hover {
    transform: none;
    border-color: var(--color-border);
    background: #f5f5f5;
  }

  .unit-button.active .unit-name,
  .unit-button.active .unit-price {
    color: white;
  }

  .unit-button.active .unit-stock {
    background: rgba(255, 255, 255, 0.2);
    color: white;
  }

  .unit-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    color: var(--color-ink);
    margin-bottom: 0.3rem;
  }

  .unit-select {
    width: 100%;
    padding: 0.5rem 0.7rem;
    border: 2px solid var(--color-border);
    border-radius: 8px;
    background: white;
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--color-ink);
    cursor: pointer;
    transition: all 0.2s ease;
    appearance: none;
    background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg fill='%23666' height='20' viewBox='0 0 20 20' width='20' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 0.7rem center;
    background-size: 16px;
    padding-right: 2.5rem;
  }

  [dir="rtl"] .unit-select {
    background-position: left 0.7rem center;
    padding-right: 0.7rem;
    padding-left: 2.5rem;
  }

  .unit-select:hover,
  .unit-select:focus {
    border-color: var(--color-primary);
    outline: none;
    box-shadow: 0 0 0 3px rgba(var(--color-primary-rgb), 0.1);
  }

  .unit-select-inline {
    background: transparent;
    border: none;
    font-size: 0.85rem;
    color: var(--color-ink-light);
    font-style: italic;
    cursor: pointer;
    padding: 0;
    appearance: none;
    background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg fill='%23999' height='16' viewBox='0 0 20 20' width='16' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 0.2rem center;
    background-size: 12px;
    padding-right: 1.2rem;
  }

  [dir="rtl"] .unit-select-inline {
    background-position: left 0.2rem center;
    padding-right: 0;
    padding-left: 1.2rem;
  }

  .unit-select-inline:hover,
  .unit-select-inline:focus {
    color: var(--color-primary);
    outline: none;
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

  .stock-info {
    font-size: 0.8rem;
    font-weight: 600;
    padding: 0.3rem 0.5rem;
    border-radius: 6px;
    margin-bottom: 0.5rem;
    text-align: center;
  }

  .stock-info.in-stock {
    background: #e8f5e8;
    color: #2d7d32;
  }

  .stock-info.low-stock {
    background: #fff3e0;
    color: #f57c00;
  }

  .stock-info.out-of-stock {
    background: #ffebee;
    color: #d32f2f;
  }

  .product-card.out-of-stock {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .product-card.out-of-stock:hover {
    transform: none;
    border-color: var(--color-border);
    box-shadow: none;
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