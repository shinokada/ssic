<script lang="ts">
  import type { ComponentType } from 'svelte';
  import { getContext } from 'svelte';

  interface CtxType {
    icon: ComponentType;
    size?: string;
    role?: string;
    color?: string;
    variation?: "solid" | "outline";
    viewBox?: string;
  }

  interface Props {
    icon: ComponentType;
    size?: string;
    role?: string;
    color?: string;
    ariaLabel?: string;
    variation?: 'solid' | 'outline';
    viewBox?: string;
  }
  
  const ctx: CtxType = getContext('iconCtx') ?? {};
  let {icon, size = ctx.size || "24", role = ctx.role || 'img', ariaLabel, viewBox = ctx.viewBox || '0 0 24 24', color = ctx.color || 'currentColor', variation = ctx.variation || 'outline', ...attributes}: Props  = $props();
</script>

<svelte:component 
  {...attributes}
  {role}
  this={icon} 
  {size} 
  {variation} 
  {color} 
  viewBox="0 0 24 24"
  aria-label={ariaLabel}
/>