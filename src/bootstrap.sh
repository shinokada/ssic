fn_modify_svg() {
  DIR=$1
  SUBDIR=$2

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # removing width="24" height="24"
  sed -i 's/width="16" height="16"/width="{size}" height="{size}"/' ./*.* >/dev/null 2>&1

  # remove fill="currentColor"
  sed -i 's/fill="currentColor"//' ./*.* >/dev/null 2>&1

  # remove class="bi bi-alt", class="bi bi-align-center", class="bi bi-align-end", etc
  sed 's/class="[^"]*"/class="{$$props.class}"/g' ./*.* >/dev/null 2>&1

  # replace width="any number" with width={size}
  # sed 's/width="[^"]*"/width="{size}"/g' ./*.*
  # replace height="any number" with height={size}
  # sed 's/height="[^"]*"/height="{size}"/g' ./*.*

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="16"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/fill={color} {...$$restProps} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.* >/dev/null 2>&1

  bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
  # get textname from filename
  for filename in "${DIR}/${SUBDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
  done

  #  modify file names
  bannerColor "Renaming all files in the ${SUBDIR} dir." "blue" "*"
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_bootstrap() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/twbs/icons"
  DIRNAME='icons'
  SVGDIR='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-bootstrap-svg-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

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
  npx tiged -f "${GITURL}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"
  # Move all files to lib dir
  mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1


  # Add component doc
  for file in ./*.*; do
    echo -e "\n<!--\n@component\n[Go to Document](https://svelte-bootstrap-svg-icons.codewithshin.com/)\n## Props\n@prop size = '16';\n@prop color = 'currentColor';\n@prop ariaLabel = 'icon name';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
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
