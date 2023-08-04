fn_crypto() {
  GITURL="git@github.com:spothq/cryptocurrency-icons.git"
  DIRNAME='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-cryptocurrency-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"
  repo_name="svelte-cryptocurrency-icons"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # Move and rename svg files from the "black" directory
  for file in black/*.svg; do
      new_name="${file/black\//}"
      new_name="${new_name/.svg/-black.svg}"
      mv "$file" "$new_name"
  done

  # Move and rename svg files from the "color" directory
  # for file in color/*.svg; do
  #     new_name="${file/color\//}"
  #     new_name="${new_name/.svg/-color.svg}"
  #     mv "$file" "$new_name"
  # done

  # Move and rename svg files from the "icon" directory
  for file in icon/*.svg; do
      # new_name="${file/icon\//}"
      # new_name="${new_name/.svg/-icon.svg}"
      mv "$file" "$CURRENTDIR"
  done

  # Move and rename svg files from the "white" directory
  for file in white/*.svg; do
      new_name="${file/white\//}"
      new_name="${new_name/.svg/-white.svg}"
      mv "$file" "$new_name"
  done

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
        new_entry=", '$icon_name': { box: 32, svg: '$path_data' }"
      
        # sed -i ", /};/i ${new_entry}," "$file_name"
        sed -i "s|, \}|${new_entry} \n&|" "$file_name"
      
      else
        echo "Adding first time $icon_name ..."
        # If icons.js does not exist, create a new one with the provided data
        echo "{ '$icon_name': { box: 32, svg: '$path_data' }, }" > "$file_name"
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
  cp "${script_dir}/templates/IconNoColor.svelte" "${CURRENTDIR}/Icon.svelte"
  # replace replace_size with 32
  target_value="\"32\""
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
  rm -rf black
  rm -rf color
  rm -rf icon
  rm -rf white

  bannerColor 'Done.' "green" "*"  
}
