fn_modify_svg() {
  bannerColor "Changing dir to ${CURRENTDIR}" "blue" "*"
  cd "${CURRENTDIR}" || exit
  # For each svelte file modify contents of all file by
  # pwd
  bannerColor "Modifying all files." "cyan" "*"

  sed -i 's/width="16" height="16"/width="{size}" height="{size}"/' ./*.* >/dev/null 2>&1

  # remove fill="currentColor"
  sed -i 's/fill="currentColor"//' ./*.* >/dev/null 2>&1

  # remove class="bi bi-alt", class="bi bi-align-center", class="bi bi-align-end", etc
  sed 's/class="[^"]*"/class="{$$props.class}"/g' ./*.* >/dev/null 2>&1

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "16"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; <\/script>/' ./*.* && sed -i 's/viewBox=/fill={color} {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.* >/dev/null 2>&1

  bannerColor "Getting file names." "blue" "*"
  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
  done

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_bootstrap() {
  GITURL="https://github.com/twbs/icons"
  DIRNAME='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-bootstrap-svg-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "$CURRENTDIR" "$DIRNAME" "$GITURL"

  # call fn_modify_svg to modify svg files and rename them and move file to lib dir
  fn_modify_svg

  cp "${script_dir}/templates/bootstrap/Icon.svelte" "${CURRENTDIR}/Icon.svelte"
  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"
  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}