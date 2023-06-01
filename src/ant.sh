fn_remove(){
  # remove <?xml version="1.0" standalone="no"?>
  bannerColor 'Removing <?xml version="1.0" standalone="no"?> from all files.' "blue" "*"
  sed -i 's/<?xml version="1.0" standalone="no"?>/\n/' ./*.*
  # remove <?xml version="1.0" encoding="utf-8"?>
  bannerColor 'Removing <?xml version="1.0" encoding="utf-8"?> from all files.' "blue" "*"
  sed -i 's/<?xml version="1.0" encoding="utf-8"?>/\n/' ./*.*
  # remove <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
  bannerColor 'Removing DOCTYPE all files.' "blue" "*"
  sed -i 's;<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">;\n;' ./*.*
  # remove class="icon"
  sed -i 's/class="icon"/\n/' ./*.*
  # remove width="200" height="200"
  sed -i 's/width="200" height="200"/\n/' ./*.*
  # remove <?xml version="1.0" encoding="UTF-8"?>
  sed -i 's/<?xml version="1.0" encoding="UTF-8"?>/\n/' ./*.*
}

fn_scripttag(){
  # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role="img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*
}

fn_ant() {
  ################
  # This script creates a single directory main
  # Move it's contents to Repo lib dir.
  ######################
  GITURL="https://github.com/ant-design/ant-design-icons"
  DIRNAME='ant-design-icons'
  SVGDIR='packages/icons-svg/svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-ant-design-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # if there is lib dir, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${CURRENTDIR} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${SVGDIR}" svg >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  #########################
  #         Filled        #
  #########################
  bannerColor 'Changing dir to svg/filled' "blue" "*"
  cd "${CURRENTDIR}/svg/filled" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  fn_remove

  fn_scripttag

  # get textname from filename
  for filename in "${CURRENTDIR}"/svg/filled/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in filled dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Filled.svelte"
  }ge' ./*.svg >/dev/null 2>&1

  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in outline dir.' "green" "*"

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"
  
  #########################
  #        Outlined       #
  #########################
  bannerColor 'Changing dir to svg/outlined' "blue" "*"
  cd "${CURRENTDIR}/svg/outlined" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  fn_remove

  fn_scripttag

  # get textname from filename
  for filename in "${CURRENTDIR}"/svg/outlined/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in filled dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Outlined.svelte"
  }ge' ./*.svg >/dev/null 2>&1

  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in outline dir.' "green" "*"

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"

  #########################
  #         Twotone       #
  #########################
  bannerColor 'Changing dir to svg/twotone' "blue" "*"
  cd "${CURRENTDIR}/svg/twotone" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  fn_remove

  fn_scripttag

  # change fill
  for filename in "${CURRENTDIR}"/svg/twotone/*; do
    if grep -q 'fill="#333"' "${filename}"; then
      # remove fill={color}
      sed -i 's/fill={color}/\n/' "${filename}"
      # change export let color="currentColor"; to export let strokeColor="currentColor"
      sed -i 's/export let color="currentColor";/export let strokeColor="#333";/' "${filename}"
      # change fill="#333" to fill={strokeColor}
      sed -i 's/fill="#333"/fill={strokeColor}/' "${filename}"
    fi
    if grep -q 'fill="#E6E6E6"' "${filename}"; then
      # insert export let insideColor="#E6E6E6" to script tag
      # use ; instead of /
      sed -i 's;</script>;export let insideColor="#E6E6E6"\; &;' "${filename}"
      # change fill="#E6E6E6" to fill={insideColor}
      sed -i 's/fill="#E6E6E6"/fill={insideColor}/' "${filename}"
    fi
    # Files with #D9D9D9 fill inside
    if grep -q 'fill="#D9D9D9"' "${filename}"; then
      # change export let color="currentColor"; to export let strokeColor="currentColor"
      sed -i 's/export let color="currentColor";/export let strokeColor="currentColor";/' "${filename}"
      # insert export let insideColor="#D9D9D9" to script tag
      # use ; instead of /
      sed -i 's;</script>;export let insideColor="#D9D9D9"\; &;' "${filename}"
      # change fill={color} to fill={strokeColor}
      sed -i 's/fill={color}/fill={strokeColor}/' "${filename}"
      # change fill="#D9D9D9" to fill={fillInside}
      sed -i 's/fill="#D9D9D9"/fill={insideColor}/' "${filename}"
    fi
  done

  # get textname from filename
  for filename in "${CURRENTDIR}"/svg/twotone/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in twotone dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Twotone.svelte"
  }ge' ./*.svg >/dev/null 2>&1

  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in outline dir.' "green" "*"

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"
  
  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  # append component docs 
  for file in ./*.*; do
    echo -e "\n<!--\n@component\n[Go to Document](https://svelte-ant-design-icons.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop role = 'img';\n@prop color = 'currentColor';\n@prop ariaLabel = 'icon name';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
  done




  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/svg"
    # move this to the end
  if [ -d "${CURRENTDIR}/packages" ]; then
    bannerColor "Removing the previous package dir." "blue" "*"
    rm -rf "${CURRENTDIR}/packages"
  fi

  bannerColor 'All done.' "green" "*"
}
