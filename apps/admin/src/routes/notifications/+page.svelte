<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { notifications, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let pushNotificationsEnabled = false;
  
  // Subscribe to notifications store
  $: currentNotifications = $notifications;
  $: unreadCount = currentNotifications.filter(notif => !notif.isRead).length;
  
  onMount(async () => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Check if push notifications are supported and enabled
    if ('Notification' in window) {
      pushNotificationsEnabled = Notification.permission === 'granted';
    }

    // Request notification permission if not already granted
    if ('Notification' in window && Notification.permission === 'default') {
      const permission = await Notification.requestPermission();
      pushNotificationsEnabled = permission === 'granted';
    }

    // Listen for language changes
    function handleStorageChange(event) {
      if (event.key === 'language') {
        currentLanguage = event.newValue || 'ar';
        document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
        document.documentElement.lang = currentLanguage;
      }
    }

    window.addEventListener('storage', handleStorageChange);
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  });

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'مركز الإشعارات',
    enableNotifications: 'تفعيل الإشعارات',
    disableNotifications: 'إيقاف الإشعارات',
    markAllAsRead: 'تحديد الكل كمقروء',
    clearAll: 'مسح الكل',
    newOrder: 'طلب جديد',
    orderUpdate: 'تحديث الطلب',
    lowStock: 'مخزون منخفض',
    systemAlert: 'تنبيه النظام',
    noNotifications: 'لا توجد إشعارات',
    unreadNotifications: 'إشعارات غير مقروءة',
    allNotifications: 'جميع الإشعارات',
    markAsRead: 'تحديد كمقروء',
    delete: 'حذف',
    minute: 'دقيقة',
    minutes: 'دقائق',
    hour: 'ساعة',
    hours: 'ساعات',
    day: 'يوم',
    days: 'أيام',
    ago: 'منذ',
    now: 'الآن',
    notificationSettings: 'إعدادات الإشعارات',
    pushNotifications: 'الإشعارات الفورية',
    enabled: 'مفعل',
    disabled: 'معطل',
    testNotification: 'إشعار تجريبي',
    testNotificationSent: 'تم إرسال إشعار تجريبي',
    confirmClearAll: 'هل أنت متأكد من مسح جميع الإشعارات؟'
  } : {
    title: 'Notification Center',
    enableNotifications: 'Enable Notifications',
    disableNotifications: 'Disable Notifications',
    markAllAsRead: 'Mark All as Read',
    clearAll: 'Clear All',
    newOrder: 'New Order',
    orderUpdate: 'Order Update',
    lowStock: 'Low Stock',
    systemAlert: 'System Alert',
    noNotifications: 'No notifications',
    unreadNotifications: 'Unread Notifications',
    allNotifications: 'All Notifications',
    markAsRead: 'Mark as Read',
    delete: 'Delete',
    minute: 'minute',
    minutes: 'minutes',
    hour: 'hour',
    hours: 'hours',
    day: 'day',
    days: 'days',
    ago: 'ago',
    now: 'now',
    notificationSettings: 'Notification Settings',
    pushNotifications: 'Push Notifications',
    enabled: 'Enabled',
    disabled: 'Disabled',
    testNotification: 'Test Notification',
    testNotificationSent: 'Test notification sent',
    confirmClearAll: 'Are you sure you want to clear all notifications?'
  };

  async function enableNotifications() {
    if ('Notification' in window) {
      const permission = await Notification.requestPermission();
      pushNotificationsEnabled = permission === 'granted';
      
      if (pushNotificationsEnabled) {
        sendTestNotification();
      }
    }
  }

  function sendTestNotification() {
    adminActions.addNotification({
      type: 'system_alert',
      title: texts.testNotification,
      titleAr: 'إشعار تجريبي',
      message: texts.testNotificationSent,
      messageAr: 'تم إرسال إشعار تجريبي',
      isRead: false
    });
  }

  function markAsRead(notificationId) {
    adminActions.markNotificationAsRead(notificationId);
  }

  function markAllAsRead() {
    currentNotifications.forEach(notif => {
      if (!notif.isRead) {
        adminActions.markNotificationAsRead(notif.id);
      }
    });
  }

  function deleteNotification(notificationId) {
    notifications.update(notifs => notifs.filter(notif => notif.id !== notificationId));
  }

  function clearAllNotifications() {
    if (confirm(texts.confirmClearAll)) {
      notifications.update(() => []);
    }
  }

  function getNotificationIcon(type) {
    switch (type) {
      case 'new_order': return '🛒';
      case 'order_update': return '📦';
      case 'low_stock': return '⚠️';
      case 'system_alert': return '🔔';
      default: return '📢';
    }
  }

  function getTimeAgo(dateString) {
    const now = new Date();
    const notificationTime = new Date(dateString);
    const diffInSeconds = Math.floor((now - notificationTime) / 1000);
    
    if (diffInSeconds < 60) {
      return texts.now;
    }
    
    const diffInMinutes = Math.floor(diffInSeconds / 60);
    if (diffInMinutes < 60) {
      const unit = diffInMinutes === 1 ? texts.minute : texts.minutes;
      return `${diffInMinutes} ${unit} ${texts.ago}`;
    }
    
    const diffInHours = Math.floor(diffInMinutes / 60);
    if (diffInHours < 24) {
      const unit = diffInHours === 1 ? texts.hour : texts.hours;
      return `${diffInHours} ${unit} ${texts.ago}`;
    }
    
    const diffInDays = Math.floor(diffInHours / 24);
    const unit = diffInDays === 1 ? texts.day : texts.days;
    return `${diffInDays} ${unit} ${texts.ago}`;
  }

  function getNotificationTitle(notification) {
    return currentLanguage === 'ar' ? 
      (notification.titleAr || notification.title) : 
      notification.title;
  }

  function getNotificationMessage(notification) {
    return currentLanguage === 'ar' ? 
      (notification.messageAr || notification.message) : 
      notification.message;
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="header">
    <h1>{texts.title}</h1>
    <div class="unread-badge" class:hidden={unreadCount === 0}>
      {unreadCount}
    </div>
  </div>

  <!-- Notification Settings -->
  <Card>
    <div class="settings-section">
      <h2>{texts.notificationSettings}</h2>
      
      <div class="setting-item">
        <div class="setting-info">
          <label>{texts.pushNotifications}</label>
          <span class="setting-status" class:enabled={pushNotificationsEnabled} class:disabled={!pushNotificationsEnabled}>
            {pushNotificationsEnabled ? texts.enabled : texts.disabled}
          </span>
        </div>
        
        <div class="setting-actions">
          {#if !pushNotificationsEnabled}
            <Button variant="primary" size="sm" on:click={enableNotifications}>
              {texts.enableNotifications}
            </Button>
          {:else}
            <Button variant="outline" size="sm" on:click={sendTestNotification}>
              {texts.testNotification}
            </Button>
          {/if}
        </div>
      </div>
    </div>
  </Card>

  <!-- Notification Actions -->
  {#if currentNotifications.length > 0}
    <div class="notification-actions">
      <Button variant="outline" size="sm" on:click={markAllAsRead} disabled={unreadCount === 0}>
        {texts.markAllAsRead}
      </Button>
      <Button variant="error" size="sm" on:click={clearAllNotifications}>
        {texts.clearAll}
      </Button>
    </div>
  {/if}

  <!-- Notifications List -->
  <div class="notifications-container">
    {#if currentNotifications.length === 0}
      <div class="no-notifications">
        <div class="empty-icon">🔔</div>
        <p>{texts.noNotifications}</p>
      </div>
    {:else}
      <!-- Unread Notifications -->
      {@const unreadNotifications = currentNotifications.filter(notif => !notif.isRead)}
      {#if unreadNotifications.length > 0}
        <div class="notifications-section">
          <h3>{texts.unreadNotifications} ({unreadNotifications.length})</h3>
          <div class="notifications-list">
            {#each unreadNotifications as notification}
              <Card>
                <div class="notification-item unread">
                  <div class="notification-icon">
                    {getNotificationIcon(notification.type)}
                  </div>
                  
                  <div class="notification-content">
                    <div class="notification-header">
                      <h4>{getNotificationTitle(notification)}</h4>
                      <span class="notification-time">{getTimeAgo(notification.createdAt)}</span>
                    </div>
                    <p class="notification-message">{getNotificationMessage(notification)}</p>
                  </div>
                  
                  <div class="notification-actions">
                    <Button variant="outline" size="sm" on:click={() => markAsRead(notification.id)}>
                      {texts.markAsRead}
                    </Button>
                    <Button variant="error" size="sm" on:click={() => deleteNotification(notification.id)}>
                      {texts.delete}
                    </Button>
                  </div>
                </div>
              </Card>
            {/each}
          </div>
        </div>
      {/if}

      <!-- Read Notifications -->
      {@const readNotifications = currentNotifications.filter(notif => notif.isRead)}
      {#if readNotifications.length > 0}
        <div class="notifications-section">
          <h3>{texts.allNotifications}</h3>
          <div class="notifications-list">
            {#each readNotifications as notification}
              <Card>
                <div class="notification-item read">
                  <div class="notification-icon">
                    {getNotificationIcon(notification.type)}
                  </div>
                  
                  <div class="notification-content">
                    <div class="notification-header">
                      <h4>{getNotificationTitle(notification)}</h4>
                      <span class="notification-time">{getTimeAgo(notification.createdAt)}</span>
                    </div>
                    <p class="notification-message">{getNotificationMessage(notification)}</p>
                  </div>
                  
                  <div class="notification-actions">
                    <Button variant="error" size="sm" on:click={() => deleteNotification(notification.id)}>
                      {texts.delete}
                    </Button>
                  </div>
                </div>
              </Card>
            {/each}
          </div>
        </div>
      {/if}
    {/if}
  </div>
</div>

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 800px;
    margin: 0 auto;
  }

  .header {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-3);
    margin-bottom: var(--space-6);
    position: relative;
  }

  .header h1 {
    margin: 0;
    color: var(--color-ink);
  }

  .unread-badge {
    background: var(--color-error);
    color: white;
    border-radius: 50%;
    width: 2rem;
    height: 2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.8rem;
    font-weight: 700;
    animation: pulse 2s infinite;
  }

  .unread-badge.hidden {
    display: none;
  }

  @keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
  }

  .settings-section {
    padding: var(--space-4);
  }

  .settings-section h2 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .setting-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
  }

  .setting-info {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
  }

  .setting-info label {
    font-weight: 600;
    color: var(--color-ink);
  }

  .setting-status {
    font-size: 0.8rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .setting-status.enabled {
    color: var(--color-success-dark);
  }

  .setting-status.disabled {
    color: var(--color-error-dark);
  }

  .notification-actions {
    display: flex;
    gap: var(--space-3);
    justify-content: center;
    margin: var(--space-6) 0;
  }

  .notifications-container {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
  }

  .no-notifications {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .empty-icon {
    font-size: 4rem;
    margin-bottom: var(--space-4);
  }

  .notifications-section h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
    padding-bottom: var(--space-2);
    border-bottom: 2px solid var(--color-border);
  }

  .notifications-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .notification-item {
    display: flex;
    gap: var(--space-3);
    padding: var(--space-4);
    align-items: flex-start;
  }

  .notification-item.unread {
    border-left: 4px solid var(--color-primary);
    background: var(--color-primary-light);
  }

  .notification-item.read {
    opacity: 0.7;
  }

  .notification-icon {
    font-size: 1.5rem;
    flex-shrink: 0;
    width: 2.5rem;
    height: 2.5rem;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--color-surface);
    border-radius: 50%;
  }

  .notification-content {
    flex: 1;
  }

  .notification-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: var(--space-2);
    margin-bottom: var(--space-2);
  }

  .notification-header h4 {
    margin: 0;
    color: var(--color-ink);
    font-size: 1rem;
    line-height: 1.3;
  }

  .notification-time {
    font-size: 0.8rem;
    color: var(--color-ink-light);
    white-space: nowrap;
  }

  .notification-message {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.9rem;
    line-height: 1.4;
  }

  .notification-actions {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
    flex-shrink: 0;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .setting-item {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .notification-item {
      flex-direction: column;
      gap: var(--space-3);
    }

    .notification-header {
      flex-direction: column;
      gap: var(--space-1);
    }

    .notification-actions {
      flex-direction: row;
      justify-content: flex-start;
    }

    .notification-actions {
      flex-direction: column;
      align-items: stretch;
    }
  }
</style>