fn_svg_path(){

  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline or solid
    # echo ${SUBDIRNAME} # outline
    # echo ${SUBSRC} 
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
        SVGPATH=$(sed '1d; $d' "${file}")
        # replace new line with space
        SVGPATH=$(echo "${SVGPATH}" | tr '\n' ' ')

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
      # replace <path fill="currentColor"  with <path 
      # sed -i 's/<path fill="currentColor"/<path fill="\{color\}"/' "${filename}"

      if grep -q 'stroke-linecap="round"' "${filename}"; then
        # replace stroke-linecap="round" with stroke-linecap="{strokeLinecap}"
        sed -i 's/stroke-linecap="round"/stroke-linecap="\{strokeLinecap\}"/' "${filename}"
        # insert export let strokeLinecap:  "round" | "inherit" | "butt" | "square" | null | undefined = "round"; before </script>
        sed -i '/<\/script>/i export let strokeLinecap: "round" | "inherit" | "butt" | "square" | null | undefined = "round";' "${filename}"
      fi

      if grep -q 'stroke-linejoin="round"' "${filename}"; then
        # replace stroke-linejoin="round" with stroke-linejoin="{strokeLinejoin}"
        sed -i 's/stroke-linejoin="round"/stroke-linejoin="\{strokeLinejoin\}"/' "${filename}"
        sed -i '/<\/script>/i export let strokeLinejoin:"round" | "inherit" | "miter" | "bevel" | null | undefined = "round";' "${filename}"
      fi

      if grep -q 'stroke-width="2"' "${filename}"; then
        # replace stroke-width="2" with stroke-width="{strokeWidth}"
        sed -i 's/stroke-width="2"/stroke-width="\{strokeWidth\}"/g' "${filename}"
        sed -i '/<\/script>/i export let strokeWidth= "2";' "${filename}"
      fi

      # replace fill="#xxxxxx", or any other css hex with fill="currentColor"
      # sed -i 's/fill="#[0-9A-Fa-f]\{6\}"/fill="currentColor"/g' "${filename}"
      # sed -i 's/\(fill\|stroke\)="#[0-9A-Fa-f]\{6\}"/\1="currentColor"/g' "${filename}"
      # 
      sed -i 's/fill="#000"\|\(fill\|stroke\)="#[0-9A-Fa-f]\{6\}"/fill="currentColor"/g' "${filename}"


    done
  }


fn_flowbite() {
  ################
  # This script creates a single directory main
  # Move it's contents to Repo lib dir.
  ######################
  GITURL="https://github.com/themesberg/flowbite-icons"
  DIRNAME='src'
  SVGDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/flowbite-svelte-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # if there is lib dir, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${CURRENTDIR} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

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

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  bannerColor 'All done.' "green" "*"
}
