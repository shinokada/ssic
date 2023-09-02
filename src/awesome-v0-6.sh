fn_awesome() {
  GITURL="git@github.com:FortAwesome/Font-Awesome.git"
  DIRNAME='svgs'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-awesome-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  
  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  cp "${script_dir}/templates/awesome/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  
  # remove font awesome comments
  find . -type f -exec sed -i '/<!--! Font Awesome Free/,/-->/ s/<!--! Font Awesome Free.*-->//' {} \;


  #########################
  #         Solid         #
  #########################
  bannerColor 'Changing dir to svgs/solid' "blue" "*"
  cd "${CURRENTDIR}/solid" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/solid/*; do
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
  cd "${CURRENTDIR}/regular" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/regular/*; do
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
  cd "${CURRENTDIR}/brands" || exit

  # For each svelte file modify contents of all file by adding
  bannerColor 'Modifying all files.' "blue" "*"

  # Insert script tag at the beginning for solid and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>export let size="24"; export let role = "img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} width={size} height={size} fill={color} class={$$props.class} aria-label={ariaLabel} &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/brands/*; do
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

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/solid" "${CURRENTDIR}/brands" "${CURRENTDIR}/regular"

  bannerColor 'All done.' "green" "*"
}