fn_boxicons() {
  GITURL="https://github.com/atisawd/boxicons"
  DIRNAME='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-boxicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # Move files from brands directory
  for file in logos/*.svg; do
    mv "$file" "$CURRENTDIR"
  done

  # Move and rename svg files from the "regular" directory
  for file in regular/*.svg; do
    new_name="${file/regular\//}"
    new_name="${new_name/.svg/-regular.svg}"
    mv "$file" "$new_name"
  done

  for file in solid/*.svg; do
    new_name="${file/solid\//}"
    new_name="${new_name/.svg/-solid.svg}"
    mv "$file" "$new_name"
  done

  rm -rf logos
  rm -rf regular
  rm -rf solid

  # Loop through all SVG files in the current directory
  for svg_file in *.svg; do
      # Extract the icon name and remove the prefix/suffix
      icon_name=$(extract_icon_name "$svg_file")
      # icon_name=$(extract_icon_name "$svg_file" "bx-")
      # icon_name=$(extract_icon_name "$svg_file" "bxs-")

      # Extract the path data from the SVG file
      path_data=$(extract_svg_path "$svg_file")

      if [ -n "$path_data" ]; then
        # Update icons.js with the new data
        # Check if icons.js file exists
        if [ -f "$file_name" ]; then
          echo "Adding $icon_name ..."
          # Create the new entry to be added
           new_entry=", '$icon_name': { box: 24, svg: '$path_data' }"
        
          # sed -i ", /};/i ${new_entry}," "$file_name"
          sed -i "s|, \}|${new_entry} \n&|" "$file_name"
        
        else
          echo "Adding first time $icon_name ..."
          # If icons.js does not exist, create a new one with the provided data
          echo "{ '$icon_name': { box: 24, svg: '$path_data' }, }" > "$file_name"
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
  cp "${script_dir}/templates/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  # replace replace_size with 24
  target_value="\"24\""
  sed -i "s/replace_size/$target_value/g" Icon.svelte
  # replace replace_name
  sed -i "s/replace_name/svelte-oct/g" Icon.svelte

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
