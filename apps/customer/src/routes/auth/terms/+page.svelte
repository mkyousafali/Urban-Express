<script>
  import Card from '$lib/components/Card.svelte';
  import Button from '$lib/components/Button.svelte';
  import { goto } from '$app/navigation';
  
  let currentLanguage = 'ar';

  $: texts = currentLanguage === 'ar' ? {
    title: 'الشروط والأحكام',
    backButton: 'العودة',
    lastUpdated: 'آخر تحديث: أكتوبر 2025'
  } : {
    title: 'Terms & Conditions',
    backButton: 'Back',
    lastUpdated: 'Last updated: October 2025'
  };
</script>

<div class="terms-container">
  <Card>
    <div class="terms-content">
      <header>
        <h1>{texts.title}</h1>
        <p class="last-updated">{texts.lastUpdated}</p>
      </header>
      
      <div class="terms-text">
        {#if currentLanguage === 'ar'}
          <h2>1. الخدمات</h2>
          <p>Urban Express يوفر خدمات التوصيل السريع والموثوق في المملكة العربية السعودية.</p>
          
          <h2>2. المسؤولية</h2>
          <p>المستخدم مسؤول عن دقة المعلومات المقدمة.</p>
          
          <h2>3. الدفع</h2>
          <p>الدفع نقداً أو بالبطاقة عند التسليم فقط.</p>
        {:else}
          <h2>1. Services</h2>
          <p>Urban Express provides fast and reliable delivery services in Saudi Arabia.</p>
          
          <h2>2. Responsibility</h2>
          <p>User is responsible for accuracy of provided information.</p>
          
          <h2>3. Payment</h2>
          <p>Cash or card on delivery only.</p>
        {/if}
      </div>
      
      <div class="footer">
        <Button on:click={() => goto('/auth/login')}>{texts.backButton}</Button>
      </div>
    </div>
  </Card>
</div>

<style>
  .terms-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
  }

  .terms-content {
    padding: var(--space-8);
    max-width: 800px;
    margin: 0 auto;
  }

  header {
    text-align: center;
    margin-bottom: var(--space-6);
  }

  .last-updated {
    color: var(--color-ink-light);
    font-size: 0.875rem;
  }

  .terms-text h2 {
    color: var(--color-primary);
    margin-top: var(--space-6);
  }

  .footer {
    text-align: center;
    margin-top: var(--space-8);
  }
</style>