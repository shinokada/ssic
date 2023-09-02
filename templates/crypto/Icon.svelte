<script lang="ts">
  import type { ComponentType } from 'svelte';
  export let icon: ComponentType;
  export let size = '';
  export let variation: 'black' | 'color' | 'icon' | 'white' = 'color';
  export let role: string = 'img';
  export let ariaLabel: string = 'Icon';
</script>

<svelte:component 
  {...$$restProps} 
  {role}
  this={icon} 
  {size} 
  {variation}
  class={$$props.class} 
  aria-label={ariaLabel}
/>