fn_svg_path() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    # replace every newline character (\n) with a single space character
    sed -i "s;'\n'; ' ';" "${file}"

    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVETLENAME="${CURRENTDIR}/${FILENAME}.svelte"
  
    cp "${script_dir}/templates/lucide/next/lucide-v2-next.txt" "${SVETLENAME}"
    
    SVGPATH=$(extract_svg_path "$file")
    # replace replace_svg_path with svg path
    sed -i "s|replace_svg_path|${SVGPATH}|" "${SVETLENAME}"
  done
}


fn_lucide() {
    GITURL="git@github.com:lucide-icons/lucide.git"
    DIRNAME='icons'
    LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/svelte-lucide-next-runes-webkit"
    SVELTE_LIB_DIR='src/lib'
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

    clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

    bannerColor 'Remove all json files.' "blue" "*"
    if ls *.json &> /dev/null; then
      echo "Directory contains JSON files."
      bannerColor 'Directory contains JSON files. Removing them ...' "blue" "*"
      rm *.json
      bannerColor 'Removed.' "green" "*"
    else
      bannerColor 'Directory does not contain any JSON files.' "blue" "*"
    fi
    
    bannerColor 'Running fn_svg_path ...' "blue" "*"
    fn_svg_path

    bannerColor 'Removing all .svg files ...' "blue" "*"
    fn_remove_svg

    bannerColor 'Running fn_add_arialabel ...' "blue" "*"
    fn_add_arialabel

    bannerColor 'Running fn_rename ...' "blue" "*"
    fn_rename

    cp "${script_dir}/templates/lucide/next/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

    bannerColor 'Creating index.js file.' "blue" "*"
    fn_create_index_js
    
    bannerColor 'All done.' "green" "*"
}