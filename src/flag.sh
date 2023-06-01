fn_flag() {
  ###########################################################
  # This script creates flag-icons. 
  ###########################################################
  GITURL="git@github.com:hampusborgos/country-flags.git"
  REPONAME='country-flags'
  SVGDIR='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-flags"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone icons from github
  cd "${CURRENTDIR}" || exit 1
  # if there is icon dir remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${REPONAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"*
  fi

  # clone the repo
  bannerColor 'Cloning the repo.' "yellow" "*"
  npx tiged "${GITURL}/${SVGDIR}" || {
      echo "not able to clone"
      exit 1
  }
  bannerColor 'Cloning is done.' "green" "*"
  
  ######################### 
  #        ICONS      #
  #########################
  bannerColor 'Changing dir to icons dir' "blue" "*"
  cd "${CURRENTDIR}" || exit
  
  #  modify file names
  bannerColor 'Renaming all files in outline dir.' "blue" "*"
  # rename file names 
  rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg  > /dev/null 2>&1
  bannerColor 'Renaming is done.' "green" "*"

  # For each svelte file modify contents of all file
  bannerColor 'Modifying all files.' "blue" "*"

  # Insert 	width={size} height={size} class={$$props.class} before viewBox=
  sed -i '1s/^/<script>export let size="24"; export let role="img";<\/script>/' ./*.* && sed -i 's/xmlns/width={size} height={size} {...$$restProps} {role} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # Add component doc
  for file in ./*.*; do
    echo -e "\n<!--\n@component\n[Go to Document](https://svelte-flags.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop role = 'img';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
  done

  bannerColor 'Modification is done in outline dir.' "green" "*"

  bannerColor 'Creating index.js file.' "blue" "*"
  # list file names to each index.txt
  find . -type f '(' -name '*.svelte' ')' > index1
  
  # removed ./ from each line
  sed 's/^.\///' index1 > index2
  rm index1

  # create a names.txt
  sed 's/.svelte//' index2 > names.txt
  # Add , after each line in names.txt
  sed -i 's/$/,/' names.txt

  # Create import section in index2 files.
  # for outline
  sed "s:\(.*\)\.svelte:import \1 from './&':" index2 > index3
  bannerColor 'Created index.js file with import.' "green" "*"

  #################
  #    INDEX.JS   #
  #################
  
  bannerColor 'Adding export to index.js file.' "blue" "*"
  # Add export{} section
  # 1 insert export { to index.js, 
  # 2 insert icon-names to index.js after export { 
  # 3. append }
  echo 'export {' >> index3 && cat index3 names.txt > index.js && echo '}' >> index.js

  rm names.txt index2 index3

  bannerColor 'Added export to index.js file.' "green" "*"

  bannerColor "Cleaning up ${CURRENTDIR}/${REPONAME}." "blue" "*"
  # clean up
  rm -rf "${CURRENTDIR}/${REPONAME}"
  
  bannerColor 'All done.' "green" "*"
}