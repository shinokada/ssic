# fn_modify_svg() {
#   DIR=$1
#   SUBDIR=$2

#   bannerColor "Changing dir to ${DIR}/${SUBDIR}" "blue" "*"
#   cd "${DIR}/${SUBDIR}" || exit
#   # For each svelte file modify contents of all file by
#   # pwd
#   bannerColor "Modifying all files in ${SUBDIR}." "cyan" "*"

#   # removing width="24" height="24"
#   sed -i 's/width="16" height="16"/width="{size}" height="{size}"/' ./*.* >/dev/null 2>&1

#   # remove fill="currentColor"
#   sed -i 's/fill="currentColor"//' ./*.* >/dev/null 2>&1

#   # remove class="bi bi-alt", class="bi bi-align-center", class="bi bi-align-end", etc
#   sed 's/class="[^"]*"/class="{$$props.class}"/g' ./*.* >/dev/null 2>&1

#   # replace width="any number" with width={size}
#   # sed 's/width="[^"]*"/width="{size}"/g' ./*.*
#   # replace height="any number" with height={size}
#   # sed 's/height="[^"]*"/height="{size}"/g' ./*.*

#   bannerColor "Inserting script tag to all files." "magenta" "*"
#   # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
#   sed -i '1s/^/<script>export let size="16";  export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/fill={color} {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.* >/dev/null 2>&1

#   bannerColor "Getting file names in ${SUBDIR}." "blue" "*"
#   # get textname from filename
#   for filename in "${DIR}/${SUBDIR}"/*; do
#     FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
#     # echo "${FILENAME}"
#     sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
#   done

#   #  modify file names
#   bannerColor "Renaming all files in the ${SUBDIR} dir." "blue" "*"
#   rename -v 's{^\./(\d*)(.*)\.svg\Z}{
#   ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

#   bannerColor 'Renaming is done.' "green" "*"

#   bannerColor 'Modification is done in the dir.' "green" "*"
# }

fn_bootstrap() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/twbs/icons"
  DIRNAME='icons'
  SVGDIR='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-bootstrap-svg-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  # fn_modify_svg "${CURRENTDIR}" "${SVGDIR}"
  # Move all files to lib dir
  # mv "${CURRENTDIR}/${SVGDIR}"/* "${CURRENTDIR}"
  # Loop through all SVG files in the current directory
  for svg_file in *.svg; do
    # Extract the icon name and remove the 'ei-' prefix
    icon_name=$(extract_icon_name "$svg_file")

    # Extract the path data from the SVG file
    path_data=$(extract_svg_path "$svg_file")

    if [ -n "$path_data" ]; then
      # Update icons.js with the new data
      # Check if icons.js file exists
      if [ -f "$file_name" ]; then
        echo "Adding $icon_name ..."
        # Create the new entry to be added
        new_entry=", '$icon_name': { box: 16, svg: '$path_data' }"
      
        # sed -i ", /};/i ${new_entry}," "$file_name"
        sed -i "s|, \}|${new_entry} \n&|" "$file_name"
      
      else
        echo "Adding first time $icon_name ..."
        # If icons.js does not exist, create a new one with the provided data
        echo "{ '$icon_name': { box: 16, svg: '$path_data' }, }" > "$file_name"
      fi
      echo "Successfully updated $file_name with the path data for \"$icon_name\" icon."
    else
      echo "SVG content in \"$svg_file\" is invalid or does not contain any path data."
    fi

    # replace fill="currentColor" with fill={color}"
    sed -i "s|currentColor|\{color\}|g" "$file_name"

  done

   # modify icons.js
  # Contents to be added at the beginning
  start_content="const icons ="

  # Contents to be added at the end
  end_content="export default icons;"

  # Temp file to store modified contents
  touch temp_file.js
  temp_file="temp_file.js"
  # Add the start_content at the beginning of the file
  echo "$start_content" > "$temp_file"
  cat "$file_name" >> "$temp_file"

  # Add an empty line and the end_content at the end of the file
  echo "" >> "$temp_file"
  echo "$end_content" >> "$temp_file"
  # Overwrite the original file with the modified contents
  mv "$temp_file" "$file_name"
  # end of modifying icons.js

  # copy 
  cp "${script_dir}/templates/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  # replace replace_size with 16
  target_value="\"16\""
  sed -i "s/replace_size/$target_value/g" Icon.svelte
  # replace replace_name with svelte-bootstrap-svg-icons
  sed -i "s/replace-name/svelte-bootstrap-svg-icons/g" Icon.svelte

  # create a index.js
  # Content to write in the index.js file
  content="export { default as Icon } from './Icon.svelte';
export { default as icons } from './icons.js';"

  # Write the content to index.js
  echo "$content" > index.js
  # endo fo creating the index.js
  
  # cleanup
  # remove all svg files
  find . -type f -name "*.svg" -exec rm {} \;

  bannerColor 'Done.' "green" "*"
}
