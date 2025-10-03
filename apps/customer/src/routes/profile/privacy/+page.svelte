<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';

  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }
  });

  $: texts = currentLanguage === 'ar' ? {
    title: 'سياسة الخصوصية',
    backToProfile: 'العودة إلى الملف الشخصي',
    lastUpdated: 'آخر تحديث: 1 أكتوبر 2024',
    content: 'سيتم إضافة سياسة الخصوصية قريباً'
  } : {
    title: 'Privacy Policy',
    backToProfile: 'Back to Profile',
    lastUpdated: 'Last updated: October 1, 2024',
    content: 'Privacy policy content will be added soon'
  };
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="privacy-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <header class="page-header">
    <Button variant="outline" size="sm" on:click={() => goto('/profile')}>
      ← {texts.backToProfile}
    </Button>
    <h1>{texts.title}</h1>
    <div></div>
  </header>

  <Card>
    <div class="content-section">
      <p class="last-updated">{texts.lastUpdated}</p>
      <div class="coming-soon">
        <div class="icon">📄</div>
        <p>{texts.content}</p>
      </div>
    </div>
  </Card>
</div>

<style>
  .privacy-container {
    min-height: 100vh;
    background: var(--color-surface);
    padding: var(--space-4);
    max-width: 800px;
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

  .content-section {
    padding: var(--space-6);
  }

  .last-updated {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink-light);
    font-size: 0.9rem;
  }

  .coming-soon {
    text-align: center;
    padding: var(--space-8);
  }

  .icon {
    font-size: 4rem;
    margin-bottom: var(--space-4);
  }

  .coming-soon p {
    margin: 0;
    color: var(--color-ink-light);
  }
</style>