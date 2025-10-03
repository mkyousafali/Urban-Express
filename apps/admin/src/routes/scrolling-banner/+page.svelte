<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import { scrollingContent, scrollingContentActions } from '$lib/stores/scrollingContent.js';
  
  let currentLanguage = 'ar';
  let saved = false;
  let contentSlots = [];
  
  // Subscribe to scrolling content store
  $: contentSlots = $scrollingContent;
  
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }

    // Listen for language changes
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

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة شريط الإعلانات المتحرك',
    description: 'قم بتحرير محتوى الشريط المتحرك الذي يظهر في صفحة المنتجات',
    contentSlot: 'المحتوى',
    arabicContent: 'المحتوى بالعربية',
    englishContent: 'المحتوى بالإنجليزية',
    isActive: 'مفعل',
    active: 'مفعل',
    inactive: 'غير مفعل',
    save: 'حفظ التغييرات',
    saved: 'تم الحفظ بنجاح!',
    resetToDefaults: 'إعادة تعيين للافتراضي',
    preview: 'معاينة',
    noActiveContent: 'لا يوجد محتوى مفعل',
    confirmReset: 'هل أنت متأكد من إعادة تعيين المحتوى للإعدادات الافتراضية؟'
  } : {
    title: 'Manage Scrolling Banner',
    description: 'Edit the scrolling banner content that appears on the products page',
    contentSlot: 'Content Slot',
    arabicContent: 'Arabic Content',
    englishContent: 'English Content',
    isActive: 'Active',
    active: 'Active',
    inactive: 'Inactive',
    save: 'Save Changes',
    saved: 'Saved successfully!',
    resetToDefaults: 'Reset to Defaults',
    preview: 'Preview',
    noActiveContent: 'No active content',
    confirmReset: 'Are you sure you want to reset content to default settings?'
  };

  function updateContent(id, field, value) {
    scrollingContentActions.updateContent(id, { [field]: value });
  }

  function toggleActive(id) {
    scrollingContentActions.toggleActive(id);
  }

  function saveChanges() {
    // Content is automatically saved via the store subscription
    saved = true;
    setTimeout(() => saved = false, 3000);
  }

  function resetToDefaults() {
    if (confirm(texts.confirmReset)) {
      scrollingContentActions.resetToDefaults();
      saved = true;
      setTimeout(() => saved = false, 3000);
    }
  }

  function getActivePreview() {
    return scrollingContentActions.getActiveContent(contentSlots, currentLanguage);
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <h1>{texts.title}</h1>
  <p class="description">{texts.description}</p>

  <!-- Content Slots -->
  {#each contentSlots as slot (slot.id)}
    <Card>
      <div class="content-slot">
        <div class="slot-header">
          <h3>{texts.contentSlot} {slot.id}</h3>
          <label class="toggle-switch">
            <input 
              type="checkbox" 
              checked={slot.isActive}
              on:change={() => toggleActive(slot.id)}
            />
            <span class="toggle-slider"></span>
            <span class="toggle-label">
              {slot.isActive ? texts.active : texts.inactive}
            </span>
          </label>
        </div>

        <div class="content-inputs">
          <div class="input-group">
            <Input
              label={texts.arabicContent}
              value={slot.contentAr}
              on:input={(e) => updateContent(slot.id, 'contentAr', e.target.value)}
              placeholder="أدخل المحتوى بالعربية..."
            />
          </div>

          <div class="input-group">
            <Input
              label={texts.englishContent}
              value={slot.contentEn}
              on:input={(e) => updateContent(slot.id, 'contentEn', e.target.value)}
              placeholder="Enter content in English..."
            />
          </div>
        </div>
      </div>
    </Card>
  {/each}

  <!-- Preview Section -->
  <Card>
    <div class="preview-section">
      <h3>{texts.preview}</h3>
      <div class="preview-container">
        {#if getActivePreview().length > 0}
          <div class="preview-scrolling">
            {#each getActivePreview() as text}
              <span class="preview-text">{text}</span>
            {/each}
            {#each getActivePreview() as text}
              <span class="preview-text">{text}</span>
            {/each}
          </div>
        {:else}
          <div class="no-content">
            <p>{texts.noActiveContent}</p>
          </div>
        {/if}
      </div>
    </div>
  </Card>

  <!-- Action Buttons -->
  <div class="actions">
    <Button variant="primary" on:click={saveChanges}>
      {texts.save}
    </Button>
    
    <Button variant="outline" on:click={resetToDefaults}>
      {texts.resetToDefaults}
    </Button>
    
    {#if saved}
      <div class="saved-message">
        ✓ {texts.saved}
      </div>
    {/if}
  </div>
</div>

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 1000px;
    margin: 0 auto;
  }

  h1 {
    text-align: center;
    margin-bottom: var(--space-2);
    color: var(--color-ink);
  }

  .description {
    text-align: center;
    color: var(--color-ink-light);
    margin-bottom: var(--space-6);
    font-size: 1.1rem;
  }

  .content-slot {
    padding: var(--space-4);
  }

  .slot-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-4);
    padding-bottom: var(--space-2);
    border-bottom: 2px solid var(--color-border);
  }

  .slot-header h3 {
    margin: 0;
    color: var(--color-ink);
  }

  .toggle-switch {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    cursor: pointer;
  }

  .toggle-switch input {
    position: relative;
    width: 60px;
    height: 30px;
    appearance: none;
    background: #ccc;
    border-radius: 25px;
    outline: none;
    transition: 0.3s;
  }

  .toggle-switch input:checked {
    background: var(--color-primary);
  }

  .toggle-switch input::before {
    content: '';
    position: absolute;
    width: 26px;
    height: 26px;
    border-radius: 50%;
    top: 2px;
    left: 2px;
    background: white;
    transition: 0.3s;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
  }

  .toggle-switch input:checked::before {
    transform: translateX(30px);
  }

  .toggle-label {
    font-weight: 600;
    color: var(--color-ink);
  }

  .content-inputs {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: var(--space-4);
  }

  .input-group {
    display: flex;
    flex-direction: column;
  }

  .preview-section {
    padding: var(--space-4);
  }

  .preview-section h3 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
  }

  .preview-container {
    background: linear-gradient(90deg, #22c55e, #16a34a);
    padding: 0.5rem 0;
    border-radius: 8px;
    overflow: hidden;
    position: relative;
    min-height: 50px;
    display: flex;
    align-items: center;
  }

  .preview-scrolling {
    display: flex;
    white-space: nowrap;
    animation: scrollLeft 15s linear infinite;
  }

  .preview-text {
    color: white;
    font-weight: 600;
    font-size: 0.9rem;
    margin-right: 4rem;
    flex-shrink: 0;
  }

  [dir="rtl"] .preview-text {
    margin-right: 0;
    margin-left: 4rem;
  }

  [dir="rtl"] .preview-scrolling {
    animation: scrollRight 15s linear infinite;
  }

  @keyframes scrollLeft {
    0% { transform: translateX(100%); }
    100% { transform: translateX(-100%); }
  }

  @keyframes scrollRight {
    0% { transform: translateX(-100%); }
    100% { transform: translateX(100%); }
  }

  .no-content {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 50px;
    color: white;
    font-style: italic;
  }

  .actions {
    display: flex;
    gap: var(--space-3);
    align-items: center;
    justify-content: center;
    margin-top: var(--space-6);
  }

  .saved-message {
    padding: var(--space-2) var(--space-3);
    background: var(--color-success-light);
    color: var(--color-success-dark);
    border-radius: var(--radius-md);
    font-weight: 500;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .content-inputs {
      grid-template-columns: 1fr;
    }

    .slot-header {
      flex-direction: column;
      gap: var(--space-2);
      align-items: flex-start;
    }

    .actions {
      flex-direction: column;
    }
  }
</style>