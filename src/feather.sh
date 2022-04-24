fn_feather() {
    ################
    # This script creates a single directory main 
    # and it contains all Heroicons.
    # Move it's contents to Repo svelte-heroicons' lib dir.
    ######################
    GITURL="https://github.com/feathericons/feather"
    # clone heroicons from github
    cd "${CURRENTDIR}" || exit 1
    # if heroicons dir remove it
    if [ -d "${CURRENTDIR}/feathericons" ]; then
      bannerColor 'Removing the previous feathericons dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/feathericons"
    fi

    # clone it
    bannerColor 'Cloning feathericons.' "green" "*"
    git clone "${GITURL}" > /dev/null 2>&1 || {
        echo "not able to clone"
        exit 1
    }

    # copy bin from the cloned dir to feathericons dir
    bannerColor 'Moving feather/bin to the root.' "green" "*"
    if [ -d "${CURRENTDIR}/bin" ]; then
      bannerColor 'Removing the previous bin dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/bin"
    fi

    mv "${CURRENTDIR}/feathericons/bin" "${CURRENTDIR}"

    # create main dir
    if [ -d "${CURRENTDIR}/main" ]; then
      bannerColor 'Removing the previous main dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/main"
    fi
    mkdir "${CURRENTDIR}/main"

    ######################### 
    #        OUTLINE        #
    #########################
    bannerColor 'Changing dir to bin' "blue" "*"
    cd "${CURRENTDIR}/bin" || exit
    exit
    #  modify file names
    bannerColor 'Renaming all files in outline dir.' "blue" "*"
    # in heroicons/outline rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/IconOutline.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # VIEWBOX
    # viewBox="0 0 24 24" to {viewBox} for outline
    sed -i 's/viewBox="0 0 24 24"/{viewBox}/' ./*.*

    # Insert script tag at the beginning and insert class={className} and viewBox
    sed -i '1s/^/<script>export let className="h-6 w-6"; export let viewBox="0 0 24 24";<\/script>/' ./*.* && sed -i 's/fill/class={className} &/' ./*.*
    # END OF VIEWBOX

    bannerColor 'Modification is done in outline dir.' "green" "*"

    # Move all files to main dir
    mv ./* "${CURRENTDIR}/main"

    
    ######################### 
    #         SOLID         #
    #########################

    bannerColor 'Changing dir to optimized/solid' "blue" "*"
    cd "${CURRENTDIR}/optimized/solid" || exit

    #  modify file names
    bannerColor 'Renaming all files in solid dir.' "blue" "*"
    # in heroicons/solid rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/IconSolid.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # VIEWBOX
    # viewBox="0 0 20 20" to {viewBox} for solid
    sed -i 's/viewBox="0 0 20 20"/{viewBox}/' ./*.*

    # Insert script tag at the beginning for solid and insert class={className} and viewBox
    sed -i '1s/^/<script>export let className="h-6 w-6"; export let viewBox="0 0 20 20";<\/script>/' ./*.* && sed -i 's/fill/class={className} &/' ./*.*
    # END OF VIEWBOX

    bannerColor 'Modification is done in solid dir.' "green" "*"

    # Move all files to main dir
    mv ./* "${CURRENTDIR}/main"

    #############################
    #    INDEX.JS PART 1 IMPORT #
    #############################
    cd "${CURRENTDIR}/main" || exit 1

    bannerColor 'Creating index.js file.' "blue" "*"
    # list file names to each index.txt
    find . -type f '(' -name '*.svelte' ')' > index1
    
    # remove ./ from each line
    sed 's/^.\///' index1 > index2
    rm index1

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

    # rm names.txt index2 index3

    bannerColor 'Added export to index.js file.' "green" "*"

    # clean up
    rm -rf "${CURRENTDIR}/heroicons"
    
    bannerColor 'All done.' "green" "*"

     bannerColor 'Copy all files in the main dir to svelte-heroicons lib directory.' 'magenta' '='
}
