<script>
  import { onMount } from 'svelte';
  import Card from '$lib/components/Card.svelte';
  import Button from '$lib/components/Button.svelte';
  
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
  
  const notifications = [
    {
      id: 1,
      type: 'order_delivered',
      titleAr: 'تم تسليم طلبك #2847',
      titleEn: 'Your order #2847 has been delivered',
      messageAr: 'تم تسليم طلبك بنجاح إلى حي العليا',
      messageEn: 'Your order has been successfully delivered to Al-Olaya District',
      time: '2024-09-28T14:30:00',
      read: false
    },
    {
      id: 2,
      type: 'order_pickup',
      titleAr: 'تم استلام طلبك #2856',
      titleEn: 'Your order #2856 has been picked up',
      messageAr: 'قام السائق باستلام طلبك وهو في طريقه إليك',
      messageEn: 'Driver has picked up your order and is on the way',
      time: '2024-10-01T13:15:00',
      read: false
    },
    {
      id: 3,
      type: 'delivery_charge',
      titleAr: 'رسوم توصيل إضافية',
      titleEn: 'Additional delivery charge',
      messageAr: 'تم إضافة رسوم توصيل 10 ر.س لطلبك. هل توافق؟',
      messageEn: 'Delivery charge of 10 SAR added to your order. Do you accept?',
      time: '2024-10-01T12:00:00',
      read: true,
      actionRequired: true
    }
  ];

  $: texts = currentLanguage === 'ar' ? {
    title: 'الإشعارات',
    markAllRead: 'تعيين الكل كمقروء',
    noNotifications: 'لا توجد إشعارات',
    accept: 'قبول',
    decline: 'رفض',
    viewOrder: 'عرض الطلب'
  } : {
    title: 'Notifications',
    markAllRead: 'Mark All Read',
    noNotifications: 'No notifications',
    accept: 'Accept',
    decline: 'Decline', 
    viewOrder: 'View Order'
  };

  function markAllAsRead() {
    notifications.forEach(n => n.read = true);
  }

  function formatTime(timeString) {
    const time = new Date(timeString);
    const now = new Date();
    const diff = now - time;
    const hours = Math.floor(diff / (1000 * 60 * 60));
    
    if (hours < 1) {
      return currentLanguage === 'ar' ? 'منذ قليل' : 'Just now';
    } else if (hours < 24) {
      return currentLanguage === 'ar' ? `منذ ${hours} ساعة` : `${hours}h ago`;
    } else {
      const days = Math.floor(hours / 24);
      return currentLanguage === 'ar' ? `منذ ${days} يوم` : `${days}d ago`;
    }
  }

  function getNotificationIcon(type) {
    switch(type) {
      case 'order_delivered': return '✅';
      case 'order_pickup': return '🚚';
      case 'delivery_charge': return '💰';
      default: return '🔔';
    }
  }

  function handleAcceptCharge(notificationId) {
    // Handle acceptance logic
    console.log('Accepted charge for notification:', notificationId);
  }

  function handleDeclineCharge(notificationId) {
    // Handle decline logic
    console.log('Declined charge for notification:', notificationId);
  }
</script>

<div class="notifications-container">
  <header class="page-header">
    <h1>{texts.title}</h1>
    {#if notifications.some(n => !n.read)}
      <Button size="sm" variant="secondary" on:click={markAllAsRead}>
        {texts.markAllRead}
      </Button>
    {/if}
  </header>

  {#if notifications.length === 0}
    <div class="empty-notifications">
      <p>{texts.noNotifications}</p>
    </div>
  {:else}
    <div class="notifications-list">
      {#each notifications as notification}
        <Card>
          <div class="notification-item" class:unread={!notification.read}>
            <div class="notification-header">
              <div class="notification-icon">
                {getNotificationIcon(notification.type)}
              </div>
              <div class="notification-content">
                <h3>{currentLanguage === 'ar' ? notification.titleAr : notification.titleEn}</h3>
                <p>{currentLanguage === 'ar' ? notification.messageAr : notification.messageEn}</p>
              </div>
              <div class="notification-time">
                {formatTime(notification.time)}
              </div>
            </div>
            
            {#if notification.actionRequired}
              <div class="notification-actions">
                <Button size="sm" variant="success" on:click={() => handleAcceptCharge(notification.id)}>
                  {texts.accept}
                </Button>
                <Button size="sm" variant="danger" on:click={() => handleDeclineCharge(notification.id)}>
                  {texts.decline}
                </Button>
              </div>
            {/if}
            
            {#if !notification.read}
              <div class="unread-indicator"></div>
            {/if}
          </div>
        </Card>
      {/each}
    </div>
  {/if}
</div>

<style>
  .notifications-container {
    padding: var(--space-4);
    min-height: 100vh;
    background: var(--color-surface);
    max-width: 600px;
    margin: 0 auto;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
  }

  .empty-notifications {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .notifications-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .notification-item {
    padding: var(--space-4);
    position: relative;
  }

  .notification-item.unread {
    background: linear-gradient(135deg, var(--color-surface) 0%, #F0F9FF 100%);
  }

  .notification-header {
    display: flex;
    gap: var(--space-3);
    align-items: flex-start;
  }

  .notification-icon {
    font-size: 1.5rem;
    flex-shrink: 0;
  }

  .notification-content {
    flex: 1;
  }

  .notification-content h3 {
    margin: 0 0 var(--space-1) 0;
    color: var(--color-ink);
    font-size: 0.95rem;
  }

  .notification-content p {
    margin: 0;
    color: var(--color-ink-light);
    font-size: 0.875rem;
    line-height: 1.4;
  }

  .notification-time {
    color: var(--color-ink-lighter);
    font-size: 0.75rem;
    flex-shrink: 0;
  }

  .notification-actions {
    display: flex;
    gap: var(--space-2);
    margin-top: var(--space-3);
    padding-top: var(--space-3);
    border-top: 1px solid var(--color-border-light);
  }

  .unread-indicator {
    position: absolute;
    top: var(--space-4);
    right: var(--space-4);
    width: 8px;
    height: 8px;
    background: var(--color-primary);
    border-radius: 50%;
  }
</style>