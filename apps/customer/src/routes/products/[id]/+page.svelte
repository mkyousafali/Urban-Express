<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import { cartActions } from '$lib/stores/cart.js';
  
  let currentLanguage = 'ar';
  let quantity = 1;
  let product = null;
  
  // Sample products data (in real app, this would come from API)
  const products = [
    {
      id: 3,
      category: 'dairy',
      nameAr: 'المراعي كريمة طبخ كاملة الدسم 500 مل',
      nameEn: 'Almarai Cooking Cream Full Fat-500ML',
      descriptionAr: 'كريمة طبخ فاخرة من المراعي',
      descriptionEn: 'Premium cooking cream from Almarai',
      basePrice: 13.25,
      originalPrice: 17.50,
      unit: 'حبة',
      unitEn: 'pieces',
      image: '/products/almarai-cooking-cream.jpg', // You can replace with actual image
      icon: '🥛'
    }
    // Add more products as needed
  ];

  // Load language from localStorage
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }

    // Get product ID from URL and find product
    const productId = parseInt($page.params.id);
    product = products.find(p => p.id === productId);
    
    if (!product) {
      // If product not found, redirect to products page
      goto('/products');
    }
  });

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

  $: texts = currentLanguage === 'ar' ? {
    addToCart: 'أضف للسلة',
    sar: 'ر.س'
  } : {
    addToCart: 'Add to Cart',
    sar: 'SAR'
  };

  function decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  function increaseQuantity() {
    quantity++;
  }

  function addToCart() {
    cartActions.addItem(product, quantity);
    // Optional: Show success message or redirect
    console.log(`Added ${quantity} ${product.nameEn} to cart`);
  }
</script>

<svelte:head>
  <title>{product ? (currentLanguage === 'ar' ? product.nameAr : product.nameEn) : 'Product'}</title>
</svelte:head>

{#if product}
<div class="product-detail-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="product-card">
    <!-- Product Image -->
    <div class="product-image">
      <div class="image-placeholder">
        <!-- For now using a colored background, replace with actual product image -->
        <div class="product-icon">{product.icon}</div>
        <div class="brand-badge">
          <span class="brand-name">المراعي</span>
          <span class="brand-name-en">Almarai</span>
        </div>
        <div class="product-package">
          <div class="package-text">COOKING</div>
          <div class="package-text">CREAM</div>
          <div class="fat-badge">Fat</div>
          <div class="volume">500ML</div>
        </div>
        <div class="product-visual">
          <!-- Cream visual representation -->
          <div class="cream-bowl"></div>
        </div>
      </div>
    </div>

    <!-- Product Info -->
    <div class="product-info">
      <h1 class="product-title">{currentLanguage === 'ar' ? product.nameAr : product.nameEn}</h1>
      
      <div class="pricing">
        <div class="current-price">{product.basePrice.toFixed(2)} {texts.sar}</div>
        {#if product.originalPrice}
          <div class="original-price">{product.originalPrice.toFixed(2)} {texts.sar}</div>
        {/if}
      </div>

      <div class="unit">/{currentLanguage === 'ar' ? product.unit : product.unitEn}</div>

      <!-- Quantity Selector -->
      <div class="quantity-section">
        <div class="quantity-controls">
          <button class="quantity-btn" on:click={decreaseQuantity}>−</button>
          <div class="quantity-display">{quantity}</div>
          <button class="quantity-btn" on:click={increaseQuantity}>+</button>
        </div>
      </div>

      <!-- Add to Cart Button -->
      <Button 
        variant="primary" 
        size="lg" 
        fullWidth={true}
        on:click={addToCart}
      >
        {texts.addToCart}
      </Button>
    </div>
  </div>
</div>
{/if}

<style>
  .product-detail-container {
    padding: 1rem;
    max-width: 500px;
    margin: 0 auto;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .product-card {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px;
  }

  .product-image {
    margin-bottom: 2rem;
  }

  .image-placeholder {
    width: 100%;
    height: 300px;
    background: linear-gradient(135deg, #8BC34A, #4CAF50);
    border-radius: 12px;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }

  .product-icon {
    position: absolute;
    top: 1rem;
    left: 1rem;
    font-size: 2rem;
    background: rgba(255, 255, 255, 0.9);
    padding: 0.5rem;
    border-radius: 8px;
  }

  .brand-badge {
    position: absolute;
    top: 1rem;
    right: 1rem;
    background: #2196F3;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 8px;
    text-align: center;
  }

  .brand-name {
    display: block;
    font-weight: bold;
    font-size: 0.9rem;
  }

  .brand-name-en {
    display: block;
    font-size: 0.8rem;
  }

  .package-text {
    color: white;
    font-size: 1.5rem;
    font-weight: bold;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  }

  .fat-badge {
    background: #FF9800;
    color: white;
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: bold;
    margin: 0.5rem 0;
    display: inline-block;
  }

  .volume {
    color: white;
    font-size: 1.2rem;
    font-weight: bold;
    margin-top: 0.5rem;
  }

  .cream-bowl {
    position: absolute;
    bottom: 1rem;
    left: 50%;
    transform: translateX(-50%);
    width: 120px;
    height: 60px;
    background: white;
    border-radius: 50%;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  }

  .product-info {
    text-align: center;
  }

  .product-title {
    font-size: 1.4rem;
    font-weight: 700;
    color: var(--color-ink);
    margin-bottom: 1.5rem;
    line-height: 1.3;
  }

  .pricing {
    margin-bottom: 0.5rem;
  }

  .current-price {
    font-size: 2rem;
    font-weight: 700;
    color: #4CAF50;
    margin-bottom: 0.25rem;
  }

  .original-price {
    font-size: 1rem;
    color: var(--color-ink-light);
    text-decoration: line-through;
  }

  .unit {
    color: var(--color-ink-light);
    font-size: 1rem;
    margin-bottom: 2rem;
  }

  .quantity-section {
    margin-bottom: 2rem;
  }

  .quantity-controls {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .quantity-btn {
    width: 50px;
    height: 50px;
    border: 2px solid var(--color-border);
    background: white;
    border-radius: 8px;
    font-size: 1.5rem;
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

  .quantity-display {
    font-size: 1.5rem;
    font-weight: bold;
    color: var(--color-ink);
    min-width: 60px;
    text-align: center;
    padding: 0.75rem;
    border: 2px solid var(--color-border);
    border-radius: 8px;
    background: white;
  }

  /* Mobile optimizations */
  @media (max-width: 480px) {
    .product-detail-container {
      padding: 0.5rem;
    }

    .product-card {
      padding: 1.5rem;
    }

    .image-placeholder {
      height: 250px;
    }

    .product-title {
      font-size: 1.2rem;
    }

    .current-price {
      font-size: 1.75rem;
    }
  }
</style>