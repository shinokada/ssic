fn_flagicons() {
    ################
    # This script creates all icons in src/lib directory.
    ######################
    GITURL="https://github.com/lipis/flag-icons"
    DIRNAME='flag-icons'
    SVGDIR='flags/4x3'
    LOCAL_REPO_NAME="$HOME/Svelte/svelte-flag-icons"
    SVELTE_LIB_DIR='src/lib'
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
    # clone from github
    cd "${CURRENTDIR}" || exit 1
    # if there is the svgs, remove it
    if [ -d "${CURRENTDIR}" ]; then
      bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
      rm -rf "${CURRENTDIR:?}/"*
    fi

    # clone the repo
    bannerColor "Cloning ${DIRNAME}." "green" "*"
    npx degit "${GITURL}/${SVGDIR}" > /dev/null 2>&1 || {
        echo "not able to clone"
        exit 1
    }

    # copy svgs dir from the cloned dir
    # bannerColor 'Moving svgs dir to the root.' "green" "*"
    # if [ -d "${CURRENTDIR}/${SVGDIR}" ]; then
    #   bannerColor 'Removing the previous svgs dir.' "blue" "*"
    #   rm -rf "${CURRENTDIR}/${SVGDIR}"
    # fi

    # mv "${CURRENTDIR}/${DIRNAME}/${SVGDIR}" "${CURRENTDIR}"
    
    # bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
    # cd "${CURRENTDIR}" || exit

    # For each svelte file modify contents of all file by 
    bannerColor 'Modifying all files.' "blue" "*"

    # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} class={$$props.class} {...$$restProps} aria-label={ariaLabel} &/' ./*.*

    # get textname from filename
    for filename in "${CURRENTDIR}"/*;
    do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"flag of ${FILENAME}\" &;" "${filename}"
    done

    #  modify file names
    bannerColor 'Renaming all files in the dir.' "blue" "*"

    # rename files with number at the beginning with A
    # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
    rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  }ge' ./*.svg > /dev/null 2>&1

    bannerColor 'Renaming is done.' "green" "*"

    bannerColor 'Modification is done in the dir.' "green" "*"

    # Move all files to lib dir
    # mv ./* "${CURRENTDIR}"

    
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
