<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { userStore, userActions, getCurrentUser } from '$lib/stores/user.js';
  
  let currentLanguage = 'ar';
  let videoContainer;
  let currentVideoIndex = 0;
  let isVideoHidden = false;
  let videoError = false;
  let userName = 'Guest'; // Default fallback name
  
  // Advertisement videos data (admin can upload these)
  const advertisementVideos = [
    {
      id: 1,
      src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', // Demo video
      title: 'عرض تجريبي - منتجات Urban Express',
      titleEn: 'Demo - Urban Express Products',
      duration: 15,
      fileSize: '8.2 MB',
      uploadTime: '2024-10-01 14:30'
    },
    {
      id: 2,
      src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', // Demo video
      title: 'منتجات الألبان الطازجة',
      titleEn: 'Fresh Dairy Products',
      duration: 12,
      fileSize: '6.8 MB',
      uploadTime: '2024-10-01 15:45'
    },
    {
      id: 3,
      src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', // Demo video
      title: 'خصومات كبيرة على جميع المنتجات',
      titleEn: 'Big Discounts on All Products',
      duration: 18,
      fileSize: '5.1 MB',
      uploadTime: '2024-10-01 16:20'
    }
  ];

  // Load language from localStorage
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }
    
    // Reset video error state on mount
    videoError = false;
    
    // Load user information
    userActions.loadFromStorage();
    
    // For demo purposes, if no user is set, create a demo user
    const currentUser = getCurrentUser();
    if (!currentUser.name && !currentUser.phone) {
      // You can set a demo user or prompt for login
      userActions.setUser({
        name: 'أحمد محمد', // Demo Arabic name
        phone: '+966501234567'
      });
    }
    
    // Start video rotation
    startVideoRotation();
  });

  // Listen for language changes
  function handleStorageChange(event) {
    if (event.key === 'language') {
      currentLanguage = event.newValue || 'ar';
    }
  }

  // Video rotation functionality
  function startVideoRotation() {
    if (advertisementVideos.length === 0) return;
    
    // Auto-change video after current video duration + 2 seconds buffer
    function scheduleNextVideo() {
      const currentVideo = advertisementVideos[currentVideoIndex];
      const duration = currentVideo.duration * 1000 + 2000; // Convert to ms + buffer
      
      setTimeout(() => {
        nextVideo();
        scheduleNextVideo(); // Schedule the next rotation
      }, duration);
    }
    
    scheduleNextVideo();
  }
  
  function nextVideo() {
    currentVideoIndex = (currentVideoIndex + 1) % advertisementVideos.length;
    updateVideoDisplay();
  }
  
  function updateVideoDisplay() {
    if (videoContainer) {
      const video = videoContainer.querySelector('video');
      if (video) {
        video.src = advertisementVideos[currentVideoIndex].src;
        video.load();
        video.play().catch(e => {
          console.log('Video autoplay prevented:', e);
          videoError = false; // Reset error state for autoplay issues
        });
      }
    }
  }

  function handleVideoError() {
    console.log('Video failed to load');
    // Don't show fallback content, keep video area clean
    videoError = false; // Force video error to false to prevent fallback display
  }
  
  function handleVideoClick() {
    // Navigate to products or special offers page
    goto('/products');
  }

  function hideVideo() {
    isVideoHidden = true;
    // Save preference to localStorage
    localStorage.setItem('videoHidden', 'true');
  }

  function showVideo() {
    isVideoHidden = false;
    // Remove preference from localStorage
    localStorage.removeItem('videoHidden');
  }

  // Load video visibility preference
  onMount(() => {
    const videoHiddenPref = localStorage.getItem('videoHidden');
    if (videoHiddenPref === 'true') {
      isVideoHidden = true;
    }
  });

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

  // Subscribe to user store for reactive updates
  $: userStore.subscribe(user => {
    userName = user.name || user.phone || 'Guest';
  });

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'الرئيسية - Urban Express',
    greeting: `${userName} 👋`,
    subtitle: 'اختر فئة المنتجات التي تريد التسوق منها',
    allCategories: 'جميع المنتجات',
    hideVideo: 'إخفاء الفيديو',
    showVideo: 'إظهار الفيديو'
  } : {
    title: 'Home - Urban Express',
    greeting: `${userName} 👋`,
    subtitle: 'Choose a product category to shop from',
    allCategories: 'All Products',
    hideVideo: 'Hide Video',
    showVideo: 'Show Video'
  };

  function handleCategoryClick(categoryId) {
    goto(`/products?category=${categoryId}`);
  }

  function handleAllProducts() {
    goto('/products');
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="home-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Header Section with LED Welcome Message -->
  <div class="header-section">
    <div class="led-welcome-container">
      <div class="led-border">
        <div class="welcome-content">
          <img src="/logo.png" alt="Urban Express" class="welcome-logo" />
          <h1 class="welcome-text">{texts.greeting}</h1>
        </div>
      </div>
    </div>
  </div>

  <!-- Advertisement Video Section (LED Screen Style) -->
  {#if !isVideoHidden}
    <div class="advertisement-section" bind:this={videoContainer}>
      <div class="led-screen-container">
        <div class="led-frame">
          <div class="video-content">
            {#if !videoError}
              <video 
                autoplay 
                muted 
                loop
                playsinline
                on:click={handleVideoClick}
                on:error={handleVideoError}
                src={advertisementVideos[currentVideoIndex]?.src}
              >
                <source src={advertisementVideos[currentVideoIndex]?.src} type="video/mp4">
                Your browser does not support the video tag.
              </video>
            {:else}
              <!-- Fallback content when video fails to load -->
              <div class="video-fallback" on:click={handleVideoClick}>
                <div class="fallback-content">
                  <div class="fallback-icon">📺</div>
                  <div class="fallback-title">
                    {currentLanguage === 'ar' 
                      ? advertisementVideos[currentVideoIndex]?.title 
                      : advertisementVideos[currentVideoIndex]?.titleEn}
                  </div>
                  <div class="fallback-subtitle">
                    {currentLanguage === 'ar' ? 'انقر للمشاهدة' : 'Click to Watch'}
                  </div>
                </div>
                <div class="fallback-background"></div>
              </div>
            {/if}
            
            <!-- Video Size Info Only -->
            <div class="video-size-info">
              <div class="size-display">1080 × 1920</div>
              <div class="aspect-ratio">9:16 Vertical</div>
            </div>
            
            <!-- Video Details Info -->
            <div class="video-details-info">
              <div class="duration-info">
                Duration: {advertisementVideos[currentVideoIndex]?.duration}s / 20s max
              </div>
              <div class="file-info">
                Size: {advertisementVideos[currentVideoIndex]?.fileSize}
              </div>
              <div class="format-info">
                Format: 9:16 Vertical (TikTok/Reels)
              </div>
              <div class="time-info">
                Uploaded: {advertisementVideos[currentVideoIndex]?.uploadTime}
              </div>
            </div>
            
            <!-- Next Button -->
            <button class="next-btn" on:click={nextVideo} title="Next Video">
              <span>▶</span>
            </button>

            <!-- Hide Button -->
            <button class="hide-btn" on:click={hideVideo} title={texts.hideVideo}>
              <span>✕</span>
            </button>
            
            <!-- LED Screen Effects -->
            <div class="led-dots"></div>
            <div class="screen-glow"></div>
          </div>
        </div>
      </div>
    </div>
  {:else}
    <!-- Show Video Button when hidden -->
    <div class="show-video-section">
      <button class="show-video-btn" on:click={showVideo}>
        <span class="video-icon">📺</span>
        <span>{texts.showVideo}</span>
      </button>
    </div>
  {/if}

  <!-- Category Selection Section -->
  <div class="category-selection-section">
    <p class="category-subtitle">{texts.subtitle}</p>
    <!-- All Products Button -->
    <button class="all-products-btn" on:click={handleAllProducts}>
      <div class="btn-icon">🛒</div>
      <span>{texts.allCategories}</span>
    </button>
  </div>

  <!-- Categories Grid -->
  <div class="categories-grid">
    {#each categories as category}
      <button 
        class="category-card" 
        on:click={() => handleCategoryClick(category.id)}
      >
        <div class="category-icon">{category.icon}</div>
        <h3>{currentLanguage === 'ar' ? category.nameAr : category.nameEn}</h3>
      </button>
    {/each}
  </div>
</div>

<style>
  .home-container {
    padding: 1rem;
    padding-top: calc(60px + 1rem); /* Increased padding to ensure clear separation from TopBar */
    max-width: 100%;
    margin: 0 auto;
    min-height: 100vh;
  }

  .header-section {
    text-align: center;
    margin-bottom: 1.5rem;
    padding: 1rem 0; /* Increased padding for better visibility */
    width: 100%;
  }

  .led-welcome-container {
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 0 auto 1.5rem auto; /* Center and add bottom margin */
    padding: 0 1rem;
    width: 100%;
    max-width: 800px; /* Increased maximum width for better presence */
  }

  .led-border {
    position: relative;
    width: min(500px, 95vw); /* Significantly wider for better presence */
    height: 100px; /* Taller to accommodate larger content */
    border-radius: 25px; /* Larger border radius for proportional scaling */
    padding: 12px; /* More padding for better content spacing */
    background: linear-gradient(45deg, 
      #4CAF50 0%, 
      #4CAF50 25%, 
      #FF9800 50%, 
      #FF9800 75%, 
      #4CAF50 100%
    );
    background-size: 400% 400%;
    animation: ledGlow 3s ease-in-out infinite;
    box-shadow: 
      0 0 35px rgba(76, 175, 80, 0.5),
      0 0 70px rgba(255, 152, 0, 0.3),
      inset 0 0 25px rgba(255, 255, 255, 0.15);
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto; /* Ensure perfect centering */
  }

  .led-border::before {
    content: '';
    position: absolute;
    top: 5px; /* Adjusted for larger border */
    left: 5px;
    right: 5px;
    bottom: 5px;
    border-radius: 20px; /* Adjusted for new border radius */
    background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
    z-index: 1;
  }

  .welcome-content {
    position: relative;
    z-index: 2;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem; /* Increased gap for wider container */
    width: 100%;
    height: 100%;
    padding: 0 0.75rem; /* More padding for larger container */
  }

  .welcome-logo {
    width: 50px; /* Larger logo for wider container */
    height: 50px;
    object-fit: contain;
    border-radius: 10px; /* Larger border radius */
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
    flex-shrink: 0; /* Prevent logo from shrinking */
  }

  .welcome-text {
    font-size: clamp(1.3rem, 4.5vw, 1.8rem); /* Larger text for wider container */
    font-weight: 700;
    color: var(--color-primary);
    margin: 0;
    text-align: center;
    line-height: 1.2;
    white-space: nowrap; /* Prevent text wrapping */
    overflow: hidden;
    text-overflow: ellipsis;
    background: linear-gradient(45deg, var(--color-primary), var(--color-accent));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    filter: drop-shadow(0 3px 6px rgba(0, 0, 0, 0.15));
  }

  @keyframes ledGlow {
    0% {
      background-position: 0% 50%;
      box-shadow: 
        0 0 35px rgba(76, 175, 80, 0.8),
        0 0 70px rgba(76, 175, 80, 0.5),
        inset 0 0 25px rgba(255, 255, 255, 0.15);
    }
    50% {
      background-position: 100% 50%;
      box-shadow: 
        0 0 35px rgba(255, 152, 0, 0.8),
        0 0 70px rgba(255, 152, 0, 0.5),
        inset 0 0 25px rgba(255, 255, 255, 0.15);
    }
    100% {
      background-position: 0% 50%;
      box-shadow: 
        0 0 35px rgba(76, 175, 80, 0.8),
        0 0 70px rgba(76, 175, 80, 0.5),
        inset 0 0 25px rgba(255, 255, 255, 0.15);
    }
  }

  /* Advertisement LED Screen Styles */
  .advertisement-section {
    margin: 1rem 0 2rem 0;
    padding: 0;
  }

  .led-screen-container {
    position: relative;
    width: 100%;
    max-width: 300px; /* Narrower for 9:16 aspect ratio */
    margin: 0 auto;
  }

  .led-frame {
    position: relative;
    background: #000; /* Solid black background to prevent white bar */
    padding: 8px; /* Reduced padding to minimize white space */
    border-radius: 20px;
    box-shadow: 
      0 0 30px rgba(0, 0, 0, 0.5);
    border: 2px solid #333;
  }

  /* LED border removed from LCD screen - only for welcome message */

  @keyframes ledGlow {
    from { 
      box-shadow: 0 0 10px #00ff88, inset 0 0 10px #00ff88; 
      opacity: 0.6;
    }
    to { 
      box-shadow: 0 0 20px #00ff88, inset 0 0 15px #00ff88; 
      opacity: 1;
    }
  }

  .video-content {
    position: relative;
    width: 100%;
    height: 480px; /* 9:16 aspect ratio height for mobile-first */
    aspect-ratio: 9/16; /* CSS aspect ratio for consistent 9:16 */
    border-radius: 12px;
    overflow: hidden;
    background: #000 !important; /* Ensure solid black background */
    isolation: isolate; /* Create new stacking context */
    margin: 0; /* Remove any margin */
    padding: 0; /* Remove any padding */
  }

  .video-content video {
    width: 100%;
    height: 100%;
    object-fit: cover;
    cursor: pointer;
    transition: transform 0.3s ease;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 1; /* Ensure video is behind overlay elements */
    border-radius: 12px; /* Match container border radius */
  }

  .video-content:hover video {
    transform: scale(1.02);
  }

  .video-fallback {
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    left: 0;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent; /* Make fallback transparent */
    transition: transform 0.3s ease;
    z-index: -1; /* Put fallback behind video */
  }

  .video-fallback:hover {
    transform: scale(1.02);
  }

  .fallback-content {
    display: none; /* Hide fallback content completely */
    text-align: center;
    z-index: 2;
    color: #00ff88;
  }

  .fallback-icon {
    font-size: 4rem;
    margin-bottom: 1rem;
    opacity: 0.8;
  }

  .fallback-title {
    font-size: 1.2rem;
    font-weight: bold;
    margin-bottom: 0.5rem;
    text-shadow: 0 0 10px #00ff88;
  }

  .fallback-subtitle {
    font-size: 0.9rem;
    opacity: 0.7;
    font-style: italic;
  }

  .fallback-background {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: transparent; /* Remove interfering background */
    z-index: 1;
  }

  .video-size-info {
    display: none; /* Hide for production - these are development info panels */
    position: absolute;
    top: 1rem;
    right: 1rem;
    background: rgba(0, 0, 0, 0.8);
    color: #00ff88;
    padding: 0.5rem 1rem;
    border-radius: 8px;
    font-family: 'Courier New', monospace;
    font-size: 0.8rem;
    font-weight: bold;
    border: 1px solid #00ff88;
    box-shadow: 0 0 10px rgba(0, 255, 136, 0.3);
    z-index: 10;
    text-align: center;
  }

  .aspect-ratio {
    font-size: 0.7rem;
    opacity: 0.8;
    margin-top: 0.25rem;
  }

  .video-details-info {
    display: none; /* Hide for production - these are development info panels */
    position: absolute;
    bottom: 1rem;
    left: 1rem;
    background: rgba(0, 0, 0, 0.9);
    color: #00ff88;
    padding: 0.75rem;
    border-radius: 8px;
    font-family: 'Courier New', monospace;
    font-size: 0.7rem;
    font-weight: bold;
    border: 1px solid #00ff88;
    box-shadow: 0 0 10px rgba(0, 255, 136, 0.3);
    z-index: 10;
    line-height: 1.4;
  }

  .duration-info, .file-info, .time-info, .format-info {
    margin-bottom: 0.25rem;
    text-shadow: 0 0 3px #00ff88;
  }

  .format-info {
    color: #ff6b6b;
    text-shadow: 0 0 3px #ff6b6b;
  }

  .time-info {
    margin-bottom: 0;
    opacity: 0.8;
  }

  .next-btn {
    position: absolute;
    top: 50%;
    right: 1rem;
    transform: translateY(-50%);
    background: rgba(0, 255, 136, 0.2);
    color: #00ff88;
    border: 2px solid #00ff88;
    border-radius: 50%;
    width: 50px;
    height: 50px;
    font-size: 1.2rem;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 5;
    backdrop-filter: blur(10px);
    box-shadow: 0 0 15px rgba(0, 255, 136, 0.4);
  }

  .hide-btn {
    position: absolute;
    top: 1rem;
    left: 1rem;
    background: rgba(255, 107, 107, 0.2);
    color: #ff6b6b;
    border: 2px solid #ff6b6b;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 5;
    backdrop-filter: blur(10px);
    box-shadow: 0 0 15px rgba(255, 107, 107, 0.4);
  }

  .hide-btn:hover {
    background: rgba(255, 107, 107, 0.4);
    transform: scale(1.1);
    box-shadow: 0 0 20px rgba(255, 107, 107, 0.6);
  }

  .hide-btn span {
    text-shadow: 0 0 5px #ff6b6b;
    font-weight: bold;
  }

  .next-btn:hover {
    background: rgba(0, 255, 136, 0.4);
    transform: translateY(-50%) scale(1.1);
    box-shadow: 0 0 20px rgba(0, 255, 136, 0.6);
  }

  .next-btn span {
    text-shadow: 0 0 5px #00ff88;
    margin-left: 2px; /* Slight offset for play icon */
  }

  .size-display {
    text-shadow: 0 0 5px #00ff88;
  }

  /* Show Video Section Styles */
  .show-video-section {
    margin: 2rem 0;
    padding: 0;
    text-align: center;
  }

  .show-video-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
    padding: 1rem 2rem;
    background: linear-gradient(45deg, #1a1a1a, #2d2d2d);
    color: #00ff88;
    border: 2px solid #00ff88;
    border-radius: 12px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 0 20px rgba(0, 255, 136, 0.3);
    text-shadow: 0 0 5px #00ff88;
  }

  .show-video-btn:hover {
    background: linear-gradient(45deg, #2d2d2d, #1a1a1a);
    transform: translateY(-2px);
    box-shadow: 0 0 30px rgba(0, 255, 136, 0.5);
  }

  .video-icon {
    font-size: 1.2rem;
    filter: brightness(1.2);
  }

  .led-dots {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image: 
      radial-gradient(circle at 2px 2px, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
    background-size: 8px 8px;
    pointer-events: none;
    opacity: 0.1; /* Reduced opacity to be less intrusive */
    z-index: 2; /* Above video but below buttons */
  }

  .screen-glow {
    position: absolute;
    top: -5px;
    left: -5px;
    right: -5px;
    bottom: -5px;
    background: linear-gradient(45deg, #00ff88, #0088ff, #ff0088, #00ff88);
    border-radius: 16px;
    opacity: 0.2;
    filter: blur(8px);
    z-index: -1;
    animation: screenGlow 3s ease-in-out infinite;
  }

  @keyframes screenGlow {
    0%, 100% { opacity: 0.2; }
    50% { opacity: 0.4; }
  }

  .category-selection-section {
    margin-bottom: 1.5rem;
  }

  .category-subtitle {
    font-size: 1rem;
    color: var(--color-ink-light);
    line-height: 1.5;
    text-align: center;
    margin-bottom: 1rem;
    margin-top: 0;
  }

  .all-products-btn {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
    padding: 1rem;
    background: var(--color-primary);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 1.1rem;
    font-weight: 600;
    margin-bottom: 1.5rem;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .all-products-btn:hover {
    background: var(--color-primary-dark);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .btn-icon {
    font-size: 1.5rem;
  }

  .categories-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
  }

  .category-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 1.5rem 1rem;
    background: white;
    border: 2px solid var(--color-border);
    border-radius: 16px;
    cursor: pointer;
    transition: all 0.2s ease;
    text-decoration: none;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    min-height: 120px;
  }

  .category-card:hover {
    border-color: var(--color-primary);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .category-icon {
    font-size: 2.5rem;
    margin-bottom: 0.75rem;
  }

  .category-card h3 {
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--color-ink);
    text-align: center;
    line-height: 1.3;
    margin: 0;
  }

  /* Mobile optimizations */
  @media (max-width: 480px) {
    .home-container {
      padding: 0.75rem;
      padding-top: calc(60px + 0.75rem); /* Adequate mobile padding to clear TopBar */
    }

    .header-section {
      padding: 0.75rem 0; /* Better mobile spacing */
      margin-bottom: 1rem;
    }

    .led-welcome-container {
      padding: 0 0.5rem; /* Tighter mobile padding */
      max-width: 100%; /* Full width on mobile */
    }

    .led-border {
      width: min(420px, 90vw); /* Wider responsive width for mobile */
      height: 85px; /* Proportional height for mobile */
      border-radius: 20px;
      padding: 10px;
      margin: 0 auto; /* Force centering on mobile */
    }

    .welcome-logo {
      width: 38px; /* Proportionally larger for mobile */
      height: 38px;
    }

    .welcome-content {
      gap: 0.75rem; /* Proportional gap on mobile */
      padding: 0 0.5rem;
    }

    .led-border::before {
      top: 4px;
      left: 4px;
      right: 4px;
      bottom: 4px;
      border-radius: 16px;
    }

    .welcome-text {
      font-size: clamp(1.1rem, 4vw, 1.4rem); /* Larger mobile text scaling */
    }

    .advertisement-section {
      margin: 1rem 0 1.5rem 0;
    }

    .led-screen-container {
      max-width: 250px;
    }

    .video-content {
      height: 400px; /* Smaller height for mobile */
    }

    .video-details-info {
      font-size: 0.6rem;
      padding: 0.5rem;
      bottom: 0.5rem;
      left: 0.5rem;
    }

    .video-size-info {
      font-size: 0.7rem;
      padding: 0.4rem 0.75rem;
      top: 0.5rem;
      right: 0.5rem;
    }

    .next-btn {
      width: 40px;
      height: 40px;
      font-size: 1rem;
      right: 0.5rem;
    }

    .hide-btn {
      width: 35px;
      height: 35px;
      font-size: 0.9rem;
      top: 0.5rem;
      left: 0.5rem;
    }

    .show-video-btn {
      padding: 0.75rem 1.5rem;
      font-size: 0.9rem;
    }

    .led-frame {
      padding: 6px; /* Minimal padding for mobile */
      margin: 0 auto; /* Center the LED frame */
    }

    .category-card {
      padding: 1.25rem 0.75rem;
      min-height: 110px;
    }

    .category-icon {
      font-size: 2.25rem;
      margin-bottom: 0.5rem;
    }

    .category-card h3 {
      font-size: 0.85rem;
    }
  }

  /* Tablet and larger screens */
  @media (min-width: 768px) {
    .home-container {
      max-width: 800px;
      padding: 2rem;
      padding-top: calc(60px + 2rem); /* Proper tablet padding to clear TopBar */
    }

    .header-section {
      padding: 1rem 0; /* Better tablet spacing */
      margin-bottom: 1.5rem;
    }

    .led-welcome-container {
      padding: 0 2rem; /* More generous tablet padding */
      max-width: 900px; /* Larger limit width for better proportions */
    }

    .led-border {
      width: min(550px, 85vw); /* Wider and responsive on tablets */
      height: 110px; /* Taller for better proportions */
      border-radius: 28px;
      padding: 14px;
    }

    .welcome-logo {
      width: 58px; /* Larger tablet logo */
      height: 58px;
    }

    .welcome-content {
      gap: 1.25rem; /* More generous gap on tablet */
      padding: 0 1rem;
    }

    .led-border::before {
      top: 6px;
      left: 6px;
      right: 6px;
      bottom: 6px;
      border-radius: 22px;
    }

    .welcome-text {
      font-size: clamp(1.5rem, 3.5vw, 2rem); /* Larger tablet scaling */
    }

    .led-screen-container {
      max-width: 600px;
    }

    .led-screen-container {
      max-width: 350px;
    }

    .video-content {
      height: 560px; /* Larger height for tablet */
    }

    .video-details-info {
      font-size: 0.75rem;
    }

    .video-size-info {
      font-size: 0.9rem;
    }

    .next-btn {
      width: 55px;
      height: 55px;
      font-size: 1.3rem;
    }

    .hide-btn {
      width: 45px;
      height: 45px;
      font-size: 1.1rem;
    }

    .categories-grid {
      grid-template-columns: repeat(3, 1fr);
      gap: 1.5rem;
    }

    .category-card {
      padding: 2rem 1.5rem;
      min-height: 140px;
    }

    .category-icon {
      font-size: 3rem;
      margin-bottom: 1rem;
    }

    .category-card h3 {
      font-size: 1rem;
    }
  }

  @media (min-width: 1024px) {
    .led-welcome-container {
      max-width: 1000px; /* Even larger for desktop */
    }

    .led-border {
      width: min(600px, 80vw); /* Maximum width for desktop */
      height: 120px; /* Tallest for desktop */
      border-radius: 30px;
      padding: 16px;
    }

    .welcome-logo {
      width: 65px; /* Largest logo for desktop */
      height: 65px;
      border-radius: 12px;
    }

    .welcome-content {
      gap: 1.5rem; /* Maximum gap for desktop */
      padding: 0 1.25rem;
    }

    .led-border::before {
      top: 7px;
      left: 7px;
      right: 7px;
      bottom: 7px;
      border-radius: 23px;
    }

    .welcome-text {
      font-size: clamp(1.7rem, 3vw, 2.2rem); /* Largest text for desktop */
    }

    .led-screen-container {
      max-width: 400px;
    }

    .video-content {
      height: 640px; /* Full size for desktop */
    }

    .video-details-info {
      font-size: 0.8rem;
      padding: 1rem;
    }

    .video-size-info {
      font-size: 1rem;
      padding: 0.6rem 1.2rem;
    }

    .next-btn {
      width: 60px;
      height: 60px;
      font-size: 1.4rem;
    }

    .hide-btn {
      width: 50px;
      height: 50px;
      font-size: 1.2rem;
    }

    .categories-grid {
      grid-template-columns: repeat(4, 1fr);
    }
  }
</style>