<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';
  let currentPassword = '';
  let newPassword = '';
  let confirmPassword = '';
  let loading = false;
  let error = '';
  let success = false;

  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }
  });

  $: texts = currentLanguage === 'ar' ? {
    title: 'تغيير كلمة المرور',
    backToProfile: 'العودة إلى الملف الشخصي',
    currentPasswordLabel: 'كلمة المرور الحالية',
    newPasswordLabel: 'كلمة المرور الجديدة',
    confirmPasswordLabel: 'تأكيد كلمة المرور الجديدة',
    changePasswordButton: 'تغيير كلمة المرور',
    changing: 'جاري التغيير...',
    success: 'تم تغيير كلمة المرور بنجاح!',
    passwordsNotMatch: 'كلمات المرور غير متطابقة',
    passwordTooShort: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
  } : {
    title: 'Change Password',
    backToProfile: 'Back to Profile',
    currentPasswordLabel: 'Current Password',
    newPasswordLabel: 'New Password',
    confirmPasswordLabel: 'Confirm New Password',
    changePasswordButton: 'Change Password',
    changing: 'Changing...',
    success: 'Password changed successfully!',
    passwordsNotMatch: 'Passwords do not match',
    passwordTooShort: 'Password must be at least 6 characters'
  };

  async function handleSubmit() {
    error = '';
    
    if (newPassword !== confirmPassword) {
      error = texts.passwordsNotMatch;
      return;
    }
    
    if (newPassword.length < 6) {
      error = texts.passwordTooShort;
      return;
    }
    
    loading = true;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      success = true;
      setTimeout(() => {
        goto('/profile');
      }, 1500);
    } catch (err) {
      error = 'Failed to change password. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="change-password-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <header class="page-header">
    <Button variant="outline" size="sm" on:click={() => goto('/profile')}>
      ← {texts.backToProfile}
    </Button>
    <h1>{texts.title}</h1>
    <div></div>
  </header>

  <Card>
    <div class="form-section">
      {#if success}
        <div class="success-message">
          ✅ {texts.success}
        </div>
      {:else}
        <form on:submit|preventDefault={handleSubmit}>
          <Input 
            label={texts.currentPasswordLabel} 
            bind:value={currentPassword} 
            type="password" 
            required 
          />
          <Input 
            label={texts.newPasswordLabel} 
            bind:value={newPassword} 
            type="password" 
            required 
          />
          <Input 
            label={texts.confirmPasswordLabel} 
            bind:value={confirmPassword} 
            type="password" 
            required 
          />
          
          {#if error}
            <div class="error-message">{error}</div>
          {/if}
          
          <Button type="submit" variant="primary" fullWidth {loading}>
            {loading ? texts.changing : texts.changePasswordButton}
          </Button>
        </form>
      {/if}
    </div>
  </Card>
</div>

<style>
  .change-password-container {
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

  .form-section {
    padding: var(--space-6);
  }

  .success-message {
    text-align: center;
    padding: var(--space-4);
    background: var(--color-success-light);
    color: var(--color-success-dark);
    border-radius: var(--radius-lg);
    font-weight: 600;
  }

  .error-message {
    padding: var(--space-3);
    background: var(--color-error-light);
    color: var(--color-error-dark);
    border-radius: var(--radius-md);
    margin-bottom: var(--space-4);
    font-weight: 500;
  }
</style>