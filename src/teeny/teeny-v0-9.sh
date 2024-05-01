fn_modify_svg() {
  # there are outline and solid directories
  for SUBSRC in "${CURRENTDIR}"/*; do
    # echo "${SUBSRC}" /Users/shinichiokada/Svelte/svelte-teenyicons/src/lib/src/outline
    SUBDIRNAME=$(basename "${SUBSRC}")

    cd "${SUBSRC}" || exit
    for file in *; do
      # if ${DIR}/${file} doesn't exist, create it
      if [ ! -f "${CURRENTDIR}/${file}" ]; then
        # copy "${script_dir}/templates/teeny.txt" to ${DIR}/${file}
        cp "${script_dir}/templates/teeny.txt" "${CURRENTDIR}/${file}"
      fi
      # echo "${file}"
      SVGPATH=$(sed '1d; $d' "$file")
      # replace new line with space
      SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

      sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${CURRENTDIR}/${file}"
    done
  done

  # bannerColor "Removing src dir." "blue" "*"
  # rm -rf "${CURRENTDIR:?}/${SUBDIR}"
  # bannerColor "Removed ${SUBDIR} dir." "green" "*"
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
  GITURL="https://github.com/teenyicons/teenyicons"
  DIRNAME='src'
  # SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/teeny/svelte-teenyicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

  fn_modify_svg

  rm -rf "${CURRENTDIR}"/outline
  rm -rf "${CURRENTDIR}"/solid

  fn_modify_filenames "${CURRENTDIR}"

  for filename in "${CURRENTDIR}"/*; do
    # replace fill="black" and stroke="black"
    sed -i 's/fill="black"/fill="{color}"/g' "${filename}"
    sed -i 's/stroke="black"/stroke="{color}"/g' "${filename}"
  done

  cp "${script_dir}/templates/teeny/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}