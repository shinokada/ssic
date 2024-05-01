fn_modify_svg() {
  DIR=$1
  SUBDIR=$2
 
  cd "${DIR}/${SUBDIR}" || exit

  # removing width="24" height="24"
  sed -i 's/width="24" height="24"//' ./*.*

  # bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; <\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} fill={color} {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
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

  # bannerColor "Adding ${SUBDIR} to file names." "blue" "*"
  # add ${SUBDIR} before .svelte
  rename -v "s/\.svelte/${SUBDIR}.svelte/" ./*.svelte >/dev/null 2>&1

  # bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_remix() {
  GITURL="https://github.com/Remix-Design/RemixIcon"
  DIRNAME='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/remix/svelte-remix"
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

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

  NEW_DIR_ARR=()

  for SUB in "${DIR_ARR[@]}"; do
    NEW_SUB=$(echo "$SUB" | tr -d '[:space:]&')
    mv "${CURRENTDIR}/${SUB}" "${CURRENTDIR}/${NEW_SUB}_tmp"
    mv "${CURRENTDIR}/${NEW_SUB}_tmp" "${CURRENTDIR}/${NEW_SUB}"
    NEW_DIR_ARR+=("$NEW_SUB")
  done


  for SUB in "${NEW_DIR_ARR[@]}"; do
    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}" "${SUB}"
    # Move all files to lib dir
    mv "${CURRENTDIR}/${SUB}"/* "${CURRENTDIR}"
  done

  cd "${CURRENTDIR}" || exit 1
  cp "${script_dir}/templates/remix/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # Loop through the array and remove each directory
  rm -rf HealthMedical
  rm -rf UserFaces
  for dir in "${DIR_ARR[@]}"; do
    if [ -d "$dir" ]; then
        echo "Removing directory: $dir"
        rm -r "$dir"
    else
        echo "Directory not found: $dir"
    fi
  done

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}