fn_modify_svg() {
  DIR=$1
  SUBDIR=$2
  # UPPERSUBDIR=$(echo "$2" | tr [:lower:] [:upper:] | tr '-' '_')

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # removing width="16" height="16"
  sed -i 's/width="[^"]*"/width="{size}"/' ./*.* >/dev/null 2>&1
  sed -i 's/height="[^"]*"/height="{size}"/' ./*.* >/dev/null 2>&1

  # change fill="none" to fill={color}
  sed -i 's/fill="none"/fill={color}/' ./*.* >/dev/null 2>&1

  # remove fill="currentColor"
  sed -i 's/fill="currentColor"//' ./*.* >/dev/null 2>&1

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script lang="ts">export let size="15"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/ class={$$props.class} {...$$restProps} aria-label={ariaLabel} &/' ./*.*

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
  # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  # bannerColor "Adding ${UPPERSUBDIR} to file names." "blue" "*"
  # # add ${UPPERSUBDIR} before .svelte
  # rename -v "s/\.svelte/${UPPERSUBDIR}.svelte/" ./*.svelte >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_radix() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="git@github.com:radix-ui/icons.git"
  DIRNAME='icons'
  SVGDIR='packages/radix-icons/icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-radix-icons"
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
  rm -rf "${CURRENTDIR}/packages"
  # rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}