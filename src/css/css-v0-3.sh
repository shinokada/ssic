fn_modify_svg() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    # replace width="24" with width="{size}"
    sed -i 's/width="24"/width="{size}"/' "$filename"
    # replace height="24" with height="{size}"
    sed -i 's/height="24"/height="{size}"/' "$filename"
    # replace fill="currentColor" with fill="{color}"
    sed -i 's/fill="currentColor"/fill="{color}"/' "$filename"
    # Change stroke="currentColor" to stroke={color}
    sed -i 's/stroke="currentColor"/stroke={color}/' "$filename"
    # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor";<\/script>/' "$filename"
    sed -i 's/viewBox=/{role}\n {...$$restProps}\n aria-label="{ariaLabel}"\n on:click\n on:keydown\n on:keyup\n on:focus\n on:blur\n on:mouseenter\n on:mouseleave\n on:mouseover\n on:mouseout\n &/' "$filename"

    FILENAMEONE=$(basename "${filename}" .svg)
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" \n&;" "${filename}" >/dev/null 2>&1

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
  
  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_css(){
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/astrit/css.gg"
  DIRNAME='icons/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/cssgg/svelte-cssgg-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  fn_modify_svg 

  cp "${script_dir}/templates/cssgg/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}