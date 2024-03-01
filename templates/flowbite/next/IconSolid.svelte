<script lang="ts">
  import type { ComponentType } from 'svelte';
  interface Props{
    icon: ComponentType;
    size?: "xs" | "sm" | "md" | "lg" | "xl";
    role?: string;
    ariaLabel?: string;
    class?: string;
  }
  let {icon, size, role, ariaLabel, class: classname, ...restProps} = $props<Props>()

</script>

<svelte:component 
  {...restProps} 
  {role}
  this={icon} 
  {size}
  class={classname} 
  {ariaLabel}
/>