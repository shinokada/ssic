fn_modify_svg() {
  DIR=$1
  SUBDIR=$2

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # remove <?xml version="1.0" encoding="utf-8"?>
  sed -i 's|<?xml version="1.0" encoding="utf-8"?>||g' "${DIR}/${SUBDIR}"/*.*

  # remove <!-- Generator: Adobe Illustrator 22.0.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
  sed -i 's|<!-- Generator: Adobe Illustrator 22.0.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->||' ./*.* >/dev/null 2>&1

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="30"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} {...$$restProps} aria-label={ariaLabel} fill={color} &/' ./*.* >/dev/null 2>&1

  bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
  # get textname from filename
  for filename in ./*; do
    # echo "${filename}"
    # translate - to a space
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ') # ./wi cloud up
    FILENAME1=$(basename "${filename}" .svg)             # ./wi-cloud-up
    # remove first 4 characters from ./wi cloud up
    FILENAME="${FILENAME:3}"
    # remove first 4 charcters from ./wi-cloud-up
    FILENAME1="${FILENAME1:3}" # cloud-up
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
    mv "${filename}" "${FILENAME1}.svg"
  done

  #  modify file names
  bannerColor "Renaming all files in the ${SUBDIR} dir." "blue" "*"
  # rename files with number at the beginning with A

  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  # bannerColor "Removing Wi from file names." "blue" "*"
  # rename -v "////*.svelte"

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_weather() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="git@github.com:erikflowers/weather-icons.git"
  DIRNAME='weather-icons'
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-weather-icons"
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
  mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"

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
