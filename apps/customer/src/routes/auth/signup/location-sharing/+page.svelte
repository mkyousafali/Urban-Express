<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import { goto } from '$app/navigation';
  
  let currentLanguage = 'ar';
  let adminWhatsAppNumber = '+966501234567'; // This will be set by admin in settings
  
  // Load language from localStorage and listen for changes
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Listen for language changes from other tabs/pages
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

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'مشاركة الموقع مطلوبة',
    subtitle: 'تم إرسال طلب إنشاء الحساب بنجاح',
    instruction1: 'الخطوة الأخيرة المطلوبة: شارك موقعك مع فريق Urban Express',
    instruction2: 'انقر على الزر أدناه لفتح الواتساب ومشاركة موقعك',
    instruction3: 'لن يتم قبول طلبك وتفعيل حسابك حتى تشارك موقعك',
    activation: 'سيتم تفعيل حسابك خلال 24 ساعة بعد مشاركة الموقع',
    futureChange: 'يمكنك تغيير موقعك لاحقاً من صفحة الملف الشخصي',
    shareLocationBtn: 'مشاركة الموقع عبر الواتساب',
    backToLogin: 'العودة إلى تسجيل الدخول',
    whatsappMessage: 'مرحباً، أود مشاركة موقعي لتفعيل حساب Urban Express الخاص بي.',
    howToShare: 'كيفية مشاركة الموقع:',
    step1: '1. انقر على أيقونة المرفق (📎) في الواتساب',
    step2: '2. اختر "الموقع" من القائمة',
    step3: '3. اختر "الموقع الحالي" أو "الموقع المباشر"',
    step4: '4. أرسل الموقع',
    mandatory: '⚠️ مشاركة الموقع إجبارية',
    mandatoryNote: 'لا يمكن تفعيل حسابك بدون مشاركة موقعك. هذا ضروري لضمان توصيل طلباتك بدقة.'
  } : {
    title: 'Location Sharing Required',
    subtitle: 'Your signup request has been submitted successfully',
    instruction1: 'Final Required Step: Share your location with Urban Express team',
    instruction2: 'Click the button below to open WhatsApp and share your location',
    instruction3: 'Your request will NOT be accepted until you share your location',
    activation: 'Your account will be activated within 24 hours after sharing your location',
    futureChange: 'You can change your location later from your profile page',
    shareLocationBtn: 'Share Location via WhatsApp',
    backToLogin: 'Back to Login',
    whatsappMessage: 'Hello, I would like to share my location to activate my Urban Express account.',
    howToShare: 'How to share location:',
    step1: '1. Click the attachment icon (📎) in WhatsApp',
    step2: '2. Select "Location" from the menu',
    step3: '3. Choose "Current Location" or "Live Location"',
    step4: '4. Send the location',
    mandatory: '⚠️ Location Sharing is Mandatory',
    mandatoryNote: 'Your account cannot be activated without sharing your location. This is required to ensure accurate delivery of your orders.'
  };

  function openWhatsApp() {
    const message = encodeURIComponent(texts.whatsappMessage);
    const whatsappUrl = `https://wa.me/${adminWhatsAppNumber.replace(/[^0-9]/g, '')}?text=${message}`;
    
    // Open in new window/tab
    window.open(whatsappUrl, '_blank');
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="location-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <Card>
    <div class="location-content">
      <!-- Required Step Icon -->
      <div class="required-icon">
        <div class="location-icon">📍</div>
      </div>
      
      <h1>{texts.title}</h1>
      <p class="subtitle">{texts.subtitle}</p>
      
      <div class="instructions">
        <p class="instruction">{texts.instruction1}</p>
        <p class="instruction">{texts.instruction2}</p>
        <p class="instruction warning">{texts.instruction3}</p>
      </div>

      <!-- Mandatory Warning -->
      <div class="mandatory-warning">
        <h3>{texts.mandatory}</h3>
        <p>{texts.mandatoryNote}</p>
      </div>

      <!-- Activation Timeline -->
      <div class="timeline-info">
        <p class="activation-note">✅ {texts.activation}</p>
        <p class="future-change">🔄 {texts.futureChange}</p>
      </div>

      <!-- How to Share Location Guide -->
      <div class="guide-section">
        <h3>{texts.howToShare}</h3>
        <ul class="steps-list">
          <li>{texts.step1}</li>
          <li>{texts.step2}</li>
          <li>{texts.step3}</li>
          <li>{texts.step4}</li>
        </ul>
      </div>

      <!-- Action Button -->
      <div class="button-group">
        <Button 
          variant="primary" 
          fullWidth 
          on:click={openWhatsApp}
        >
          <span class="whatsapp-icon">📱</span>
          {texts.shareLocationBtn}
        </Button>
      </div>
      
      <div class="footer">
        <a href="/auth/login">{texts.backToLogin}</a>
      </div>
    </div>
  </Card>
</div>

<style>
  .location-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-4);
    background: var(--gradient-primary);
  }

  .location-content {
    padding: var(--space-8);
    max-width: 500px;
    width: 100%;
    text-align: center;
  }

  .required-icon {
    margin: 0 auto var(--space-6) auto;
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, #f59e0b, #d97706);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 20px rgba(245, 158, 11, 0.3);
    animation: pulse 2s infinite;
  }

  .location-icon {
    color: white;
    font-size: 2.5rem;
  }

  @keyframes pulse {
    0% {
      box-shadow: 0 4px 20px rgba(245, 158, 11, 0.3);
    }
    50% {
      box-shadow: 0 4px 30px rgba(245, 158, 11, 0.6);
    }
    100% {
      box-shadow: 0 4px 20px rgba(245, 158, 11, 0.3);
    }
  }

  .success-icon {
    margin: 0 auto var(--space-6) auto;
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, #4CAF50, #45a049);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 20px rgba(76, 175, 80, 0.3);
  }

  .checkmark {
    color: white;
    font-size: 2.5rem;
    font-weight: bold;
  }

  h1 {
    margin-bottom: var(--space-2);
    color: var(--color-ink);
  }

  .subtitle {
    color: var(--color-ink-light);
    margin-bottom: var(--space-6);
    font-size: 1.1rem;
  }

  .instructions {
    margin-bottom: var(--space-6);
    text-align: start;
  }

  .instruction {
    margin-bottom: var(--space-3);
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-lg);
    border-left: 4px solid var(--color-primary);
  }

  .instruction.warning {
    background: var(--color-error-light);
    border-left-color: var(--color-error);
    font-weight: 600;
    color: var(--color-error-dark);
  }

  .mandatory-warning {
    margin-bottom: var(--space-6);
    padding: var(--space-4);
    background: #fef2f2;
    border: 2px solid #f87171;
    border-radius: var(--radius-lg);
    text-align: center;
  }

  .mandatory-warning h3 {
    margin-bottom: var(--space-2);
    color: #dc2626;
    font-size: 1.2rem;
  }

  .mandatory-warning p {
    color: #7f1d1d;
    font-weight: 500;
    margin: 0;
  }

  .timeline-info {
    margin-bottom: var(--space-6);
    padding: var(--space-4);
    background: #f0f9ff;
    border: 1px solid #7dd3fc;
    border-radius: var(--radius-lg);
    text-align: center;
  }

  .activation-note {
    color: #0c4a6e;
    font-weight: 600;
    margin-bottom: var(--space-2);
  }

  .future-change {
    color: #0369a1;
    font-size: 0.9rem;
    margin: 0;
  }

  .instruction.final {
    background: var(--color-success-light);
    border-left-color: var(--color-success);
    font-weight: 500;
  }

  .guide-section {
    margin-bottom: var(--space-6);
    padding: var(--space-4);
    background: var(--color-surface-variant);
    border-radius: var(--radius-lg);
    text-align: start;
  }

  .guide-section h3 {
    margin-bottom: var(--space-3);
    color: var(--color-ink);
    font-size: 1.1rem;
  }

  .steps-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .steps-list li {
    margin-bottom: var(--space-2);
    padding: var(--space-2) var(--space-3);
    background: var(--color-surface);
    border-radius: var(--radius-md);
    border: 1px solid var(--color-border);
  }

  .button-group {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
    margin-bottom: var(--space-6);
  }

  .whatsapp-icon {
    margin-right: var(--space-2);
  }

  .footer {
    text-align: center;
  }

  .footer a {
    color: var(--color-primary);
    text-decoration: none;
    font-weight: 500;
  }

  .footer a:hover {
    text-decoration: underline;
  }

  /* Mobile Responsiveness */
  @media (max-width: 480px) {
    .location-container {
      padding: var(--space-2);
    }

    .location-content {
      padding: var(--space-4);
    }

    .success-icon {
      width: 60px;
      height: 60px;
    }

    .required-icon {
      width: 60px;
      height: 60px;
    }

    .location-icon {
      font-size: 2rem;
    }

    .checkmark {
      font-size: 2rem;
    }
  }
</style>