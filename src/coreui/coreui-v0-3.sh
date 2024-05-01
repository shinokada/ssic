fn_modify_svg() {

  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit

  # there are brand, flag, and free directories
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}")
    cd "${SUBSRC}" || exit

    for filename in *; do

      if [ "$SUBDIRNAME" = "brand" ]; then
        sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "32"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor";<\/script>/' "$filename"
        sed -i 's/width="32"/width="{size}"/' "$filename"
        sed -i 's/height="32"/height="{size}"/' "$filename"
        sed -i 's/viewBox=/{role}\n{...$$restProps}\naria-label="{ariaLabel}"\nfill="{color}"\non:click\non:keydown\non:keyup\non:focus\non:blur\non:mouseenter\non:mouseleave\non:mouseover\non:mouseout\n &/' "$filename"
      fi

      if [ "$SUBDIRNAME" = "flag" ]; then
        # this returns box_width and box_height
        extract_box_dimensions "$filename"
        sed -i "1s/^/<script>import { getContext } from 'svelte'; const ctx = getContext('iconCtx') ?? {}; export let width = ctx.width || $box_width; export let height = ctx.height || $box_height; export let role = ctx.role || 'img';<\/script>/" "$filename"
        sed -i 's/\(width=\)"[0-9]*"/\1"{width}"/' "${filename}"
        sed -i 's/\(height=\)"[0-9]*"/\1"{height}"/' "${filename}"
        sed -i 's/viewBox=/{role}\n{...$$restProps}\naria-label="{ariaLabel}"\non:click\non:keydown\non:keyup\non:focus\non:blur\non:mouseenter\non:mouseleave\non:mouseover\non:mouseout\n &/' "$filename"
      fi

      if [ "$SUBDIRNAME" = "free" ]; then
        sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "32"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor";<\/script>/' "$filename"
        sed -i 's/viewBox=/width="{size}"\nheight="{size}" &/' "$filename"
        # replace fill="var(--ci-primary-color, currentColor)" with fill="var(--ci-primary-color, {color})"
        sed -i 's/fill="var(--ci-primary-color, currentColor)"/fill="var(--ci-primary-color, {color})"/g' "$filename"
        # remove class="ci-primary"
        sed -i 's/class="ci-primary"//g' "$filename"
        sed -i 's/viewBox=/{role}\n{...$$restProps}\naria-label="{ariaLabel}"\nfill="{color}"\non:click\non:keydown\non:keyup\non:focus\non:blur\non:mouseenter\non:mouseleave\non:mouseover\non:mouseout\n &/' "$filename"
      fi
      
      FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
      
      
      
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
      mv "${SUBSRC}/${FILENAMEONE}.svg" "${CURRENTDIR}/${new_name}.svelte"
    done
  done
  
  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_coreui(){
  GITURL="https://github.com/coreui/coreui-icons"
  DIRNAME='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/coreui/svelte-coreui-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # fn_scripttag
  fn_modify_svg 

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1
  cp "${script_dir}/templates/coreui/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js
  rm -rf "${CURRENTDIR}/brand" "${CURRENTDIR}/flag" "${CURRENTDIR}/free"
  bannerColor 'Added export to index.js file.' "green" "*"
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}