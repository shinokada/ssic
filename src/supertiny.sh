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
  
    # Add component doc
    echo -e "\n<!--\n@component\n[Go to Document](https://shinokada.github.io/svelte-supertiny/)\n## Props\n@prop size = '24';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$filename"

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
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/edent/SuperTinyIcons"
  DIRNAME='images/svg'
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-supertiny"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  # clone from github
  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${DIRNAME}" "${CURRENTDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg 

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