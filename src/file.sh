fn_file() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/file-icons/icons"
  DIRNAME='icons'
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-file-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone from github
  cd "${CURRENTDIR}" || exit 1
  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"*
  fi

  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx degit "${GITURL}/${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # For each svelte file modify contents of all file by
  bannerColor 'Modifying all files.' "blue" "*"

  # 1. replace width="any number or string" to width="{size}"
  # 2. replace height="any number or string" to height="{size}"
  # 3. insert viewBox="0 0 512 512" fill={color} class={$$props.class} {...$$restProps} aria-label={ariaLabel} before closeing first >
  bannerColor 'Inserting to all files.' "blue" "*"
  sed -i 's/width="[^"]*"/width="{size}"/g' ./*.* >/dev/null 2>&1 && sed -i 's/height="[^"]*"/height="{size}"/g' ./*.* >/dev/null 2>&1 && sed -i 's/>/ viewBox="0 0 512 512" fill={color} class={$$props.class} {...$$restProps} aria-label={ariaLabel} &/' ./*.* >/dev/null 2>&1

  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  # replacing from width to > with content
  sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in the dir.' "blue" "*"

  # replace # with Sharp and + with Plus in the file names
  rename -v 's/\#/Sharp/g' ./*.svg >/dev/null 2>&1
  rename -v 's/\+/Plus/g' ./*.svg >/dev/null 2>&1

  # replace . with _ in the file names
  mv draw.io.svg draw_io.svg

  # rename files with number at the beginning with A
  # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

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
