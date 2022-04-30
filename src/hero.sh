fn_hero() {
    ################
    # This script creates a single directory main 
    # and it contains all Heroicons.
    # Move it's contents to Repo svelte-heroicons' lib dir.
    ######################
    GITURL="https://github.com/tailwindlabs/heroicons"
    DIRNAME='heroicons'
    # clone heroicons from github
    cd "${CURRENTDIR}" || exit 1
    # if there is the heroicons dir, remove it
    if [ -d "${CURRENTDIR}/${DIRNAME}" ]; then
      bannerColor 'Removing the previous heroicons dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/${DIRNAME}"
    fi

    # clone it
    bannerColor 'Cloning Heroicons.' "green" "*"
    git clone "${GITURL}" > /dev/null 2>&1 || {
        echo "not able to clone"
        exit 1
    }

    # copy optimized from the cloned dir to heroicons dir
    bannerColor 'Moving heroicons/optimized to the root.' "green" "*"
    if [ -d "${CURRENTDIR}/optimized" ]; then
      bannerColor 'Removing the previous optimized dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/optimized"
    fi

    mv "${CURRENTDIR}/${DIRNAME}/optimized" "${CURRENTDIR}"

    # create main dir
    if [ -d "${CURRENTDIR}/main" ]; then
      bannerColor 'Removing the previous main dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/main"
    fi
    mkdir "${CURRENTDIR}/main"

    ######################### 
    #        OUTLINE        #
    #########################
    bannerColor 'Changing dir to optimized/outline' "blue" "*"
    cd "${CURRENTDIR}/optimized/outline" || exit
    
    #  modify file names
    bannerColor 'Renaming all files in outline dir.' "blue" "*"
    # in heroicons/outline rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Outline.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/fill=/width={size} height={size} &/' ./*.*

    # Change stroke="currentColor" to stroke={color}
    sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

    # Insert class={$$props.class} after aria-hidden="true"
    sed -i 's/aria-hidden="true"/& class={$$props.class}/' ./*.*


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
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Solid.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/fill=/stroke="currentColor" width={size} height={size} &/' ./*.*

    # Change stroke="currentColor" to stroke={color}
    sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

    # Change fill="currentColor" to fill={color}
    sed -i 's/fill="currentColor"/fill={color}/' ./*.*

    # Insert class={$$props.class} after aria-hidden="true"
    sed -i 's/aria-hidden="true"/& class={$$props.class}/' ./*.*

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
    rm -rf "${CURRENTDIR}/heroicons"
    
    bannerColor 'All done.' "green" "*"

     bannerColor 'Copy all files in the main dir to svelte-heroicons lib directory.' 'magenta' '='
}
