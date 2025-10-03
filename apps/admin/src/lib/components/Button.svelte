<script>
  export let variant = 'primary'; // primary, secondary, outline, error, success
  export let size = 'md'; // sm, md, lg
  export let disabled = false;
  export let type = 'button';
  export let fullWidth = false;
</script>

<button
  {type}
  {disabled}
  class="btn btn-{variant} btn-{size}"
  class:btn-full-width={fullWidth}
  on:click
>
  <slot />
</button>

<style>
  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 500;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.2s ease;
    white-space: nowrap;
    font-family: inherit;
  }

  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  /* Sizes */
  .btn-sm {
    padding: var(--space-1) var(--space-3);
    font-size: 0.875rem;
  }

  .btn-md {
    padding: var(--space-2) var(--space-4);
    font-size: 1rem;
  }

  .btn-lg {
    padding: var(--space-3) var(--space-6);
    font-size: 1.125rem;
  }

  /* Variants */
  .btn-primary {
    background: var(--color-primary);
    color: white;
  }

  .btn-primary:hover:not(:disabled) {
    background: var(--color-primary-dark);
  }

  .btn-secondary {
    background: var(--color-surface-variant);
    color: var(--color-ink);
  }

  .btn-secondary:hover:not(:disabled) {
    background: var(--color-border);
  }

  .btn-outline {
    background: transparent;
    color: var(--color-primary);
    border: 1px solid var(--color-primary);
  }

  .btn-outline:hover:not(:disabled) {
    background: var(--color-primary);
    color: white;
  }

  .btn-error {
    background: var(--color-error);
    color: white;
  }

  .btn-error:hover:not(:disabled) {
    background: var(--color-error-dark);
  }

  .btn-success {
    background: var(--color-success);
    color: white;
  }

  .btn-success:hover:not(:disabled) {
    background: var(--color-success-dark);
  }

  .btn-full-width {
    width: 100%;
  }
</style>