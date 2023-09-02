# Tried creating js file, but it won't work when you build because they won't compile to dist dir.

fn_hero2() {
  # for svelte-heros-v2 trial
  GITURL="git@github.com:tailwindlabs/heroicons.git"
  DIRNAME='src'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-heros-v2"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  file_name="icons.js"
  repo_name="svelte-heros-v2"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # Move and rename svg files from the "outline" directory
  for file in 24/outline/*.svg; do
    # Remove the '24/outline/' prefix from the file path
    new_name="${file/24\/outline\//}"

    # Remove the '.svg' extension
    new_name="${new_name%.svg}"

    # Convert dashes to camel case and add 'Outline'
    new_name="${new_name//-/}"
    new_name="${new_name^}Outline.svg"

    # Rename the original SVG file to the new name
    mv "$file" "$new_name"
  done

  # Loop through each SVG file in the '24/solid/' directory
  for file in 24/solid/*.svg; do
    
    # Remove the '24/solid/' prefix from the file path
    new_name="${file/24\/solid\//}"

    # Remove the '.svg' extension
    new_name="${new_name%.svg}"

    # Convert dashes to camel case and add 'Solid'
    new_name="${new_name//-/}"
    new_name="${new_name^}Solid.svg"

    # Rename the original SVG file to the new name
    mv "$file" "$new_name"
  done

  # Loop through each SVG file in the '20/solid/' directory
  for file in 20/solid/*.svg; do

    # Remove the '20/solid/' prefix from the file path
    new_name="${file/20\/solid\//}"

    # Remove the '.svg' extension
    new_name="${new_name%.svg}"

    # Add '-mini' suffix before the '.svg' extension
    new_name="${new_name//-/}"
    new_name="${new_name^}Mini.svg"

    # Rename the original SVG file to the new name
    mv "$file" "$new_name"
  done

  # Loop through all SVG files in the current directory
  for svg_file in *.svg; do
      # Remove the 'fill' attribute and its value from the SVG file
      sed -i 's/fill="[^"]*"//g' "$svg_file"

      # Remove the 'stroke' attribute and its value from the SVG file
      sed -i 's/stroke="[^"]*"//g' "$svg_file"

      # Extract the icon name and remove the prefix/suffix
      icon_name=$(extract_icon_name "$svg_file")

      # Extract the path data from the SVG file
      path_data=$(extract_svg_path "$svg_file")

      # Escape double quotes in $path_data
      escaped_path_data=$(echo "$path_data" | sed 's/"/\\"/g')

      if [ -n "$path_data" ]; then
        echo "Adding $icon_name ..."
        # Check if the SVG file is not named "Mini.svg"
        if [[ "$svg_file" != *"Mini.svg" ]]; then
          # Create the new entry with box size 24
          new_entry="const $icon_name = { name: '$icon_name', box: 24, svg: '$escaped_path_data' };"
        else
          # Create the new entry with box size 20 for Mini icons
          new_entry="const $icon_name = { name: '$icon_name', box: 20, svg: '$escaped_path_data' };"
        fi

        # Append the export line with a new line before it
        new_entry_with_export="$new_entry\\nexport default $icon_name;"

        echo -e "$new_entry_with_export" >> "$icon_name.js"
        echo "Successfully created \"${icon_name}.js\""
      else
        echo "SVG content in \"$svg_file\" is invalid or does not contain any path data."
      fi
  done

  # copy 
  # since Variable imports cannot import their own directory, place imports in a separate directory we save the helper.js in utils
  mkdir "${CURRENTDIR}/utils"
  cp "${script_dir}/templates/hero2-trial/helper.js" "${CURRENTDIR}/utils/helper.js"
  cp "${script_dir}/templates/hero2-trial/IconSolid.svelte" "${CURRENTDIR}/IconSolid.svelte"
  cp "${script_dir}/templates/hero2-trial/IconSolid.svelte" "${CURRENTDIR}/IconMini.svelte"
  cp "${script_dir}/templates/hero2-trial/IconOutline.svelte" "${CURRENTDIR}/IconOutline.svelte"
  
  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' -o -name '*.js' ! -name 'index.js' ! -name 'helper.js' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  
  # cleanup
  # remove all svg and json files
  find . -type f \( -name "*.svg" \) -exec rm {} \;
  rm -rf "20"
  rm -rf "24"

  bannerColor 'Done.' "green" "*"
}
