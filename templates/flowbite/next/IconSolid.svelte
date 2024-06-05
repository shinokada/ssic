<script lang="ts">
  import type { Component } from 'svelte';
  interface Props{
    icon: Component;
    size?: "xs" | "sm" | "md" | "lg" | "xl";
    role?: string;
    color?: string;
    ariaLabel?: string;
    class?: string;
  }
  let {icon, size, role, color, ariaLabel, class: classname, ...restProps}: Props = $props()

</script>

<svelte:component 
fill={color}
  {...restProps} 
  {role}
  this={icon} 
  {size}
  class={classname} 
  {ariaLabel}
/>