fn_svg_path() {

  newBannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  for file in *; do
    # replace every newline character (\n) with a single space character
    sed -i "s;'\n'; ' ';" "${file}"

    FILENAME=$(basename "${file%.*}")
    # create svelte file like address-book-solid.svelte
    SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
  
    cp "${script_dir}/src/animate/ion/template.txt" "${SVELTENAME}"

     # Only perform replacement for specific Ion icons
    case "${FILENAME}" in
       "binoculars-outline"| "server-outline"|"arrow-up-right-box-outline"|"arrow-up-left-box-outline"|"arrow-down-right-box-outline"|"arrow-down-left-box-outline")
            sed -i 's/fill={color}/fill="none"/g' "${SVELTENAME}"
            ;;
    esac
    
    SVGPATH=$(extract_svg_path "$file")
    # replace stroke="#000" with stroke={color}
    SVGPATH=$(echo "$SVGPATH" | sed 's/stroke="#000"/stroke={color}/g')
    # replace stroke="currentColor" with stroke={color}
    SVGPATH=$(echo "$SVGPATH" | sed 's/stroke="currentColor"/stroke={color}/g')
    # replace stroke="black" with stroke={color}
    SVGPATH=$(echo "$SVGPATH" | sed 's/stroke="black"/stroke={color}/g')
    # SVGPATH=$(echo "$SVGPATH" | sed 's/fill="currentColor"//g')
    # replace stroke:#000 with stroke:{color}
    SVGPATH=$(echo "$SVGPATH" | sed 's/stroke:#000/stroke:{color}/g')

    # Prepare the transitions to be inserted
    transition1="transition:draw={transitionParams}"
    # transition2="transition:draw={shouldAnimate ? transitionParams2 : undefined}"
    # transition3="transition:draw={shouldAnimate ? transitionParams3 : undefined}"
    # transition4="transition:draw={shouldAnimate ? transitionParams4 : undefined}"

    # Replace <path with <path $transition1, etc.
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<path |<path $transition1 |g")
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<circle |<circle $transition1 |g")
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<rect |<rect $transition1 |g")
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<line |<line $transition1 |g")
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<ellipse |<ellipse $transition1 |g")
    # <polyline
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<polyline |<polyline $transition1 |g")
    # <polygon
    SVGPATH=$(echo "$SVGPATH" | sed "1 s|<polygon |<polygon $transition1 |g")
    # SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;s|<path |<path $transition2 |}")
    # SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;n;s|<path |<path $transition3 |}")
    # SVGPATH=$(echo "$SVGPATH" | sed "/^<path /{n;n;n;s|<path |<path $transition4 |}")
    # replace replace_svg_path with svg path
    # if SVELTENAME is PeopleCircleOutlineIon, BatteryChargingOutlineIon, CaretBackOutlineIon, 
    #  then insert fill={color}

    # replace fill={color} to fill="none" for file name with ServerOutlineIon,ArrowUpRightBoxOutlineIon, ArrowUpLeftBoxOutlineIon, ArrowDownRightBoxOutlineIon, ArrowDownLeftBoxOutlineIon
   

    sed -i "s|replace_svg_path|${SVGPATH}|" "${SVELTENAME}"
  done
}

fn_animate() {
  GITURL="git@github.com:ionic-team/ionicons.git"
  DIRNAME='src/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/Runes/svelte-animated-icons"
  SVELTE_LIB_DIR='src/lib/ion'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"
  
  # Delete files that don't contain 'outline' in their name
  find . -maxdepth 1 -type f ! -name '*outline*' -delete

  newBannerColor 'Running fn_svg_path ...' "blue" "*"
  fn_svg_path

  newBannerColor 'Removing all .svg files ...' "blue" "*"
  fn_remove_svg

  newBannerColor 'Running fn_add_arialabel ...' "blue" "*"
  fn_add_arialabel

  newBannerColor 'Running fn_rename ...' "blue" "*"
  fn_rename_with_repo "Ion"

  newBannerColor 'Creating index.js file.' "blue" "*"
  fn_create_index_js
  
  newBannerColor 'All done.' "green" "*"
}

