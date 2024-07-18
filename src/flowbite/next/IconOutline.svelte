<script lang="ts">
  import type { Component } from 'svelte';
  import type { SVGAttributes } from 'svelte/elements';

  interface Props extends SVGAttributes<SVGElement>{
    icon: Component;
    size?: "xs" | "sm" | "md" | "lg" | "xl";
    role?: string;
    color?: string;
    ariaLabel?: string;
    strokeWidth?: string;
    class?: string;
  }
  let {icon, size, role, color, ariaLabel, strokeWidth, class: classname, ...restProps}: Props = $props()
</script>

<svelte:component 
  fill="none"
  {color}
  {...restProps} 
  {role}
  this={icon} 
  {size}
  {strokeWidth}
  class={classname} 
  {ariaLabel}
/>