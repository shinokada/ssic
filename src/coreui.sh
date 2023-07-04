fn_modify_svg() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  # there are brand, flag, and free directories
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}")
    cd "${SUBSRC}" || exit

    for filename in *; do

      sed -i '1s/^/<script>\nexport let color = "currentColor"\nexport let role="img";\n<\/script>\n/' "$filename"

      if [ "$SUBDIRNAME" = "brand" ]; then
        # if SUBDIRNAME is brand
        # width="32" height="32" viewBox="0 0 32 32"
        # replace to width="{size}" height="{size}" and add export let size = "32"; to script
        sed -i 's/width="32"/width="{size}"/' "$filename"
        sed -i 's/height="32"/height="{size}"/' "$filename"
        sed -i 's|</script>|export let size = "32"; &|' "${filename}"

        # Add component doc
        echo -e "\n<!--\n@component\n[Go to Document](https://shinokada.github.io/svelte-coreui-icons/)\n## Props\n@prop role = 'img';\n@prop size = '32';\n@prop color = 'currentColor'\n@prop ariaLabel='file name'\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$filename"
      fi

      if [ "$SUBDIRNAME" = "flag" ]; then
        # if SUBDIRNAME is flag
        # width="300" height="210" viewBox="0 0 300 210"
        # to {width} or {height} and add export let width; export let height;
        sed -i 's/\(width=\)"[0-9]*"/\1"{width}"/' "${filename}"
        sed -i 's/\(height=\)"[0-9]*"/\1"{height}"/' "${filename}"
        sed -i "s/<\/script>/export let width; export let height; &/" "${filename}"
        # Add component doc
        echo -e "\n<!--\n@component\n[Go to Document](https://shinokada.github.io/svelte-coreui-icons/)\n## Props\n@prop role = 'img';\n@prop width || height;\n@prop ariaLabel='file name'\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$filename"
      fi

      if [ "$SUBDIRNAME" = "free" ]; then
        # if SUBDIRNAME is free
        # viewBox="0 0 512 512"
        # add width="{size}" height="{size}" and export let size = "32"; to script
        sed -i 's/viewBox=/width="{size}"\nheight="{size}" &/' "$filename"
        sed -i 's/<\/script>/export let size = "32"; &/' "${filename}"
        # replace fill="var(--ci-primary-color, currentColor)" with fill="var(--ci-primary-color, {color})"
        sed -i 's/fill="var(--ci-primary-color, currentColor)"/fill="var(--ci-primary-color, {color})"/g' "$filename"
        # remove class="ci-primary"
        sed -i 's/class="ci-primary"//g' "$filename"
        # Add component doc
        echo -e "\n<!--\n@component\n[Go to Document](https://shinokada.github.io/svelte-coreui-icons/)\n## Props\n@prop role = 'img';\n@prop size = '32';\n@prop color = 'currentColor'\n@prop ariaLabel='file name'\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$filename"
      fi
      
      # aria-label
      FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
      # echo "${FILENAME}"
      # sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
      
      sed -i 's/viewBox=/{role}\n{...$$restProps}\naria-label="{ariaLabel}"\nfill="{color}"\non:click\non:keydown\non:keyup\non:focus\non:blur\non:mouseenter\non:mouseleave\non:mouseover\non:mouseout\n &/' "$filename"
      
      FILENAMEONE=$(basename "${filename}" .svg)
      FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
      sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" \n&;" "${filename}" >/dev/null 2>&1

      # Capitalize the first letter
      new_name=$(echo "${FILENAMEONE^}")
      # Capitalize the letter after -
      new_name=$(echo "$new_name" | sed 's/-./\U&/g')
      # Remove all -
      new_name=$(echo "$new_name" | sed 's/-//g')
      # Change the extension from svg to svelte
      # new_name=$(echo "$new_name" | sed 's/svg$/svelte/g')
      mv "${SUBSRC}/${FILENAMEONE}.svg" "${CURRENTDIR}/${new_name}.svelte"
    done
  done
  
  bannerColor 'Modification is done in the dir.' "green" "*"
}

# fn_scripttag(){
#   # Insert script tag at the beginning and insert width={size} height={size} class={$$props.class}
#   sed -i '1s/^/<script>\nexport let size="24";\nexport let role="img";\nexport let color="currentColor";\n<\/script>/' ./*.* && sed -i 's/viewBox=/{...$$restProps} {role} fill={color} class={$$props.class} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*
# }

fn_coreui(){
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/coreui/coreui-icons"
  DIRNAME='svg'
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-coreui-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  # clone from github
  # if there is the svg files, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${DIRNAME}" "${CURRENTDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # fn_scripttag
  fn_modify_svg 

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js
  rm -rf "${CURRENTDIR}/brand" "${CURRENTDIR}/flag" "${CURRENTDIR}/free"
  bannerColor 'Added export to index.js file.' "green" "*"
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}