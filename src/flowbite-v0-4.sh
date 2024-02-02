fn_svg_path(){

  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline or solid
    cd "${SUBSRC}" || exit

    for CATEGORY in "${SUBSRC}"/*; do
      cd "${CATEGORY}" || exit
      for file in *; do
        FILENAME=$(basename "${file%.*}")
        SVETLENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
        if [ ! -f "${SUBDIRNAME}/${file}" ]; then
          cp "${script_dir}/templates/flowbite-${SUBDIRNAME}.txt" "${SVETLENAME}"
        fi

        # delete the first and last lines to get <path ..../> part
        # SVGPATH=$(sed '1d; $d' "${file}")
        SVGPATH=$(extract_svg_path "$file")
        # replace new line with space
        # SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')
        # sed -i "s;replace_svg;${SVGPATH};" "${CURRENTDIR}/${file}"
        sed -i "s;replace_svg_path;${SVGPATH};" "${SVETLENAME}"
        # get viewBox value
        VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
        sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVETLENAME}"
      done
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
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1

    #  modify file names
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

fn_modify_file(){
  cd "${CURRENTDIR}" || exit 1
  bannerColor "Modifying stroke, stroke-linecap etc." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    # replace #2F2F38 with currentColor
    sed -i "s;#2F2F38;currentColor;" "${filename}"

    if grep -q 'stroke-linecap="round"' "${filename}"; then
      # replace stroke-linecap="round" with stroke-linecap="{strokeLinecap}"
      sed -i 's/stroke-linecap="round"/stroke-linecap="\{strokeLinecap\}"/' "${filename}"
      # insert export let strokeLinecap:  "round" | "inherit" | "butt" | "square" | null | undefined = "round"; before </script>
      sed -i '/<\/script>/i export let strokeLinecap: "round" | "inherit" | "butt" | "square" | null | undefined = ctx.strokeLinecap || "round";' "${filename}"
    fi

    if grep -q 'stroke-linejoin="round"' "${filename}"; then
      # replace stroke-linejoin="round" with stroke-linejoin="{strokeLinejoin}"
      sed -i 's/stroke-linejoin="round"/stroke-linejoin="\{strokeLinejoin\}"/' "${filename}"
      sed -i '/<\/script>/i export let strokeLinejoin:"round" | "inherit" | "miter" | "bevel" | null | undefined = ctx.strokeLinejoin || "round";' "${filename}"
    fi

    if grep -q 'stroke-width="2"' "${filename}"; then
      # replace stroke-width="2" with stroke-width="{strokeWidth}"
      sed -i 's/stroke-width="2"/stroke-width="\{strokeWidth\}"/g' "${filename}"
      sed -i '/<\/script>/i export let strokeWidth= ctx.strokeWidth || "2";' "${filename}"
    fi

    # if grep -q 'stroke="currentColor"' "${filename}"; then
    #   # replace stroke="currentColor" with stroke={color}
    #   sed -i 's/stroke="currentColor"/stroke=\{color\}/g' "${filename}"
    # fi

    sed -i 's/fill="#000"\|fill="#[0-9A-Fa-f]\{6\}"/fill="currentColor"/g' "${filename}"
    sed -i 's/stroke="#[0-9A-Fa-f]\{6\}"/stroke="currentColor"/g' "${filename}"
  done
}


fn_flowbite() {
  GITURL="https://github.com/themesberg/flowbite-icons"
  DIRNAME='src'
  # SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/flowbite-svelte-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  # since there are two x.svg and X.svg rename X.svg to twitter.svg
  mv "${CURRENTDIR}/solid/brands/X.svg" "${CURRENTDIR}/solid/brands/twitter.svg"
  mv "${CURRENTDIR}/outline/media/Grid (24x24px).svg" "${CURRENTDIR}/outline/media/pause.svg"
  
  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"
  
  fn_svg_path 

  # Remove 
  rm -rf "${CURRENTDIR}/outline" "${CURRENTDIR}/solid"

  #  modify file names
  bannerColor 'Renaming all files.' "blue" "*"
  
  fn_modify_filenames
 
  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  fn_modify_file

  cp "${script_dir}/templates/flowbite/IconOutline.svelte" "${CURRENTDIR}/IconSolid.svelte" || exit 1
  cp "${script_dir}/templates/flowbite/IconSolid.svelte" "${CURRENTDIR}/IconOutline.svelte" || exit 1

  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'All done.' "green" "*"
}