# Only outline icons without Outline as the suffix will be created

fn_svg_path(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline and filled
    cd "${SUBSRC}" || exit
  
    for file in *; do
      # remove all lines before <svg
      sed -i '0,/<svg/ { /<svg/!d; }' "$file"
      
      FILENAME=$(basename "${file%.*}")
    
    if [[ $FILENAME =~ ^[0-9] ]]; then
      # echo "${FILENAME}"
      # Add "A" to the filename if it starts with a number
      FILENAME="A$FILENAME"
    fi

      # create svelte file like address-book-solid.svelte
      SVELTENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
      if [ ! -f "${SUBDIRNAME}/${file}" ]; then
        cp "${script_dir}/templates/tabler/next/tabler-v2.txt" "${SVELTENAME}"
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

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do

    # if SUBDIRNAME is outline, insert fill="none" after viewBox="0 0 24 24" else insert fill={color}
    
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
    # Remove all &
    new_name=$(echo "$new_name" | sed 's/&//g')
    # echo "${new_name}"
    # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
    mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/${new_name}.svelte"
 
    if [[ $new_name == *Outline ]]; then
    
      sed -i 's/viewBox="0 0 24 24"/viewBox="0 0 24 24" \n fill="none" \n stroke={color} \n stroke-width={strokeWidth} \n stroke-linecap="round" \n stroke-linejoin="round"/' "${new_name}.svelte"
      sed -i 's/color?: string;/color?: string; \n strokeWidth?: string;/' "${new_name}.svelte"
      sed -i "s/color = ctx.color || 'currentColor',/color = ctx.color || 'currentColor', \n strokeWidth = ctx.strokeWidth || '2',/" "${new_name}.svelte"
    else
      sed -i 's/viewBox="0 0 24 24"/viewBox="0 0 24 24" \n fill={color}/' "${new_name}.svelte"
    fi 
  done

  
  
  bannerColor 'Modification and renaming is done.' "green" "*"
}

fn_tabler_next() {
  GITURL="https://github.com/tabler/tabler-icons"
  DIRNAME='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/Runes-dev-icons/svelte-tabler-runes-webkit"
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

  cp "${script_dir}/templates/remix/next/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  cp "${script_dir}/templates/types/types.txt" "${CURRENTDIR}/types.ts"


  fn_create_index_js

  bannerColor 'All done.' "green" "*"
}