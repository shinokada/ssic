fn_modify_svg() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    # replace fill="#xxxxxx" to fill="curentColor"
    sed -i 's/fill="#[0-9a-fA-F]\+"/fill="{color}"/g' "$filename"
    # remove width="50"
    sed -i 's/width="50"//' "$filename"
    # remove height="50" 
    sed -i 's/height="50"//' "$filename"
    # inserting script tag at the beginning
    sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let strokeWidth = ctx.strokeWidth || "2"; export let size = ctx.size || "50"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor";<\/script>/' "$filename"
    sed -i 's/viewBox=/\nwidth="{size}"\nheight="{size}"\nfill="{color}"\n{role}\nstroke-linecap="round"\nstroke-linejoin="round"\nstroke-width="{strokeWidth}"\n{...$$restProps}\n aria-label="{ariaLabel}"\n on:click\n on:keydown\n on:keyup\n on:focus\n on:blur\n on:mouseenter\n on:mouseleave\n on:mouseover\n on:mouseout\n &/' "$filename"

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
  
  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_evil(){
  GITURL="https://github.com/evil-icons/evil-icons"
  DIRNAME='assets/icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-evil-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  fn_modify_svg 

  cp "${script_dir}/templates/evil/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

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