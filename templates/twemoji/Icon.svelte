<script lang="ts">
  import type { ComponentType } from 'svelte';
  export let icon: ComponentType;
  export let size: number = 30;
  export let role: string = 'img';
  export let ariaLabel = 'Icon';
</script>

<svelte:component 
  {...$$restProps} 
  {role}
  this={icon} 
  {size}
  class={$$props.class} 
  {ariaLabel}
/>