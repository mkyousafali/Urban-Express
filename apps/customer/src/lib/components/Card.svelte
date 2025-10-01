<script>
  export let padding = 'default';
  export let shadow = true;
  export let border = true;
  export let rounded = true;
</script>

<div 
  class="card"
  class:card-padding-none={padding === 'none'}
  class:card-padding-sm={padding === 'sm'}
  class:card-padding-default={padding === 'default'}
  class:card-padding-lg={padding === 'lg'}
  class:card-shadow={shadow}
  class:card-border={border}
  class:card-rounded={rounded}
>
  <slot />
</div>

<style>
  .card {
    background-color: white;
    display: flex;
    flex-direction: column;
  }

  .card-border {
    border: 1px solid #E5E7EB;
  }

  .card-rounded {
    border-radius: 1rem;
  }

  .card-shadow {
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05), 0 10px 15px rgba(0, 0, 0, 0.1);
  }

  /* Padding variants */
  .card-padding-none {
    padding: 0;
  }

  .card-padding-sm {
    padding: 1rem;
  }

  .card-padding-default {
    padding: 1.5rem;
  }

  .card-padding-lg {
    padding: 2rem;
  }

  /* Hover effect */
  .card {
    transition: all 0.2s ease;
  }

  .card:hover {
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1), 0 16px 24px rgba(0, 0, 0, 0.1);
  }
</style>