fn_modify_svg() {
  # DIR=$1
  # SUBDIR=$2
  # "${CURRENTDIR}" "${SVGDIR}"

  bannerColor "Changing dir to ${CURRENTDIR}/src" "blue" "*"
  cd "${CURRENTDIR}/src" || exit
  # For each svelte file modify contents of all file by
  # pwd
  # bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # there are outline, mini, micro and solid directories
  for SUBSRC in "${CURRENTDIR}"/src/*; do
    SUBDIRNAME=$(basename "${SUBSRC}")

    cd "${SUBSRC}" || exit
    for file in *; do
      # if ${DIR}/${file} doesn't exist, create it
      if [ ! -f "${CURRENTDIR}/${file}" ]; then
        # copy "${script_dir}/templates/hero2.txt" to ${DIR}/${file}
        cp "${script_dir}/src/heros/next/heros-v2-template.txt" "${CURRENTDIR}/${file}"
      fi
      # echo "${file}"
      SVGPATH=$(sed '1d; $d' "$file")
      # replace new line with space
      SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

      sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${CURRENTDIR}/${file}"
    done
  done

  bannerColor 'Replacing fill="#..." and stroke="#..." with fill={color}.' "blue" "*"
  sed -i 's/fill="#[^"]*"/fill="{color}"/g' "${CURRENTDIR:?}"/*.*
  # sed -i 's/fill="#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})"/fill="{color}"/g' "${CURRENTDIR:?}"/*.*
  sed -i 's/stroke="[^"]*"/stroke="{color}"/g' "${CURRENTDIR:?}"/*.*
  # replacing fill="black" with fill={color}
  sed -i 's/fill="black"/fill="{color}"/g' "${CURRENTDIR:?}"/*.*
  sed -i 's/stroke-width="1.5"/stroke-width="{strokeWidth}"/g' "${CURRENTDIR:?}"/*.*
  bannerColor "Replacing completed." "green" "*"

}


fn_modify_filenames() {
  cd "${CURRENTDIR}" || exit 1
  bannerColor "cd to ${CURRENTDIR}." "blue" "*"
  bannerColor "Adding arialabel to all files." "blue" "*"

  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel;\"${FILENAME}\";" "${filename}" >/dev/null 2>&1
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


fn_hero_next() {
  GITURL="https://github.com/tailwindlabs/heroicons/tree/v1"
  DIRNAME='src'
  # SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/svelte-heros-runes-webkit"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  #  clean up the CURRENTDIR
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  # clone from github
  npx tiged tailwindlabs/heroicons/#v1.0.6 "${CURRENTDIR}/temp"
  # move "${CURRENTDIR}/temp/src" to "${CURRENTDIR}"
  mv "${CURRENTDIR}/temp/src" "${CURRENTDIR}"
  # mv "${CURRENTDIR}/temp/src/outline" "${CURRENTDIR}"
  # remove temp
  rm -rf "${CURRENTDIR}/temp"

  fn_modify_svg 
  rm -rf "${CURRENTDIR}/src"

  fn_modify_filenames

  cp "${script_dir}/src/heros/next/heros-v2-Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  cp "${script_dir}/src/heros/next/heros-types.txt" "${CURRENTDIR}/types.ts"

  bannerColor 'Creating index.js file.' "blue" "*"
  fn_create_index_js
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}