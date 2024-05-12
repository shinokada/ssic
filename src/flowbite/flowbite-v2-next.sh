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
          cp "${script_dir}/templates/flowbite/next/flowbite-svelte-5-base.txt" "${SVETLENAME}"
        fi

        SVGPATH=$(extract_svg_path "$file")
        sed -i "s;replace_svg_path;${SVGPATH};" "${SVETLENAME}"
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
    
    sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1

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
    # if filename has Outline, like NpmOutline.svelte add  fill="none"\n{color} before {...restProps} otherwise add fill={color} before {...restProps}
    if [[ "${filename}" == *Outline.svelte ]]; then
      sed -i 's|{...restProps}|fill="none"\n{color}\n&|' "${filename}"
    else
      sed -i 's|{...restProps}|fill={color}\n&|;' "${filename}"
    fi
    # replace stroke-width="2" with stroke-width={strokeWidth}
    # sed -i "s;stroke-width=\"2\";stroke-width=\{strokeWidth\};" "${filename}"
    if grep -q 'stroke-width="2"' "${filename}"; then
      # replace stroke-width="2" with stroke-width="{strokeWidth}"
      sed -i 's/stroke-width="2"/stroke-width="\{strokeWidth\}"/g' "${filename}"
      # add strokeWidth = ctx.strokeWidth || '2', before desc = {},
      sed -i '/desc = {},/i strokeWidth= ctx.strokeWidth || "2",' "${filename}"
      # add strokeWidth?: string; before withEvents?: boolean;
      sed -i '/withEvents?: boolean;/i strokeWidth?: string;' "${filename}"
    fi
  done
}


fn_flowbite() {
  GITURL="https://github.com/themesberg/flowbite-icons"
  DIRNAME='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/flowbite-svelte-icons-next-runes-webkit"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  
  bannerColor 'Modifying all files.' "blue" "*"
  
  fn_svg_path 

  # Remove 
  rm -rf "${CURRENTDIR}/outline" "${CURRENTDIR}/solid"
  
  fn_modify_filenames
 
  bannerColor 'Renaming is done.' "green" "*"

  fn_modify_file

  cp "${script_dir}/templates/flowbite/next/IconOutline.svelte" "${CURRENTDIR}/IconSolid.svelte" || exit 1
  cp "${script_dir}/templates/flowbite/next/IconSolid.svelte" "${CURRENTDIR}/IconOutline.svelte" || exit 1

  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'All done.' "green" "*"
}