fn_svg_path(){
    for CATEGORY in "${CURRENTDIR}"/*; do
      cd "${CATEGORY}" || exit
      for file in *; do
        FILENAME=$(basename "${file%.*}")
        SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
      
        cp "${script_dir}/src/animate/flowbite/template.txt" "${SVELTENAME}"
       
        SVGPATH=$(extract_svg_path "$file")
          
        SVGPATH=$(echo "$SVGPATH" | sed 's/stroke="currentColor"/stroke={color}/g')
        SVGPATH=$(echo "$SVGPATH" | sed 's/stroke-width="2"/stroke-width={strokeWidth}/g')

        # Prepare the transitions to be inserted
        transition1="transition:draw={shouldAnimate ? transitionParams : undefined}"
        transition2="transition:draw={shouldAnimate ? transitionParams2 : undefined}"
        transition3="transition:draw={shouldAnimate ? transitionParams3 : undefined}"
        transition4="transition:draw={shouldAnimate ? transitionParams4 : undefined}"

        # Replace <path with <path $transition1, etc.
        SVGPATH=$(echo "$SVGPATH" | sed "1 s|<path |<path $transition1 |")
        SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;s|<path |<path $transition2 |}")
        SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;n;s|<path |<path $transition3 |}")
        SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;n;n;s|<path |<path $transition4 |}")

        sed -i "s;replace_svg_path;${SVGPATH};" "${SVELTENAME}"
      done
    done
}

fn_animate() {
  GITURL="https://github.com/themesberg/flowbite-icons"
  DIRNAME="src/outline"
  LOCAL_REPO_NAME="$HOME/Svelte/Runes/svelte-animated-icons"
  SVELTE_LIB_DIR='src/lib/flowbite'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  newBannerColor 'Running fn_svg_path ...' "blue" "*"
  fn_svg_path

  newBannerColor 'Removing all .svg files ...' "blue" "*"
  rm -rf "${CURRENTDIR}/arrows" "${CURRENTDIR}/e-commerce" "${CURRENTDIR}/emoji" "${CURRENTDIR}/files:folders" "${CURRENTDIR}/general" "${CURRENTDIR}/media" "${CURRENTDIR}/text" "${CURRENTDIR}/user" "${CURRENTDIR}/weather"

  # fn_remove_svg

  newBannerColor 'Running fn_add_arialabel ...' "blue" "*"
  fn_add_arialabel

  newBannerColor 'Running fn_rename ...' "blue" "*"
  fn_rename_with_repo "Flowbite"

  # cp "${script_dir}/src/animate/hero/types.ts" "${CURRENTDIR}/herotypes.ts"

  newBannerColor 'Creating index.js file.' "blue" "*"
  fn_create_index_js
  
  newBannerColor 'All done.' "green" "*"
}

