fn_feather() {
    ###########################################################
    # This script creates feather-icons. 
    ###########################################################
    GITURL="git@github.com:feathericons/feather.git"
    DIRNAME='feather'
    ICONDIR='icons'
    LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-feathers"
    SVELTE_LIB_DIR='src/lib'
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
    # clone icons from github
    cd "${CURRENTDIR}" || exit 1
    # if there is the svgs, remove it
    if [ -d "${CURRENTDIR}" ]; then
      bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
      rm -rf "${CURRENTDIR:?}/"*
    fi

    # clone it
    bannerColor "Cloning ${DIRNAME}." "green" "*"
    npx tiged "${GITURL}/${ICONDIR}" >/dev/null 2>&1 || {
      echo "not able to clone"
      exit 1
    }

    ######################### 
    #        ICONS      #
    #########################
    
    bannerColor 'Removing all files starting with a number.' "blue" "*"
    find . -type f -name "[0-9]*"  -exec rm {} \;
    bannerColor 'Done.' "green" "*"
    
    #  modify file names
    bannerColor 'Renaming all files in outline dir.' "blue" "*"
    # in heroicons/outline rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon.svelte/' -- *.svg  > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file
    bannerColor 'Modifying all files.' "blue" "*"

    # Change from width="24" and height="24" to width={size} and height={size}
    sed -i 's/width="24"/width={size}/' ./*.*
    sed -i 's/height="24"/height={size}/' ./*.*

    # Change stroke="currentColor" to stroke={color}
    sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

    # Insert script tag at the beginning and insert class={className} and viewBox
    sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* 

    # Insert {...$$restprops} after stroke-linejoin="round" 
    sed -i 's/stroke-linejoin="round"/& class={$$props.class} {role} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout /' ./*.*

    # Add component doc
    for file in ./*.*; do
      echo -e "\n<!--\n@component\n[Go to Document](https://svelte-feathers.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop role = 'img';\n@prop color = 'currentColor';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
    done

    bannerColor 'Modification is done in outline dir.' "green" "*"

    bannerColor 'Creating index.js file.' "blue" "*"
    
    find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

    bannerColor 'Added export to index.js file.' "green" "*"
    
    bannerColor 'All done.' "green" "*"
}