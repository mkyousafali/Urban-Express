<script>
  export let padding = 'md'; // sm, md, lg
  export let variant = 'default'; // default, elevated
</script>

<div class="card card-{variant} card-{padding}">
  <slot />
</div>

<style>
  .card {
    background: white;
    border-radius: var(--radius-lg);
    border: 1px solid var(--color-border);
  }

  .card-elevated {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    border: none;
  }

  .card-sm {
    padding: var(--space-3);
  }

  .card-md {
    padding: var(--space-4);
  }

  .card-lg {
    padding: var(--space-6);
  }
</style>