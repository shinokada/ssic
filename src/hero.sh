fn_hero() {
    
    # clone heroicons from github
    cd "${CURRENTDIR}" || exit 1
    # if heroicons dir remove it
    if [ -d "${CURRENTDIR}/heroicons" ]; then
      bannerColor 'Removing the previous heroicons dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/heroicons"
    fi

    # clone it
    bannerColor 'Cloning Heroicons.' "green" "*"
    git clone "${GITHEROURL}" || {
        echo "not able to clone"
        exit 1
    }

    # copy optimized from the cloned dir to heroicons dir
    bannerColor 'Moving heroicons/optimized to the root.' "green" "*"
    if [ -d "${CURRENTDIR}/optimized" ]; then
      bannerColor 'Removing the previous optimized dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/optimized"
    fi

    mv "${CURRENTDIR}/heroicons/optimized" "${CURRENTDIR}"

    ######################### 
    #        OUTLINE        #
    #########################
    bannerColor 'Changing dir to optimized/outline' "blue" "*"
    cd "${CURRENTDIR}/optimized/outline" || exit
    
    #  modify file names
    bannerColor 'Renaming all files in outline dir.' "blue" "*"
    # in heroicons/outline rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon.svelte/' -- *.svg  
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

    bannerColor 'Creating index.js file.' "blue" "*"
    # list file names to each index.txt
    find . -type f '(' -name '*.svelte' ')' > index1
    
    # removed ./ from each line
    sed 's/^.\///' index1 > index2
    rm index1

    # create a names.txt
    sed 's/.svelte//' index2 > names.txt
    # Add , after each line in names.txt
    sed -i 's/$/,/' names.txt

    # Create import section in index2 files.
    # for outline
    sed "s:\(.*\)\.svelte:import \1 from './/&':" index2 > index3
    bannerColor 'Created index.js file with import.' "green" "*"

    #################
    #    INDEX.JS   #
    #################
    
    bannerColor 'Adding export to index.js file.' "blue" "*"
    # Add export{} section
    # 1 insert export { to index.js, 
    # 2 insert icon-names to index.js after export { 
    # 3. append }
    echo 'export {' >> index3 && cat index3 names.txt > index.js && echo '}' >> index.js

    rm names.txt index2 index3

    bannerColor 'Added export to index.js file.' "green" "*"

    
    ######################### 
    #         SOLID         #
    #########################
    bannerColor 'Changing dir to optimized/solid' "blue" "*"
    cd "${CURRENTDIR}/optimized/solid" || exit

    #  modify file names
    bannerColor 'Renaming all files in solid dir.' "blue" "*"
    # in heroicons/solid rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon.svelte/' -- *.svg  
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

    bannerColor 'Creating index.js file.' "blue" "*"
    # list file names to each index.txt
    find . -type f '(' -name '*.svelte' ')' > index1
    
    # removed ./ from each line
    sed 's/^.\///' index1 > index2
    rm index1

    # create a names.txt
    sed 's/.svelte//' index2 > names.txt
    # Add , after each line in names.txt
    sed -i 's/$/,/' names.txt

    # Create import section in index2 files.
    # for solid
    sed "s:\(.*\)\.svelte:import \1 from './/&':" index2 > index3
    bannerColor 'Created index.js file with import.' "green" "*"
    

    #################
    #    INDEX.JS   #
    #################
    
    bannerColor 'Adding export to index.js file.' "blue" "*"
    # Add export{} section
    # 1 insert export { to index.js, 
    # 2 insert icon-names to index.js after export { 
    # 3. append }
    echo 'export {' >> index3 && cat index3 names.txt > index.js && echo '}' >> index.js
    # echo 'export {' >> index-solid.txt && cat index-solid.txt names.txt > index-solid.js && echo '}' >> index-solid.js

    rm names.txt index2 index3

    bannerColor 'Added export to index.js file.' "green" "*"

    # clean up
    rm -rf "${CURRENTDIR}/heroicons"
    
    bannerColor 'All done.' "green" "*"
}
