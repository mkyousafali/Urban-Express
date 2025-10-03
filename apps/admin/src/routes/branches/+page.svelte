<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
  import Input from '$lib/components/Input.svelte';
  import AdminNav from '$lib/components/AdminNav.svelte';
  import { branches, adminActions } from '$lib/stores/admin.js';
  
  let currentLanguage = 'ar';
  let showForm = false;
  let editingBranch = null;
  let saved = false;
  
  // Form data
  let formData = {
    nameAr: '',
    nameEn: '',
    addressAr: '',
    addressEn: '',
    phone: '',
    latitude: '',
    longitude: '',
    pickupService: {
      isActive: true,
      isAvailable24Hours: false,
      startTime: '08:00',
      endTime: '22:00',
      displayAr: '',
      displayEn: ''
    },
    deliveryService: {
      isActive: true,
      isAvailable24Hours: false,
      startTime: '08:00',
      endTime: '23:00',
      displayAr: '',
      displayEn: '',
      deliveryRadius: 10, // km
      deliveryFee: 15,
      minimumOrder: 50
    },
    staff: {
      pickupStaff: [],
      deliveryBoys: []
    },
    isActive: true
  };
  
  // Subscribe to stores
  $: currentBranches = $branches;
  
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
      document.documentElement.dir = currentLanguage === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = currentLanguage;
    }
  });

  // Language texts
  $: texts = currentLanguage === 'ar' ? {
    title: 'إدارة الفروع',
    addBranch: 'إضافة فرع جديد',
    editBranch: 'تعديل الفرع',
    basicInfo: 'المعلومات الأساسية',
    arabicName: 'الاسم بالعربية',
    englishName: 'الاسم بالإنجليزية',
    arabicAddress: 'العنوان بالعربية',
    englishAddress: 'العنوان بالإنجليزية',
    phone: 'رقم الهاتف',
    location: 'الموقع',
    latitude: 'خط العرض',
    longitude: 'خط الطول',
    getLocation: 'الحصول على الموقع',
    pickupService: 'خدمة الاستلام',
    deliveryService: 'خدمة التوصيل',
    serviceActive: 'الخدمة مفعلة',
    available24Hours: 'متاح 24 ساعة',
    startTime: 'وقت البداية',
    endTime: 'وقت النهاية',
    deliveryRadius: 'نطاق التوصيل (كم)',
    deliveryFee: 'رسوم التوصيل',
    minimumOrder: 'الحد الأدنى للطلب',
    staffManagement: 'إدارة الموظفين',
    pickupStaff: 'موظفي الاستلام',
    deliveryBoys: 'مناديب التوصيل',
    addStaff: 'إضافة موظف',
    staffName: 'اسم الموظف',
    staffPhone: 'هاتف الموظف',
    save: 'حفظ',
    cancel: 'إلغاء',
    edit: 'تعديل',
    delete: 'حذف',
    active: 'مفعل',
    inactive: 'غير مفعل',
    saved: 'تم الحفظ بنجاح!',
    sar: 'ريال',
    km: 'كم',
    required: 'مطلوب',
    noBranches: 'لا توجد فروع',
    confirmDelete: 'هل أنت متأكد من حذف هذا الفرع؟',
    remove: 'إزالة',
    locationObtained: 'تم الحصول على الموقع',
    locationError: 'خطأ في الحصول على الموقع'
  } : {
    title: 'Branch Management',
    addBranch: 'Add New Branch',
    editBranch: 'Edit Branch',
    basicInfo: 'Basic Information',
    arabicName: 'Arabic Name',
    englishName: 'English Name',
    arabicAddress: 'Arabic Address',
    englishAddress: 'English Address',
    phone: 'Phone Number',
    location: 'Location',
    latitude: 'Latitude',
    longitude: 'Longitude',
    getLocation: 'Get Current Location',
    pickupService: 'Pickup Service',
    deliveryService: 'Delivery Service',
    serviceActive: 'Service Active',
    available24Hours: 'Available 24 Hours',
    startTime: 'Start Time',
    endTime: 'End Time',
    deliveryRadius: 'Delivery Radius (km)',
    deliveryFee: 'Delivery Fee',
    minimumOrder: 'Minimum Order',
    staffManagement: 'Staff Management',
    pickupStaff: 'Pickup Staff',
    deliveryBoys: 'Delivery Boys',
    addStaff: 'Add Staff',
    staffName: 'Staff Name',
    staffPhone: 'Staff Phone',
    save: 'Save',
    cancel: 'Cancel',
    edit: 'Edit',
    delete: 'Delete',
    active: 'Active',
    inactive: 'Inactive',
    saved: 'Saved successfully!',
    sar: 'SAR',
    km: 'km',
    required: 'Required',
    noBranches: 'No branches',
    confirmDelete: 'Are you sure you want to delete this branch?',
    remove: 'Remove',
    locationObtained: 'Location obtained',
    locationError: 'Error getting location'
  };

  function resetForm() {
    formData = {
      nameAr: '',
      nameEn: '',
      addressAr: '',
      addressEn: '',
      phone: '',
      latitude: '',
      longitude: '',
      pickupService: {
        isActive: true,
        isAvailable24Hours: false,
        startTime: '08:00',
        endTime: '22:00',
        displayAr: '',
        displayEn: ''
      },
      deliveryService: {
        isActive: true,
        isAvailable24Hours: false,
        startTime: '08:00',
        endTime: '23:00',
        displayAr: '',
        displayEn: '',
        deliveryRadius: 10,
        deliveryFee: 15,
        minimumOrder: 50
      },
      staff: {
        pickupStaff: [],
        deliveryBoys: []
      },
      isActive: true
    };
    editingBranch = null;
  }

  function showAddForm() {
    resetForm();
    showForm = true;
  }

  function showEditForm(branch) {
    editingBranch = branch;
    formData = JSON.parse(JSON.stringify(branch)); // Deep copy
    showForm = true;
  }

  function cancelForm() {
    showForm = false;
    resetForm();
  }

  function getCurrentLocation() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          formData.latitude = position.coords.latitude.toString();
          formData.longitude = position.coords.longitude.toString();
          alert(texts.locationObtained);
        },
        (error) => {
          console.error("Error getting location:", error);
          alert(texts.locationError);
        }
      );
    } else {
      alert("Geolocation is not supported by this browser.");
    }
  }

  function addStaff(type) {
    const staffMember = {
      id: Date.now(),
      name: '',
      phone: '',
      isActive: true
    };
    
    if (type === 'pickup') {
      formData.staff.pickupStaff = [...formData.staff.pickupStaff, staffMember];
    } else {
      formData.staff.deliveryBoys = [...formData.staff.deliveryBoys, staffMember];
    }
  }

  function removeStaff(type, index) {
    if (type === 'pickup') {
      formData.staff.pickupStaff = formData.staff.pickupStaff.filter((_, i) => i !== index);
    } else {
      formData.staff.deliveryBoys = formData.staff.deliveryBoys.filter((_, i) => i !== index);
    }
  }

  function updateTimeDisplays() {
    // Update pickup service display
    if (formData.pickupService.isAvailable24Hours) {
      formData.pickupService.displayAr = '24 ساعة';
      formData.pickupService.displayEn = '24 Hours';
    } else {
      const startTime12 = convertTo12Hour(formData.pickupService.startTime);
      const endTime12 = convertTo12Hour(formData.pickupService.endTime);
      formData.pickupService.displayAr = `${startTime12.ar} - ${endTime12.ar}`;
      formData.pickupService.displayEn = `${startTime12.en} - ${endTime12.en}`;
    }

    // Update delivery service display
    if (formData.deliveryService.isAvailable24Hours) {
      formData.deliveryService.displayAr = '24 ساعة';
      formData.deliveryService.displayEn = '24 Hours';
    } else {
      const startTime12 = convertTo12Hour(formData.deliveryService.startTime);
      const endTime12 = convertTo12Hour(formData.deliveryService.endTime);
      formData.deliveryService.displayAr = `${startTime12.ar} - ${endTime12.ar}`;
      formData.deliveryService.displayEn = `${startTime12.en} - ${endTime12.en}`;
    }
  }

  function convertTo12Hour(time24) {
    const [hours, minutes] = time24.split(':');
    const hour = parseInt(hours);
    const hour12 = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
    const period = hour < 12 ? 'AM' : 'PM';
    const periodAr = hour < 12 ? 'ص' : 'م';
    
    return {
      en: `${hour12}:${minutes} ${period}`,
      ar: `${hour12}:${minutes} ${periodAr}`
    };
  }

  function saveBranch() {
    // Validation
    if (!formData.nameAr || !formData.nameEn || !formData.addressAr || 
        !formData.addressEn || !formData.phone) {
      alert(texts.required);
      return;
    }

    updateTimeDisplays();

    const branchData = {
      ...formData,
      updatedAt: new Date().toISOString()
    };

    if (editingBranch) {
      adminActions.updateBranch(editingBranch.id, branchData);
    } else {
      adminActions.addBranch(branchData);
    }

    saved = true;
    setTimeout(() => saved = false, 3000);
    showForm = false;
    resetForm();
  }

  function deleteBranch(branch) {
    if (confirm(texts.confirmDelete)) {
      adminActions.updateBranch(branch.id, { isActive: false });
    }
  }

  function toggleBranchStatus(branch) {
    adminActions.updateBranch(branch.id, { isActive: !branch.isActive });
  }



  // Watch for time changes and update displays
  $: if (formData.pickupService.startTime || formData.pickupService.endTime || 
         formData.deliveryService.startTime || formData.deliveryService.endTime) {
    updateTimeDisplays();
  }
</script>

<svelte:head>
  <title>{texts.title}</title>
</svelte:head>

<AdminNav title={texts.title} />

<div class="admin-container" dir={currentLanguage === 'ar' ? 'rtl' : 'ltr'}>
  <div class="header">
    <h1>{texts.title}</h1>
    <Button variant="primary" on:click={showAddForm}>
      {texts.addBranch}
    </Button>
  </div>

  {#if saved}
    <div class="saved-message">
      ✓ {texts.saved}
    </div>
  {/if}

  <!-- Branch Form -->
  {#if showForm}
    <Card>
      <div class="form-container">
        <h2>{editingBranch ? texts.editBranch : texts.addBranch}</h2>
        
        <!-- Basic Information -->
        <div class="form-section">
          <h3>{texts.basicInfo}</h3>
          
          <div class="form-row">
            <Input
              label="{texts.arabicName} *"
              bind:value={formData.nameAr}
              required
            />
            <Input
              label="{texts.englishName} *"
              bind:value={formData.nameEn}
              required
            />
          </div>

          <div class="form-row">
            <Input
              label="{texts.arabicAddress} *"
              bind:value={formData.addressAr}
              required
            />
            <Input
              label="{texts.englishAddress} *"
              bind:value={formData.addressEn}
              required
            />
          </div>

          <div class="form-row">
            <Input
              label="{texts.phone} *"
              type="tel"
              bind:value={formData.phone}
              required
            />
          </div>

          <!-- Location -->
          <div class="location-section">
            <h4>{texts.location}</h4>
            <div class="form-row">
              <Input
                label={texts.latitude}
                type="number"
                step="any"
                bind:value={formData.latitude}
              />
              <Input
                label={texts.longitude}
                type="number"
                step="any"
                bind:value={formData.longitude}
              />
              <Button variant="outline" on:click={getCurrentLocation}>
                {texts.getLocation}
              </Button>
            </div>
          </div>
        </div>

        <!-- Pickup Service -->
        <div class="form-section">
          <h3>{texts.pickupService}</h3>
          
          <div class="service-controls">
            <label class="checkbox-label">
              <input type="checkbox" bind:checked={formData.pickupService.isActive} />
              {texts.serviceActive}
            </label>
            
            <label class="checkbox-label">
              <input type="checkbox" bind:checked={formData.pickupService.isAvailable24Hours} />
              {texts.available24Hours}
            </label>
          </div>

          {#if !formData.pickupService.isAvailable24Hours}
            <div class="form-row">
              <Input
                label={texts.startTime}
                type="time"
                bind:value={formData.pickupService.startTime}
              />
              <Input
                label={texts.endTime}
                type="time"
                bind:value={formData.pickupService.endTime}
              />
            </div>
          {/if}
        </div>

        <!-- Delivery Service -->
        <div class="form-section">
          <h3>{texts.deliveryService}</h3>
          
          <div class="service-controls">
            <label class="checkbox-label">
              <input type="checkbox" bind:checked={formData.deliveryService.isActive} />
              {texts.serviceActive}
            </label>
            
            <label class="checkbox-label">
              <input type="checkbox" bind:checked={formData.deliveryService.isAvailable24Hours} />
              {texts.available24Hours}
            </label>
          </div>

          {#if !formData.deliveryService.isAvailable24Hours}
            <div class="form-row">
              <Input
                label={texts.startTime}
                type="time"
                bind:value={formData.deliveryService.startTime}
              />
              <Input
                label={texts.endTime}
                type="time"
                bind:value={formData.deliveryService.endTime}
              />
            </div>
          {/if}

          <div class="form-row">
            <Input
              label="{texts.deliveryRadius} ({texts.km})"
              type="number"
              bind:value={formData.deliveryService.deliveryRadius}
              min="1"
            />
            <Input
              label="{texts.deliveryFee} ({texts.sar})"
              type="number"
              step="0.01"
              bind:value={formData.deliveryService.deliveryFee}
              min="0"
            />
            <Input
              label="{texts.minimumOrder} ({texts.sar})"
              type="number"
              step="0.01"
              bind:value={formData.deliveryService.minimumOrder}
              min="0"
            />
          </div>
        </div>

        <!-- Staff Management -->
        <div class="form-section">
          <h3>{texts.staffManagement}</h3>
          
          <!-- Pickup Staff -->
          <div class="staff-subsection">
            <div class="staff-header">
              <h4>{texts.pickupStaff}</h4>
              <Button variant="outline" size="sm" on:click={() => addStaff('pickup')}>
                {texts.addStaff}
              </Button>
            </div>
            
            {#each formData.staff.pickupStaff as staff, index}
              <div class="staff-item">
                <Input
                  label={texts.staffName}
                  bind:value={staff.name}
                />
                <Input
                  label={texts.staffPhone}
                  type="tel"
                  bind:value={staff.phone}
                />
                <Button variant="error" size="sm" on:click={() => removeStaff('pickup', index)}>
                  {texts.remove}
                </Button>
              </div>
            {/each}
          </div>

          <!-- Delivery Boys -->
          <div class="staff-subsection">
            <div class="staff-header">
              <h4>{texts.deliveryBoys}</h4>
              <Button variant="outline" size="sm" on:click={() => addStaff('delivery')}>
                {texts.addStaff}
              </Button>
            </div>
            
            {#each formData.staff.deliveryBoys as staff, index}
              <div class="staff-item">
                <Input
                  label={texts.staffName}
                  bind:value={staff.name}
                />
                <Input
                  label={texts.staffPhone}
                  type="tel"
                  bind:value={staff.phone}
                />
                <Button variant="error" size="sm" on:click={() => removeStaff('delivery', index)}>
                  {texts.remove}
                </Button>
              </div>
            {/each}
          </div>
        </div>

        <!-- Form Actions -->
        <div class="form-actions">
          <Button variant="primary" on:click={saveBranch}>
            {texts.save}
          </Button>
          <Button variant="outline" on:click={cancelForm}>
            {texts.cancel}
          </Button>
        </div>
      </div>
    </Card>
  {/if}

  <!-- Branches List -->
  <div class="branches-list">
    {#if currentBranches.length === 0}
      <div class="no-branches">
        <p>{texts.noBranches}</p>
      </div>
    {:else}
      {#each currentBranches as branch}
        <Card>
          <div class="branch-item">
            <div class="branch-info">
              <div class="branch-header">
                <h3>{currentLanguage === 'ar' ? branch.nameAr : branch.nameEn}</h3>
                <div class="branch-status">
                  <span class="status-badge" class:active={branch.isActive} class:inactive={!branch.isActive}>
                    {branch.isActive ? texts.active : texts.inactive}
                  </span>
                </div>
              </div>
              
              <p class="address">📍 {currentLanguage === 'ar' ? branch.addressAr : branch.addressEn}</p>
              <p class="phone">📞 {branch.phone}</p>
              
              <div class="services">
                <div class="service-info">
                  <strong>{texts.pickupService}:</strong>
                  {#if branch.pickupService?.isActive}
                    <span class="service-active">
                      {currentLanguage === 'ar' ? branch.pickupService.displayAr : branch.pickupService.displayEn}
                    </span>
                  {:else}
                    <span class="service-inactive">{texts.inactive}</span>
                  {/if}
                </div>
                
                <div class="service-info">
                  <strong>{texts.deliveryService}:</strong>
                  {#if branch.deliveryService?.isActive}
                    <span class="service-active">
                      {currentLanguage === 'ar' ? branch.deliveryService.displayAr : branch.deliveryService.displayEn}
                    </span>
                  {:else}
                    <span class="service-inactive">{texts.inactive}</span>
                  {/if}
                </div>
              </div>

              {#if branch.staff}
                <div class="staff-summary">
                  <span>{texts.pickupStaff}: {branch.staff.pickupStaff?.length || 0}</span>
                  <span>{texts.deliveryBoys}: {branch.staff.deliveryBoys?.length || 0}</span>
                </div>
              {/if}
            </div>

            <div class="branch-actions">
              <Button variant="outline" size="sm" on:click={() => showEditForm(branch)}>
                {texts.edit}
              </Button>
              <Button 
                variant={branch.isActive ? 'outline' : 'primary'} 
                size="sm" 
                on:click={() => toggleBranchStatus(branch)}
              >
                {branch.isActive ? texts.inactive : texts.active}
              </Button>
              <Button variant="error" size="sm" on:click={() => deleteBranch(branch)}>
                {texts.delete}
              </Button>
            </div>
          </div>
        </Card>
      {/each}
    {/if}
  </div>
</div>

<style>
  .admin-container {
    min-height: 100vh;
    padding: var(--space-4);
    background: var(--color-surface);
    max-width: 1200px;
    margin: 0 auto;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-6);
  }

  .header h1 {
    margin: 0;
    color: var(--color-ink);
  }

  .saved-message {
    margin-bottom: var(--space-4);
    padding: var(--space-3);
    background: var(--color-success-light);
    color: var(--color-success-dark);
    border-radius: var(--radius-md);
    font-weight: 500;
    text-align: center;
  }

  .form-container {
    padding: var(--space-6);
  }

  .form-container h2 {
    margin: 0 0 var(--space-6) 0;
    color: var(--color-ink);
  }

  .form-section {
    margin-bottom: var(--space-6);
    padding-bottom: var(--space-4);
    border-bottom: 1px solid var(--color-border);
  }

  .form-section:last-child {
    border-bottom: none;
  }

  .form-section h3 {
    margin: 0 0 var(--space-4) 0;
    color: var(--color-ink);
  }

  .form-section h4 {
    margin: 0 0 var(--space-3) 0;
    color: var(--color-ink);
    font-size: 1rem;
  }

  .form-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: var(--space-4);
    margin-bottom: var(--space-4);
  }

  .location-section {
    margin-top: var(--space-4);
  }

  .service-controls {
    display: flex;
    gap: var(--space-4);
    margin-bottom: var(--space-4);
  }

  .checkbox-label {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    cursor: pointer;
    font-weight: 500;
  }

  .checkbox-label input[type="checkbox"] {
    width: 18px;
    height: 18px;
  }

  .staff-subsection {
    margin-bottom: var(--space-4);
  }

  .staff-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-3);
  }

  .staff-header h4 {
    margin: 0;
  }

  .staff-item {
    display: grid;
    grid-template-columns: 1fr 1fr auto;
    gap: var(--space-3);
    align-items: end;
    margin-bottom: var(--space-3);
    padding: var(--space-3);
    background: var(--color-surface-variant);
    border-radius: var(--radius-md);
  }

  .form-actions {
    display: flex;
    gap: var(--space-3);
    justify-content: flex-end;
    margin-top: var(--space-6);
  }

  .branches-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .no-branches {
    text-align: center;
    padding: var(--space-8);
    color: var(--color-ink-light);
  }

  .branch-item {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: var(--space-4);
  }

  .branch-info {
    flex: 1;
  }

  .branch-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-2);
  }

  .branch-header h3 {
    margin: 0;
    color: var(--color-ink);
  }

  .status-badge {
    padding: var(--space-1) var(--space-3);
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-badge.active {
    background: var(--color-success-light);
    color: var(--color-success-dark);
  }

  .status-badge.inactive {
    background: var(--color-error-light);
    color: var(--color-error-dark);
  }

  .address, .phone {
    color: var(--color-ink-light);
    margin: 0 0 var(--space-2) 0;
  }

  .services {
    margin: var(--space-3) 0;
  }

  .service-info {
    margin-bottom: var(--space-2);
    font-size: 0.9rem;
  }

  .service-active {
    color: var(--color-success-dark);
    font-weight: 500;
  }

  .service-inactive {
    color: var(--color-error-dark);
    font-weight: 500;
  }

  .staff-summary {
    display: flex;
    gap: var(--space-4);
    font-size: 0.85rem;
    color: var(--color-ink-light);
  }

  .branch-actions {
    display: flex;
    gap: var(--space-2);
    flex-shrink: 0;
    flex-wrap: wrap;
  }

  /* Mobile Responsiveness */
  @media (max-width: 768px) {
    .admin-container {
      padding: var(--space-2);
    }

    .header {
      flex-direction: column;
      gap: var(--space-3);
      align-items: stretch;
    }

    .form-row {
      grid-template-columns: 1fr;
    }

    .service-controls {
      flex-direction: column;
    }

    .staff-item {
      grid-template-columns: 1fr;
    }

    .branch-item {
      flex-direction: column;
      gap: var(--space-3);
    }

    .branch-actions {
      justify-content: flex-start;
    }

    .form-actions {
      flex-direction: column;
    }
  }
</style>