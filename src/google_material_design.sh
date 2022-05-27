fn_modify_svg(){
  DIR=$1
  SUBDIR=$2
  UPPERSUBDIR=$(echo "$2"| tr [:lower:] [:upper:] | tr '-' '_')
  echo "${UPPERSUBDIR}"

  bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
  cd "${DIR}/${SUBDIR}" || exit
  # For each svelte file modify contents of all file by 
  # pwd
  bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

  # removing width="24" height="24"
  sed -i 's/width="24" height="24"//' ./*.*

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} fill={color} class={$$props.class} {...$$restProps} aria-label={ariaLabel} &/' ./*.*

  bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
  # get textname from filename
  for filename in "${DIR}/${SUBDIR}"/*;
  do
  FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
  # echo "${FILENAME}"
  sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor "Renaming all files in the ${SUBDIR} dir." "blue" "*"
  # rename files with number at the beginning with A
  # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg > /dev/null 2>&1

  bannerColor "Adding ${UPPERSUBDIR} to file names." "blue" "*"
  # add ${UPPERSUBDIR} before .svelte
  rename -v "s/\.svelte/${UPPERSUBDIR}.svelte/" ./*.svelte > /dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_google_material_design() {
    ################
    # This script creates all icons in src/lib directory.
    ######################
    GITURL="git@github.com:marella/material-design-icons.git"
    DIRNAME='material-design-icons'
    SVGDIR='svg'
    LOCAL_REPO_NAME="$HOME/Svelte/svelte-google-materialdesign"
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
    npx degit "${GITURL}/${SVGDIR}" "${SVGDIR}" > /dev/null 2>&1 || {
      echo "not able to clone"
      exit 1
    }
    
    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}/${SVGDIR}" filled

    # Move all files to lib dir
    mv "${CURRENTDIR}/${SVGDIR}/filled"/* "${CURRENTDIR}"

    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}/${SVGDIR}" outlined

    # Move all files to lib dir
    mv "${CURRENTDIR}/${SVGDIR}/outlined"/* "${CURRENTDIR}"

    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}/${SVGDIR}" round

    # Move all files to lib dir
    mv "${CURRENTDIR}/${SVGDIR}/round"/* "${CURRENTDIR}"

    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}/${SVGDIR}" sharp

    # Move all files to lib dir
    mv "${CURRENTDIR}/${SVGDIR}/sharp"/* "${CURRENTDIR}"

    # call fn_modify_svg to modify svg files and rename them and move file to lib dir
    fn_modify_svg "${CURRENTDIR}/${SVGDIR}" two-tone

    # Move all files to lib dir
    mv "${CURRENTDIR}/${SVGDIR}/two-tone"/* "${CURRENTDIR}"
    
    #############################
    #    INDEX.JS PART 1 IMPORT #
    #############################
    cd "${CURRENTDIR}" || exit 1

    bannerColor 'Creating index.js file.' "blue" "*"
    # list file names to each index.txt
    find . -type f '(' -name '*.svelte' ')' > index1
    
    # remove ./ from each line
    sed 's/^.\///' index1 > index2

    # create a names.txt
    sed 's/.svelte//' index2 > names.txt
    # Add , after each line in names.txt
    sed -i 's/$/,/' names.txt

    # Create import section in index2 files.
    # for solid
    sed "s:\(.*\)\.svelte:import \1 from './&':" index2 > index3
    bannerColor 'Created index.js file with import.' "green" "*"
    
    ##########################
    # INDEX.JS PART 2 EXPORT #
    ##########################

    bannerColor 'Adding export to index.js file.' "blue" "*"
    # Add export{} section
    # 1 insert export { to index.js, 
    # 2 insert icon-names to index.js after export { 
    # 3. append }
    echo 'export {' >> index3 && cat index3 names.txt > index.js && echo '}' >> index.js

    # remove unnecessary files
    rm names.txt index1 index2 index3

    bannerColor 'Added export to index.js file.' "green" "*"

    # clean up
    rm -rf "${CURRENTDIR}/${DIRNAME}"
    rm -rf "${CURRENTDIR}/${SVGDIR}"
    
    bannerColor 'All done.' "green" "*"

    bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}
