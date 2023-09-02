<script lang="ts">
  import type { ComponentType } from 'svelte';
  export let icon: ComponentType;
  export let size: number = 24;
  export let variation: "solid" | "outline" = 'outline';
  export let color: string = '';
  export let role = "img";
export let ariaLabel=""
</script>

<svelte:component 
  {...$$restProps} 
  {role}
  this={icon} 
  {size} 
  {variation} 
  {color} 
  class={$$props.class} 
  viewBox="0 0 24 24"
  aria-label={ariaLabel}
/>