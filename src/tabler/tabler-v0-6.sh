fn_modify_svg() {
  # remove <desc>Download more icon variants from https://tabler-icons.io/i/ad</desc>
  sed -i 's|<desc>Download more icon variants from https://tabler-icons.io/i/activity</desc>||' ./*.* >/dev/null 2>&1

  # replace stroke="currentColor" with stroke={color}
  sed -i 's/stroke="currentColor"/stroke={color}/' ./*.* >/dev/null 2>&1

  # replace stroke-width="2" with stroke-width={strokeWidth}
  sed -i 's/stroke-width="2"/stroke-width={strokeWidth}/' ./*.* >/dev/null 2>&1

  # removing width="24" height="24"
  sed -i 's/width="24" height="24"/width={size} height={size}/' ./*.* >/dev/null 2>&1

  # remove class="bi bi-alt", class="bi bi-align-center", class="bi bi-align-end", etc
  sed -i 's/class="[^"]*"/class={$$props.class}/g' ./*.* >/dev/null 2>&1

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "16"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; export let strokeWidth = ctx.strokeWidth || "2"; <\/script>/' ./*.* && sed -i 's/viewBox=/ {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.* >/dev/null 2>&1

  # bannerColor "Getting file names." "blue" "*"
  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
  done

  #  modify file names
  bannerColor "Renaming all files." "blue" "*"
  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_tabler() {
  GITURL="https://github.com/tabler/tabler-icons"
  DIRNAME='icons'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/tabler/svelte-tabler"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
 
  fn_modify_svg

  cp "${script_dir}/templates/tabler/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}