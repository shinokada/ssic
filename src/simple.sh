fn_simple() {
    ###########################################################
    # This script creates simple-icons. 
    ###########################################################
    GITURL="git@github.com:simple-icons/simple-icons.git"
    DIRNAME='simple-icons'
    ICONDIR='icons'
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

    bannerColor 'Moving icons dir to the root.' "green" "*"
    if [ -d "${CURRENTDIR}/${ICONDIR}" ]; then
      bannerColor 'Removing the previous icons dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/${ICONDIR}"
    fi

    mv "${CURRENTDIR}/${DIRNAME}/${ICONDIR}" "${CURRENTDIR}"

    ######################### 
    #        ICONS      #
    #########################
    bannerColor 'Changing dir to icons dir' "blue" "*"
    cd "${CURRENTDIR}/${ICONDIR}" || exit

    bannerColor 'Removing all files starting with a number.' "blue" "*"
    find . -type f -name "[0-9]*"  -exec rm {} \;
    bannerColor 'Done.' "green" "*"
    
    #  modify file names
    bannerColor 'Renaming all files in outline dir.' "blue" "*"
    # rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg  > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file
    bannerColor 'Modifying all files.' "blue" "*"

    # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24"; export let color="#1877F2"<\/script>/' ./*.* && sed -i 's/xmlns/width={size} height={size} fill={color} &/' ./*.*

    # Insert {...$$restprops} before xmlns="http://www.w3.org/2000/svg"
    sed -i 's/xmlns=/ class={$$props.class} &/' ./*.*
    

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
    sed "s:\(.*\)\.svelte:import \1 from './&':" index2 > index3
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

    bannerColor "Cleaning up ${CURRENTDIR}/${DIRNAME}." "blue" "*"
    # clean up
    rm -rf "${CURRENTDIR}/${DIRNAME}"
    
    bannerColor 'All done.' "green" "*"
}