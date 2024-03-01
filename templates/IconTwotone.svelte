<script>
  import icons from './icons.js'

  export let name;
  export let width = replace_size;
  export let height = replace_size;
  export let strokeColor = 'currentColor';
  export let role = 'img';
  export let ariaLabel = name;
  
  $: displayIcon = icons[name]
</script>
<svg
xmlns="http://www.w3.org/2000/svg"
{width}
{height}
fill={strokeColor}
{role}
aria-label={ariaLabel}
{...$$restProps}
class={$$props.class}
on:click
on:keydown
on:keyup
on:focus
on:blur
on:mouseenter
on:mouseleave
on:mouseover
on:mouseout
viewBox="0 0 {displayIcon.box} {displayIcon.box}"
>
  {@html displayIcon.svg}
</svg>

<!--
@component
[Go to Document](https://replace_name.codewithshin.com)
## Props
@prop name;
@prop width = replace_size;
@prop height = replace_size;
@prop strokeColor = 'currentColor';
@prop insideColor = '#D9D9D9';
@prop role = 'img';
@prop ariaLabel='icon name'
## Event
- on:click
- on:keydown
- on:keyup
- on:focus
- on:blur
- on:mouseenter
- on:mouseleave
- on:mouseover
- on:mouseout
-->