<script lang="ts">
  import type { ComponentType } from 'svelte';
  export let icon: ComponentType;
  export let size: number = 16;
  export let role: string = 'img';
  export let color: string = 'currentColor';
  export let ariaLabel = 'Icon';
</script>

<svelte:component 
  {...$$restProps} 
  {role}
  this={icon} 
  {size}
  {color}
  class={$$props.class} 
  {ariaLabel}
/>