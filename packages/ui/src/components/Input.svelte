<script lang="ts">
  export let value = '';
  export let placeholder = '';
  export let type: 'text' | 'password' | 'email' | 'tel' | 'number' = 'text';
  export let disabled = false;
  export let error = '';
  export let label = '';
  export let hint = '';
  export let required = false;
  export let dir: 'ltr' | 'rtl' | 'auto' = 'auto';

  let inputElement: HTMLInputElement;
  
  export function focus() {
    inputElement?.focus();
  }

  $: inputClasses = [
    'input',
    error ? 'input-error' : '',
    disabled ? 'input-disabled' : ''
  ].filter(Boolean).join(' ');
</script>

<div class="input-group" {dir}>
  {#if label}
    <label class="input-label" for={$$props.id}>
      {label}
      {#if required}
        <span class="required">*</span>
      {/if}
    </label>
  {/if}
  
  <input
    bind:this={inputElement}
    bind:value
    {type}
    {placeholder}
    {disabled}
    {required}
    class={inputClasses}
    on:input
    on:focus
    on:blur
    on:keydown
    {...$$restProps}
  />
  
  {#if error}
    <div class="input-error-text">{error}</div>
  {:else if hint}
    <div class="input-hint">{hint}</div>
  {/if}
</div>

<style>
  .input-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    width: 100%;
  }

  .input-label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #0F172A;
  }

  .required {
    color: #EF4444;
  }

  .input {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 2px solid #E2E8F0;
    border-radius: 1rem;
    font-size: 1rem;
    line-height: 1.4;
    background-color: white;
    color: #0F172A;
    min-height: 48px;
    transition: border-color 0.2s ease-in-out;
    font-family: inherit;
  }

  .input::placeholder {
    color: #64748B;
  }

  .input:focus {
    outline: none;
    border-color: #10B981;
    box-shadow: 0 0 0 3px rgb(16 185 129 / 0.1);
  }

  .input-disabled {
    background-color: #F8FAFC;
    opacity: 0.6;
    cursor: not-allowed;
  }

  .input-error {
    border-color: #EF4444;
  }

  .input-error:focus {
    border-color: #EF4444;
    box-shadow: 0 0 0 3px rgb(239 68 68 / 0.1);
  }

  .input-error-text {
    font-size: 0.875rem;
    color: #EF4444;
  }

  .input-hint {
    font-size: 0.875rem;
    color: #64748B;
  }

  /* RTL Support */
  .input-group[dir="rtl"] .input {
    text-align: right;
  }

  .input-group[dir="rtl"] .input-label {
    text-align: right;
  }
</style>