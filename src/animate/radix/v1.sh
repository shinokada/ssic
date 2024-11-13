fn_svg_path() {

  newBannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    # replace every newline character (\n) with a single space character
    sed -i "s;'\n'; ' ';" "${file}"

    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
  
    cp "${script_dir}/src/animate/radix/template.txt" "${SVELTENAME}"
    
    SVGPATH=$(extract_svg_path "$file")

    SVGPATH=$(echo "$SVGPATH" | sed 's/fill="currentColor"//g')

    # Prepare the transitions to be inserted
    transition1="transition:draw={transitionParams}"
    # transition2="transition:draw={shouldAnimate ? transitionParams2 : undefined}"
    # transition3="transition:draw={shouldAnimate ? transitionParams3 : undefined}"
    # transition4="transition:draw={shouldAnimate ? transitionParams4 : undefined}"

    # Replace <path with <path $transition1, etc.
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<path |<path $transition1 |")
    # SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;s|<path |<path $transition2 |}")
    # SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;n;s|<path |<path $transition3 |}")
    # SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;n;n;s|<path |<path $transition4 |}")
    # replace replace_svg_path with svg path
    sed -i "s|replace_svg_path|${SVGPATH}|" "${SVELTENAME}"
  done
}

fn_animate() {
  GITURL="git@github.com:radix-ui/icons.git"
  DIRNAME='packages/radix-icons/icons'
  LOCAL_REPO_NAME="$HOME/Svelte/Runes/svelte-animated-icons"
  SVELTE_LIB_DIR='src/lib/radix'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  newBannerColor 'Running fn_svg_path ...' "blue" "*"
  fn_svg_path

  newBannerColor 'Removing all .svg files ...' "blue" "*"
  fn_remove_svg

  newBannerColor 'Running fn_add_arialabel ...' "blue" "*"
  fn_add_arialabel

  newBannerColor 'Running fn_rename ...' "blue" "*"
  fn_rename_with_repo "Radix"

  newBannerColor 'Creating index.js file.' "blue" "*"
  fn_create_index_js
  
  newBannerColor 'All done.' "green" "*"
}

