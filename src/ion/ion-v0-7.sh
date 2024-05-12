fn_ion() {
  GITURL="git@github.com:ionic-team/ionicons.git"
  DIRNAME='src/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-ionicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "${DIRNAME}" "$GITURL"
  
  bannerColor 'Changing dir to icons dir' "blue" "*"
  cd "${CURRENTDIR}" || exit

  bannerColor 'Removing all files starting with a number.' "blue" "*"
  find . -type f -name "[0-9]*" -exec rm {} \;
  bannerColor 'Done.' "green" "*"

  #  modify file names
  bannerColor 'Renaming all files in outline dir.' "blue" "*"
  rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg >/dev/null 2>&1
  bannerColor 'Renaming is done.' "green" "*"

  # For each svelte file modify contents of all file
  bannerColor 'Modifying all files.' "blue" "*"

  # remove <?xml version="1.0" encoding="utf-8"?>
  sed -i 's/<?xml version="1.0" encoding="utf-8"?>//' ./*.*

  # Change viewBox="0 0 512 512" to viewBox="0 0 512 512" width={size} height={size} class={$$props.class}
  sed -i 's/viewBox="0 0 512 512"/viewBox="0 0 512 512" {...$$restProps} {role} width={size} height={size} fill={color} aria-label={ariaLabel} class={$$props.class} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout /' ./*.*

  # remove  width="512" and height="512"
  sed -i 's/width="512"//' ./*.*
  sed -i 's/height="512"//' ./*.*
  sed -i 's/stroke="#000"/stroke="currentColor"/g' ./*.*

  # remove title>ionicons-v5-a</title>
  sed -i 's|<title>ionicons-v5-a</title>||' ./*.*

  # remove fill="currentColor"
  sed -i 's/fill="currentColor"//g' ./*.*

  # Change stroke:#000 to stroke:{color}
  sed -i 's/stroke:#000/stroke:{color}/g' ./*.*

  # Insert script tag at the beginning and insert class={className} and viewBox
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor";<\/script>/' ./*.*

  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\"\; \n&;" "${filename}" >/dev/null 2>&1
  done

  bannerColor 'Modification is done in outline dir.' "green" "*"


  cp "${script_dir}/templates/ion/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"
  
  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'All done.' "green" "*"
}