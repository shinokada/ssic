fn_modify_svg() {
  DIR=$1
  SUBDIR=$2

  bannerColor 'Changing dir to icons dir' "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit

  bannerColor 'Modifying all files.' "blue" "*"

  # create files from templates if they don't exist
  # file name should be accessibility-outline.svg to accessibility.svg
  # by removing -outline from the file name.
  for file in *; do

    # find out dashes
    # dashes="${file//[^-]/}"
    # numofdashes="${#dashes}"
    # echo "${numofdashes}"
    # if a file doesn't have -, copy ${script_dir}/templates/ion.txt with the same name to ${DIR}/${file}
    # for file in *-outline.svg; do
    # remove between <title> and </title> from all files
    sed -i 's/<title>.*<\/title>//' "${file}"
    # remove 
    # sed -i 's/<title>*<\/title>//g' "${file}"

    # if file name has -outline
    if [[ "${file}" == *-outline.svg ]]; then
      # ${name%-*} removes the last part of the string
      svgfile=${file%-*}
      # if ${DIR}/${svgfile}.svelte doesn't exist, create it
      if [ ! -f "${DIR}/${svgfile}.svelte" ]; then
        echo "copying to ${DIR}/${svgfile}.svelte"
        cp "${script_dir}/templates/ion.txt" "${DIR}/${svgfile}.svelte"
      fi
      echo "${file}"
      echo "Getting between "0 0 512 512"> and </svg> from ${file}."
      SVGPATH=$(grep -oP '(?<=viewBox="0 0 512 512">).*(?=</svg>)' "${file}")
      # echo "${SVGPATH}"
      echo "Replacing ..."
      sed -i "s|replace_svg_outline|${SVGPATH}|" "${DIR}/${svgfile}.svelte"
      echo "Done outline."
    #  if file name has -sharp.svg
    elif [[ "${file}" == *-sharp.svg ]]; then
      echo "${file}"
      echo "Getting between "0 0 512 512"> and </svg> from ${file}."
      SVGPATH=$(grep -oP '(?<=viewBox="0 0 512 512">).*(?=</svg>)' "${file}")
      # echo "${SVGPATH}"
      echo "Replacing ..."
      sed -i "s|replace_svg_sharp|${SVGPATH}|" "${DIR}/${svgfile}.svelte"
      echo "Done sharp."
    else
      echo "Getting between "0 0 512 512"> and </svg> from regular ${file}."
      SVGPATH=$(grep -oP '(?<=viewBox="0 0 512 512">).*(?=</svg>)' "${file}")
      echo "Replacing ..."
      sed -i "s|replace_svg_regular|${SVGPATH}|" "${DIR}/${svgfile}.svelte"
      echo "Done regular."
    fi
    #   echo "Has dashes and copying..."
    #   # else remove the last part of the file name and copy
    #   filename="${file%-*}"
    #   # if ${DIR}/${filename}.svelte doesn't exist, create it
    #   if [ ! -f "${DIR}/${filename}.svelte" ]; then
    #     echo "copying to ${DIR}/${filename}.svelte"
    #     cp "${script_dir}/templates/ion.txt" "${DIR}/${filename}.svelte"
    #   fi
    #   # ${file##*-} removes everything before the last - and return outline, sharp
    #   variation=${file##*-}
    #   echo "variation: ${variation}"
    #   # ${name%-*} removes the last part of the string
    #   svgfile=${file%-*}
    #   echo "Getting between "0 0 512 512"> and </svg> from ${file}."
    #   SVGPATH=$(grep -oP '(?<=viewBox="0 0 512 512">).*(?=</svg>)' "${file}")
    #   # echo "${SVGPATH}"
    #   echo "Replacing ..."
    #   sed -i "s|replace_svg_${variation}|${SVGPATH}|" "${DIR}/${svgfile}.svelte"
    #   echo "Done ${variation}."
    # fi

  done

  bannerColor 'Modification is done in outline dir.' "green" "*"

}

fn_ion() {
  GITURL="git@github.com:ionic-team/ionicons.git"
  DIRNAME='ionicons'
  SVGDIR='svg'
  SUBDIR='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-ionicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx degit "${GITURL}/${SUBDIR}/${SVGDIR}" "${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"

  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"

  #########################
  #        ICONS      #
  #########################
  # bannerColor 'Changing dir to icons dir' "blue" "*"
  # cd "${CURRENTDIR}/${ICONDIR}" || exit

  # bannerColor 'Removing all files starting with a number.' "blue" "*"
  # find . -type f -name "[0-9]*"  -exec rm {} \;
  # bannerColor 'Done.' "green" "*"

  # #  modify file names
  # bannerColor 'Renaming all files in outline dir.' "blue" "*"
  # # in heroicons/outline rename file names
  # # rename files with number at the beginning with A
  # rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  #   ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1
  # bannerColor 'Renaming is done.' "green" "*"

  # For each svelte file modify contents of all file
  # bannerColor 'Modifying all files.' "blue" "*"

  # # remove <?xml version="1.0" encoding="utf-8"?>
  # sed -i 's/<?xml version="1.0" encoding="utf-8"?>//' ./*.*

  # # Change viewBox="0 0 512 512" to viewBox="0 0 24 24" stroke={color} width={size} height={size} class={$$props.class} {...$$restProps} aria-label={ariaLabel}
  # sed -i 's/viewBox="0 0 512 512"/viewBox="0 0 512 512" width={size} height={size} class={$$props.class} {...$$restProps} aria-label={ariaLabel}/' ./*.*

  # bannerColor "Getting file names." "blue" "*"
  # # get textname from filename
  # for filename in "${CURRENTDIR}/${ICONDIR}"/*; do
  #   FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
  #   # echo "${FILENAME}"
  #   sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
  # done

  # # remove  width="512" and height="512"
  # sed -i 's/width="512"//' ./*.*
  # sed -i 's/height="512"//' ./*.*

  # # Change stroke="currentColor" to stroke={color}
  # # sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

  # # Insert script tag at the beginning and insert class={className} and viewBox
  # sed -i '1s/^/<script>export let size="24";<\/script>/' ./*.*

  # # Insert {...$$restprops} after stroke-linejoin="round"
  # # sed -i 's/stroke-linejoin="round"/& class={$$props.class}/' ./*.*

  # bannerColor 'Modification is done in outline dir.' "green" "*"

  bannerColor 'Creating index.js file.' "blue" "*"
  cd "${CURRENTDIR}" || exit 1
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

  bannerColor "Cleaning up ${CURRENTDIR}/${SVGDIR}." "blue" "*"
  # clean up
  rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"
}
