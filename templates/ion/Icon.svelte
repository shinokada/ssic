<script lang="ts">
  import type { ComponentType } from 'svelte';
  export let icon: ComponentType;
  export let size: number = 24;
  export let role: string = 'img';
  export let color = 'currentColor';
  export let ariaLabel: string = 'Icon';
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