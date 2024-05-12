fn_remove(){
  # remove <?xml version="1.0" standalone="no"?>
  sed -i 's/<?xml version="1.0" standalone="no"?>/\n/' ./*.*
  # remove <?xml version="1.0" encoding="utf-8"?>
  sed -i 's/<?xml version="1.0" encoding="utf-8"?>/\n/' ./*.*
  # remove <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
  sed -i 's;<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">;\n;' ./*.*
  # remove class="icon"
  sed -i 's/class="icon"/\n/' ./*.*
  # remove width="200" height="200"
  sed -i 's/width="200" height="200"/\n/' ./*.*
  # remove <?xml version="1.0" encoding="UTF-8"?>
  sed -i 's/<?xml version="1.0" encoding="UTF-8"?>/\n/' ./*.*
  sed -i 's/fill="currentColor"//g' ./*.*
  # remove p-id="xxxxx"
  sed -i 's/p-id="[0-9]*"//g' ./*.*
}

fn_svg_path(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # filled, outlined, twotone
    cd "${SUBSRC}" || exit
    fn_remove

    for file in *; do
      FILENAME=$(basename "${file%.*}")
      # create svelte file like address-book-solid.svelte
      SVELTENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
      if [ ! -f "${SUBDIRNAME}/${file}" ]; then
        cp "${script_dir}/templates/template-v2.txt" "${SVELTENAME}"
      fi

      SVGPATH=$(extract_svg_path "$file")
      # replace replace_svg_path with svg path
      sed -i "s;replace_svg_path;${SVGPATH};" "${SVELTENAME}"
      # get viewBox value
      VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
      sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVELTENAME}"

      # replace <defs>    <style\/>    </defs>
      # sed -i 's|<style/>|<style></style>|' "${SVELTENAME}"
      sed -i 's|<defs> *<style/> *</defs>||' "${SVELTENAME}"
      # remove <defs><style type="text/css"></style></defs>
      sed -i 's|<defs><style type="text/css"></style></defs>||' "${SVELTENAME}"
      # if SVELTENAME doesn't contain Twotone, remove fill="#333"
      if [[ ! "$SVELTENAME" =~ "Twotone" ]]; then
        # Replace only if "Twotone" (case-sensitive) is not found
        sed -i 's/fill="#333"//' "${SVELTENAME}"
      fi
    done
  done
}

fn_modify_filenames() {
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1

    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Remove all spaces
    new_name=$(echo "$new_name" | sed 's/ //g')
    # echo "${new_name}"
    # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
    mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/${new_name}.svelte"
  done
  
  bannerColor 'Modification and renaming is done.' "green" "*"
}

fn_ant() {
  GITURL="https://github.com/ant-design/ant-design-icons"
  DIRNAME='packages/icons-svg/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/Runes/svelte-ant-design-icons-next-runes-webkit"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  fn_svg_path

  # clean up
  rm -rf "${CURRENTDIR}/filled" "${CURRENTDIR}/outlined" "${CURRENTDIR}/twotone"

#  modify file names
  bannerColor 'Renaming all files.' "blue" "*"
  
  fn_modify_filenames

  cd "${CURRENTDIR}" || exit 1

  cp "${script_dir}/templates/TemplateIconv2.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  bannerColor 'All done.' "green" "*"
  
}