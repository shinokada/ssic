fn_feather() {
  GITURL="git@github.com:feathericons/feather.git"
  DIRNAME='icons'
  # ICONDIR='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-feathers"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # For each svelte file modify contents of all file
  bannerColor 'Modifying all files.' "blue" "*"

  # Change from width="24" and height="24" to width={size} and height={size}
  sed -i 's/width="24"/width={size}/' ./*.*
  sed -i 's/height="24"/height={size}/' ./*.*

  # Change stroke="currentColor" to stroke={color}
  sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

  # Insert script tag at the beginning and insert class={className} and viewBox
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor";<\/script>/' ./*.* 

  # Insert {...$$restprops} after stroke-linejoin="round" 
  sed -i 's/stroke-linejoin="round"/& class={$$props.class} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout /' ./*.*

  for filename in "${CURRENTDIR}"/*; do
    # add arialabel
    FILENAMEONE=$(basename "${filename}" .svg)
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\"\; \n&;" "${filename}" >/dev/null 2>&1

    # Capitalize the first letter
    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Change the extension from svg to svelte
    # new_name=$(echo "$new_name" | sed 's/svg$/svelte/g')
    mv "${CURRENTDIR}/${FILENAMEONE}.svg" "${CURRENTDIR}/${new_name}.svelte"
  done

    cp "${script_dir}/templates/feather/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

    bannerColor 'Creating index.js file.' "blue" "*"
    
    find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

    bannerColor 'Added export to index.js file.' "green" "*"
    
    bannerColor 'All done.' "green" "*"
}