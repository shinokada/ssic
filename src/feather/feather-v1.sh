# fn_svg_path(){
#   for file in *; do
#     FILENAME=$(basename "${file%.*}")
#     SVETLENAME="${CURRENTDIR}/${FILENAME}.svelte"
#     # create svelte file like address-book-solid.svelte
#     if [ ! -f "${file}" ]; then
#       cp "${TEMPLATE}" "${SVETLENAME}"
#     fi

#     SVGPATH=$(extract_svg_path "$file")
#     # replace replace_svg_path with svg path
#     sed -i "s;replace_svg_path;${SVGPATH};" "${SVETLENAME}"
#     # get viewBox value
#     VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
#     sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVETLENAME}"
#   done
# }

# fn_modify_filenames() {
#   # cd "${CURRENTDIR}" || exit 1
#   bannerColor "Adding arialabel to all files." "blue" "*"
#   for filename in "${CURRENTDIR}"/*; do
#     FILENAMEONE=$(basename "${filename}")
#     FILENAME=$(basename "${filename}" | tr '-' ' ')
    
#     # echo "${FILENAME}"
#     sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1

#     new_name=$(echo "${FILENAMEONE^}")
#     # Capitalize the letter after -
#     new_name=$(echo "$new_name" | sed 's/-./\U&/g')
#     # Remove all -
#     new_name=$(echo "$new_name" | sed 's/-//g')
#     # Remove all spaces
#     new_name=$(echo "$new_name" | sed 's/ //g')
#     # echo "${new_name}"
#     # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
#     mv "${CURRENTDIR}/${FILENAMEONE}.svg" "${CURRENTDIR}/${new_name}.svelte"
#   done
  
#   bannerColor 'Modification and renaming is done.' "green" "*"
# }


fn_feather() {
  GITURL="git@github.com:feathericons/feather.git"
  DIRNAME='icons'
  # ICONDIR='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-feathers"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  TEMPLATE="${script_dir}/templates/feather/feather-v1.txt"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  bannerColor 'Modifying all files.' "blue" "*"
  fn_svg

  # remove all svg files
  find . -type f -name "*.svg" -exec rm {} \;

  bannerColor 'Renaming all files.' "blue" "*"
  fn_add_arialabel

  bannerColor 'Removing all svg files.' "blue" "*"
  fn_remove_svg

  bannerColor 'Renaming all files.' "blue" "*"
  fn_rename

   # rename files with number at the beginning with A
  # rename -v 's{^\./(\d*)(.*)\.svelte\Z}{
  # ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  # }ge' ./*.svelte >/dev/null 2>&1

  cd "${CURRENTDIR}" || exit 1

  cp "${script_dir}/templates/feather/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"


  bannerColor 'All done.' "green" "*"

  # Change from width="24" and height="24" to width={size} and height={size}
  # sed -i 's/width="24"/width={size}/' ./*.*
  # sed -i 's/height="24"/height={size}/' ./*.*

  # Change stroke="currentColor" to stroke={color}
  # sed -i 's/stroke="currentColor"/stroke={color}/' ./*.*
  # chage fill="none" to {fill}
  # sed -i 's/fill="none"/{fill}/' ./*.*

  # Insert script tag at the beginning 
  # sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; export let tabIndex = ctx.tabIndex || '-1'; export let fill = ctx.fill || "none";<\/script>/' ./*.* 

  # Insert {...$$restprops} after stroke-linejoin="round" 
  # sed -i 's/stroke-linejoin="round"/& class={$$props.class} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout /' ./*.*

  # for filename in "${CURRENTDIR}"/*; do
  #   # add arialabel
  #   FILENAMEONE=$(basename "${filename}" .svg)
  #   FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
  #   sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\"\; \n&;" "${filename}" >/dev/null 2>&1

  #   # Capitalize the first letter
  #   new_name=$(echo "${FILENAMEONE^}")
  #   # Capitalize the letter after -
  #   new_name=$(echo "$new_name" | sed 's/-./\U&/g')
  #   # Remove all -
  #   new_name=$(echo "$new_name" | sed 's/-//g')
  #   # Change the extension from svg to svelte
  #   # new_name=$(echo "$new_name" | sed 's/svg$/svelte/g')
  #   mv "${CURRENTDIR}/${FILENAMEONE}.svg" "${CURRENTDIR}/${new_name}.svelte"
  # done

  #   cp "${script_dir}/templates/feather/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  #   bannerColor 'Creating index.js file.' "blue" "*"
    
  #   find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  #   print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  #   }' >index.js

  #   bannerColor 'Added export to index.js file.' "green" "*"
    
  #   bannerColor 'All done.' "green" "*"
}