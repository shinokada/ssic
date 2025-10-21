fn_svg_path(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # brands, regular, solid
    cd "${SUBSRC}" || exit
  
    for file in *; do
      FILENAME=$(basename "${file%.*}")

    
    if [[ $FILENAME =~ ^[0-9] ]]; then
      # echo "${FILENAME}"
      # Add "A" to the filename if it starts with a number
      FILENAME="A$FILENAME"
    fi

      # create svelte file like address-book-solid.svelte
      SVELTENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
      if [ ! -f "${SUBDIRNAME}/${file}" ]; then
        cp "${script_dir}/src/remix/v2/remix-v2-template.txt" "${SVELTENAME}"
      fi

      SVGPATH=$(extract_svg_path "$file")
      # replace replace_svg_path with svg path
      sed -i "s;replace_svg_path;${SVGPATH};" "${SVELTENAME}"
      # get viewBox value
      # VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
      # sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVELTENAME}"
    done
  done
}

fn_modify_filenames() {
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Modifing file names." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do

    FILENAMEONE=$(basename "${filename}" .svelte)
    # FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')

    # echo "${FILENAME}"
    # sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1

    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Remove all spaces
    new_name=$(echo "$new_name" | sed 's/ //g')
    # Remove all &
    new_name=$(echo "$new_name" | sed 's/&//g')
    # echo "${new_name}"
    # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
    mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/${new_name}.svelte"
  done
  
  bannerColor 'Modification and renaming is done.' "green" "*"
}

fn_remix() {
  GITURL="https://github.com/Remix-Design/RemixIcon"
  DIRNAME='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-remix"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  
  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

  fn_svg_path
  
  bannerColor 'Removing all subdirectories.' "blue" "*"
  for dir in "$CURRENTDIR"/*; do
    if [[ -d "$dir" ]]; then
      rm -rf "$dir"
    fi
  done
  
  fn_modify_filenames

  cp "${script_dir}/src/remix/v2/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  cp "${script_dir}/src/remix/v2/remix-v2-types.txt" "${CURRENTDIR}/types.ts"

  fn_create_index_js

  bannerColor 'All done.' "green" "*"
}