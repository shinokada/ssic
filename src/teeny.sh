fn_modify_svg() {
  DIR=$1    # ${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}
  SUBDIR=$2 # src

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # there are outline and solid directories
  for SUBSRC in "${DIR}/${SUBDIR}"/*; do
    # echo "${SUBSRC}" /Users/shinichiokada/Svelte/svelte-teenyicons/src/lib/src/outline
    SUBDIRNAME=$(basename "${SUBSRC}")

    cd "${SUBSRC}" || exit
    for file in *; do
      # if ${DIR}/${file} doesn't exist, create it
      if [ ! -f "${DIR}/${file}" ]; then
        # copy "${script_dir}/templates/teeny.txt" to ${DIR}/${file}
        cp "${script_dir}/templates/teeny.txt" "${DIR}/${file}"
      fi
      # echo "${file}"
      SVGPATH=$(sed '1d; $d' "$file")
      # replace new line with space
      SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

      sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${DIR}/${file}"
    done
  done
  bannerColor "Modifying all files is done." "cyan" "*"
  # remove src dir
  bannerColor "Removing src dir." "blue" "*"
  rm -rf "${CURRENTDIR:?}/${SUBDIR}"
  bannerColor "Removed ${SUBDIR} dir." "green" "*"
}

fn_modify_filenames() {
  CURRENTDIR=$1
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
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

fn_teeny() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/teenyicons/teenyicons"
  DIRNAME='teenyicons'
  SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-teenyicons"
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

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"
  # Move all files to lib dir
  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"
  fn_modify_filenames "${CURRENTDIR}"

  for filename in "${CURRENTDIR}"/*; do
    # replace fill="black" and stroke="black"
    sed -i 's/fill="black"/fill="{color}"/g' "${filename}"
    sed -i 's/stroke="black"/stroke="{color}"/g' "${filename}"
  done

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
  rm -rf "${CURRENTDIR}/${DIRNAME}"
  rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}
