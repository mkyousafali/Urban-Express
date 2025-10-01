<script>
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  import { goto } from '$app/navigation';
  
  let whatsappNumber = '';
  let password = '';
  let loading = false;
  let error = '';
  let adminClickCount = 0;
  let showAdminHint = false;
  let currentLanguage = 'ar'; // 'ar' for Arabic, 'en' for English

  // Demo credentials
  const demoCustomer = {
    whatsapp: '0501234567',
    password: 'demo123'
  };

  function formatWhatsAppNumber(value) {
    // Remove any non-digit characters
    const cleaned = value.replace(/\D/g, '');
    
    // Ensure it starts with 05
    if (cleaned.length > 0 && !cleaned.startsWith('05')) {
      return '05' + cleaned;
    }
    
    // Limit to 10 digits
    return cleaned.slice(0, 10);
  }

  function handleWhatsAppInput(event) {
    whatsappNumber = formatWhatsAppNumber(event.target.value);
  }

  async function handleLogin() {
    error = '';
    
    if (!whatsappNumber || !password) {
      error = texts.errors.required;
      return;
    }

    if (whatsappNumber.length !== 10) {
      error = texts.errors.invalidPhone;
      return;
    }

    loading = true;

    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Check demo credentials
      if (whatsappNumber === demoCustomer.whatsapp && password === demoCustomer.password) {
        // Save language preference
        localStorage.setItem('language', currentLanguage);
        
        // Successful login - redirect to home
        goto('/home');
      } else {
        error = texts.errors.invalidCredentials;
      }
    } catch (err) {
      error = texts.errors.loginError;
    } finally {
      loading = false;
    }
  }

  function fillDemoCredentials() {
    whatsappNumber = demoCustomer.whatsapp;
    password = demoCustomer.password;
  }

  function handleLogoClick() {
    adminClickCount++;
    if (adminClickCount >= 5) {
      showAdminHint = true;
      setTimeout(() => {
        showAdminHint = false;
        adminClickCount = 0;
      }, 3000);
    }
  }

  function handleAdminLogin() {
    goto('/auth/admin-login');
  }

  function handleSignUp() {
    goto('/auth/signup');
  }

  function toggleLanguage() {
    currentLanguage = currentLanguage === 'ar' ? 'en' : 'ar';
    // Update document direction
    document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = currentLanguage;
  }

  // Language text
  $: texts = currentLanguage === 'ar' ? {
    title: 'تسجيل الدخول',
    tagline: 'توصيل سريع، خدمة موثوقة',
    demoAccount: '🎯 حساب تجريبي',
    demoInstructions: 'للتجربة السريعة، استخدم البيانات التالية:',
    whatsappLabel: 'رقم الواتساب:',
    passwordLabel: 'كلمة المرور:',
    autoFill: 'املأ البيانات تلقائياً',
    whatsappPlaceholder: '05xxxxxxxx',
    passwordPlaceholder: 'أدخل كلمة المرور',
    signInButton: 'تسجيل الدخول',
    signingIn: 'جاري تسجيل الدخول...',
    signUpButton: 'إنشاء حساب',
    signUpText: 'ليس لديك حساب؟',
    createAccount: 'إنشاء حساب جديد',
    forgotPassword: 'نسيت كلمة المرور؟',
    adminHint: '🔐 تم اكتشاف محاولة دخول للإدارة',
    adminLogin: 'دخول كمدير نظام',
    termsText: 'بالمتابعة، أنت توافق على',
    terms: 'الشروط والأحكام',
    and: 'و',
    privacy: 'سياسة الخصوصية',
    errors: {
      required: 'يرجى إدخال رقم الواتساب وكلمة المرور',
      invalidPhone: 'رقم الواتساب يجب أن يكون 10 أرقام',
      invalidCredentials: 'رقم الواتساب أو كلمة المرور غير صحيحة',
      loginError: 'حدث خطأ في تسجيل الدخول. يرجى المحاولة مرة أخرى.'
    }
  } : {
    title: 'Sign In',
    tagline: 'Fast delivery, reliable service',
    demoAccount: '🎯 Demo Account',
    demoInstructions: 'For quick testing, use the following credentials:',
    whatsappLabel: 'WhatsApp Number:',
    passwordLabel: 'Password:',
    autoFill: 'Auto-fill credentials',
    whatsappPlaceholder: '05xxxxxxxx',
    passwordPlaceholder: 'Enter password',
    signInButton: 'Sign In',
    signingIn: 'Signing in...',
    signUpButton: 'Sign Up',
    signUpText: 'Don\'t have an account?',
    createAccount: 'Create new account',
    forgotPassword: 'Forgot password?',
    adminHint: '🔐 Admin access detected',
    adminLogin: 'Login as admin',
    termsText: 'By continuing, you agree to our',
    terms: 'Terms & Conditions',
    and: 'and',
    privacy: 'Privacy Policy',
    errors: {
      required: 'Please enter WhatsApp number and password',
      invalidPhone: 'WhatsApp number must be 10 digits',
      invalidCredentials: 'Invalid WhatsApp number or password',
      loginError: 'Sign in error occurred. Please try again.'
    }
  };
</script>

<svelte:head>
  <title>تسجيل الدخول - Urban Express</title>
</svelte:head>

<div class="login-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="login-content">
    <!-- Login Card with Logo Inside -->
    <Card>
      <div class="form-content">
        <!-- Logo Section Inside Form -->
        <div class="logo-section" role="button" tabindex="0" on:click={handleLogoClick} on:keydown={handleLogoClick}>
          <div class="logo">
            <div class="led-border">
              <img src="/logo.png" alt="Urban Express Logo" class="logo-image" />
            </div>
          </div>
          <p class="tagline">{texts.tagline}</p>
        </div>
        
        <!-- Language Toggle -->
        <div class="form-language-toggle">
          <button type="button" class="lang-btn" class:active={currentLanguage === 'ar'} on:click={toggleLanguage}>
            العربية
          </button>
          <button type="button" class="lang-btn" class:active={currentLanguage === 'en'} on:click={toggleLanguage}>
            English
          </button>
        </div>
        
        <h2>{texts.title}</h2>
        
        <!-- Demo Credentials Banner -->
        <div class="demo-banner">
          <div class="demo-content">
            <h3>{texts.demoAccount}</h3>
            <p>{texts.demoInstructions}</p>
            <div class="demo-credentials">
              <div class="credential-item">
                <span class="label">{texts.whatsappLabel}</span>
                <span class="value">{demoCustomer.whatsapp}</span>
              </div>
              <div class="credential-item">
                <span class="label">{texts.passwordLabel}</span>
                <span class="value">{demoCustomer.password}</span>
              </div>
            </div>
            <Button variant="secondary" size="sm" on:click={fillDemoCredentials}>
              {texts.autoFill}
            </Button>
          </div>
        </div>

        <form on:submit|preventDefault={handleLogin}>
          <div class="form-group">
            <Input
              label={texts.whatsappLabel.replace(':', '')}
              placeholder={texts.whatsappPlaceholder}
              type="tel"
              bind:value={whatsappNumber}
              on:input={handleWhatsAppInput}
              error={error && whatsappNumber.length > 0 && whatsappNumber.length !== 10 ? texts.errors.invalidPhone : ''}
              required
              dir="ltr"
            />
          </div>

          <div class="form-group">
            <Input
              label={texts.passwordLabel.replace(':', '')}
              placeholder={texts.passwordPlaceholder}
              type="password"
              bind:value={password}
              required
              dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}
            />
          </div>

          {#if error}
            <div class="error-message">
              {error}
            </div>
          {/if}

          <div class="form-actions">
            <Button 
              type="submit" 
              fullWidth 
              {loading}
              disabled={!whatsappNumber || !password}
            >
              {loading ? texts.signingIn : texts.signInButton}
            </Button>
          </div>
        </form>

        <div class="form-footer">
          <div class="signup-section">
            <span class="signup-text">{texts.signUpText}</span>
            <Button variant="secondary" size="sm" on:click={handleSignUp}>
              {texts.signUpButton}
            </Button>
          </div>
          <div class="links-section">
            <a href="/auth/forgot-password" class="link">{texts.forgotPassword}</a>
          </div>
        </div>

        <!-- Admin Hint -->
        {#if showAdminHint}
          <div class="admin-hint">
            <p>{texts.adminHint}</p>
            <Button variant="tertiary" size="sm" on:click={handleAdminLogin}>
              {texts.adminLogin}
            </Button>
          </div>
        {/if}
      </div>
    </Card>

    <!-- Terms Link -->
    <div class="terms-section">
      <p>
        {texts.termsText}
        <a href="/terms" class="link">{texts.terms}</a>
        {texts.and}
        <a href="/privacy" class="link">{texts.privacy}</a>
      </p>
    </div>
  </div>
</div>

<style>
  .login-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-4);
    background: var(--gradient-primary);
  }

  .form-language-toggle {
    display: flex;
    justify-content: center;
    gap: var(--space-2);
    margin-bottom: var(--space-6);
    padding: var(--space-2);
    background: var(--color-surface);
    border-radius: 0.75rem;
    border: 1px solid var(--color-border);
  }

  .lang-btn {
    padding: var(--space-2) var(--space-4);
    background: transparent;
    color: var(--color-ink-light);
    border: none;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
    min-width: 70px;
  }

  .lang-btn:hover {
    background: var(--color-border-light);
    color: var(--color-ink);
  }

  .lang-btn.active {
    background: var(--color-primary);
    color: white;
    font-weight: 600;
  }

  .login-content {
    width: 100%;
    max-width: 400px;
    text-align: center;
  }

  .logo-section {
    margin-bottom: var(--space-6);
    cursor: pointer;
    transition: transform 0.2s ease;
    text-align: center;
    padding: var(--space-4) 0;
    border-bottom: 1px solid var(--color-border-light);
  }

  .logo-section:hover {
    transform: scale(1.02);
  }

  .logo {
    margin-bottom: var(--space-3);
    display: flex;
    justify-content: center;
  }

  .led-border {
    position: relative;
    width: 180px;
    height: 120px;
    border-radius: 12px;
    padding: 8px;
    background: linear-gradient(45deg, 
      var(--color-primary) 0%, 
      var(--color-primary) 25%, 
      var(--color-accent) 50%, 
      var(--color-accent) 75%, 
      var(--color-primary) 100%
    );
    background-size: 400% 400%;
    animation: ledGlow 2s ease-in-out infinite;
    box-shadow: 
      0 0 20px rgba(76, 175, 80, 0.3),
      0 0 40px rgba(255, 152, 0, 0.2),
      inset 0 0 20px rgba(255, 255, 255, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .led-border::before {
    content: '';
    position: absolute;
    top: 4px;
    left: 4px;
    right: 4px;
    bottom: 4px;
    border-radius: 8px;
    background: white;
    z-index: 1;
  }

  .logo-image {
    width: 100px;
    height: 100px;
    object-fit: contain;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
    position: relative;
    z-index: 2;
    border-radius: 50%;
  }

  @keyframes ledGlow {
    0% {
      background-position: 0% 50%;
      box-shadow: 
        0 0 20px rgba(76, 175, 80, 0.6),
        0 0 40px rgba(76, 175, 80, 0.3),
        inset 0 0 20px rgba(255, 255, 255, 0.1);
    }
    50% {
      background-position: 100% 50%;
      box-shadow: 
        0 0 20px rgba(255, 152, 0, 0.6),
        0 0 40px rgba(255, 152, 0, 0.3),
        inset 0 0 20px rgba(255, 255, 255, 0.1);
    }
    100% {
      background-position: 0% 50%;
      box-shadow: 
        0 0 20px rgba(76, 175, 80, 0.6),
        0 0 40px rgba(76, 175, 80, 0.3),
        inset 0 0 20px rgba(255, 255, 255, 0.1);
    }
  }

  .tagline {
    color: var(--color-ink-light);
    font-size: 0.9rem;
    margin: 0;
    font-weight: 500;
  }

  .form-content {
    padding: var(--space-8);
  }

  h2 {
    color: var(--color-ink);
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0 0 var(--space-6) 0;
    text-align: center;
  }

  .demo-banner {
    background: linear-gradient(135deg, var(--color-success-light) 0%, #E8F5E8 100%);
    border: 1px solid var(--color-primary);
    border-radius: 1rem;
    padding: var(--space-4);
    margin-bottom: var(--space-6);
    text-align: right;
  }

  /* RTL/LTR Support */
  [dir="ltr"] .demo-banner {
    text-align: left;
  }

  [dir="ltr"] .form-group {
    text-align: left;
  }

  [dir="ltr"] .form-footer {
    text-align: center;
  }

  [dir="ltr"] .terms-section {
    text-align: center;
  }

  .demo-content h3 {
    color: var(--color-primary-dark);
    font-size: 1rem;
    font-weight: 600;
    margin: 0 0 var(--space-2) 0;
  }

  .demo-content p {
    color: var(--color-primary-dark);
    font-size: 0.875rem;
    margin: 0 0 var(--space-3) 0;
  }

  .demo-credentials {
    background: white;
    border-radius: 0.5rem;
    padding: var(--space-3);
    margin-bottom: var(--space-3);
  }

  .credential-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: var(--space-1);
    font-size: 0.875rem;
  }

  .credential-item:last-child {
    margin-bottom: 0;
  }

  .label {
    color: var(--color-ink-light);
  }

  .value {
    font-family: monospace;
    color: var(--color-ink);
    font-weight: 600;
    direction: ltr;
  }

  .form-group {
    margin-bottom: var(--space-4);
    text-align: right;
  }

  .error-message {
    background-color: var(--color-danger-light);
    color: var(--color-danger);
    padding: var(--space-3);
    border-radius: 0.5rem;
    font-size: 0.875rem;
    margin-bottom: var(--space-4);
    text-align: center;
  }

  .form-actions {
    margin-bottom: var(--space-6);
  }

  .form-footer {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
    text-align: center;
  }

  .link {
    color: var(--color-primary);
    text-decoration: none;
    font-weight: 500;
    transition: color 0.2s ease;
  }

  .link:hover {
    color: var(--color-primary-dark);
    text-decoration: underline;
  }

  .admin-hint {
    background: linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%);
    border: 1px solid var(--color-info);
    border-radius: 1rem;
    padding: var(--space-4);
    margin-top: var(--space-4);
    text-align: center;
  }

  .admin-hint p {
    color: var(--color-info);
    font-size: 0.875rem;
    margin: 0 0 var(--space-2) 0;
  }

  .terms-section {
    margin-top: var(--space-6);
    text-align: center;
  }

  .terms-section p {
    color: rgba(255, 255, 255, 0.8);
    font-size: 0.875rem;
    line-height: 1.5;
  }

  .terms-section .link {
    color: rgba(255, 255, 255, 0.9);
  }

  .terms-section .link:hover {
    color: white;
  }

  .signup-section {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-3);
    margin-bottom: var(--space-4);
    padding: var(--space-4);
    background: linear-gradient(135deg, var(--color-surface) 0%, #FFF8E1 100%);
    border-radius: 1rem;
    border: 1px solid rgba(225, 119, 57, 0.2);
  }

  .signup-text {
    color: var(--color-ink-light);
    font-size: 0.875rem;
    font-weight: 500;
  }

  .links-section {
    display: flex;
    justify-content: center;
  }

  /* Mobile Responsiveness */
  @media (max-width: 480px) {
    .login-container {
      padding: var(--space-2);
    }

    .form-content {
      padding: var(--space-4);
    }

    .led-border {
      width: 100px;
      height: 100px;
      padding: 6px;
    }

    .logo-image {
      width: 80px;
      height: 80px;
    }

    .tagline {
      font-size: 0.8rem;
    }

    .lang-btn {
      padding: var(--space-1) var(--space-3);
      font-size: 0.8rem;
      min-width: 60px;
    }

    .demo-credentials {
      font-size: 0.8rem;
    }
  }
</style>