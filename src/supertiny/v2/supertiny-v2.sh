fn_svg_path() {

  newBannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    # replace every newline character (\n) with a single space character
    sed -i "s;'\n'; ' ';" "${file}"

    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
  
    cp "${script_dir}/src/supertiny/v2/supertiny-v2.txt" "${SVELTENAME}"
    
    SVGPATH=$(extract_svg_path "$file")
    # Replace fill="#fff" with fill="none"
    SVGPATH=$(echo "$SVGPATH" | sed 's/d="m0 0H512V512H0" fill="#fff"/d="m0 0H512V512H0" fill="none"/g')

    # replace replace_svg_path with svg path
    sed -i "s|replace_svg_path|${SVGPATH}|" "${SVELTENAME}"
    # Extract the first SVG tag content (up to the first >)
    FIRST_SVG_TAG=$(sed -n '/<svg/,/>/p' "${file}")

    # Check for attributes in the first SVG tag
    if echo "$FIRST_SVG_TAG" | grep -q 'stroke-width="20"'; then
        sed -i '/viewBox="0 0 512 512"/a\   stroke-width="20"' "${SVELTENAME}"
    fi

    if echo "$FIRST_SVG_TAG" | grep -q 'stroke-linecap="round" stroke-width="25" stroke-linejoin="round"'; then
      sed -i '/viewBox="0 0 512 512"/a\   stroke-linecap="round" stroke-width="25" stroke-linejoin="round"' "${SVELTENAME}"
    fi

    if echo "$FIRST_SVG_TAG" | grep -q 'viewBox="-128 -128 256 256"'; then
      sed -i 's/viewBox="0 0 512 512"/viewBox="-128 -128 256 256"/' "${SVELTENAME}"
    fi

    # Extract and insert fill attribute if it exists
    FILL_VALUE=$(echo "$FIRST_SVG_TAG" | grep -o 'fill="[^"]*"' | head -n 1)
    if [ ! -z "$FILL_VALUE" ]; then
        sed -i "/viewBox=\"[^\"]*\"/a\   ${FILL_VALUE}" "${SVELTENAME}"
    fi

    # for file name is Slack insert stroke-width="78" stroke-linecap="round" after viewBox="0 0 512 512"
    # sed -i "/viewBox=\"[^\"]*\"/a\   stroke-width=\"78\" stroke-linecap=\"round\"" "${SVELTENAME}"

  done
}


fn_add_arialabel() {
  cd "${CURRENTDIR}" || exit 1

  newBannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1

    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Remove all spaces
    new_name=$(echo "$new_name" | sed 's/ //g')
  done
  
  newBannerColor 'Added arialabel to all files.' "green" "*"
}

fn_supertiny(){
  GITURL="https://github.com/edent/SuperTinyIcons"
  DIRNAME='images/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/svelte-supertiny-runes-webkit"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

  newBannerColor 'Modifying all files.' "blue" "*"

  fn_svg_path

  newBannerColor 'Removing all .svg files.' "blue" "*"

  fn_remove_svg

  add_A_if_starts_with_number

  newBannerColor 'Renaming all files.' "blue" "*"
  
  fn_add_arialabel
  
  fn_rename

  cd "${CURRENTDIR}" || exit 1

  fn_create_index_js
  cp "${script_dir}/src/supertiny/v2/types.txt" "${CURRENTDIR}/types.ts"


  newBannerColor 'All done.' "green" "*"
}