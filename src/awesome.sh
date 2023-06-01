fn_awesome() {
  ################
  # This script creates a single directory main
  # Move it's contents to Repo lib dir.
  ######################
  GITURL="git@github.com:FortAwesome/Font-Awesome.git"
  DIRNAME='Font-Awesome'
  SVGDIR='svgs'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-awesome-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone Font-Awesome from github
  cd "${CURRENTDIR}" || exit 1
  # if there is the svgs dir, remove it
  if [ -d "${CURRENTDIR}/${DIRNAME}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR}/${DIRNAME}"
  fi

  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  git clone "${GITURL}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # copy svgs dir from the cloned dir
  bannerColor 'Moving svgs dir to the root.' "green" "*"
  if [ -d "${CURRENTDIR}/${SVGDIR}" ]; then
    bannerColor "Removing the previous ${SVGDIR} dir." "blue" "*"
    rm -rf "${CURRENTDIR}/${SVGDIR}"
  fi

  mv "${CURRENTDIR}/${DIRNAME}/${SVGDIR}" "${CURRENTDIR}"

  #########################
  #         Solid         #
  #########################
  bannerColor 'Changing dir to svgs/solid' "blue" "*"
  cd "${CURRENTDIR}/${SVGDIR}/solid" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  # remove <!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->
  sed -i 's/<!--! Font Awesome Free 6.1.1 by @fontawesome - https:\/\/fontawesome.com License - https:\/\/fontawesome.com\/license\/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->/\n/' ./*.*

  # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}/${SVGDIR}"/solid/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in solid dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Solid.svelte"
  }ge' ./*.svg >/dev/null 2>&1

  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in outline dir.' "green" "*"

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"

  #########################
  #         Regular         #
  #########################

  bannerColor 'Changing dir to svgs/regular' "blue" "*"
  cd "${CURRENTDIR}/${SVGDIR}/regular" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  # remove <!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->
  sed -i 's/<!--! Font Awesome Free 6.1.1 by @fontawesome - https:\/\/fontawesome.com License - https:\/\/fontawesome.com\/license\/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->/\n/' ./*.*

  # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}/${SVGDIR}"/regular/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in regular dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Regular.svelte"
  }ge' ./*.svg >/dev/null 2>&1

  # rename file names
  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in regular dir.' "green" "*"

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"

  #########################
  #         Brands         #
  #########################

  bannerColor 'Changing dir to svgs/brands' "blue" "*"
  cd "${CURRENTDIR}/${SVGDIR}/brands" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  # remove <!--! Font Awesome Free 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->
  sed -i 's/<!--! Font Awesome Free 6.1.1 by @fontawesome - https:\/\/fontawesome.com License - https:\/\/fontawesome.com\/license\/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. -->/\n/' ./*.*

  # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}/${SVGDIR}"/brands/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  # modify file names
  bannerColor 'Renaming all files in brands dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . "Brand.svelte"
  }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in solid dir.' "green" "*"

  # Move all files to main dir
  mv ./* "${CURRENTDIR}"

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1


  # Add component doc
  for file in ./*.*; do
    echo -e "\n<!--\n@component\n[Go to Document](https://svelte-awesome-icons.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop role = 'img';\n@prop color = 'currentColor';\n@prop ariaLabel = 'icon name';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
  done

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/${DIRNAME}"
  rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"
}
