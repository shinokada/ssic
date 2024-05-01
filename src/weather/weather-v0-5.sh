fn_modify_svg() {
  # remove <?xml version="1.0" encoding="utf-8"?>
  sed -i 's|<?xml version="1.0" encoding="utf-8"?>||g' ./*.*

  # remove <!-- Generator: Adobe Illustrator 22.0.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
  sed -i 's|<!-- Generator: Adobe Illustrator 22.0.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->||' ./*.* >/dev/null 2>&1

  bannerColor "Inserting script tag to all files." "magenta" "*"
  # inserting script tag at the beginning and insert width={size} height={size} class={$$props.class}
  sed -i '1s/^/<script>import { getContext } from "svelte"; const ctx = getContext("iconCtx") ?? {}; export let size = ctx.size || "24"; export let role = ctx.role || "img"; export let color = ctx.color || "currentColor"; <\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} {...$$restProps} {role} aria-label={ariaLabel} fill={color} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.* >/dev/null 2>&1

  bannerColor "Getting file names." "blue" "*"
  # get textname from filename
  for filename in ./*; do
    # echo "${filename}"
    # translate - to a space
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ') # ./wi cloud up
    FILENAME1=$(basename "${filename}" .svg)             # ./wi-cloud-up
    # remove first 4 characters from ./wi cloud up
    FILENAME="${FILENAME:3}"
    # remove first 4 charcters from ./wi-cloud-up
    FILENAME1="${FILENAME1:3}" # cloud-up
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"${FILENAME}\" &;" "${filename}" >/dev/null 2>&1
    mv "${filename}" "${FILENAME1}.svg"
  done

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
  ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte" }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Modification is done in the dir.' "green" "*"
}

fn_weather() {
  GITURL="git@github.com:erikflowers/weather-icons.git"
  DIRNAME='svg'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/weather/svelte-weather"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

  clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
  
  fn_modify_svg
  
  cp "${script_dir}/templates/weather/Icon.svelte" "${CURRENTDIR}/Icon.svelte"

  bannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}