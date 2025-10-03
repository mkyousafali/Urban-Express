<script>
  export let label = '';
  export let type = 'text';
  export let value = '';
  export let placeholder = '';
  export let required = false;
  export let disabled = false;
  export let error = '';
  export let helpText = '';
  export let fullWidth = true;
</script>

<div class="input-group" class:input-full-width={fullWidth}>
  {#if label}
    <label class="input-label" class:required>
      {label}
    </label>
  {/if}
  
  {#if type === 'textarea'}
    <textarea
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input textarea"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    ></textarea>
  {:else if type === 'email'}
    <input
      type="email"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else if type === 'password'}
    <input
      type="password"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else if type === 'number'}
    <input
      type="number"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else if type === 'tel'}
    <input
      type="tel"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else if type === 'url'}
    <input
      type="url"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else if type === 'date'}
    <input
      type="date"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else if type === 'time'}
    <input
      type="time"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {:else}
    <input
      type="text"
      {placeholder}
      {required}
      {disabled}
      bind:value
      class="input"
      class:error
      on:input
      on:blur
      on:focus
      on:change
    />
  {/if}
  
  {#if error}
    <span class="input-error">{error}</span>
  {:else if helpText}
    <span class="input-help">{helpText}</span>
  {/if}
</div>

<style>
  .input-group {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
  }

  .input-full-width {
    width: 100%;
  }

  .input-label {
    font-weight: 500;
    color: var(--color-ink);
    font-size: 0.875rem;
  }

  .input-label.required::after {
    content: ' *';
    color: var(--color-error);
  }

  .input {
    padding: var(--space-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    font-size: 1rem;
    transition: all 0.2s ease;
    background: white;
    font-family: inherit;
  }

  .input:focus {
    outline: none;
    border-color: var(--color-primary);
    box-shadow: 0 0 0 3px var(--color-primary-light);
  }

  .input.error {
    border-color: var(--color-error);
  }

  .input.error:focus {
    border-color: var(--color-error);
    box-shadow: 0 0 0 3px var(--color-error-light);
  }

  .input:disabled {
    background: var(--color-surface-variant);
    cursor: not-allowed;
    opacity: 0.6;
  }

  .textarea {
    min-height: 100px;
    resize: vertical;
    font-family: inherit;
  }

  .input-error {
    color: var(--color-error);
    font-size: 0.75rem;
    font-weight: 500;
  }

  .input-help {
    color: var(--color-ink-light);
    font-size: 0.75rem;
  }
</style>