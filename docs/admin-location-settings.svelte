<!-- Admin Settings Component for Managing Location Sharing -->
<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let adminWhatsAppNumber = '+966501234567';
  let locationLinkField = '';
  let saved = false;
  let currentLanguage = 'ar';
  
  // Load settings from localStorage
  onMount(() => {
    const savedNumber = localStorage.getItem('adminWhatsAppNumber');
    if (savedNumber) {
      adminWhatsAppNumber = savedNumber;
    }
    
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }
  });

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'إعدادات مشاركة الموقع',
    whatsappLabel: 'رقم الواتساب لاستقبال المواقع',
    whatsappHelp: 'سيتم توجيه العملاء لإرسال مواقعهم إلى هذا الرقم',
    locationLinkLabel: 'رابط الموقع المستلم',
    locationLinkHelp: 'انسخ والصق رابط الموقع المستلم من العميل هنا',
    locationLinkPlaceholder: 'https://maps.google.com/...',
    saveButton: 'حفظ الإعدادات',
    saved: 'تم الحفظ بنجاح!',
    copyButton: 'نسخ الرابط',
    testWhatsAppButton: 'اختبار الواتساب',
    instructions: 'التعليمات:',
    step1: '1. تأكد من صحة رقم الواتساب أدناه',
    step2: '2. عندما يرسل العميل موقعه، انسخ رابط الموقع',
    step3: '3. الصق الرابط في حقل "رابط الموقع المستلم"',
    step4: '4. احفظ الإعدادات لربط العميل بموقعه'
  } : {
    title: 'Location Sharing Settings',
    whatsappLabel: 'WhatsApp Number for Receiving Locations',
    whatsappHelp: 'Customers will be directed to send their locations to this number',
    locationLinkLabel: 'Received Location Link',
    locationLinkHelp: 'Copy and paste the location link received from customer here',
    locationLinkPlaceholder: 'https://maps.google.com/...',
    saveButton: 'Save Settings',
    saved: 'Saved successfully!',
    copyButton: 'Copy Link',
    testWhatsAppButton: 'Test WhatsApp',
    instructions: 'Instructions:',
    step1: '1. Ensure the WhatsApp number below is correct',
    step2: '2. When customer sends their location, copy the location link',
    step3: '3. Paste the link in "Received Location Link" field',
    step4: '4. Save settings to link customer with their location'
  };

  function saveSettings() {
    localStorage.setItem('adminWhatsAppNumber', adminWhatsAppNumber);
    saved = true;
    setTimeout(() => saved = false, 3000);
  }

  function copyLocationLink() {
    if (locationLinkField) {
      navigator.clipboard.writeText(locationLinkField);
    }
  }

  function testWhatsApp() {
    const testMessage = encodeURIComponent('Test message from Urban Express admin panel');
    const whatsappUrl = `https://wa.me/${adminWhatsAppNumber.replace(/[^0-9]/g, '')}?text=${testMessage}`;
    window.open(whatsappUrl, '_blank');
  }
</script>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <Card>
    <div class="admin-content">
      <h1>{texts.title}</h1>
      
      <!-- Instructions -->
      <div class="instructions-section">
        <h3>{texts.instructions}</h3>
        <ul class="instructions-list">
          <li>{texts.step1}</li>
          <li>{texts.step2}</li>
          <li>{texts.step3}</li>
          <li>{texts.step4}</li>
        </ul>
      </div>

      <!-- WhatsApp Number Setting -->
      <div class="setting-group">
        <Input 
          label={texts.whatsappLabel} 
          bind:value={adminWhatsAppNumber} 
          type="tel" 
          required 
        />
        <p class="help-text">{texts.whatsappHelp}</p>
        <Button variant="outline" on:click={testWhatsApp}>
          {texts.testWhatsAppButton}
        </Button>
      </div>

      <!-- Location Link Field -->
      <div class="setting-group">
        <Input 
          label={texts.locationLinkLabel} 
          bind:value={locationLinkField} 
          placeholder={texts.locationLinkPlaceholder}
        />
        <p class="help-text">{texts.locationLinkHelp}</p>
        <Button variant="outline" on:click={copyLocationLink} disabled={!locationLinkField}>
          {texts.copyButton}
        </Button>
      </div>

      <!-- Save Button -->
      <div class="save-section">
        <Button variant="primary" fullWidth on:click={saveSettings}>
          {texts.saveButton}
        </Button>
        
        {#if saved}
          <div class="saved-message">
            ✓ {texts.saved}
          </div>
        {/if}
      </div>
    </div>
  </Card>
</div>

<style>
  .admin-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-4);
    background: var(--gradient-primary);
  }

  .admin-content {
    padding: var(--space-8);
    max-width: 600px;
    width: 100%;
  }

  h1 {
    text-align: center;
    margin-bottom: var(--space-6);
    color: var(--color-ink);
  }

  .instructions-section {
    margin-bottom: var(--space-6);
    padding: var(--space-4);
    background: var(--color-surface-variant);
    border-radius: var(--radius-lg);
  }

  .instructions-section h3 {
    margin-bottom: var(--space-3);
    color: var(--color-ink);
  }

  .instructions-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .instructions-list li {
    margin-bottom: var(--space-2);
    padding: var(--space-2) var(--space-3);
    background: var(--color-surface);
    border-radius: var(--radius-md);
    border: 1px solid var(--color-border);
  }

  .setting-group {
    margin-bottom: var(--space-6);
    padding: var(--space-4);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    background: var(--color-surface);
  }

  .help-text {
    font-size: 0.875rem;
    color: var(--color-ink-light);
    margin: var(--space-2) 0 var(--space-3) 0;
  }

  .save-section {
    text-align: center;
  }

  .saved-message {
    margin-top: var(--space-3);
    padding: var(--space-2);
    background: var(--color-success-light);
    color: var(--color-success-dark);
    border-radius: var(--radius-md);
    font-weight: 500;
  }

  /* Mobile Responsiveness */
  @media (max-width: 480px) {
    .admin-container {
      padding: var(--space-2);
    }

    .admin-content {
      padding: var(--space-4);
    }
  }
</style>