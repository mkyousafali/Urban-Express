<script>
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  import { goto } from '$app/navigation';
  
  let whatsappNumber = '';
  let loading = false;
  let sent = false;
  let currentLanguage = 'ar';

  $: texts = currentLanguage === 'ar' ? {
    title: 'نسيت كلمة المرور؟',
    subtitle: 'سنرسل لك رابط إعادة تعيين كلمة المرور عبر الواتساب',
    whatsappLabel: 'رقم الواتساب',
    sendButton: 'إرسال الرابط',
    sending: 'جاري الإرسال...',
    sentMessage: 'تم إرسال رابط إعادة التعيين إلى واتساب',
    backToLogin: 'العودة لتسجيل الدخول'
  } : {
    title: 'Forgot Password?',
    subtitle: 'We\'ll send you a password reset link via WhatsApp',
    whatsappLabel: 'WhatsApp Number',
    sendButton: 'Send Link',
    sending: 'Sending...',
    sentMessage: 'Reset link sent to your WhatsApp',
    backToLogin: 'Back to Login'
  };

  async function handleSubmit() {
    loading = true;
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000));
    sent = true;
    loading = false;
  }
</script>

<div class="forgot-container">
  <Card>
    <div class="forgot-content">
      {#if !sent}
        <h1>{texts.title}</h1>
        <p class="subtitle">{texts.subtitle}</p>
        
        <form on:submit|preventDefault={handleSubmit}>
          <Input 
            label={texts.whatsappLabel} 
            bind:value={whatsappNumber} 
            type="tel" 
            placeholder="05xxxxxxxx"
            required 
          />
          
          <Button type="submit" fullWidth {loading}>
            {loading ? texts.sending : texts.sendButton}
          </Button>
        </form>
      {:else}
        <div class="success">
          <h1>✅</h1>
          <h2>{texts.sentMessage}</h2>
          <p>تحقق من رسائل الواتساب</p>
        </div>
      {/if}
      
      <div class="footer">
        <a href="/auth/login">{texts.backToLogin}</a>
      </div>
    </div>
  </Card>
</div>

<style>
  .forgot-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-4);
    background: var(--gradient-brand);
  }

  .forgot-content {
    padding: var(--space-8);
    max-width: 400px;
    width: 100%;
    text-align: center;
  }

  .subtitle {
    color: var(--color-ink-light);
    margin-bottom: var(--space-6);
  }

  .success h1 {
    font-size: 3rem;
    margin-bottom: var(--space-4);
  }

  .footer {
    margin-top: var(--space-6);
  }
</style>