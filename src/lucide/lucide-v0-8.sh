fn_lucide() {
    GITURL="git@github.com:lucide-icons/lucide.git"
    DIRNAME='icons'
    LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-lucide"
    SVELTE_LIB_DIR='src/lib'
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

    clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

    bannerColor 'Remove all json files.' "blue" "*"
    if ls *.json &> /dev/null; then
      echo "Directory contains JSON files."
      bannerColor 'Directory contains JSON files. Removing them ...' "blue" "*"
      rm *.json
      bannerColor 'Removed.' "green" "*"
    else
      bannerColor 'Directory does not contain any JSON files.' "blue" "*"
    fi
    
    #  modify file names
    bannerColor 'Renaming all files in outline dir.' "blue" "*"
    # in heroicons/outline rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg  > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # For each svelte file modify contents of all file
    bannerColor 'Modifying all files.' "blue" "*"

    # Change from width="24" and height="24" to width={size} and height={size}
    sed -i 's/width="24"/width={size}/' ./*.*
    sed -i 's/height="24"/height={size}/' ./*.*
    # stroke-width="2" to stroke-width={strokeWidth}
    sed -i 's/stroke-width="2"/stroke-width=\{strokeWidth\}/' ./*.*
    # Change stroke="currentColor" to stroke={color}
    sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*

    # Insert script tag at the beginning and insert class={className} and viewBox
    sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; export let strokeWidth = ctx.strokeWidth || "2";<\/script>/' ./*.* 

    # Insert {...$$restprops} after stroke-linejoin="round" 
    sed -i 's/stroke-linejoin="round"/& {...$$restProps} {role} aria-label="{ariaLabel}" on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout /' ./*.*

    for filename in "${CURRENTDIR}"/*; do
      FILENAMEONE=$(basename "${filename}" .svelte)
      FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
      sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\"\; \n&;" "${filename}" >/dev/null 2>&1
    done

    bannerColor 'Modification is done in outline dir.' "green" "*"

    cp "${script_dir}/templates/lucide/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

    bannerColor 'Creating index.js file.' "blue" "*"
    
    find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js
    
    bannerColor 'All done.' "green" "*"
}