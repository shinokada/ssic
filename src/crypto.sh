fn_modify_svg() {
  DIR=$1
  SUBDIR=$2

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  for SUBSRC in "${DIR}/${SUBDIR}"/*; do
    bannerColor "Modifying ${SUBSRC}" "cyan" "*"
    # if SUBSRC is a directory, go inside
    if [ -d "$SUBSRC" ]; then
      bannerColor "In directory ${SUBSRC}" "cyan" "*"
      SUBDIRNAME=$(basename "${SUBSRC}")

      cd "${SUBSRC}" || exit

      for file in *; do
        # if ${DIR}/${file} doesn't exist, create it
        if [ ! -f "${DIR}/${file}" ]; then
          # copy "${script_dir}/templates/teeny.txt" to ${DIR}/${file}
          cp "${script_dir}/templates/crypto.txt" "${DIR}/${file}"
        fi
        # echo "${SUBDIRNAME}"
        bannerColor "Modifying ${file}" "cyan" "*"
        # echo "not icon dir"
        SVGPATH=$(grep -oP '(?<=xmlns="http://www.w3.org/2000/svg">).*(?=</svg>)' "${file}") || SVGPATH=$(grep -oP '(?<=viewBox="0 0 32 32">).*(?=</svg>)' "${file}") || SVGPATH=$(grep -oP '(?<=xmlns:xlink="http://www.w3.org/1999/xlink">).*(?=</svg>)' "${file}")
        # echo "${SVGPATH}"
        # echo "Done if statement"
        # replace new line with space
        # SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

        sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${DIR}/${file}"
      done
    fi
  done
  # remove src dir
  # bannerColor "Removing src dir." "blue" "*"
  # rm -rf "${CURRENTDIR:?}/${SUBDIR}"
  # bannerColor "Removed ${SUBDIR} dir." "green" "*"

  # bannerColor "Replacing fill="#..." and stroke="#..." with fill={color}." "blue" "*"
  # sed -i 's/fill="[^"]*"/fill="${color}"/g' "${CURRENTDIR:?}"/*.*
  # sed -i 's/stroke="[^"]*"/stroke="${color}"/g' "${CURRENTDIR:?}"/*.*
  # bannerColor "Replacing completed." "green" "*"

  # bannerColor "Adding fill=none before viewBox=0 0 24 24." "blue" "*"
  # since you are adding fill="${color}" previously, you need to insert it before viewBox="0 0 24 24"
  # sed -i 's/viewBox="0 0 24 24"/fill="none" viewBox="0 0 24 24"/' "${CURRENTDIR:?}"/*.*
  # bannerColor "Added fill=none before viewBox=0 0 24 24." "green" "*"

  # remove svg dir
  bannerColor "Removing svg dir." "blue" "*"
  rm -rf "${CURRENTDIR:?}/svg"
  bannerColor "Removed svg dir." "green" "*"
}

fn_modify_filenames() {
  CURRENTDIR=$1
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '_' ' ')
    # echo "${FILENAME}"
    sed -i "s:</script>:export let ariaLabel=\"${FILENAME}\";\n &:" "${filename}"
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

fn_crypto() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="git@github.com:spothq/cryptocurrency-icons.git"
  DIRNAME='cryptocurrency-icons'
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-cryptocurrency-icons"
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
  npx degit "${GITURL}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"
  # Move all files to lib dir
  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"
  fn_modify_filenames "${CURRENTDIR}"

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
