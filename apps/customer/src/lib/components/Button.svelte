<script>
  export let variant = 'primary';
  export let size = 'md';
  export let disabled = false;
  export let loading = false;
  export let fullWidth = false;
  export let type = 'button';

  $: classes = [
    'btn',
    `btn-${variant}`,
    `btn-${size}`,
    fullWidth && 'btn-full-width',
    disabled && 'btn-disabled',
    loading && 'btn-loading'
  ].filter(Boolean).join(' ');
</script>

<button 
  class={classes}
  {type}
  {disabled}
  on:click
  on:focus
  on:blur
  on:keydown
  on:keyup
  on:mouseenter
  on:mouseleave
>
  {#if loading}
    <span class="btn-spinner"></span>
  {/if}
  <slot />
</button>

<style>
  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    border: 1px solid transparent;
    border-radius: 0.5rem;
    font-size: 1rem;
    font-weight: 600;
    line-height: 1.25;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.2s ease;
    white-space: nowrap;
  }

  .btn:focus {
    outline: none;
    box-shadow: 0 0 0 3px rgba(16, 179, 0, 0.1);
  }

  /* Variants */
  .btn-primary {
    background: var(--gradient-primary);
    color: white;
    border-color: var(--color-primary);
  }

  .btn-primary:hover:not(.btn-disabled) {
    background: linear-gradient(135deg, var(--color-primary-dark) 0%, var(--color-secondary) 100%);
    border-color: var(--color-primary-dark);
    transform: translateY(-1px);
  }

  .btn-secondary {
    background: linear-gradient(135deg, #F3F4F6 0%, #E5E7EB 100%);
    color: #374151;
    border-color: #D1D5DB;
  }

  .btn-secondary:hover:not(.btn-disabled) {
    background: linear-gradient(135deg, #E5E7EB 0%, #D1D5DB 100%);
    border-color: #9CA3AF;
  }

  .btn-tertiary {
    background: transparent;
    color: var(--color-primary);
    border-color: var(--color-primary);
  }

  .btn-tertiary:hover:not(.btn-disabled) {
    background: var(--color-success-light);
    border-color: var(--color-primary-dark);
    color: var(--color-primary-dark);
  }

  /* Sizes */
  .btn-sm {
    padding: 0.5rem 0.75rem;
    font-size: 0.875rem;
  }

  .btn-md {
    padding: 0.75rem 1rem;
    font-size: 1rem;
  }

  .btn-lg {
    padding: 1rem 1.5rem;
    font-size: 1.125rem;
  }

  /* States */
  .btn-full-width {
    width: 100%;
  }

  .btn-disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none !important;
  }

  .btn-loading {
    cursor: wait;
  }

  .btn-spinner {
    width: 1rem;
    height: 1rem;
    border: 2px solid transparent;
    border-top: 2px solid currentColor;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
</style>