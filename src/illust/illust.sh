# Function to generate aria-label from filename
generate_aria_label() {
    local filename="$1"
    # Remove file extension
    filename=$(basename "$filename" .svg)
    
    # Replace - and _ with spaces, then capitalize first letter of each word
    echo "$filename" | sed -E 's/[-_]/ /g' | awk '{
        for(i=1;i<=NF;i++){ 
            $i=toupper(substr($i,1,1)) substr($i,2) 
        }
        print
    }'
}

fn_create_svelte_file(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # dark or light
    cd "${SUBSRC}" || exit

    # Function to extract unique hex colors from an SVG
    extract_unique_colors() {
        local svg_file="$1"
        # Use grep to find hex color values, sort, and get unique values
        grep -oE '#[0-9A-Fa-f]{6}' "$svg_file" | sort -u
    }

    for svg_file in *; do
      [ -e "$svg_file" ] || continue

      # Get the filename without path and extension
      filename=$(basename "$svg_file" .svg)

      # Generate aria-label
      aria_label=$(generate_aria_label "$svg_file")

      # Extract unique colors
      mapfile -t unique_colors < <(extract_unique_colors "$svg_file")

      # Create the Svelte component file
      output_file="${CURRENTDIR}/${filename}.svelte"

      # Create a temporary file for sed replacements
      temp_svg=$(mktemp)
      cp "$svg_file" "$temp_svg"

      # Start creating the Svelte component
      {
        # Script tag with interface and props
        echo "<script lang=\"ts\">"
        echo "import type { TitleType, DescType } from './types';"
        echo "import type { SVGAttributes } from 'svelte/elements';"
        echo "  interface Props extends SVGAttributes<SVGElement> {"
        
        # Add color props
        color_mapping=()
        color_props=()
        default_values=()
        for i in "${!unique_colors[@]}"; do
            prop_name="color$((i+1))"
            color=${unique_colors[i]}
            echo "    ${prop_name}?: string;"
            color_props+=("${prop_name}")
            default_values+=("${prop_name}=\"${color}\"")
            
            # Escape the color for sed replacement (replace '/' with '\/')
            escaped_color=$(echo "$color" | sed 's/[\/&]/\\&/g')
            color_mapping+=("-e s/fill=\"${escaped_color}\"/fill={${prop_name}}/g")
        done
        
        # Add ariaLabel to interface
        echo "    ariaLabel?: string;"
        echo "class?: string;"
        echo "height?: string;"
        echo "title?: TitleType;"
        echo "desc?: DescType;"
          
        echo "  };"
        echo ""
        
        # Props definition with default values in a single line
        printf "  let { %s, ariaLabel=\"%s\", class: className =\"shrink-0 w-auto max-w-[16rem] text-gray-800 dark:text-white\", height=\"100\", title, desc, ...restProps }: Props = \$props()\n" "$(IFS=, ; echo "${default_values[*]}")" "$aria_label"
        echo "let ariaDescribedby = \`\${title?.id || ''} \${desc?.id || ''}\`;"
        echo "const hasDescription = \$derived(!!(title?.id || desc?.id));"
        echo "</script>"
        echo ""
        
        # Process SVG content
        # 1. Add restProps and aria-label to SVG tag
        # 2. Replace hex colors with prop references
        # 3. Insert title and desc conditionals right after SVG tag
        sed -E \
            -e '/<svg/s/class="[^"]*"/class={className}/' \
            -e '/<svg/s/>/ style={`height: ${height}`} aria-label={ariaLabel} aria-describedby={hasDescription ? ariaDescribedby : undefined} {...restProps}>/' \
            -e '/<svg[^>]*>/a\    {#if title?.id && title.title}\n        <title id={title.id}>{title.title}</title>\n    {/if}\n    {#if desc?.id && desc.desc}\n        <desc id={desc.id}>{desc.desc}</desc>\n    {/if}' \
            "${color_mapping[@]}" \
            "$temp_svg"
      } > "$output_file"

      # Clean up temporary file
      rm "$temp_svg"
    done
  done
}


fn_illust() {
    GITURL="git@github.com:themesberg/flowbite-illustrations.git"
    DIRNAME='src/3d'
    LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/flowbite-svelte-illustrations"
    SVELTE_LIB_DIR='src/lib'
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"

    clone_repo "${CURRENTDIR}" "$DIRNAME" "$GITURL"
    
    bannerColor 'Running fn_create_svelte_file ...' "blue" "*"
    fn_create_svelte_file

    bannerColor 'Removing all .svg files ...' "blue" "*"
    find "${CURRENTDIR}" -maxdepth 1 -type d -not -path "${CURRENTDIR}" -exec rm -rf {} +

    bannerColor 'Running fn_rename ...' "blue" "*"
    # add_A_if_starts_with_number()
    fn_rename

    bannerColor 'Copying types.ts ...' "blue" "*"
    cp "${script_dir}/src/illust/types.txt" "${CURRENTDIR}/types.ts"

    bannerColor 'Creating index.js file.' "blue" "*"
    fn_create_index_js
    
    bannerColor 'All done.' "green" "*"
}