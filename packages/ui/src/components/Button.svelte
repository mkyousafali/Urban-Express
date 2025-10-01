<script lang="ts">
  export let variant: 'primary' | 'secondary' | 'tertiary' | 'danger' = 'primary';
  export let size: 'sm' | 'md' | 'lg' = 'md';
  export let disabled = false;
  export let loading = false;
  export let fullWidth = false;
  export let type: 'button' | 'submit' | 'reset' = 'button';

  $: classes = [
    'btn',
    `btn-${variant}`,
    `btn-${size}`,
    fullWidth ? 'btn-full' : '',
    disabled || loading ? 'btn-disabled' : ''
  ].filter(Boolean).join(' ');
</script>

<button 
  {type}
  class={classes}
  {disabled}
  on:click
  {...$$restProps}
>
  {#if loading}
    <div class="spinner"></div>
  {/if}
  <slot />
</button>

<style>
  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    border-radius: 1rem;
    font-weight: 500;
    font-size: 1rem;
    line-height: 1.4;
    text-decoration: none;
    border: 2px solid transparent;
    cursor: pointer;
    transition: all 0.2s ease-in-out;
    min-height: 48px;
    font-family: inherit;
  }

  .btn:focus-visible {
    outline: 2px solid #10B981;
    outline-offset: 2px;
  }

  .btn-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  /* Primary Button */
  .btn-primary {
    background-color: #10B981;
    color: white;
  }

  .btn-primary:hover:not(.btn-disabled) {
    background-color: #047857;
  }

  .btn-primary:active {
    background-color: #047857;
    transform: translateY(1px);
  }

  /* Secondary Button */
  .btn-secondary {
    background-color: transparent;
    color: #10B981;
    border-color: #10B981;
  }

  .btn-secondary:hover:not(.btn-disabled) {
    background-color: #10B981;
    color: white;
  }

  /* Tertiary Button */
  .btn-tertiary {
    background-color: transparent;
    color: #0F172A;
  }

  .btn-tertiary:hover:not(.btn-disabled) {
    background-color: #E2E8F0;
  }

  /* Danger Button */
  .btn-danger {
    background-color: #EF4444;
    color: white;
  }

  .btn-danger:hover:not(.btn-disabled) {
    background-color: #dc2626;
  }

  /* Button Sizes */
  .btn-sm {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
    min-height: 40px;
  }

  .btn-lg {
    padding: 1rem 2rem;
    font-size: 1.125rem;
    min-height: 56px;
  }

  /* Full Width Button */
  .btn-full {
    width: 100%;
  }

  /* Loading Spinner */
  .spinner {
    width: 20px;
    height: 20px;
    border: 2px solid transparent;
    border-top-color: currentColor;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>