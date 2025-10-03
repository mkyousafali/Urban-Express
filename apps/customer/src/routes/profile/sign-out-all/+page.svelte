<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';
  let loading = false;
  let confirmed = false;

  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }
  });

  $: texts = currentLanguage === 'ar' ? {
    title: 'تسجيل الخروج من جميع الأجهزة',
    backToProfile: 'العودة إلى الملف الشخصي',
    warning: 'تحذير: هذا الإجراء سيؤدي إلى تسجيل خروجك من جميع الأجهزة',
    description: 'ستحتاج إلى تسجيل الدخول مرة أخرى على جميع أجهزتك',
    confirmButton: 'تأكيد تسجيل الخروج',
    signingOut: 'جاري تسجيل الخروج...',
    cancel: 'إلغاء'
  } : {
    title: 'Sign Out All Devices',
    backToProfile: 'Back to Profile',
    warning: 'Warning: This action will sign you out from all devices',
    description: 'You will need to sign in again on all your devices',
    confirmButton: 'Confirm Sign Out',
    signingOut: 'Signing out...',
    cancel: 'Cancel'
  };

  async function handleSignOutAll() {
    loading = true;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Clear all local storage
      localStorage.clear();
      
      // Redirect to login
      goto('/auth/login');
    } catch (err) {
      console.error('Failed to sign out:', err);
    } finally {
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="signout-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <header class="page-header">
    <Button variant="outline" size="sm" on:click={() => goto('/profile')}>
      ← {texts.backToProfile}
    </Button>
    <h1>{texts.title}</h1>
    <div></div>
  </header>

  <Card>
    <div class="warning-section">
      <div class="warning-icon">⚠️</div>
      <h2>{texts.warning}</h2>
      <p>{texts.description}</p>
      
      <div class="actions">
        <Button 
          variant="primary" 
          on:click={handleSignOutAll}
          {loading}
          class="danger"
        >
          {loading ? texts.signingOut : texts.confirmButton}
        </Button>
        
        <Button 
          variant="outline" 
          on:click={() => goto('/profile')}
          disabled={loading}
        >
          {texts.cancel}
        </Button>
      </div>
    </div>
  </Card>
</div>

<style>
  .signout-container {
    min-height: 100vh;
    background: var(--color-surface);
    padding: var(--space-4);
    max-width: 500px;
    margin: 0 auto;
    padding-top: calc(60px + 1rem);
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
  }

  .page-header h1 {
    margin: 0;
    color: var(--color-ink);
    font-size: 1.5rem;
  }

  .warning-section {
    text-align: center;
    padding: var(--space-6);
  }

  .warning-icon {
    font-size: 4rem;
    margin-bottom: var(--space-4);
  }

  .warning-section h2 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-error);
  }

  .warning-section p {
    margin: 0 0 var(--space-6) 0;
    color: var(--color-ink-light);
    line-height: 1.5;
  }

  .actions {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  :global(.actions .button.danger) {
    background: var(--color-error);
    border-color: var(--color-error);
    color: white;
  }

  :global(.actions .button.danger:hover) {
    background: var(--color-error-dark);
    border-color: var(--color-error-dark);
  }
</style>