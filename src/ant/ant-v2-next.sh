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

fn_replace_twotone(){
    if grep -q 'fill="#333"' "${file}"; then
      # remove fill={color}
      sed -i 's/fill={color}/\n/' "${filename}"
      # change export let color="currentColor"; to export let strokeColor="currentColor"
      # export let strokeColor = ctx.color || "#333";
      sed -i 's/export let color = ctx.color || "currentColor";/export let strokeColor = ctx.strokeColor || "#333";/' "${filename}"
      # change fill="#333" to fill={strokeColor}
      sed -i 's/fill="#333"/fill={strokeColor}/' "${file}"
    fi
    if grep -q 'fill="#E6E6E6"' "${file}"; then
      # change fill="#E6E6E6" to fill={insideColor}
      sed -i 's/fill="#E6E6E6"/fill={insideColor}/' "${file}"
    fi
    # Files with #D9D9D9 fill inside
    if grep -q 'fill="#D9D9D9"' "${file}"; then
      # change fill={color} to fill={strokeColor}
      sed -i 's/fill={color}/fill={strokeColor}/' "${file}"
      # change fill="#D9D9D9" to fill={fillInside}
      sed -i 's/fill="#D9D9D9"/fill={insideColor}/' "${file}"
    fi
}

fn_svg_path(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # filled, outlined, twotone
    cd "${SUBSRC}" || exit
    fn_remove

    for file in *; do
      FILENAME=$(basename "${file%.*}")
      # create svelte file like address-book-solid.svelte
      SVETLENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
      if [ ! -f "${SUBDIRNAME}/${file}" ]; then
        cp "${script_dir}/templates/template-v2.txt" "${SVETLENAME}"
      fi

      SVGPATH=$(extract_svg_path "$file")
      # replace replace_svg_path with svg path
      sed -i "s;replace_svg_path;${SVGPATH};" "${SVETLENAME}"
      # get viewBox value
      VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
      sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVETLENAME}"
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
    mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/${new_name}.svelte"
  done
  
  bannerColor 'Modification and renaming is done.' "green" "*"
}

fn_ant() {
  GITURL="https://github.com/ant-design/ant-design-icons"
  DIRNAME='packages/icons-svg/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-ant-design-icons-next"
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
  # cp "${script_dir}/templates/awesome/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  #########################
  #         Filled        #
  #########################
  # bannerColor 'Changing dir to svg/filled' "blue" "*"
  # cd "${CURRENTDIR}/filled" || exit

  # # For each svelte file modify contents of all file by adding
  # bannerColor 'Modifying all files.' "blue" "*"

  # fn_remove

  # fn_scripttag

  # get textname from filename
  # for filename in "${CURRENTDIR}"/filled/*; do
  #   FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
  #   # echo "${FILENAME}"
  #   sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  # done

  #  modify file names
  # bannerColor 'Renaming all files in filled dir.' "blue" "*"

  # rename file names
  # bannerColor 'Renaming is done.' "green" "*"

  # bannerColor 'Modification is done in outline dir.' "green" "*"

  # Move all files to main dir
  # mv ./* "${CURRENTDIR}"
  
  #########################
  #        Outlined       #
  #########################
  # bannerColor 'Changing dir to svg/outlined' "blue" "*"
  # cd "${CURRENTDIR}/outlined" || exit

  # For each svelte file modify contents of all file by adding
  # bannerColor 'Modifying all files.' "blue" "*"

  # fn_remove

  # fn_scripttag

  # get textname from filename
  # for filename in "${CURRENTDIR}"/outlined/*; do
  #   FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
  #   # echo "${FILENAME}"
  #   sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  # done

  #  modify file names
  # bannerColor 'Renaming all files in filled dir.' "blue" "*"

  # rename files with number at the beginning with A
  # rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  #   ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Outlined.svelte"
  # }ge' ./*.svg >/dev/null 2>&1

  # rename file names
  # bannerColor 'Renaming is done.' "green" "*"

  # bannerColor 'Modification is done in outline dir.' "green" "*"

  # Move all files to main dir
  # mv ./* "${CURRENTDIR}"

  #########################
  #         Twotone       #
  #########################
  # bannerColor 'Changing dir to svg/twotone' "blue" "*"
  # cd "${CURRENTDIR}/twotone" || exit

  # For each svelte file modify contents of all file by adding
  # bannerColor 'Modifying all files.' "blue" "*"

  # fn_remove

  # fn_scripttag

  # change fill
  # for filename in "${CURRENTDIR}"/twotone/*; do
  #   if grep -q 'fill="#333"' "${filename}"; then
  #     # remove fill={color}
  #     sed -i 's/fill={color}/\n/' "${filename}"
  #     # change export let color="currentColor"; to export let strokeColor="currentColor"
  #     # export let strokeColor = ctx.color || "#333";
  #     sed -i 's/export let color = ctx.color || "currentColor";/export let strokeColor = ctx.strokeColor || "#333";/' "${filename}"
  #     # change fill="#333" to fill={strokeColor}
  #     sed -i 's/fill="#333"/fill={strokeColor}/' "${filename}"
  #   fi
  #   if grep -q 'fill="#E6E6E6"' "${filename}"; then
  #     # insert export let insideColor="#E6E6E6" to script tag
  #     # export let insideColor = ctx.insideColor || "#E6E6E6";
  #     # use ; instead of /
  #     sed -i 's;</script>;export let insideColor = ctx.insideColor || "#E6E6E6"\; &;' "${filename}"
  #     # change fill="#E6E6E6" to fill={insideColor}
  #     sed -i 's/fill="#E6E6E6"/fill={insideColor}/' "${filename}"
  #   fi
  #   # Files with #D9D9D9 fill inside
  #   if grep -q 'fill="#D9D9D9"' "${filename}"; then
  #     # change export let color="currentColor"; to export let strokeColor="currentColor"
  #     # export let color = ctx.color || "currentColor"; to
  #     # export let strokeColor = ctx.strokeColor || "currentColor";
  #     sed -i 's/export let color = ctx.color || "currentColor";/export let strokeColor = ctx.strokeColor || "currentColor";/' "${filename}"
  #     # insert export let insideColor="#D9D9D9" to script tag
  #     # export let insideColor = ctx.insideColor || "#D9D9D9" 
  #     # use ; instead of /
  #     sed -i 's;</script>;export let insideColor = ctx.insideColor || "#D9D9D9"\; &;' "${filename}"
  #     # change fill={color} to fill={strokeColor}
  #     sed -i 's/fill={color}/fill={strokeColor}/' "${filename}"
  #     # change fill="#D9D9D9" to fill={fillInside}
  #     sed -i 's/fill="#D9D9D9"/fill={insideColor}/' "${filename}"
  #   fi
  # done

  # # get textname from filename
  # for filename in "${CURRENTDIR}"/twotone/*; do
  #   FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
  #   # echo "${FILENAME}"
  #   sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  # done

  # #  modify file names
  # bannerColor 'Renaming all files in twotone dir.' "blue" "*"

  # # rename files with number at the beginning with A
  # rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  #   ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Twotone.svelte"
  # }ge' ./*.svg >/dev/null 2>&1

  # # rename file names
  # bannerColor 'Renaming is done.' "green" "*"

  # bannerColor 'Modification is done in outline dir.' "green" "*"

  # # Move all files to main dir
  # mv ./* "${CURRENTDIR}"
  
  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  # cd "${CURRENTDIR}" || exit 1

  # bannerColor 'Creating index.js file.' "blue" "*"

  # find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  # print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  # }' >index.js

  # bannerColor 'Added export to index.js file.' "green" "*"

  # # clean up
  # rm -rf "${CURRENTDIR}/filled"
  # rm -rf "${CURRENTDIR}/outlined"
  # rm -rf "${CURRENTDIR}/twotone"
  
  # if [ -d "${CURRENTDIR}/packages" ]; then
  #   bannerColor "Removing the previous package dir." "blue" "*"
  #   rm -rf "${CURRENTDIR}/packages"
  # fi

  # bannerColor 'All done.' "green" "*"
}