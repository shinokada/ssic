fn_svg_path(){
  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVETLENAME="${CURRENTDIR}/${FILENAME}.svelte"
    cp "${script_dir}/templates/radix/radix.txt" "${SVETLENAME}"

    SVGPATH=$(extract_svg_path "$file")
    # replace replace_svg_path with svg path
    # with g option for all occurrences
    sed -i "s;replace_svg_path;${SVGPATH};g" "${SVETLENAME}"
    # get viewBox value
    # VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
    # sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVETLENAME}"
  done
}

fn_modify_filenames(){
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  # need this dir to store temp files
  mkdir -p "${CURRENTDIR}/temp"

  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel; \"${FILENAME},\" ;" "${filename}" >/dev/null 2>&1

    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Remove all spaces
    new_name=$(echo "$new_name" | sed 's/ //g')
    # echo "${new_name}"
    # echo "${filename}"

    # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
    
    # since you cannot move the same file name even the different case, move the files to temp directory.  Then move them back.
    
    mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/temp/${new_name}.svelte"
    mv "${CURRENTDIR}/temp/${new_name}.svelte" "${CURRENTDIR}/${new_name}.svelte"
  done
  rm -rf "${CURRENTDIR}/temp"
  
  bannerColor 'Modification and renaming is done.' "green" "*"
}


fn_radix() {
  GITURL="git@github.com:radix-ui/icons.git"
  DIRNAME='packages/radix-icons/icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-radix"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

  # fn_modify_svg 
  fn_svg_path

  # clean up
  bannerColor "Removing all svg files." "blue" "*"
  find . -type f -name "*.svg" -delete

  #  modify file names
  bannerColor 'Renaming all files.' "blue" "*"
  
  fn_modify_filenames

  cp "${script_dir}/templates/radix/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}