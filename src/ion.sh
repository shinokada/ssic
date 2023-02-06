fn_ion() {
  ###########################################################
  # This script creates ionicons.
  ###########################################################
  GITURL="git@github.com:ionic-team/ionicons.git"
  DIRNAME='ionicons'
  SUBDIR='src'
  ICONDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-ionicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone icons from github
  cd "${CURRENTDIR}" || exit 1
  # remove files from src/lib
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${CURRENTDIR} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1

  # clone it
  bannerColor 'Cloning the repo.' "green" "*"
  git clone "${GITURL}" || {
    echo "not able to clone"
    exit 1
  }

  # move to the icon dir to the root dir
  bannerColor 'Moving icons dir to the root.' "green" "*"
  if [ -d "${CURRENTDIR}/${ICONDIR}" ]; then
    bannerColor 'Removing the previous icons dir.' "blue" "*"
    rm -rf "${CURRENTDIR}/${ICONDIR}"
  fi

  mv "${CURRENTDIR}/${DIRNAME}/${SUBDIR}/${ICONDIR}" "${CURRENTDIR}"

  #########################
  #        ICONS      #
  #########################
  bannerColor 'Changing dir to icons dir' "blue" "*"
  cd "${CURRENTDIR}/${ICONDIR}" || exit

  bannerColor 'Removing all files starting with a number.' "blue" "*"
  find . -type f -name "[0-9]*" -exec rm {} \;
  bannerColor 'Done.' "green" "*"

  #  modify file names
  bannerColor 'Renaming all files in outline dir.' "blue" "*"
  # in heroicons/outline rename file names
  rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg >/dev/null 2>&1
  bannerColor 'Renaming is done.' "green" "*"

  # For each svelte file modify contents of all file
  bannerColor 'Modifying all files.' "blue" "*"

  # remove <?xml version="1.0" encoding="utf-8"?>
  sed -i 's/<?xml version="1.0" encoding="utf-8"?>//' ./*.*

  # Change viewBox="0 0 512 512" to viewBox="0 0 512 512" width={size} height={size} class={$$props.class}
  sed -i 's/viewBox="0 0 512 512"/viewBox="0 0 512 512" {...$$restProps} width={size} height={size} fill={color} class={$$props.class} /' ./*.*

  # remove  width="512" and height="512"
  sed -i 's/width="512"//' ./*.*
  sed -i 's/height="512"//' ./*.*

  # remove title>ionicons-v5-a</title>
  sed -i 's|<title>ionicons-v5-a</title>||' ./*.*

  # Change stroke:#000 to stroke:{color}
  sed -i 's/stroke:#000/stroke:{color}/g' ./*.*

  # Insert script tag at the beginning and insert class={className} and viewBox
  sed -i '1s/^/<script>export let size="24"; export let color="currentColor"<\/script>/' ./*.*

  # Insert {...$$restprops} after stroke-linejoin="round"
  # sed -i 's/stroke-linejoin="round"/& class={$$props.class}/' ./*.*

  bannerColor 'Modification is done in outline dir.' "green" "*"

  bannerColor 'Creating index.js file.' "blue" "*"
  
  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # Move all files to lib dir
  mv ./* "${CURRENTDIR}"
  # remove svg and ionicons dir
  rm -rf ./* "${CURRENTDIR}/svg" "${CURRENTDIR}/ionicons" || exit 1


  # bannerColor "Cleaning up ${CURRENTDIR}/${DIRNAME}." "blue" "*"
  # # clean up
  # rm -rf "${CURRENTDIR}/${DIRNAME}"

  bannerColor 'All done.' "green" "*"
}
