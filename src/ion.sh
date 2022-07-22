fn_ion() {
  ###########################################################
  # This script creates ionicons.
  ###########################################################
  GITURL="git@github.com:ionic-team/ionicons.git"
  DIRNAME='ionicons'
  SUBDIR='src'
  ICONDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/svelte-ionicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone icons from github
  cd "${CURRENTDIR}" || exit 1
  # if icons dir remove it
  if [ -d "${CURRENTDIR}/${DIRNAME}" ]; then
    bannerColor 'Removing the previous dir.' "blue" "*"
    rm -rf "${CURRENTDIR}/${DIRNAME}"
  fi

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
  sed -i 's/viewBox="0 0 512 512"/viewBox="0 0 512 512" {...$$restProps} width={size} height={size} fill="${color}" class={$$props.class} /' ./*.*

  # remove  width="512" and height="512"
  sed -i 's/width="512"//' ./*.*
  sed -i 's/height="512"//' ./*.*

  # remove title>ionicons-v5-a</title>
  sed -i 's|<title>ionicons-v5-a</title>||' ./*.*

  # Change stroke="currentColor" to stroke={color}
  # sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

  # Insert script tag at the beginning and insert class={className} and viewBox
  sed -i '1s/^/<script>export let size="24"; export let color="currentColor"<\/script>/' ./*.*

  # Insert {...$$restprops} after stroke-linejoin="round"
  # sed -i 's/stroke-linejoin="round"/& class={$$props.class}/' ./*.*

  bannerColor 'Modification is done in outline dir.' "green" "*"

  bannerColor 'Creating index.js file.' "blue" "*"
  # list file names to each index.txt
  find . -type f '(' -name '*.svelte' ')' >index1

  # removed ./ from each line
  sed 's/^.\///' index1 >index2
  rm index1

  # create a names.txt
  sed 's/.svelte//' index2 >names.txt
  # Add , after each line in names.txt
  sed -i 's/$/,/' names.txt

  # Create import section in index2 files.
  # for outline
  sed "s:\(.*\)\.svelte:import \1 from './&':" index2 >index3
  bannerColor 'Created index.js file with import.' "green" "*"

  #################
  #    INDEX.JS   #
  #################

  bannerColor 'Adding export to index.js file.' "blue" "*"
  # Add export{} section
  # 1 insert export { to index.js,
  # 2 insert icon-names to index.js after export {
  # 3. append }
  echo 'export {' >>index3 && cat index3 names.txt >index.js && echo '}' >>index.js

  rm names.txt index2 index3

  bannerColor 'Added export to index.js file.' "green" "*"

  bannerColor "Cleaning up ${CURRENTDIR}/${DIRNAME}." "blue" "*"
  # clean up
  rm -rf "${CURRENTDIR}/${DIRNAME}"

  bannerColor 'All done.' "green" "*"
}
