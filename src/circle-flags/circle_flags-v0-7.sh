fn_circle_flags() {
  GITURL="https://github.com/HatScripts/circle-flags"
  DIRNAME='flags'
  # SVGDIR='flags'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/circle-flags/svelte-circle-flags"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # remove all directories
  bannerColor "Deleting language and fictional dir" "red" "*"
  rm -rf "${CURRENTDIR}"/fictional "${CURRENTDIR}"/language || exit

  # remove all symlinks
  bannerColor "Deleting all symlinks" "red" "*"
  find "${CURRENTDIR}" -type l -exec rm {} \;

  # Loop through files matching the pattern "it-*.svg"
  for file in it-[0-9]*.svg; do
    # Check if the file name is not exactly "it.svg"
    if [ "$file" != "it.svg" ]; then
        # Delete the file
        rm "$file"
        echo "Deleted: $file"
    fi
  done
  # For each svg file modify contents by
  bannerColor 'Modifying all files.' "blue" "*"

  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img";<\/script>/' ./*.* && sed -i 's/viewBox=/class={$$props.class} {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # Change from width="512" and height="512" to width={size} and height={size}
  sed -i 's/width="512"/width={size}/' ./*.*
  sed -i 's/height="512"/height={size}/' ./*.*

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

  bannerColor 'Renaming is done.' "green" "*"
  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"
  
  cp "${script_dir}/templates/circle-flags/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  
  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  
  # clean up
  rm -rf "${CURRENTDIR}/${DIRNAME}"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}