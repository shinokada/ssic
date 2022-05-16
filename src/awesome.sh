fn_awesome() {
    ################
    # This script creates a single directory main 
    # and it contains all Heroicons.
    # Move it's contents to Repo svelte-heroicons' lib dir.
    ######################
    GITURL="git@github.com:FortAwesome/Font-Awesome.git"
    DIRNAME='Font-Awesome'
    # clone Font-Awesome from github
    cd "${CURRENTDIR}" || exit 1
    # if there is the svgs dir, remove it
    if [ -d "${CURRENTDIR}/${DIRNAME}" ]; then
      bannerColor 'Removing the previous Font-Awesome dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/${DIRNAME}"
    fi

    # clone the repo
    bannerColor 'Cloning Font-Awesome.' "green" "*"
    git clone "${GITURL}" > /dev/null 2>&1 || {
        echo "not able to clone"
        exit 1
    }

    # copy svgs dir from the cloned dir
    bannerColor 'Moving svgs dir to the root.' "green" "*"
    if [ -d "${CURRENTDIR}/svgs" ]; then
      bannerColor 'Removing the previous svgs dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/svgs"
    fi

    mv "${CURRENTDIR}/${DIRNAME}/svgs" "${CURRENTDIR}"

    # create main dir
    if [ -d "${CURRENTDIR}/main" ]; then
      bannerColor 'Removing the previous main dir.' "blue" "*"
      rm -rf "${CURRENTDIR}/main"
    fi
    mkdir "${CURRENTDIR}/main"

    ######################### 
    #         Solid         #
    #########################
    bannerColor 'Changing dir to svgs/solid' "blue" "*"
    cd "${CURRENTDIR}/svgs/solid" || exit
    
    #  modify file names
    bannerColor 'Renaming all files in solid dir.' "blue" "*"

    # rename files with number at the beginning with A
    # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
    rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Solid.svelte"
  }ge' ./*.svg > /dev/null 2>&1

    # rename file names 
    # rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Solid.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # remove <!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->
    sed -i 's/<!--! Font Awesome Free 6.1.1 by @fontawesome - https:\/\/fontawesome.com License - https:\/\/fontawesome.com\/license\/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->/\n/' ./*.*

    # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} fill={color} class={$$props.class} &/' ./*.*

    # Change stroke="currentColor" to stroke={color}
    # sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

    # Insert class={$$props.class} after aria-hidden="true"
    # sed -i 's/aria-hidden="true"/& class={$$props.class}/' ./*.*

    bannerColor 'Modification is done in outline dir.' "green" "*"

    # Move all files to main dir
    mv ./* "${CURRENTDIR}/main"

    
    ######################### 
    #         Regular         #
    #########################

    bannerColor 'Changing dir to svgs/regular' "blue" "*"
    cd "${CURRENTDIR}/svgs/regular" || exit

    #  modify file names
    bannerColor 'Renaming all files in regular dir.' "blue" "*"

    # rename files with number at the beginning with A
    # rename -v 's/^(\d+)\.svg\Z/A${1}.svg/' [0-9]*.svg
    rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Regular.svelte"
  }ge' ./*.svg > /dev/null 2>&1

    # rename file names 
    # rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Regular.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # remove <!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->
    sed -i 's/<!--! Font Awesome Free 6.1.1 by @fontawesome - https:\/\/fontawesome.com License - https:\/\/fontawesome.com\/license\/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->/\n/' ./*.*

    # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} fill={color} class={$$props.class} &/' ./*.*

    bannerColor 'Modification is done in solid dir.' "green" "*"

    # Move all files to main dir
    mv ./* "${CURRENTDIR}/main"

     ######################### 
    #         Brands         #
    #########################

    bannerColor 'Changing dir to svgs/brands' "blue" "*"
    cd "${CURRENTDIR}/svgs/brands" || exit

    #  modify file names
    bannerColor 'Renaming all files in regular dir.' "blue" "*"

    # rename files with number at the beginning with A
    # rename -v 's/^(\d+)\.svg\Z/A$.svg/' [0-9]*.svg
    # rename -v 's/^(\d+)\.svg\Z/A${1}Brand.svelte/' [0-9]*.svg
    rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Brand.svelte"
  }ge' ./*.svg > /dev/null 2>&1

    # rename file names 
    # rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Brand.svelte/' -- *.svg > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file by adding
    bannerColor 'Modifying all files.' "blue" "*"

    # remove <!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->
    sed -i 's/<!--! Font Awesome Free 6.1.1 by @fontawesome - https:\/\/fontawesome.com License - https:\/\/fontawesome.com\/license\/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->/\n/' ./*.*

    # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
    sed -i '1s/^/<script>export let size="24"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} fill={color} class={$$props.class} &/' ./*.*

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
    rm -rf "${CURRENTDIR}/Font-Awesome"
    rm -rf "${CURRENTDIR}/svgs"
    
    bannerColor 'All done.' "green" "*"

    bannerColor 'Copy all files in the main dir to svelte-heroicons lib directory.' 'magenta' '='
}
