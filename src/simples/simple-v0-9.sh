fn_simple() {
    GITURL="git@github.com:simple-icons/simple-icons.git"
    DIRNAME='icons'
    SVELTE_LIB_DIR='src/lib'
    LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/simples/svelte-simples"
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
    
    clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

    bannerColor 'Removing all files starting with a number.' "blue" "*"
    find . -type f -name "[0-9]*"  -exec rm {} \;
    
    #  modify file names
    bannerColor 'Renaming all files in the dir.' "blue" "*"
    # rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg  > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # removing width="24" height="24"
    sed -i 's/role="img"//' ./*.*
    
    # For each svelte file modify contents of all file
    bannerColor 'Modifying all files.' "blue" "*"

    # Insert script tag at the beginning and insert width={size} height={size} 
    sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; <\/script>/' ./*.* && sed -i 's/xmlns/width={size} height={size} fill={color} &/' ./*.*

    # Insert {...$$restprops} before xmlns="http://www.w3.org/2000/svg"
    sed -i 's/xmlns=/ {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

    # aria-label
    for filename in "${CURRENTDIR}"/*; do
      FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
      # echo "${FILENAME}"
      sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
    done

    cp "${script_dir}/templates/simples/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

    bannerColor 'Creating index.js file.' "blue" "*"
    
    find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
      print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js
    
    bannerColor 'All done.' "green" "*"
}