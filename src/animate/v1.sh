fn_svg_path() {

  newBannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    # replace every newline character (\n) with a single space character
    sed -i "s;'\n'; ' ';" "${file}"

    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
  
    cp "${script_dir}/src/animate/template2.txt" "${SVELTENAME}"
    
    SVGPATH=$(extract_svg_path "$file")
    # replace replace_svg_path with svg path
    sed -i "s|replace_svg_path|${SVGPATH}|" "${SVELTENAME}"
    # replace replace_viewbox with file's veiwbox value
    # VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
    # sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVELTENAME}"
  done
}

fn_animate() {
  GITURL="git@github.com:tailwindlabs/heroicons.git"
  DIRNAME="src/24/outline"
  LOCAL_REPO_NAME="$HOME/Svelte/Runes-dev/svelte-hero-draw"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"
    
  newBannerColor 'Running fn_svg_path ...' "blue" "*"
  fn_svg_path

  newBannerColor 'Removing all .svg files ...' "blue" "*"
  fn_remove_svg

  newBannerColor 'Running fn_add_arialabel ...' "blue" "*"
  fn_add_arialabel

  newBannerColor 'Running fn_rename ...' "blue" "*"
  fn_rename

  sed -i 's/stroke="[^"]*"/stroke={color}/g' "${CURRENTDIR:?}"/*.*
  sed -i -E 's/stroke-width="(1\.5|2)"/stroke-width={strokeWidth} \n     transition:draw={shouldAnimate ? transitionParams : undefined}/g' "${CURRENTDIR:?}"/*.*
  cp "${script_dir}/src/animate/types.ts" "${CURRENTDIR}/types.ts"

  newBannerColor 'Creating index.js file.' "blue" "*"
  fn_create_index_js
  
  newBannerColor 'All done.' "green" "*"
}

