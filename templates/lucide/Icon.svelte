<script lang="ts">
  import type { ComponentType } from 'svelte';
  export let icon: ComponentType;
  export let size: number = 24;
  export let role: string = 'img';
  export let color: string = 'currentColor';
  export let strokeWidth: string = '2';
  export let ariaLabel: string = 'Icon';
</script>

<svelte:component 
  {...$$restProps} 
  {role}
  this={icon} 
  {size}
  {color}
  {strokeWidth}
  class={$$props.class} 
  {ariaLabel}
/>