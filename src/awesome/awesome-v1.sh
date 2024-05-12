fn_awesome() {
  GITURL="git@github.com:FortAwesome/Font-Awesome.git"
  DIRNAME='svgs'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-awesome-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  TEMPLATE="${script_dir}/templates/template-v1.txt"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # rename brands directory to brand
  mv brands brand
  # remove font awesome comments
  bannerColor 'Removing unnecessary font awesome comments.' "blue" "*"
  find . -type f -exec sed -i '/<!--! Font Awesome Free/,/-->/ s/<!--! Font Awesome Free.*-->//' {} \;

  bannerColor 'Modifying all files.' "blue" "*"
  fn_svg_path_with_one_subdir

  # Remove svg files from regular, brands and solid directories
  bannerColor 'Removing svg files from regular, brands and solid directories.' "blue" "*"
  rm -rf "${CURRENTDIR}/brand" "${CURRENTDIR}/regular" "${CURRENTDIR}/solid"

  bannerColor 'Adding arialabel to all files.' "blue" "*"
  fn_add_arialabel

  #  modify file names
  bannerColor 'Renaming all files.' "blue" "*"

  fn_rename

  cp "${script_dir}/templates/awesome/Icon.svelte" "${CURRENTDIR}/Icon.svelte"


   # rename files with number at the beginning with A
  bannerColor 'Rename files with number at the beginning with A.' "blue" "*"
  for filename in *; do
    # Check if the filename starts with a digit (0-9)
    if [[ $filename =~ ^[0-9]+ ]]; then
      # Create a new filename with "A" prepended
      new_filename="A$filename"
      
      # Rename the file using mv command
      mv "$filename" "$new_filename"
    fi
  done

  bannerColor 'Creating index.js file.' "blue" "*"

  fn_create_index_js

  bannerColor 'All done.' "green" "*"
}