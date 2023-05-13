fn_circle_flags() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/HatScripts/circle-flags"
  DIRNAME='circle-flags'
  SVGDIR='flags'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-circle-flags"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone from github
  cd "${CURRENTDIR}" || exit 1
  # if there is the svgs, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir from ${CURRENTDIR}." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"*
  fi

  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged -f "${GITURL}/${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # remove all directories
  bannerColor "Deleting language and fictional dir" "red" "*"
  rm -rf "${CURRENTDIR}"/fictional "${CURRENTDIR}"/language || exit

  # remove all symlinks
  bannerColor "Deleting all symlinks" "red" "*"
  find "${CURRENTDIR}" -type l -exec rm {} \;

  # For each svg file modify contents by
  bannerColor 'Modifying all files.' "blue" "*"

  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24";<\/script>/' ./*.* && sed -i 's/viewBox=/class={$$props.class} {...$$restProps} aria-label={ariaLabel} on:click on:change on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave &/' ./*.*

  # Change from width="512" and height="512" to width={size} and height={size}
  sed -i 's/width="512"/width={size}/' ./*.*
  sed -i 's/height="512"/height={size}/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"flag of ${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in the dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

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
