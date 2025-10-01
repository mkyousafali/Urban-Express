<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';

  // Load language from localStorage
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
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
  
  const userProfile = {
    name: 'أحمد محمد الأحمد',
    nameEn: 'Ahmed Mohammed Al-Ahmed',
    whatsapp: '0501234567',
    joinDate: '2024-01-15',
    totalOrders: 24,
    preferredLanguage: 'ar'
  };

  const recentOrders = [
    {
      id: '#2847',
      status: 'delivered',
      items: 'مستندات مهمة',
      itemsEn: 'Important documents',
      date: '2024-09-28',
      amount: 45.00
    },
    {
      id: '#2856',
      status: 'in_transit',
      items: 'طرد شخصي',
      itemsEn: 'Personal package',
      date: '2024-10-01',
      amount: 35.00
    }
  ];

  const recentActivity = [
    {
      id: 1,
      type: 'order_delivered',
      titleAr: 'تم تسليم الطلب #2847',
      titleEn: 'Order #2847 delivered',
      time: '2024-09-28T14:30:00',
      amount: 45.00
    },
    {
      id: 2,
      type: 'order_pickup',
      titleAr: 'تم استلام الطلب #2856',
      titleEn: 'Order #2856 picked up',
      time: '2024-10-01T13:15:00',
      amount: 35.00
    }
  ];

  $: texts = currentLanguage === 'ar' ? {
    title: 'الملف الشخصي',
    personalInfo: 'المعلومات الشخصية',
    name: 'الاسم',
    whatsapp: 'رقم الواتساب',
    memberSince: 'عضو منذ',
    totalOrders: 'إجمالي الطلبات',
    addresses: 'العناوين',
    security: 'الأمان',
    legal: 'القوانين',
    support: 'الدعم',
    manageAddresses: 'إدارة العناوين',
    changePassword: 'تغيير كلمة المرور',
    qacSetup: 'إعداد رمز الوصول السريع',
    signOutAll: 'تسجيل الخروج من جميع الأجهزة',
    termsConditions: 'الشروط والأحكام',
    privacyPolicy: 'سياسة الخصوصية',
    contactSupport: 'اتصل بالدعم',
    chatSupport: 'دردشة مع الدعم',
    logout: 'تسجيل الخروج',
    orders: 'الطلبات',
    trackOrder: 'تتبع الطلب',
    orderHistory: 'سجل الطلبات',
    recentActivity: 'النشاط الأخير',
    viewAllOrders: 'عرض جميع الطلبات',
    orderDelivered: 'تم تسليم الطلب',
    orderInProgress: 'طلب قيد التوصيل',
    orderPickedUp: 'تم استلام الطلب',
    viewDetails: 'عرض التفاصيل'
  } : {
    title: 'Profile',
    personalInfo: 'Personal Information',
    name: 'Name',
    whatsapp: 'WhatsApp Number',
    memberSince: 'Member Since',
    totalOrders: 'Total Orders',
    addresses: 'Addresses',
    security: 'Security',
    legal: 'Legal',
    support: 'Support',
    manageAddresses: 'Manage Addresses',
    changePassword: 'Change Password',
    qacSetup: 'Quick Access Code Setup',
    signOutAll: 'Sign Out All Devices',
    termsConditions: 'Terms & Conditions',
    privacyPolicy: 'Privacy Policy',
    contactSupport: 'Contact Support',
    chatSupport: 'Chat with Support',
    logout: 'Logout',
    orders: 'Orders',
    trackOrder: 'Track Order',
    orderHistory: 'Order History',
    recentActivity: 'Recent Activity',
    viewAllOrders: 'View All Orders',
    orderDelivered: 'Order Delivered',
    orderInProgress: 'Order In Transit',
    orderPickedUp: 'Order Picked Up',
    viewDetails: 'View Details'
  };

  function handleLogout() {
    localStorage.clear();
    goto('/auth/login');
  }

  function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString(currentLanguage === 'ar' ? 'ar-SA' : 'en-US');
  }
</script>

<div class="profile-container">
  <header class="page-header">
    <h1>{texts.title}</h1>
  </header>

  <!-- Personal Information -->
  <Card>
    <div class="section">
      <h2>{texts.personalInfo}</h2>
      <div class="profile-info">
        <div class="avatar-large">
          {(currentLanguage === 'ar' ? userProfile.name : userProfile.nameEn).charAt(0)}
        </div>
        <div class="info-details">
          <div class="info-item">
            <label>{texts.name}:</label>
            <span>{currentLanguage === 'ar' ? userProfile.name : userProfile.nameEn}</span>
          </div>
          <div class="info-item">
            <label>{texts.whatsapp}:</label>
            <span>{userProfile.whatsapp}</span>
          </div>
          <div class="info-item">
            <label>{texts.memberSince}:</label>
            <span>{formatDate(userProfile.joinDate)}</span>
          </div>
          <div class="info-item">
            <label>{texts.totalOrders}:</label>
            <span>{userProfile.totalOrders}</span>
          </div>
        </div>
      </div>
    </div>
  </Card>

  <!-- Orders Section -->
  <Card>
    <div class="section">
      <div class="section-header">
        <h2>{texts.orders}</h2>
        <Button size="sm" on:click={() => goto('/orders')}>
          {texts.viewAllOrders}
        </Button>
      </div>
      <div class="menu-items">
        <button class="menu-item" on:click={() => goto('/orders')}>
          <span>{texts.trackOrder}</span>
          <span class="arrow">›</span>
        </button>
        <button class="menu-item" on:click={() => goto('/orders')}>
          <span>{texts.orderHistory}</span>
          <span class="arrow">›</span>
        </button>
      </div>
      
      <!-- Recent Orders Preview -->
      {#if recentOrders.length > 0}
        <div class="recent-orders">
          <h4>{texts.recentActivity}</h4>
          {#each recentOrders.slice(0, 2) as order}
            <div class="activity-item">
              <div class="activity-icon">
                {#if order.status === 'delivered'}
                  ✅
                {:else if order.status === 'in_transit'}
                  🚚
                {:else}
                  📦
                {/if}
              </div>
              <div class="activity-content">
                <h5>{currentLanguage === 'ar' ? order.items : order.itemsEn}</h5>
                <p class="activity-id">{order.id}</p>
              </div>
              <div class="activity-amount">
                {order.amount.toFixed(2)} ر.س
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </Card>

  <!-- Addresses -->
  <Card>
    <div class="section">
      <div class="section-header">
        <h2>{texts.addresses}</h2>
        <Button size="sm" on:click={() => goto('/profile/addresses')}>
          {texts.manageAddresses}
        </Button>
      </div>
    </div>
  </Card>

  <!-- Security -->
  <Card>
    <div class="section">
      <h2>{texts.security}</h2>
      <div class="menu-items">
        <button class="menu-item" on:click={() => goto('/profile/change-password')}>
          <span>{texts.changePassword}</span>
          <span class="arrow">›</span>
        </button>
        <button class="menu-item" on:click={() => goto('/profile/qac')}>
          <span>{texts.qacSetup}</span>
          <span class="arrow">›</span>
        </button>
        <button class="menu-item" on:click={() => goto('/profile/sign-out-all')}>
          <span>{texts.signOutAll}</span>
          <span class="arrow">›</span>
        </button>
      </div>
    </div>
  </Card>

  <!-- Legal -->
  <Card>
    <div class="section">
      <h2>{texts.legal}</h2>
      <div class="menu-items">
        <button class="menu-item" on:click={() => goto('/auth/terms')}>
          <span>{texts.termsConditions}</span>
          <span class="arrow">›</span>
        </button>
        <button class="menu-item" on:click={() => goto('/profile/privacy')}>
          <span>{texts.privacyPolicy}</span>
          <span class="arrow">›</span>
        </button>
      </div>
    </div>
  </Card>

  <!-- Support -->
  <Card>
    <div class="section">
      <h2>{texts.support}</h2>
      <div class="menu-items">
        <button class="menu-item" on:click={() => goto('/chat')}>
          <span>{texts.chatSupport}</span>
          <span class="arrow">›</span>
        </button>
      </div>
    </div>
  </Card>

  <!-- Logout -->
  <div class="logout-section">
    <Button variant="danger" fullWidth on:click={handleLogout}>
      {texts.logout}
    </Button>
  </div>
</div>

<style>
  .profile-container {
    padding: var(--space-4);
    min-height: 100vh;
    background: var(--color-surface);
    max-width: 600px;
    margin: 0 auto;
  }

  .page-header {
    text-align: center;
    margin-bottom: var(--space-6);
  }

  .section {
    padding: var(--space-4);
  }

  .section h2 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
    font-size: 1.1rem;
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .profile-info {
    display: flex;
    gap: var(--space-4);
    align-items: center;
  }

  .avatar-large {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--gradient-primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    font-weight: 600;
    flex-shrink: 0;
  }

  .info-details {
    flex: 1;
  }

  .info-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: var(--space-2);
    padding: var(--space-2) 0;
    border-bottom: 1px solid var(--color-border-light);
  }

  .info-item label {
    color: var(--color-ink-light);
    font-weight: 500;
  }

  .info-item span {
    color: var(--color-ink);
  }

  .menu-items {
    display: flex;
    flex-direction: column;
  }

  .menu-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-3) 0;
    border: none;
    background: none;
    cursor: pointer;
    border-bottom: 1px solid var(--color-border-light);
    color: var(--color-ink);
    transition: color 0.2s ease;
  }

  .menu-item:hover {
    color: var(--color-primary);
  }

  .menu-item:last-child {
    border-bottom: none;
  }

  .arrow {
    color: var(--color-ink-light);
    font-size: 1.2rem;
  }

  .logout-section {
    margin-top: var(--space-6);
  }

  .recent-orders {
    margin-top: var(--space-4);
    padding-top: var(--space-4);
    border-top: 1px solid var(--color-border-light);
  }

  .recent-orders h4 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
    font-size: 0.9rem;
  }

  .activity-item {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    padding: var(--space-3) 0;
    border-bottom: 1px solid var(--color-border-light);
  }

  .activity-item:last-child {
    border-bottom: none;
  }

  .activity-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--color-surface);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    flex-shrink: 0;
  }

  .activity-content {
    flex: 1;
  }

  .activity-content h5 {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
    font-size: 0.875rem;
  }

  .activity-id {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.75rem;
  }

  .activity-amount {
    color: var(--color-primary);
    font-weight: 600;
    font-size: 0.875rem;
  }
</style>