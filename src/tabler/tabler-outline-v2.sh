fn_svg_path() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    # remove all lines before <svg
    sed -i '0,/<svg/ { /<svg/!d; }' "$file"

    # replace every newline character (\n) with a single space character
    # sed -i "s;'\n'; ' ';" "${file}"

    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
  
    cp "${script_dir}/templates/tabler/next/tabler-outline-v2.txt" "${SVELTENAME}"
    
    SVGPATH=$(extract_svg_path "$file")
    # replace replace_svg_path with svg path
    sed -i "s|replace_svg_path|${SVGPATH}|" "${SVELTENAME}"
    # replace replace_viewbox with file's veiwbox value
    # VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
    # sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVELTENAME}"
  done
}

fn_tabler_outline() {
  GITURL="https://github.com/tabler/tabler-icons"
  DIRNAME='icons/outline'
  # creating only outline icons to the main tabler runes repo
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/Runes-dev-icons/svelte-tabler-runes-webkit"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  
  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  bannerColor 'creating only outline icons to the main tabler runes repo.' "blue" "*"
  # remove fill="currentColor"
  sed -i 's/fill="currentColor"//g' ./*.*
  
  bannerColor 'Running fn_svg_path ...' "blue" "*"
  fn_svg_path

  bannerColor 'Removing all .svg files ...' "blue" "*"
  fn_remove_svg

  bannerColor 'Running fn_add_arialabel ...' "blue" "*"
  fn_add_arialabel

  bannerColor 'Running fn_rename ...' "blue" "*"
  fn_rename

  cp "${script_dir}/templates/radix/next/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  cp "${script_dir}/templates/types/types.txt" "${CURRENTDIR}/types.ts"


  bannerColor 'Creating index.js file.' "blue" "*"
  fn_create_index_js
  
  bannerColor 'All done.' "green" "*"
}