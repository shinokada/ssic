fn_modify_svg() {

  bannerColor "Changing dir to ${CURRENTDIR}/${DIRNAME}" "blue" "*"
  cd "${CURRENTDIR}/${DIRNAME}" || exit
  # For each svelte file modify contents of all file by

  bannerColor "Modifying all files in ${DIRNAME}." "cyan" "*"

  # there are outline and solid directories
  # remove fill="black"
  for SUBSRC in "${CURRENTDIR}/${DIRNAME}"/*; do
    # if SUBSRC is a directory, go inside
    if [ -d "$SUBSRC" ]; then
      SUBDIRNAME=$(basename "${SUBSRC}")

      cd "${SUBSRC}" || exit
      for file in *; do
        # if ${DIR}/${file} doesn't exist, create it
        if [ ! -f "${CURRENTDIR}/${file}" ]; then
          # copy "${script_dir}/templates/teeny.txt" to ${DIR}/${file}
          cp "${script_dir}/templates/google_materialdesign.txt" "${CURRENTDIR}/${file}"
        fi
        SVGPATH=$(grep -oP '(?<=viewBox="0 0 24 24">).*(?=</svg>)' "${file}")
        sed -i "s;replace_svg_${SUBDIRNAME};${SVGPATH};" "${CURRENTDIR}/${file}"
      done
    fi
  done

  # remove svg dir
  bannerColor "Removing svg dir." "blue" "*"
  rm -rf "${CURRENTDIR:?}/svg"
  bannerColor "Removed svg dir." "green" "*"
}

fn_modify_filenames() {

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

fn_google_material_design() {
  GITURL="git@github.com:marella/material-design-icons.git"
  DIRNAME='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/google-materialdesign/svelte-google-materialdesign-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  # since using "${CURRENTDIR}/${DIRNAME}" in clone_repo
  # remove all files in ${CURRENTDIR}
  rm -rf "${CURRENTDIR:?}/"
  clone_repo "${CURRENTDIR}/${DIRNAME}" "$DIRNAME" "$GITURL"

  fn_modify_svg

  fn_modify_filenames

  cp "${script_dir}/templates/googlematerial/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/${DIRNAME}"
  rm -f "${CURRENTDIR}"/*.svg
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}