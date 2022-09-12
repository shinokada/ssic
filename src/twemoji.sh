fn_modify_svg() {
  DIR=$1    # ${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}
  SUBDIR=$2 # src

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="36";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} class={$$props.class} {...$$restProps} aria-label={ariaLabel} &/' ./*.*

  bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
  # get textname from filename
  for filename in "${DIR}/${SUBDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"
}

fn_modify_filenames() {
  CURRENTDIR=$1
  cd "${CURRENTDIR}" || exit 1

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  # rename files with number at the beginning with A
  rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_twemoji() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/twitter/twemoji"
  DIRNAME='twemoji'
  SVGDIR='assets/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-twitter-emoji"
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
  npx degit "${GITURL}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"
  # Move all files to lib dir
  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"
  fn_modify_filenames "${CURRENTDIR}"

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
  # rm -rf "${CURRENTDIR}/${SVGDIR}"
  rm -rf "${CURRENTDIR}/assets"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}
