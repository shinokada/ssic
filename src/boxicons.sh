fn_modify_svg() {
  SUBDIR=$1

  bannerColor "Changing dir to ${CURRENTDIR}/${SUBDIR}" "blue" "*"
  cd "${CURRENTDIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # there are logos, regular and solid directories
  for SUBSRC in "${CURRENTDIR}/${SUBDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}")

    cd "${SUBSRC}" || exit
    bannerColor "Modifying ${SUBSRC} files..." "yellow" "*"
    for file in *; do
      # if ${CURRENTDIR}/${file} doesn't exist, create it
      if [ ! -f "${CURRENTDIR}/${file}" ]; then
        # copy "${script_dir}/templates/boxicon.txt" to ${CURRENTDIR}/${file}
        cp "${script_dir}/templates/boxicon.txt" "${CURRENTDIR}/${file}"
      fi
      # remove the \n with a space first then remove both the opening and closing SVG tags
       
      sed -i "s;replace_svg;${SVGPATH};" "${CURRENTDIR}/${file}"
    done
  done
}


fn_modify_filenames() {
  CURRENTDIR=$1
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svg)
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1

    #  modify file names
    bannerColor "Renaming all files." "blue" "*"
    # rename files with number at the beginning with A
    # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
    # rename -v 's{^\./(\d*)(.*)\.svg\Z}{  # ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1
    # Capitalize the first letter
    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Change the extension from svg to svelte
    # new_name=$(echo "$new_name" | sed 's/svg$/svelte/g')
    mv "${CURRENTDIR}/${FILENAMEONE}.svg" "${CURRENTDIR}/${new_name}.svelte"
  done
  bannerColor "Added arialabel to all files." "green" "*"
  bannerColor 'Renaming is done.' "green" "*"
  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_boxicons() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/atisawd/boxicons"
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-boxicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  # clone from github
  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${SVGDIR} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${SVGDIR}." "green" "*"
  npx tiged -f "${GITURL}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg "${SVGDIR}"
  # remove svg dir
  rm -rf "${CURRENTDIR}/svg"

  fn_modify_filenames "${CURRENTDIR}"
  # Move all files to lib dir
  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1


  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}
