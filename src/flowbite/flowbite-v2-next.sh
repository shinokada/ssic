fn_svg_path(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline or solid
    cd "${SUBSRC}" || exit

    for CATEGORY in "${SUBSRC}"/*; do
      cd "${CATEGORY}" || exit
      for file in *; do
        FILENAME=$(basename "${file%.*}")
        # create svelte file like address-book-outline.svelte
        SVETLENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
        if [ ! -f "${SUBDIRNAME}/${file}" ]; then
          cp "${script_dir}/templates/flowbite/next/flowbite-svelte-5-${SUBDIRNAME}.txt" "${SVETLENAME}"
        fi

        # delete the first and last lines to get <path ..../> part
        # SVGPATH=$(sed '1d; $d' "${file}")
        SVGPATH=$(extract_svg_path "$file")
        # if SUBDIRNAME has solid, replace <path with <path fill="currentColor"
        if [ "${SUBDIRNAME}" = "solid" ]; then
          SVGPATH=$(echo "${SVGPATH}" | sed 's;<path;<path fill="currentColor";g')
        fi
        
        # sed -i "s;replace_svg;${SVGPATH};" "${CURRENTDIR}/${file}"
        sed -i "s;replace_svg_path;${SVGPATH};" "${SVETLENAME}"
        # get viewBox value
        VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
        sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVETLENAME}"
      done
    done
  done
}

fn_modify_filenames() {
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1

    #  modify file names
    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Remove all spaces
    new_name=$(echo "$new_name" | sed 's/ //g')
    # echo "${new_name}"
    # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
    mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/${new_name}.svelte"
  done
  
  bannerColor 'Modification and renaming is done.' "green" "*"
}

fn_modify_file(){
  cd "${CURRENTDIR}" || exit 1
  bannerColor "Modifying stroke, stroke-linecap etc." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    # replace #2F2F38 with currentColor
    sed -i "s;#2F2F38;currentColor;" "${filename}"

    sed -i 's/fill="#000"\|fill="#[0-9A-Fa-f]\{6\}"/fill="currentColor"/g' "${filename}"
    sed -i 's/stroke="#[0-9A-Fa-f]\{6\}"/stroke="currentColor"/g' "${filename}"
  done
}


fn_flowbite() {
  GITURL="https://github.com/themesberg/flowbite-icons"
  DIRNAME='src'
  # SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/flowbite-svelte-icons-next"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  
  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"
  
  fn_svg_path 

  # Remove 
  rm -rf "${CURRENTDIR}/outline" "${CURRENTDIR}/solid"

  #  modify file names
  bannerColor 'Renaming all files.' "blue" "*"
  
  fn_modify_filenames
 
  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  fn_modify_file

  cp "${script_dir}/templates/flowbite/next/IconOutline.svelte" "${CURRENTDIR}/IconSolid.svelte" || exit 1
  cp "${script_dir}/templates/flowbite/next/IconSolid.svelte" "${CURRENTDIR}/IconOutline.svelte" || exit 1

  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'All done.' "green" "*"
}