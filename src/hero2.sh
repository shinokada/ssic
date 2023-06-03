fn_modify_mini(){
  DIR=$1 #${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR} means lib dir
  SUBDIR=$2 #src/20/solid

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file
  bannerColor "Modifying all files in ${SUBDIR}/solid." "cyan" "*"
  for file in *; do
      # delete the first and last lines to get <path ..../> part
      SVGPATH=$(sed '1d; $d' "${file}")
      # replace new line with space
      SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

      sed -i "s;replace_svg_mini;${SVGPATH};" "${DIR}/${file}"
    done
}

fn_modify_svg() {
  DIR=$1
  SUBDIR=$2

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # there are outline and solid directories
  for SUBSRC in "${DIR}/${SUBDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline or solid

    cd "${SUBSRC}" || exit
    for file in *; do
      # if ${DIR}/${file} doesn't exist, create it
      if [ ! -f "${DIR}/${file}" ]; then
        # copy "${script_dir}/templates/hero2.txt" to ${DIR}/${file}
        cp "${script_dir}/templates/hero2.txt" "${DIR}/${file}"
      fi
      # echo "${file}"
      SVGPATH=$(sed '1d; $d' "$file")
      # replace new line with space
      SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

      sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${DIR}/${file}"
    done
  done

  fn_modify_mini "${CURRENTDIR}" "${MINISVG}/solid"

  # remove src dir
  bannerColor "Removing src dir." "blue" "*"
  rm -rf "${CURRENTDIR:?}/src"
  bannerColor "Removed ${SUBDIR} dir." "green" "*"

  bannerColor 'Replacing fill=" #..." and stroke="#..." with fill={color}.' "blue" "*"
  sed -i 's/fill="[^"]*"/fill="{color}"/g' "${CURRENTDIR:?}"/*.*
  sed -i 's/stroke="[^"]*"/stroke="{color}"/g' "${CURRENTDIR:?}"/*.*
  sed -i 's/stroke-width="1.5"/stroke-width="{strokeWidth}"/g' "${CURRENTDIR:?}"/*.*
  bannerColor "Replacing completed." "green" "*"

  bannerColor "Adding fill=none before viewBox=0 0 24 24." "blue" "*"
  # since you are adding fill="${color}" previously, you need to insert it before viewBox="0 0 24 24"
  sed -i 's/{viewBox}/fill="none" \n {viewBox}/' "${CURRENTDIR:?}"/*.*
  bannerColor "Added fill=none before viewBox=0 0 24 24." "green" "*"

}


fn_modify_filenames() {
  CURRENTDIR=$1
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
  done
  bannerColor "Added arialabel to all files." "green" "*"

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  # rename files with number at the beginning with A
  rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"
  bannerColor 'Modification is done in the dir.' "green" "*"
}




fn_hero2() {
  ################
  # This script creates all icons in src/lib directory.
  # v2.0.4
  ######################
  GITURL="git@github.com:tailwindlabs/heroicons.git"
  DIRNAME='heroicons'
  SVGDIR='src/24'
  MINISVG='src/20'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-heros-v2"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  # clone from github
  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # clone mini
  bannerColor "Cloning mini." "green" "*"
  npx tiged "${GITURL}/${MINISVG}" "${MINISVG}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }
  
  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"

  # Move all files to lib dir
  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"
  fn_modify_filenames "${CURRENTDIR}"

  # modify mini
  # fn_modify_mini "${CURRENTDIR}" "${MINISVG}/solid"
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
  # rm -rf "${CURRENTDIR}/${DIRNAME}"
  # rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}
