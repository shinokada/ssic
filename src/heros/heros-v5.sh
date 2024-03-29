fn_modify_svg() {
  # For each svelte file modify contents of all file by
  # pwd
  # bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"
  cd "${CURRENTDIR}" || exit 1
  # there are outline and solid directories
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}")

    cd "${SUBSRC}" || exit
    # bannerColor "cd to ${SUBSRC}" "blue" "*"
    for file in *; do
      # if ${DIR}/${file} doesn't exist, create it
      if [ ! -f "${CURRENTDIR}/${file}" ]; then
        # copy "${script_dir}/templates/teeny.txt" to ${DIR}/${file}
        cp "${script_dir}/templates/hero.txt" "${CURRENTDIR}/${file}"
      fi
      # echo "${file}"
      # bannerColor "Replace new line with space." "blue" "*"
      SVGPATH=$(sed '1d; $d' "$file")
      SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')
      sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${CURRENTDIR}/${file}"
    done
  done
  # remove src dir
  # bannerColor "Removing src dir." "blue" "*"
  # rm -rf "${CURRENTDIR:?}/${SUBDIR}"
  # bannerColor "Removed ${SUBDIR} dir." "green" "*"

  # bannerColor 'Replacing fill=" #..." and stroke="#..." with fill={color}.' "blue" "*"
  sed -i 's/fill="[^"]*"/fill="{color}"/g' "${CURRENTDIR:?}"/*.*
  sed -i 's/stroke="[^"]*"/stroke="{color}"/g' "${CURRENTDIR:?}"/*.*
  bannerColor "Replacing completed." "green" "*"

  # bannerColor "Adding fill=none before viewBox=0 0 24 24." "blue" "*"
  # since you are adding fill="${color}" previously, you need to insert it before viewBox="0 0 24 24"
  sed -i 's/{viewBox}/fill="none" \n {viewBox}/' "${CURRENTDIR:?}"/*.*
  bannerColor "Added fill=none before viewBox=0 0 24 24." "green" "*"
}

fn_modify_filenames() {
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*.svg; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    sed -i "/<\/script>/i export let ariaLabel=\"${FILENAME}\"" "${filename}" >/dev/null 2>&1
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

fn_hero() {
  GITURL="git@github.com:tailwindlabs/heroicons.git"
  DIRNAME='src'
  # SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-heros"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "${DIRNAME}/24" "$GITURL"

  fn_modify_svg

  fn_modify_filenames 

  cp "${script_dir}/templates/heros/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/solid"
  rm -rf "${CURRENTDIR}/outline"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}