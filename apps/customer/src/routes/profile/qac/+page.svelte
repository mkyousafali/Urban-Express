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
    title: 'إعداد رمز الوصول السريع',
    backToProfile: 'العودة إلى الملف الشخصي',
    description: 'سيتم إضافة هذه الميزة قريباً',
    comingSoon: 'قريباً'
  } : {
    title: 'Quick Access Code Setup',
    backToProfile: 'Back to Profile',
    description: 'This feature will be available soon',
    comingSoon: 'Coming Soon'
  };
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="qac-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <header class="page-header">
    <Button variant="outline" size="sm" on:click={() => goto('/profile')}>
      ← {texts.backToProfile}
    </Button>
    <h1>{texts.title}</h1>
    <div></div>
  </header>

  <Card>
    <div class="coming-soon">
      <div class="icon">🔧</div>
      <h2>{texts.comingSoon}</h2>
      <p>{texts.description}</p>
    </div>
  </Card>
</div>

<style>
  .qac-container {
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

  .coming-soon {
    text-align: center;
    padding: var(--space-8);
  }

  .icon {
    font-size: 4rem;
    margin-bottom: var(--space-4);
  }

  .coming-soon h2 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
  }

  .coming-soon p {
    margin: 0;
    color: var(--color-ink-light);
  }
</style>