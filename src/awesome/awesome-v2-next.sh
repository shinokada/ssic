fn_svg_path(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # brands, regular, solid
    cd "${SUBSRC}" || exit
  
    for file in *; do
      FILENAME=$(basename "${file%.*}")
      # create svelte file like address-book-solid.svelte
      SVETLENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
      if [ ! -f "${SUBDIRNAME}/${file}" ]; then
        cp "${script_dir}/templates/awesome/next/awesome-v2.txt" "${SVETLENAME}"
      fi

      SVGPATH=$(extract_svg_path "$file")
      # replace replace_svg_path with svg path
      sed -i "s;replace_svg_path;${SVGPATH};" "${SVETLENAME}"
      # get viewBox value
      VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
      sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVETLENAME}"
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

fn_awesome() {
  GITURL="git@github.com:FortAwesome/Font-Awesome.git"
  DIRNAME='svgs'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-awesome-icons-next"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # remove font awesome comments
  find . -type f -exec sed -i '/<!--! Font Awesome Free/,/-->/ s/<!--! Font Awesome Free.*-->//' {} \;

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"
  
  fn_svg_path

  # clean up
  rm -rf "${CURRENTDIR}/solid" "${CURRENTDIR}/brands" "${CURRENTDIR}/regular"

  #  modify file names
  bannerColor 'Renaming all files.' "blue" "*"
  
  fn_modify_filenames

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svelte\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  }ge' ./*.svelte >/dev/null 2>&1

  cd "${CURRENTDIR}" || exit 1

  cp "${script_dir}/templates/awesome/next/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"


  bannerColor 'All done.' "green" "*"
}