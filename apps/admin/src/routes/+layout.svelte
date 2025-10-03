<script>
  import '../app.css';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import { onMount } from 'svelte';
  
  let sidebarCollapsed = false;
  
  onMount(() => {
    const savedState = localStorage.getItem('sidebarCollapsed');
    if (savedState) {
      sidebarCollapsed = JSON.parse(savedState);
    }
    
    // Listen for sidebar state changes
    const handleStorageChange = () => {
      const newState = localStorage.getItem('sidebarCollapsed');
      if (newState) {
        sidebarCollapsed = JSON.parse(newState);
      }
    };
    
    window.addEventListener('storage', handleStorageChange);
    
    // Also listen for localStorage changes within the same tab
    const originalSetItem = localStorage.setItem;
    localStorage.setItem = function(key, value) {
      originalSetItem.apply(this, arguments);
      if (key === 'sidebarCollapsed') {
        sidebarCollapsed = JSON.parse(value);
      }
    };
    
    return () => {
      window.removeEventListener('storage', handleStorageChange);
      localStorage.setItem = originalSetItem;
    };
  });
</script>

<div class="admin-layout">
  <Sidebar />
  <main class="main-content" class:collapsed={sidebarCollapsed}>
    <slot />
  </main>
</div>

<style>
  .admin-layout {
    display: flex;
    min-height: 100vh;
  }

  .main-content {
    flex: 1;
    margin-left: 280px;
    transition: margin-left 0.3s ease;
    min-height: 100vh;
    background: #f8f9fa;
  }

  .main-content.collapsed {
    margin-left: 70px;
  }

  /* RTL Support */
  :global([dir="rtl"]) .main-content {
    margin-left: 0;
    margin-right: 280px;
  }

  :global([dir="rtl"]) .main-content.collapsed {
    margin-right: 70px;
  }

  /* Mobile responsive */
  @media (max-width: 768px) {
    .main-content {
      margin-left: 0;
    }

    :global([dir="rtl"]) .main-content {
      margin-right: 0;
    }
  }
</style>