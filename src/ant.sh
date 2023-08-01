fn_ant() {
  GITURL="https://github.com/ant-design/ant-design-icons"
  DIRNAME='packages/icons-svg/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-ant-design-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # Move and rename svg files from the "filled" directory
  for file in filled/*.svg; do
      new_name="${file/filled\//}"
      new_name="${new_name/.svg/-filled.svg}"
      mv "$file" "$new_name"
  done

  # Move and rename svg files from the "outlined" directory
  for file in outlined/*.svg; do
      new_name="${file/outlined\//}"
      new_name="${new_name/.svg/-outlined.svg}"
      mv "$file" "$new_name"
  done

  # Move and rename svg files from the "twotone" directory
  for file in twotone/*.svg; do
      new_name="${file/twotone\//}"
      new_name="${new_name/.svg/-twotone.svg}"
      mv "$file" "$new_name"
  done

  # Loop through all SVG files in the current directory
  for svg_file in *.svg; do
    # remove <?xml version="1.0" standalone="no"?>
    sed -i 's/<?xml version="1.0" standalone="no"?>/\n/' "$svg_file"
    # remove <?xml version="1.0" encoding="utf-8"?>
    sed -i 's/<?xml version="1.0" encoding="utf-8"?>/\n/' "$svg_file"
    # remove <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><defs><style type="text/css"></style></defs>
    sed -i 's|<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><defs><style type="text/css"></style></defs>|\n|' "$svg_file"

    # sed -i 's/fill="#E6E6E6"/fill={insideColor}/' "$svg_file"
    # sed -i 's/fill="#D9D9D9"/fill={insideColor}/' "$svg_file"
    # sed -i 's/fill="#333"/fill={strokeColor}/' "$svg_file"

    # Extract the icon name
    icon_name=$(extract_icon_name "$svg_file")

    # Extract the path data from the SVG file
    path_data=$(extract_svg_path "$svg_file")

    # clean_ant_twotone "$svg_file"

    if [ -n "$path_data" ]; then
      # Update icons.js with the new data
      # Check if icons.js file exists
      if [ -f "$file_name" ]; then
        echo "Adding $icon_name ..."
        # Create the new entry to be added
        new_entry=", '$icon_name': { box: 1024, svg: '$path_data' }"
      
        # sed -i ", /};/i ${new_entry}," "$file_name"
        sed -i "s|, \}|${new_entry} \n&|" "$file_name"
      
      else
        echo "Adding first time $icon_name ..."
        # If icons.js does not exist, create a new one with the provided data
        echo "{ '$icon_name': { box: 1024, svg: '$path_data' }, }" > "$file_name"
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
  cp "${script_dir}/templates/IconTwotone.svelte" "${CURRENTDIR}/IconTwotone.svelte"
  # replace replace_size with 24
  target_value="\"24\""
  sed -i "s/replace_size/$target_value/g" Icon.svelte
  sed -i "s/replace_size/$target_value/g" IconTwotone.svelte
  # replace replace_name with svelte-ant-design-icons
  sed -i "s/replace_name/svelte-ant-design-icons/g" Icon.svelte

  # create a index.js
  # Content to write in the index.js file
  content="export { default as Icon } from './Icon.svelte';
export { default as IconTwotone } from './IconTwotone.svelte';
export { default as icons } from './icons.js';"

  # Write the content to index.js
  echo "$content" > index.js
  # endo fo creating the index.js
  
  # cleanup
  # remove all svg files
  find . -type f -name "*.svg" -exec rm {} \;
  rm -rf filled
  rm -rf outlined
  rm -rf twotone

  bannerColor 'Done.' "green" "*"
}
