fn_flag() {
  GITURL="git@github.com:hampusborgos/country-flags.git"
  REPONAME='country-flags'
  DIRNAME='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-flags"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"
  
  cd "${CURRENTDIR}" || exit
  
  # rename file names 
  rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg  > /dev/null 2>&1
  bannerColor 'Renaming is done.' "green" "*"

  # For each svelte file modify contents of all file
  bannerColor 'Modifying all files.' "blue" "*"

  # add script
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img";<\/script>/' ./*.* && sed -i 's/xmlns/width={size} height={size} {...$$restProps} {role} aria-label="{ariaLabel}"\n on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  for filename in "${CURRENTDIR}"/*; do
    FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\"\; \n&;" "${filename}" >/dev/null 2>&1
  done

  cp "${script_dir}/templates/flags/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

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