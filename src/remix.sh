fn_modify_svg() {
  DIR=$1
  SUBDIR=$2
  # UPPERSUBDIR=$(echo "$2" | tr [:lower:] [:upper:] | tr '-' '_')
  # echo "${UPPERSUBDIR}"

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # removing width="24" height="24"
  sed -i 's/width="24" height="24"//' ./*.*

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} fill={color} class={$$props.class} {...$$restProps} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
  # get textname from filename
  for filename in "${DIR}/${SUBDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor "Renaming all files in the ${SUBDIR} dir." "blue" "*"
  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor "Adding ${SUBDIR} to file names." "blue" "*"
  # add ${SUBDIR} before .svelte
  rename -v "s/\.svelte/${SUBDIR}.svelte/" ./*.svelte >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_remix() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/Remix-Design/RemixIcon"
  DIRNAME='RemixIcon'
  SVGDIR='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-remix"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  DIR_ARR=(
    'Arrows'
    'Buildings'
    'Business'
    'Communication'
    'Design'
    'Development'
    'Device'
    'Document'
    'Editor'
    'Finance'
    'Health & Medical'
    'Logos'
    'Map'
    'Media'
    'Others'
    'System'
    'User & Faces'
    'Weather'
  )

  # clone from github
  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  NEW_DIR_ARR=()

  for SUB in "${DIR_ARR[@]}"; do
    NEW_SUB=$(echo "$SUB" | tr -d '[:space:]&')
    mv "${CURRENTDIR}/${SVGDIR}/${SUB}" "${CURRENTDIR}/${SVGDIR}/${NEW_SUB}_tmp"
    mv "${CURRENTDIR}/${SVGDIR}/${NEW_SUB}_tmp" "${CURRENTDIR}/${SVGDIR}/${NEW_SUB}"
    NEW_DIR_ARR+=("$NEW_SUB")
  done


  for SUB in "${NEW_DIR_ARR[@]}"; do
    # echo $SUB
    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}/${SVGDIR}" "${SUB}"
    # Move all files to lib dir
    mv "${CURRENTDIR}/${SVGDIR}/${SUB}"/* "${CURRENTDIR}"
  done

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  # Add component doc
  for file in ./*.*; do
    echo -e "\n<!--\n@component\n[Go to Document](https://svelte-remix.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop color = 'currentColor';\n@prop ariaLabel = 'icon file name';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
  done

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/${DIRNAME}"
  rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}
