fn_modify_svg() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  for filename in "${CURRENTDIR}"/*; do
    # replace role="img" with {role}
    sed -i 's/role="img"/\{role\}/' "$filename"
    # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24";export let role="img";<\/script>/' "$filename"
    sed -i 's/viewBox=/ width="{size}" height="{size}" {...$$restProps} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' "$filename"


    FILENAMEONE=$(basename "${filename}" .svelte | tr '[:upper:]' '[:lower:]') 
    # replace id="a" with fill id="file-name"
    sed -i "s/id=\"a\"/id=\"${FILENAMEONE}\"/" "${filename}"
    # replace fill="url(#a)" with fill="url(#file-name)"
    sed -i "s/fill=\"url(#a)\"/fill=\"url(#${FILENAMEONE})\"/" "${filename}"

    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    # Capitalize the first letter
    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
  done
  
  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_supertiny(){
  GITURL="https://github.com/edent/SuperTinyIcons"
  DIRNAME='images/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-supertiny"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  
  fn_modify_svg 

  cp "${script_dir}/templates/supertiny/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}