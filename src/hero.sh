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
    # in heroicons/outline and heroicons/solid rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon.svelte/' -- *.svg  
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # viewBox="0 0 24 24" to {viewBox} for outline
    sed -i 's/viewBox="0 0 24 24"/{viewBox}/' ./*.*

    # Insert script tag at the beginning for solid and insert class={className} and viewBox
    sed -i '1s/^/<script>export let className="h-6 w-6"; export let viewBox="0 0 24 24";<\/script>/' ./*.* && sed -i 's/fill/class={className} &/' ./*.*

    bannerColor 'Modification is done in outline dir.' "green" "*"

    bannerColor 'Creating index.js file.' "blue" "*"
    # list file names to each index.txt
    find . -type f '(' -name '*.svelte' ')' > index
    
    # removed ./ from each line
    sed 's/^.\///' index > index.txt
    rm index

    # create a names.txt
    sed 's/.svelte//' index.txt > names.txt
    # Add , after each line in names.txt
    sed -i 's/$/,/' names.txt

    # Create import section in index-outline.txt and index-solid.txt files.
    # for outline
    sed "s:\(.*\)\.svelte:import \1 from './heroicons/outline/&':" index.txt > index.js
    bannerColor 'Created index.js file with import.' "green" "*"
    # for solid
    # sed "s:\(.*\)\.svelte:import \1 from './heroicons/solid/&':" index.txt > index-solid.txt
    

    #################
    #    INDEX.JS   #
    #################
    
    bannerColor 'Adding export to index.js file.' "blue" "*"
    # Add export{} section
    # 1 insert export { to index.js, 
    # 2 insert icon-names to index.js after export { 
    # 3. append }
    echo 'export {' >> index-outline.txt && cat index-outline.txt names.txt > index-outline.js && echo '}' >> index-outline.js
    echo 'export {' >> index-solid.txt && cat index-solid.txt names.txt > index-solid.js && echo '}' >> index-solid.js

    rm names.txt index.txt

    bannerColor 'Added export to index.js file.' "green" "*"
    
    exit
    ######################### 
    #         SOLID         #
    #########################
    bannerColor 'Changing dir to optimized/solid' "blue" "*"
    cd "${CURRENTDIR}/optimized/solid" || exit

    #  modify file names
    bannerColor 'Renaming all files in solid dir.' "blue" "*"
    # in heroicons/outline and heroicons/solid rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon.svelte/' -- *.svg  
    bannerColor 'Renaming is done.' "green" "*"
    
    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # viewBox="0 0 20 20" to {viewBox} for solid
    sed -i 's/viewBox="0 0 20 20"/{viewBox}/' ./*.*

    # Insert script tag at the beginning for solid and insert class={className} and viewBox
    sed -i '1s/^/<script>export let className="h-6 w-6"; export let viewBox="0 0 20 20"<\/script>/' ./*.* && sed -i 's/fill/class={className} &/' ./*.*

    bannerColor 'Modification is done in solid dir.' "green" "*"

    # rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon/' -- *.svg  && ls > icon-names.txt
    
    #################
    #    INDEX.JS   #
    #################
    

    # Add export{} section
    # 1 insert export { to index.js, 
    # 2 insert icon-names to index.js after export { 
    # 3. append }
    echo 'export {' >> index-outline.txt && cat index-outline.txt names.txt > index-outline.js && echo '}' >> index-outline.js
    echo 'export {' >> index-solid.txt && cat index-solid.txt names.txt > index-solid.js && echo '}' >> index-solid.js
    
    # copy index.js files to outline and solid dir
    mv "${CURRENTDIR}/heroicons/index-outline.js" "${CURRENTDIR}/heroicons/outline/index.js" 
    mv "${CURRENTDIR}/heroicons/index-solid.js" "${CURRENTDIR}/heroicons/solid/index.js"    
    # clean up
    rm icon-names.txt index.txt
    rm -rf "${CURRENTDIR}/heroicons"
    
    echo "Done."
}
