<script>
  import { onMount } from 'svelte';
  
  let currentLanguage = 'ar';
  
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
    title: 'لوحة التحكم الإدارية',
    dashboard: 'الرئيسية',
    products: 'المنتجات',
    inventory: 'المخزون',
    orders: 'الطلبات',
    orderControl: 'مركز التحكم في الطلبات',
    offers: 'العروض',
    offersManagement: 'إدارة العروض',
    branches: 'الفروع',
    branchManagement: 'إدارة الفروع',
    customerRequests: 'طلبات العملاء',
    customerManagement: 'إدارة طلبات العملاء',
    notifications: 'الإشعارات',
    scrollingBanner: 'البانر المتحرك',
    settings: 'الإعدادات',
    logout: 'تسجيل الخروج'
  } : {
    title: 'Admin Dashboard',
    dashboard: 'Dashboard',
    products: 'Products',
    inventory: 'Inventory',
    orders: 'Orders',
    orderControl: 'Order Control Center',
    offers: 'Offers',
    offersManagement: 'Offers Management',
    branches: 'Branches',
    branchManagement: 'Branch Management',
    customerRequests: 'Customer Requests',
    customerManagement: 'Customer Request Management',
    notifications: 'Notifications',
    scrollingBanner: 'Scrolling Banner',
    settings: 'Settings',
    logout: 'Logout'
  };

  function switchLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
    localStorage.setItem('language', currentLanguage);
    document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = currentLanguage;
    // Refresh the page to apply language change
    window.location.reload();
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-dashboard" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="dashboard-header">
    <h1>👋 {currentLanguage === 'ar' ? 'مرحباً بك في لوحة التحكم' : 'Welcome to Admin Dashboard'}</h1>
    <p>{currentLanguage === 'ar' ? 'لوحة التحكم الإدارية لأوربان إكسبريس' : 'Urban Express Administrative Control Panel'}</p>
  </div>

  <main class="admin-content">
    <div class="welcome-section">
      <h2>👋 Welcome to Urban Express Admin</h2>
      <p>مرحباً بك في لوحة التحكم الإدارية لأوربان إكسبريس</p>
      
      <div class="quick-stats">
        <div class="stat-card">
          <h3>📊 Quick Stats</h3>
          <div class="stats-grid">
            <div class="stat-item">
              <span class="stat-number">25</span>
              <span class="stat-label">{texts.orders} {currentLanguage === 'ar' ? 'اليوم' : 'Today'}</span>
            </div>
            <div class="stat-item">
              <span class="stat-number">156</span>
              <span class="stat-label">{texts.products}</span>
            </div>
            <div class="stat-item">
              <span class="stat-number">2</span>
              <span class="stat-label">{texts.branches}</span>
            </div>
            <div class="stat-item">
              <span class="stat-number">8</span>
              <span class="stat-label">{currentLanguage === 'ar' ? 'الموظفين' : 'Staff'}</span>
            </div>
          </div>
        </div>

        <div class="quick-actions">
          <h3>🚀 Quick Actions</h3>
          <div class="action-buttons">
            <a href="/products" class="action-btn">
              ➕ {currentLanguage === 'ar' ? 'إضافة منتج' : 'Add Product'}
            </a>
            <a href="/order-control" class="action-btn">
              👀 {currentLanguage === 'ar' ? 'مراجعة الطلبات' : 'View Orders'}
            </a>
            <a href="/offers" class="action-btn">
              🏷️ {currentLanguage === 'ar' ? 'إدارة العروض' : 'Manage Offers'}
            </a>
            <a href="/branches" class="action-btn">
              🏪 {currentLanguage === 'ar' ? 'إدارة الفروع' : 'Manage Branches'}
            </a>
            <a href="/customer-requests" class="action-btn">
              👥 {currentLanguage === 'ar' ? 'طلبات العملاء' : 'Customer Requests'}
            </a>
            <a href="/inventory" class="action-btn">
              📦 {currentLanguage === 'ar' ? 'تحديث المخزون' : 'Update Inventory'}
            </a>
          </div>
        </div>
      </div>

      <div class="feature-highlights">
        <h3>✨ Key Features</h3>
        <div class="features-grid">
          <div class="feature-card">
            <h4>🎛️ {texts.orderControl}</h4>
            <p>{currentLanguage === 'ar' ? 
              'إدارة شاملة للطلبات مع تعيين الموظفين وتتبع الحالة' : 
              'Comprehensive order management with staff assignment and status tracking'
            }</p>
          </div>
          <div class="feature-card">
            <h4>🏪 {texts.branchManagement}</h4>
            <p>{currentLanguage === 'ar' ? 
              'إدارة الفروع مع أوقات العمل وفرق العمل' : 
              'Branch management with operating hours and staff teams'
            }</p>
          </div>
          <div class="feature-card">
            <h4>📍 {currentLanguage === 'ar' ? 'تكامل الخرائط' : 'Maps Integration'}</h4>
            <p>{currentLanguage === 'ar' ? 
              'عرض المواقع والطرق مع خرائط جوجل' : 
              'Location viewing and routing with Google Maps'
            }</p>
          </div>
          <div class="feature-card">
            <h4>💬 {currentLanguage === 'ar' ? 'واتساب' : 'WhatsApp'}</h4>
            <p>{currentLanguage === 'ar' ? 
              'مشاركة تفاصيل الطلبات مع فريق التوصيل' : 
              'Share order details with delivery team'
            }</p>
          </div>
        </div>
      </div>
    </div>
  </main>
</div>

<style>
  .admin-dashboard {
    padding: 2rem;
    min-height: 100vh;
  }

  .dashboard-header {
    margin-bottom: 3rem;
    text-align: center;
  }

  .dashboard-header h1 {
    margin: 0 0 1rem 0;
    color: #2c3e50;
    font-size: 2.5rem;
    font-weight: 700;
  }

  .dashboard-header p {
    margin: 0;
    color: #7f8c8d;
    font-size: 1.1rem;
  }

  .admin-content {
    max-width: 1200px;
    margin: 0 auto;
  }

  .admin-nav {
    width: 280px;
    background: var(--color-primary);
    color: white;
    padding: var(--space-4);
    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
  }

  .nav-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
    padding-bottom: var(--space-4);
    border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  }

  .nav-header h1 {
    margin: 0;
    font-size: 1.2rem;
    font-weight: 600;
  }

  .lang-toggle {
    background: rgba(255, 255, 255, 0.2);
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.3);
    padding: var(--space-1) var(--space-2);
    border-radius: var(--radius-sm);
    font-size: 0.8rem;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .lang-toggle:hover {
    background: rgba(255, 255, 255, 0.3);
  }

  .nav-links {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .nav-links li {
    margin-bottom: var(--space-2);
  }

  .nav-link {
    display: flex;
    align-items: center;
    padding: var(--space-3);
    color: white;
    text-decoration: none;
    border-radius: var(--radius-md);
    transition: all 0.2s ease;
    font-weight: 500;
  }

  .nav-link:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: translateX(5px);
  }

  .nav-link:active {
    background: rgba(255, 255, 255, 0.2);
  }

  .admin-content {
    flex: 1;
    padding: var(--space-6);
    overflow-y: auto;
  }

  .welcome-section {
    max-width: 1200px;
    margin: 0 auto;
  }

  .welcome-section h2 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
    font-size: 2rem;
  }

  .welcome-section p {
    margin: 0 0 var(--space-6) 0;
    color: var(--color-ink-light);
    font-size: 1.1rem;
  }

  .quick-stats {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: var(--space-6);
    margin-bottom: var(--space-8);
  }

  .stat-card, .quick-actions {
    background: white;
    padding: var(--space-6);
    border-radius: var(--radius-lg);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  }

  .stat-card h3, .quick-actions h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-4);
  }

  .stat-item {
    text-align: center;
    padding: var(--space-4);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
  }

  .stat-number {
    display: block;
    font-size: 2rem;
    font-weight: 700;
    color: var(--color-primary);
    margin-bottom: var(--space-1);
  }

  .stat-label {
    font-size: 0.9rem;
    color: var(--color-ink-light);
    font-weight: 500;
  }

  .action-buttons {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .action-btn {
    display: block;
    padding: var(--space-3);
    background: var(--color-primary-light);
    color: var(--color-primary-dark);
    text-decoration: none;
    border-radius: var(--radius-md);
    font-weight: 500;
    text-align: center;
    transition: all 0.2s ease;
  }

  .action-btn:hover {
    background: var(--color-primary);
    color: white;
    transform: translateY(-1px);
  }

  .feature-highlights {
    background: white;
    padding: var(--space-6);
    border-radius: var(--radius-lg);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  }

  .feature-highlights h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .features-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: var(--space-4);
  }

  .feature-card {
    padding: var(--space-4);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
    border-left: 4px solid var(--color-primary);
  }

  .feature-card h4 {
    margin: 0 0 var(--space-2) 0;
    color: var(--color-ink);
    font-size: 1rem;
  }

  .feature-card p {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.9rem;
    line-height: 1.5;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-dashboard {
      flex-direction: column;
    }

    .admin-nav {
      width: 100%;
      position: relative;
    }

    .nav-header {
      flex-direction: column;
      gap: var(--space-2);
      align-items: stretch;
    }

    .nav-links {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: var(--space-2);
    }

    .nav-link {
      padding: var(--space-2);
      font-size: 0.9rem;
      text-align: center;
    }

    .nav-link:hover {
      transform: none;
    }

    .admin-content {
      padding: var(--space-4);
    }

    .quick-stats {
      grid-template-columns: 1fr;
    }

    .stats-grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .welcome-section h2 {
      font-size: 1.5rem;
    }

    .features-grid {
      grid-template-columns: 1fr;
    }
  }

  @media (max-width: 480px) {
    .stats-grid {
      grid-template-columns: 1fr;
    }

    .stat-number {
      font-size: 1.5rem;
    }
  }
</style>