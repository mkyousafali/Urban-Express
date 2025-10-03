<script>
  let currentLanguage = 'ar';
  
  export let title = '';
  
  $: texts = currentLanguage === 'ar' ? {
    dashboard: 'الرئيسية',
    products: 'المنتجات',
    inventory: 'المخزون',
    orderControl: 'مركز التحكم في الطلبات',
    offers: 'العروض',
    branches: 'الفروع',
    customerRequests: 'طلبات العملاء',
    notifications: 'الإشعارات',
    scrollingBanner: 'البانر المتحرك'
  } : {
    dashboard: 'Dashboard',
    products: 'Products',
    inventory: 'Inventory',
    orderControl: 'Order Control',
    offers: 'Offers',
    branches: 'Branches',
    customerRequests: 'Customer Requests',
    notifications: 'Notifications',
    scrollingBanner: 'Scrolling Banner'
  };
</script>

<div class="page-header">
  <nav class="admin-breadcrumb">
    <a href="/">🏠 {texts.dashboard}</a>
    <span class="separator">›</span>
    <span class="current-page">{title}</span>
  </nav>
  {#if title}
    <h1 class="page-title">{title}</h1>
  {/if}
</div>

<style>
  .page-header {
    padding: 2rem;
    background: white;
    border-bottom: 1px solid #e9ecef;
    margin-bottom: 2rem;
  }

  .admin-breadcrumb {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 1rem;
    font-size: 0.875rem;
  }
  
  .admin-breadcrumb a {
    color: #007bff;
    text-decoration: none;
    font-weight: 500;
  }
  
  .admin-breadcrumb a:hover {
    text-decoration: underline;
  }

  .separator {
    color: #6c757d;
  }

  .current-page {
    color: #6c757d;
    font-weight: 500;
  }

  .page-title {
    margin: 0;
    color: #2c3e50;
    font-size: 2rem;
    font-weight: 700;
  }
</style>