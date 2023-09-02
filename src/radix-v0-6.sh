fn_modify_svg() {
  # removing width="16" height="16"
  sed -i 's/width="[^"]*"/width="{size}"/' ./*.* >/dev/null 2>&1
  sed -i 's/height="[^"]*"/height="{size}"/' ./*.* >/dev/null 2>&1

  # change fill="none" to fill={color}
  sed -i 's/fill="none"/fill={color}/' ./*.* >/dev/null 2>&1

  # remove fill="currentColor"
  sed -i 's/fill="currentColor"//' ./*.* >/dev/null 2>&1

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script lang="ts">export let size="15"; export let role="img"; export let color="currentColor";<\/script>/' ./*.* && sed -i 's/viewBox=/ {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  bannerColor "Getting file names." "blue" "*"
  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1
  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_radix() {
  GITURL="git@github.com:radix-ui/icons.git"
  DIRNAME='packages/radix-icons/icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-radix"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"

  fn_modify_svg 

  cp "${script_dir}/templates/radix/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}