fn_flowbite() {
  GITURL="https://github.com/themesberg/flowbite-icons"
  DIRNAME='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/flowbite-svelte-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"
  repo_name="flowbite-svelte-icons"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # Set your source and destination directories
  # src_dir="$CURRENTDIR"
  dest_dir="$CURRENTDIR"

  # Move and rename the SVG files in the "outline" directory with the "-outline" suffix
  move_and_rename_svg "outline" "-outline" "$dest_dir"

  # Move and rename the SVG files in the "solid" directory with the "-solid" suffix
  move_and_rename_svg "solid" "-solid" "$dest_dir"

  rm -rf "outline"
  rm -rf "solid"

  # Loop through all SVG files in the current directory
  for svg_file in *.svg; do
    
    sed -i "s;#2F2F38;currentColor;" "${svg_file}"
    # #111928
    sed -i "s;#111928;currentColor;" "${svg_file}"
    # #2F3039
    sed -i "s;#2F3039;currentColor;" "${svg_file}"
    # #1F2A37
    sed -i "s;#1F2A37;currentColor;" "${svg_file}"
    
    # Extract the icon name
    icon_name=$(extract_icon_name "$svg_file")

    # Extract the path data from the SVG file
    path_data=$(extract_svg_path "$svg_file")

    # extract box dimensions
    extract_box_dimensions "$svg_file"

    if [ -n "$path_data" ]; then
      # Update icons.js with the new data
      # Check if icons.js file exists
      if [ -f "$file_name" ]; then
        echo "Adding $icon_name ..."
        # Create the new entry to be added
        new_entry=", '$icon_name': { width: '$box_width', height: '$box_height', svg: '$path_data' }"
      
        # sed -i ", /};/i ${new_entry}," "$file_name"
        sed -i "s|, \}|${new_entry} \n&|" "$file_name"
      
      else
        echo "Adding first time $icon_name ..."
        # If icons.js does not exist, create a new one with the provided data
        echo "{ '$icon_name': { width: '$box_width', height: '$box_height', svg: '$path_data' }, }" > "$file_name"
      fi
      echo "Successfully updated $file_name with the path data for \"$icon_name\" icon."
    else
      echo "SVG content in \"$svg_file\" is invalid or does not contain any path data."
    fi

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
  cp "${script_dir}/templates/IconFlowbite.svelte" "${CURRENTDIR}/Icon.svelte"
  # replace replace_size with 50
  target_value="\"50\""
  sed -i "s/replace_size/$target_value/g" Icon.svelte
  # replace replace_name with repo_name
  sed -i "s/replace_name/$repo_name/g" Icon.svelte
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
