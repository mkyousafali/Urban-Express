<script>
  export let label = '';
  export let placeholder = '';
  export let type = 'text';
  export let value = '';
  export let disabled = false;
  export let required = false;
  export let error = '';
  export let dir = 'auto';

  let inputElement;

  export function focus() {
    inputElement?.focus();
  }

  export function blur() {
    inputElement?.blur();
  }
</script>

<div class="input-group" class:has-error={error}>
  {#if label}
    <label for={$$props.id} class="input-label">
      {label}
      {#if required}
        <span class="required">*</span>
      {/if}
    </label>
  {/if}
  
  {#if type === 'password'}
    <input
      bind:this={inputElement}
      bind:value
      type="password"
      {placeholder}
      {disabled}
      {required}
      {dir}
      class="input"
      class:input-error={error}
      id={$$props.id}
      on:input
      on:change
      on:focus
      on:blur
      on:keydown
      on:keyup
      {...$$restProps}
    />
  {:else if type === 'tel'}
    <input
      bind:this={inputElement}
      bind:value
      type="tel"
      {placeholder}
      {disabled}
      {required}
      {dir}
      class="input"
      class:input-error={error}
      id={$$props.id}
      on:input
      on:change
      on:focus
      on:blur
      on:keydown
      on:keyup
      {...$$restProps}
    />
  {:else}
    <input
      bind:this={inputElement}
      bind:value
      type="text"
      {placeholder}
      {disabled}
      {required}
      {dir}
      class="input"
      class:input-error={error}
      id={$$props.id}
      on:input
      on:change
      on:focus
      on:blur
      on:keydown
      on:keyup
      {...$$restProps}
    />
  {/if}
  
  {#if error}
    <div class="input-error-message">
      {error}
    </div>
  {/if}
</div>

<style>
  .input-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .input-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    text-align: right;
  }

  .required {
    color: #EF4444;
  }

  .input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #D1D5DB;
    border-radius: 0.5rem;
    font-size: 1rem;
    background-color: white;
    color: #111827;
    transition: all 0.2s ease;
  }

  .input:focus {
    outline: none;
    border-color: var(--color-primary);
    box-shadow: 0 0 0 3px rgba(16, 179, 0, 0.1);
  }

  .input:disabled {
    background-color: #F9FAFB;
    color: #9CA3AF;
    cursor: not-allowed;
  }

  .input-error {
    border-color: #EF4444;
  }

  .input-error:focus {
    border-color: #EF4444;
    box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
  }

  .input-error-message {
    font-size: 0.875rem;
    color: #EF4444;
    margin-top: 0.25rem;
    text-align: right;
  }

  .has-error .input-label {
    color: #EF4444;
  }

  /* RTL Support */
  [dir="rtl"] .input {
    text-align: right;
  }

  [dir="ltr"] .input {
    text-align: left;
  }
</style>