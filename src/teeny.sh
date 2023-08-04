fn_teeny() {
  GITURL="https://github.com/teenyicons/teenyicons"
  DIRNAME='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-teenyicons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"
  repo_name="svelte-teenyicons"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # Move and rename svg files from the "outline" directory
  for file in outline/*.svg; do
      new_name="${file/outline\//}"
      new_name="${new_name/.svg/-outline.svg}"
      mv "$file" "$new_name"
  done

  # Move and rename svg files from the "solid" directory
  for file in solid/*.svg; do
      new_name="${file/solid\//}"
      new_name="${new_name/.svg/-solid.svg}"
      mv "$file" "$new_name"
  done

  # Loop through all SVG files in the current directory
  for svg_file in *.svg; do
    sed -i 's/fill="black"//g' "${svg_file}"
    sed -i 's/stroke="black"//g' "${svg_file}"
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
        new_entry=", '$icon_name': { box: 15, svg: '$path_data' }"
      
        # sed -i ", /};/i ${new_entry}," "$file_name"
        sed -i "s|, \}|${new_entry} \n&|" "$file_name"
      
      else
        echo "Adding first time $icon_name ..."
        # If icons.js does not exist, create a new one with the provided data
        echo "{ '$icon_name': { box: 15, svg: '$path_data' }, }" > "$file_name"
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
  cp "${script_dir}/templates/IconHeroSolid.svelte" "${CURRENTDIR}/IconSolid.svelte"
  cp "${script_dir}/templates/IconHeroOutline.svelte" "${CURRENTDIR}/IconOutline.svelte"
  # replace replace_size with 24
  target_value="\"24\""
  sed -i "s/replace_size/$target_value/g" IconOutline.svelte
  # replace replace_size with 20
  target_value="\"20\""
  sed -i "s/replace_size/$target_value/g" IconSolid.svelte
  # replace replace_name with repo_name
  sed -i "s/replace_name/$repo_name/g" IconSolid.svelte
  sed -i "s/replace_name/$repo_name/g" IconOutline.svelte
  # replace strokeWidth = "2"; to 1.5
  # sed -i 's/strokeWidth = "2";/strokeWidth = "1.5";/g'  Icon.svelte
  
  # create a index.js
  # Content to write in the index.js file
  content="export { default as IconSolid } from './IconSolid.svelte';
export { default as IconOutline } from './IconOutline.svelte';
export { default as icons } from './icons.js';"

  # Write the content to index.js
  echo "$content" > index.js
  # endo fo creating the index.js
  
  # cleanup
  # remove all svg files
  find . -type f -name "*.svg" -exec rm {} \;
  rm -rf outline
  rm -rf solid

  bannerColor 'Done.' "green" "*"  

}
