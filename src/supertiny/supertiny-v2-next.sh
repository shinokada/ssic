fn_svg_path() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  for filename in "${CURRENTDIR}"/*; do
    # replace role="img" with {role} width={size} height={size} {...restProps}
    sed -i 's/role="img"/\{role\}/' "$filename"

    # Azure doesn't have role="img" so add width={size} height={size} {...restProps}
    # after xmlns="http://www.w3.org/2000/svg"
    sed -i 's/xmlns="http:\/\/www\.w3\.org\/2000\/svg"/xmlns="http:\/\/www\.w3\.org\/2000\/svg" width=\{size\} height=\{size\} class=\{classname\} \{...restProps\}/' "$filename"
    # append script content 
    # destination_file = "${script_dir}/templates/supertiny/next/supertiny-v2.txt"
cat <<EOF > "${filename}"
$(cat "${script_dir}/templates/supertiny/next/supertiny-v2.txt")
$(cat "${filename}")
EOF

    # if there is fill="#fff", insert fill = ctx.fill || "#fff"; 
    if grep -q 'fill="#fff"' "$filename"; then
      
      # insert fill = ctx.fill || "#fff"; before class: classname 
      sed -i 's/class\: classname/ fill = ctx.fill || "#fff", class\: classname/' "$filename"
      # add fill?: string; after class?: string;
      sed -i 's/class?: string;/class?: string; fill?: string;/' "$filename"
      # add fill?: string; after interface CtxType {
      sed -i 's/interface CtxType {/interface CtxType { fill?: string;/' "$filename"

      # replace fill="#fff" with {fill}
      sed -i 's/fill="#fff"/\{fill\}/' "$filename"
    fi
  done
}


fn_add_arialabel() {
  cd "${CURRENTDIR}" || exit 1

  bannerColor "Adding arialabel to all files." "blue" "*"
  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel; \"${FILENAME},\" ;" "${filename}" >/dev/null 2>&1

    new_name=$(echo "${FILENAMEONE^}")
    # Capitalize the letter after -
    new_name=$(echo "$new_name" | sed 's/-./\U&/g')
    # Remove all -
    new_name=$(echo "$new_name" | sed 's/-//g')
    # Remove all spaces
    new_name=$(echo "$new_name" | sed 's/ //g')
    # echo "${new_name}"
    # echo "${CURRENTDIR}/${FILENAMEONE}.svelte" 
    # mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/${new_name}.svelte"
  done
  
  bannerColor 'Added arialabel to all files.' "green" "*"
}

fn_supertiny(){
  GITURL="https://github.com/edent/SuperTinyIcons"
  DIRNAME='images/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-supertiny-next"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  
  bannerColor 'Modifying all files.' "blue" "*"
  fn_svg_path

  bannerColor 'Renaming all files.' "blue" "*"
  
  fn_add_arialabel

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svelte\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  }ge' ./*.svelte >/dev/null 2>&1

  cd "${CURRENTDIR}" || exit 1

  cp "${script_dir}/templates/supertiny/next/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"


  bannerColor 'All done.' "green" "*"
}