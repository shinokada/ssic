fn_hero() {
  GITURL="git@github.com:tailwindlabs/heroicons.git"
  DIRNAME='#v1'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-heros"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"
  repo_name="svelte-heros"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # move all to cloned 
  # Define the source and destination directories

  dest_dir="$CURRENTDIR/cloned"

  # Create the destination directory if it doesn't exist
  mkdir -p "$dest_dir"

  # Enable dotglob to include hidden files in the loop
  # use shopt to remove hidden files
  shopt -s dotglob

  # Move files and directories from src_dir to dest_dir
  for item in "$CURRENTDIR"/*; do
    # Skip moving the cloned directory itself
    if [[ "$item" != "$dest_dir" ]]; then
      mv "$item" "$dest_dir/"
    fi
  done

  # Disable dotglob to reset the behavior
  shopt -u dotglob

  # move cloned/src/outlined and cloned/src/solid to lib dir
  mv "$dest_dir"/src/outline "$CURRENTDIR/"
  mv "$dest_dir"/src/solid "$CURRENTDIR/"
  # remove cloned dir
  rm -r "$dest_dir"

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
    # remove fill="currentColor"
    # sed -i "s|fill=\"currentColor\"||g" "$svg_file"
    # remove stroke="currentColor"
    # sed -i "s|stroke=\"currentColor\"||g" "$svg_file"
    # replace fill="none" with fill={color}"
    # sed -i "s|fill=\"none\"|fill=\{color\}|g" "$svg_file"
    # Replacing fill=" #..." and stroke="#..." with fill={color}
    sed -i 's/fill="[^"]*"//g' "$svg_file"
    sed -i 's/stroke="[^"]*"//g' "$svg_file"
    
    # stroke="#0F172A" stroke-width="1.5"

    # Extract the icon name and remove the prefix/suffix
    icon_name=$(extract_icon_name "$svg_file")

    # Extract the path data from the SVG file
    path_data=$(extract_svg_path "$svg_file")

    if [ -n "$path_data" ]; then
      # Update icons.js with the new data
      # Check if icons.js file exists
      if [ -f "$file_name" ]; then
        echo "Adding $icon_name ..."
        # Create the new entry to be added
        if [[ "$icon_name" == *-solid ]]; then
          new_entry=", '$icon_name': { box: 20, svg: '$path_data' }"
        else
          new_entry=", '$icon_name': { box: 24, svg: '$path_data' }"
        fi
        # sed -i ", /};/i ${new_entry}," "$file_name"
        sed -i "s|, \}|${new_entry} \n&|" "$file_name"
      
      else
        echo "Adding first time $icon_name ..."
        # If icons.js does not exist, create a new one with the provided data
        if [[ "$icon_name" == *-solid ]]; then
          echo "{ '$icon_name': { box: 20, svg: '$path_data' }, }" > "$file_name"
        else
          echo "{ '$icon_name': { box: 24, svg: '$path_data' }, }" > "$file_name"
        fi
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
  # remove all svg and json files
  find . -type f \( -name "*.svg" -o -name "*.json" \) -exec rm {} \;
  rm -rf outline
  rm -rf solid

  bannerColor 'Done.' "green" "*"
}
