fn_flagicons() {
  GITURL="https://github.com/lipis/flag-icons"
  DIRNAME='flags/4x3'
  # SVGDIR='flags/4x3'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-flag-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # For each svelte file modify contents of all file by
  bannerColor 'Modifying all files.' "blue" "*"

  # inserting script tag at the beginning and insert width={size} height={size} 
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"flag of ${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in the dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Modification is done in the dir.' "green" "*"

  cp "${script_dir}/templates/flag-icons/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"
  
  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  # rm -rf "${CURRENTDIR}/${DIRNAME}"
  # rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}