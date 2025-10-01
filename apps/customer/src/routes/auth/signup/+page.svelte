<script>
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  import { goto } from '$app/navigation';
  
  let fullName = '';
  let whatsappNumber = '';
  let password = '';
  let confirmPassword = '';
  let defaultLocation = '';
  let acceptTerms = false;
  let loading = false;
  let error = '';
  let currentLanguage = 'ar';

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'طلب إنشاء حساب',
    subtitle: 'انضم إلى Urban Express',
    fullNameLabel: 'الاسم الكامل',
    whatsappLabel: 'رقم الواتساب',
    passwordLabel: 'كلمة المرور',
    confirmPasswordLabel: 'تأكيد كلمة المرور',
    locationLabel: 'الموقع الافتراضي',
    locationPlaceholder: 'اختر موقعك على الخريطة',
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
    locationLabel: 'Default Location',
    locationPlaceholder: 'Choose your location on map',
    termsLabel: 'I agree to Terms & Conditions',
    submitButton: 'Submit Request',
    submitting: 'Submitting...',
    backToLogin: 'Back to Login',
    requestStatus: 'Your request will be reviewed within 24 hours'
  };

  async function handleSubmit() {
    if (!acceptTerms) {
      error = 'يرجى الموافقة على الشروط والأحكام';
      return;
    }
    
    loading = true;
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Redirect to success page
    goto('/auth/signup/success');
  }

  function toggleLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
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
        <Input label={texts.locationLabel} bind:value={defaultLocation} placeholder={texts.locationPlaceholder} required />
        
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
    background: var(--gradient-brand);
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
</style>