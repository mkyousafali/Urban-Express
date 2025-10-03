<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  import { goto } from '$app/navigation';
  
  let fullName = '';
  let whatsappNumber = '';
  let password = '';
  let confirmPassword = '';
  let acceptTerms = false;
  let loading = false;
  let error = '';
  let currentLanguage = 'ar';

  // Load language from localStorage and listen for changes
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      // Update document direction immediately
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Listen for language changes from other tabs/pages
    function handleStorageChange(event) {
      if (event.key === 'language') {
        currentLanguage = event.newValue || 'ar';
        // Update document direction when language changes
        document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
        document.documentElement.lang = currentLanguage;
      }
    }

    window.addEventListener('storage', handleStorageChange);
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  });

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'طلب إنشاء حساب',
    subtitle: 'انضم إلى Urban Express',
    fullNameLabel: 'الاسم الكامل',
    whatsappLabel: 'رقم الواتساب',
    passwordLabel: 'كلمة المرور',
    confirmPasswordLabel: 'تأكيد كلمة المرور',
    termsLabel: 'أوافق على الشروط والأحكام',
    submitButton: 'إرسال الطلب',
    submitting: 'جاري الإرسال...',
    backToLogin: 'العودة لتسجيل الدخول',
    requestStatus: 'سيتم مراجعة طلبك خلال 24 ساعة'
  } : {
    title: 'Sign Up Request',
    subtitle: 'Join Urban Express',
    fullNameLabel: 'Full Name',
    whatsappLabel: 'WhatsApp Number',
    passwordLabel: 'Password',
    confirmPasswordLabel: 'Confirm Password',
    termsLabel: 'I agree to Terms & Conditions',
    submitButton: 'Submit Request',
    submitting: 'Submitting...',
    backToLogin: 'Back to Login',
    requestStatus: 'Your request will be reviewed within 24 hours'
  };

  async function handleSubmit() {
    if (!acceptTerms) {
      error = currentLanguage === 'ar' ? 'يرجى الموافقة على الشروط والأحكام' : 'Please agree to Terms & Conditions';
      return;
    }
    
    loading = true;
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // After successful signup, redirect to location sharing page
    goto('/auth/signup/location-sharing');
  }
</script>

<div class="signup-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <Card>
    <div class="signup-content">
      <h1>{texts.title}</h1>
      <p class="subtitle">{texts.subtitle}</p>
      
      <form on:submit|preventDefault={handleSubmit}>
        <Input label={texts.fullNameLabel} bind:value={fullName} required />
        <Input label={texts.whatsappLabel} bind:value={whatsappNumber} type="tel" required />
        <Input label={texts.passwordLabel} bind:value={password} type="password" required />
        <Input label={texts.confirmPasswordLabel} bind:value={confirmPassword} type="password" required />
        
        <label class="checkbox-label">
          <input type="checkbox" bind:checked={acceptTerms} />
          {texts.termsLabel}
        </label>
        
        {#if error}
          <div class="error">{error}</div>
        {/if}
        
        <Button type="submit" fullWidth {loading}>
          {loading ? texts.submitting : texts.submitButton}
        </Button>
      </form>
      
      <div class="footer">
        <a href="/auth/login">{texts.backToLogin}</a>
        <p class="status-note">{texts.requestStatus}</p>
      </div>
    </div>
  </Card>
</div>

<style>
  .signup-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-4);
    background: var(--gradient-primary);
  }

  .signup-content {
    padding: var(--space-8);
    max-width: 400px;
    width: 100%;
  }

  h1 {
    text-align: center;
    margin-bottom: var(--space-2);
  }

  .subtitle {
    text-align: center;
    color: var(--color-ink-light);
    margin-bottom: var(--space-6);
  }

  .checkbox-label {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    margin: var(--space-4) 0;
  }

  .footer {
    text-align: center;
    margin-top: var(--space-6);
  }

  .status-note {
    font-size: 0.875rem;
    color: var(--color-ink-light);
    margin-top: var(--space-2);
  }

  /* Mobile Responsiveness */
  @media (max-width: 480px) {
    .signup-container {
      padding: var(--space-2);
    }

    .signup-content {
      padding: var(--space-4);
    }
  }
</style>