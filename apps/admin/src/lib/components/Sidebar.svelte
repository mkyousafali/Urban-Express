<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  
  let currentLanguage = 'ar';
  let isCollapsed = false;
  
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }
    
    // Check for saved sidebar state
    const savedSidebarState = localStorage.getItem('sidebarCollapsed');
    if (savedSidebarState) {
      isCollapsed = JSON.parse(savedSidebarState);
    }
  });
  
  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    dashboard: 'لوحة التحكم',
    products: 'المنتجات',
    inventory: 'المخزون',
    orders: 'الطلبات',
    orderControl: 'مركز التحكم',
    offers: 'العروض',
    branches: 'الفروع',
    customerRequests: 'طلبات العملاء',
    notifications: 'الإشعارات',
    scrollingBanner: 'البانر المتحرك',
    settings: 'الإعدادات',
    logout: 'تسجيل الخروج',
    collapse: 'طي',
    expand: 'توسيع'
  } : {
    dashboard: 'Dashboard',
    products: 'Products',
    inventory: 'Inventory',
    orders: 'Orders',
    orderControl: 'Order Control',
    offers: 'Offers',
    branches: 'Branches',
    customerRequests: 'Customer Requests',
    notifications: 'Notifications',
    scrollingBanner: 'Scrolling Banner',
    settings: 'Settings',
    logout: 'Logout',
    collapse: 'Collapse',
    expand: 'Expand'
  };
  
  // Navigation items
  $: navItems = [
    { 
      href: '/', 
      icon: '📊', 
      label: texts.dashboard,
      active: $page.url.pathname === '/'
    },
    { 
      href: '/products', 
      icon: '🛍️', 
      label: texts.products,
      active: $page.url.pathname === '/products'
    },
    { 
      href: '/inventory', 
      icon: '📦', 
      label: texts.inventory,
      active: $page.url.pathname === '/inventory'
    },
    { 
      href: '/order-control', 
      icon: '🎛️', 
      label: texts.orderControl,
      active: $page.url.pathname === '/order-control'
    },
    { 
      href: '/offers', 
      icon: '🏷️', 
      label: texts.offers,
      active: $page.url.pathname === '/offers'
    },
    { 
      href: '/branches', 
      icon: '🏪', 
      label: texts.branches,
      active: $page.url.pathname === '/branches'
    },
    { 
      href: '/customer-requests', 
      icon: '👥', 
      label: texts.customerRequests,
      active: $page.url.pathname === '/customer-requests'
    },
    { 
      href: '/notifications', 
      icon: '🔔', 
      label: texts.notifications,
      active: $page.url.pathname === '/notifications'
    },
    { 
      href: '/scrolling-banner', 
      icon: '📢', 
      label: texts.scrollingBanner,
      active: $page.url.pathname === '/scrolling-banner'
    }
  ];
  
  function toggleSidebar() {
    isCollapsed = !isCollapsed;
    localStorage.setItem('sidebarCollapsed', JSON.stringify(isCollapsed));
  }
  
  function switchLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
    localStorage.setItem('language', currentLanguage);
    document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = currentLanguage;
    window.location.reload();
  }
</script>

<aside class="sidebar" class:collapsed={isCollapsed} dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <!-- Sidebar Header -->
  <div class="sidebar-header">
    <div class="logo">
      {#if !isCollapsed}
        <h2>Urban Express</h2>
        <span class="admin-badge">{currentLanguage === 'ar' ? 'إدارة' : 'Admin'}</span>
      {:else}
        <span class="logo-icon">🚚</span>
      {/if}
    </div>
    <button class="toggle-btn" on:click={toggleSidebar} title={isCollapsed ? texts.expand : texts.collapse}>
      {#if currentLanguage === 'ar'}
        {isCollapsed ? '◀' : '▶'}
      {:else}
        {isCollapsed ? '▶' : '◀'}
      {/if}
    </button>
  </div>

  <!-- Navigation -->
  <nav class="sidebar-nav">
    <ul class="nav-list">
      {#each navItems as item}
        <li class="nav-item">
          <a 
            href={item.href} 
            class="nav-link"
            class:active={item.active}
            title={isCollapsed ? item.label : ''}
          >
            <span class="nav-icon">{item.icon}</span>
            {#if !isCollapsed}
              <span class="nav-label">{item.label}</span>
            {/if}
            {#if item.active}
              <span class="active-indicator"></span>
            {/if}
          </a>
        </li>
      {/each}
    </ul>
  </nav>

  <!-- Sidebar Footer -->
  <div class="sidebar-footer">
    <button class="lang-toggle" on:click={switchLanguage} title={currentLanguage === 'ar' ? 'English' : 'عربي'}>
      {#if !isCollapsed}
        {currentLanguage === 'ar' ? 'EN' : 'عربي'}
      {:else}
        🌐
      {/if}
    </button>
    
    {#if !isCollapsed}
      <button class="logout-btn" title={texts.logout}>
        🚪 {texts.logout}
      </button>
    {:else}
      <button class="logout-btn collapsed" title={texts.logout}>
        🚪
      </button>
    {/if}
  </div>
</aside>

<style>
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    height: 100vh;
    width: 280px;
    background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
    color: white;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
    z-index: 1000;
    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
  }

  .sidebar.collapsed {
    width: 70px;
  }

  .sidebar-header {
    padding: 1.5rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 80px;
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .logo h2 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 700;
    color: #ecf0f1;
  }

  .admin-badge {
    background: #e74c3c;
    color: white;
    padding: 0.25rem 0.5rem;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 600;
  }

  .logo-icon {
    font-size: 1.5rem;
  }

  .toggle-btn {
    background: rgba(255, 255, 255, 0.1);
    border: none;
    color: white;
    width: 32px;
    height: 32px;
    border-radius: 6px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s ease;
    font-size: 0.875rem;
  }

  .toggle-btn:hover {
    background: rgba(255, 255, 255, 0.2);
  }

  .sidebar-nav {
    flex: 1;
    padding: 1rem 0;
    overflow-y: auto;
  }

  .nav-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .nav-item {
    margin: 0.25rem 0;
  }

  .nav-link {
    display: flex;
    align-items: center;
    padding: 0.75rem 1.5rem;
    color: #bdc3c7;
    text-decoration: none;
    transition: all 0.2s ease;
    position: relative;
    border-radius: 0 25px 25px 0;
    margin-right: 1rem;
  }

  .collapsed .nav-link {
    padding: 0.75rem;
    margin: 0.25rem;
    border-radius: 8px;
    justify-content: center;
  }

  .nav-link:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #ecf0f1;
    transform: translateX(5px);
  }

  .collapsed .nav-link:hover {
    transform: none;
  }

  .nav-link.active {
    background: rgba(255, 255, 255, 0.15);
    color: #3498db;
    font-weight: 600;
  }

  .nav-icon {
    font-size: 1.25rem;
    width: 24px;
    text-align: center;
    margin-right: 1rem;
  }

  .collapsed .nav-icon {
    margin-right: 0;
  }

  .nav-label {
    font-size: 0.9rem;
    font-weight: 500;
  }

  .active-indicator {
    position: absolute;
    right: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 4px;
    height: 20px;
    background: #3498db;
    border-radius: 2px 0 0 2px;
  }

  .collapsed .active-indicator {
    display: none;
  }

  .sidebar-footer {
    padding: 1rem;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .lang-toggle, .logout-btn {
    background: rgba(255, 255, 255, 0.1);
    border: none;
    color: white;
    padding: 0.75rem;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    font-size: 0.875rem;
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
  }

  .lang-toggle:hover, .logout-btn:hover {
    background: rgba(255, 255, 255, 0.2);
  }

  .logout-btn.collapsed {
    padding: 0.75rem;
  }

  /* RTL Support */
  [dir="rtl"] .sidebar {
    left: auto;
    right: 0;
  }

  [dir="rtl"] .nav-link {
    border-radius: 25px 0 0 25px;
    margin-right: 0;
    margin-left: 1rem;
  }

  [dir="rtl"] .collapsed .nav-link {
    margin: 0.25rem;
  }

  [dir="rtl"] .nav-link:hover {
    transform: translateX(-5px);
  }

  [dir="rtl"] .nav-icon {
    margin-right: 0;
    margin-left: 1rem;
  }

  [dir="rtl"] .collapsed .nav-icon {
    margin-left: 0;
  }

  [dir="rtl"] .active-indicator {
    right: auto;
    left: 0;
    border-radius: 0 2px 2px 0;
  }

  /* Mobile responsive */
  @media (max-width: 768px) {
    .sidebar {
      transform: translateX(-100%);
    }

    .sidebar.collapsed {
      transform: translateX(-100%);
    }

    [dir="rtl"] .sidebar {
      transform: translateX(100%);
    }

    [dir="rtl"] .sidebar.collapsed {
      transform: translateX(100%);
    }
  }

  /* Scrollbar styling */
  .sidebar-nav::-webkit-scrollbar {
    width: 4px;
  }

  .sidebar-nav::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.1);
  }

  .sidebar-nav::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.3);
    border-radius: 2px;
  }

  .sidebar-nav::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.5);
  }
</style>