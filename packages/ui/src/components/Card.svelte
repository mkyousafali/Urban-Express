<script lang="ts">
  export let interactive = false;
  export let padding = true;

  $: cardClasses = [
    'card',
    interactive ? 'card-interactive' : '',
    padding ? 'card-padded' : ''
  ].filter(Boolean).join(' ');
</script>

<div class={cardClasses} on:click on:keydown {...$$restProps}>
  <slot />
</div>

<style>
  .card {
    background-color: white;
    border-radius: 1.5rem;
    border: 1px solid #F1F5F9;
    box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
    overflow: hidden;
    transition: box-shadow 0.2s ease-in-out;
  }

  .card:hover {
    box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  }

  .card-padded {
    padding: 1.5rem;
  }

  .card-interactive {
    cursor: pointer;
  }

  .card-interactive:hover {
    box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
    transform: translateY(-2px);
  }

  .card-interactive:active {
    transform: translateY(0);
  }
</style>