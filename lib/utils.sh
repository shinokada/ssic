add_A_if_starts_with_number() {
  for file in *; do
    filename=$(basename -- "$file")
    if [[ $filename =~ ^[0-9] ]]; then
      mv "$file" "A$file"
      echo "Added 'A' to the beginning of the filename."
    else
      echo "Filename does not start with a number."
    fi
  done
}

fn_create_index_js() {
  cd "${CURRENTDIR}" || exit 1

  newBannerColor 'Creating index.js file.' "blue" "*"

  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
  print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  # find . -type f -name '*.svelte' | sort | awk -F'/' '{
  #   extension = $NF;
  #   filename = substr($NF, 0, length($NF)-length(extension));
  #   print "export { default as " filename " } from \047" $0 "\047;"
  # }' >index.js

  newBannerColor 'Added export to index.js file.' "green" "*"
}

fn_replace_viewbox() {
  # get viewBox value
  VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
  sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVELTENAME}"
}

fn_svg_path_with_one_subdir(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline or solid
    cd "${SUBSRC}" || exit
    for file in *; do
    FILENAME=$(basename "${file%.*}")
    SVELTENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
    if [ ! -f "${SUBDIRNAME}/${file}" ]; then
        cp "${TEMPLATE}" "${SVELTENAME}"
    fi
    SVGPATH=$(extract_svg_path "$file")
    sed -i "s;replace_svg_path;${SVGPATH};" "${SVELTENAME}"

    fn_replace_viewbox
    done
  done
}

# Loop through directories and files to generate Svelte files with SVG paths and viewboxes replaced.
fn_svg_path_two_subdirs(){
  for SUBSRC in "${CURRENTDIR}"/*; do
    SUBDIRNAME=$(basename "${SUBSRC}") # outline or solid
    cd "${SUBSRC}" || exit

    for CATEGORY in "${SUBSRC}"/*; do
      cd "${CATEGORY}" || exit
      for file in *; do
        FILENAME=$(basename "${file%.*}")
        SVELTENAME="${CURRENTDIR}/${FILENAME}-${SUBDIRNAME}.svelte"
        if [ ! -f "${SUBDIRNAME}/${file}" ]; then
          cp "${script_dir}/templates/flowbite/flowbite-${SUBDIRNAME}.txt" "${SVELTENAME}"
        fi

        SVGPATH=$(extract_svg_path "$file")
        sed -i "s;replace_svg_path;${SVGPATH};" "${SVELTENAME}"

        fn_replace_viewbox
      done
    done
  done
}

# Generates Svelte files from SVG files in the current directory.
fn_svg(){
  for file in *; do
    # echo ${file}
    # echo ${TEMPLATE}
    FILENAME=$(basename "${file%.*}")
    SVELTENAME="${CURRENTDIR}/${FILENAME}.svelte"
    # create svelte file like address-book-solid.svelte
    if [ ! -f "${SVELTENAME}" ]; then
      cp "${TEMPLATE}" "${SVELTENAME}"
    fi

    SVGPATH=$(extract_svg_path "$file")
    # replace replace_svg_path with svg path
    sed -i "s;replace_svg_path;${SVGPATH};" "${SVELTENAME}"
    # get viewBox value
    VIEWVALUE=$(sed -n 's/.*viewBox="\([^"]*\)".*/\1/p' "${file}")
    sed -i "s;replace_viewBox;${VIEWVALUE};" "${SVELTENAME}"
  done
}


fn_add_arialabel() {
  cd "${CURRENTDIR}" || exit 1

  for filename in "${CURRENTDIR}"/*; do
  
    # FILENAMEONE=$(basename "${filename}" .svelte)
    FILENAME=$(basename "${filename}" .svelte | tr '-' ' ')
    
    # echo "${FILENAME}"
    sed -i "s;replace_ariaLabel; \"${FILENAME}\" ;" "${filename}" >/dev/null 2>&1
  done
  
  newBannerColor 'Added arialabel to all files.' "green" "*"
}

fn_remove_svg(){
  for filename in "${CURRENTDIR}"/*; do
    find . -type f -name "*.svg" -exec rm {} \;
  done
}

fn_rename(){
    newBannerColor "Renaming all files." "blue" "*"
    mkdir -p "${CURRENTDIR}/tempDir"
    for filename in "${CURRENTDIR}"/*; do
      FILENAMEONE=$(basename "${filename}" .svelte)
      # echo "${FILENAMEONE}"
      new_name=$(echo "${FILENAMEONE^}")
      # Capitalize the letter after -
      new_name=$(echo "$new_name" | sed 's/-./\U&/g')
      # Remove all -
      new_name=$(echo "$new_name" | sed 's/-//g')
      # Remove all spaces
      new_name=$(echo "$new_name" | sed 's/ //g')
      # Prepend 'A' if filename starts with a number
      if [[ $new_name =~ ^[0-9] ]]; then
          new_name="A${new_name}"
      fi
      # echo "${new_name}"
      if [[ -f "$filename" ]]; then
          mv "${CURRENTDIR}/${FILENAMEONE}.svelte" "${CURRENTDIR}/tempDir/${new_name}.svelte"
      fi
      # rm "${CURRENTDIR}/${FILENAMEONE}.svelte"
    done
    
    # with -maxdepth 1 to avoid recursion
    # find "${CURRENTDIR}/tempDir" -maxdepth 1 -name "*.svelte" -exec mv -t "${CURRENTDIR}" {} \;
    # mv "${CURRENTDIR}/tempDir/*" "${CURRENTDIR}"
    find "${CURRENTDIR}/tempDir" -maxdepth 1 -name "*.svelte" -exec mv -t "${CURRENTDIR}" {} \;
    # find
    rm -rf "${CURRENTDIR}/tempDir"
}

# Function to extract box width and height from an SVG file
extract_box_dimensions() {
  local file="$1"
  local viewBox=$(grep -oP '(?<=viewBox=")[^"]+' "$file")
  local IFS=" "
  local viewBox_arr=($viewBox)
  box_width=${viewBox_arr[2]}
  box_height=${viewBox_arr[3]}
}

# Function to move and rename the SVG files
move_and_rename_svg() {
  local src_dir=$1
  local suffix=$2
  local dest_dir=$3

  find "$src_dir" -type f -name "*.svg" -print0 | while IFS= read -r -d $'\0' file; do
    # Get the filename without the extension
    file_base=$(basename "${file%.*}")

    # Move and rename the file to the destination directory with the specified suffix
    mv "$file" "$dest_dir/${file_base}${suffix}.svg"
  done
}

# clone repo
clone_repo(){
  # $1 CURRENTDIR   
  # $2 DIRNAME
  # $3 GITURL
  local CURRENTDIR="$1"
  local DIRNAME="$2"
  local GITURL="$3"

  if [ -d "${CURRENTDIR}" ]; then
    newBannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"
  fi
  mkdir -p "${CURRENTDIR}"
  cd "${CURRENTDIR}" || exit 1
  # clone the repo
  # If DIRNAME is provided, clone the repo using it
  if [ -n "${DIRNAME}" ]; then
    newBannerColor "Cloning ${DIRNAME}." "green" "*"
    npx tiged "${GITURL}/${DIRNAME}" "${CURRENTDIR}" >/dev/null 2>&1 || {
      echo "Not able to clone."
      exit 1
    }
  else
    # Clone the repo without using DIRNAME
    newBannerColor "Cloning without DIRNAME." "green" "*"
    npx tiged "${GITURL}" "${CURRENTDIR}" >/dev/null 2>&1 || {
      echo "Not able to clone."
      exit 1
    }
  fi
  newBannerColor "Cloned ${DIRNAME}." "green" "*"
}

extract_icon_name() {
  # Usage
  # Example 1: Remove only the prefix
  # result1=$(extract_icon_name "/path/to/icon_prefix_suffix.svg" "icon_")
  # echo "$result1"  # Output: "prefix_suffix"

  # Example 2: Remove only the suffix
  # result2=$(extract_icon_name "/path/to/icon_prefix_suffix.svg" "" "_suffix")
  # echo "$result2"  # Output: "icon_prefix"

  # Example 3: Remove both prefix and suffix
  # result3=$(extract_icon_name "/path/to/icon_prefix_suffix.svg" "icon_" "_suffix")
  # echo "$result3"  # Output: "prefix"

  local file_name=$(basename "$1")
  local icon_name="${file_name%.svg}"  # Remove the .svg extension

  local prefix_to_remove="${2:-}"
  local suffix_to_remove="${3:-}"
  # Remove the specified prefix
  if [ -n "$prefix_to_remove" ]; then
      icon_name="${icon_name#$prefix_to_remove}"
  fi

  # Remove the specified suffix
  if [ -n "$suffix_to_remove" ]; then
      icon_name="${icon_name%$suffix_to_remove}"
  fi

  echo "$icon_name"
}

# Function to extract path data from SVG file
extract_svg_path() {
  SVGPATH=$(tr '\n' ' ' < "$1" | sed 's/<svg[^>]*>//g; s/<\/svg>//g')
  echo "$SVGPATH"
}
remove_svg_tags() {
  # Input file path
  input_file="$1"
  # Output file path (modified content)
  output_file="${input_file}_modified.svg"

  # Check if input file exists
  if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist."
    return 1
  fi

  # Extract content without tags using tr and sed
  modified_content=$(tr '\n' ' ' < "$input_file" | sed 's/<svg[^>]*>//g; s/<\/svg>//g')

  # Write modified content to a new file
  echo "$modified_content" > "$output_file"

  echo "Successfully extracted content without tags to: $output_file"
}

# Function to extract width and height values from SVG code
extract_width_height() {
    # Get the first line of the SVG file
    first_line=$(head -n 1 "$1")

    # Use regular expressions to extract width and height values
    if [[ $first_line =~ width=\"([0-9]+)px\" ]]; then
        width="${BASH_REMATCH[1]}"
    fi

    if [[ $first_line =~ height=\"([0-9]+)px\" ]]; then
        height="${BASH_REMATCH[1]}"
    fi
}

check_cmd() {
  if [ ! "$(command -v "$1")" ]; then
      app=$1
      redprint "It seems like you don't have ${app}."
      redprint "Please install ${app}."
      exit 1
  fi
}

# bash version check
check_bash() {
    # If you are using Bash, check Bash version
    if ((BASH_VERSINFO[0] < $1)); then
        printf '%s\n' "Error: This requires Bash v${1} or higher. You have version $BASH_VERSION." 1>&2
        exit 2
    fi
}

# sed version
is_gnu_sed(){
    sed --version >/dev/null 2>&1
}

### Colors ##
ESC=$(printf '\033')
RESET="${ESC}[0m"
BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"
DEFAULT="${ESC}[39m"

### Color Functions ##

blackprint() {
    printf "${BLACK}%s${RESET}\n" "$1"
}

blueprint() {
    printf "${BLUE}%s${RESET}\n" "$1"
}

cyanprint() {
    printf "${CYAN}%s${RESET}\n" "$1"
}

defaultprint() {
    printf "${DEFAULT}%s${RESET}\n" "$1"
}

greenprint() {
    printf "${GREEN}%s${RESET}\n" "$1"
}

magentaprint() {
    printf "${MAGENTA}%s${RESET}\n" "$1"
}

redprint() {
    printf "${RED}%s${RESET}\n" "$1"
}

whiteprint() {
    printf "${WHITE}%s${RESET}\n" "$1"
}

yellowprint() {
    printf "${YELLOW}%s${RESET}\n" "$1"
}

# Text attribute
BOLD="${ESC}[1m"
FAINT="${ESC}[2m"
ITALIC="${ESC}[3m"
UNDERLINE="${ESC}[4m"
SLOWBLINK="${ESC}[5m"
SWAP="${ESC}[7m"
STRIKE="${ESC}[9m"

boldprint() {
    printf "${BOLD}%s${RESET}\n" "$1"
}

faintprint() {
    printf "${FAINT}%s${RESET}\n" "$1"
}

italicprint() {
    printf "${ITALIC}%s${RESET}\n" "$1"
}

underlineprint() {
    printf "${UNDERLINE}%s${RESET}\n" "$1"
}

slowblinkprint() {
    printf "${SLOWBLINK}%s${RESET}\n" "$1"
}

swapprint() {
    printf "${SWAP}%s${RESET}\n" "$1"
}

strikeprint() {
    printf "${STRIKE}%s${RESET}\n" "$1"
}


# lib/banners
# Usage: bannerSimple "my title" "*"
function bannerSimple() {
    msg="${2} ${1} ${2}"
    edge=$(echo "${msg}" | sed "s/./"${2}"/g")
    echo "${edge}"
    echo "$(tput bold)${msg}$(tput sgr0)"
    echo "${edge}"
    echo
}

# Usage: newBannerColor "my title" "red" "*"
function bannerColor() {
    case ${2} in
    black)
        color=0
        ;;
    red)
        color=1
        ;;
    green)
        color=2
        ;;
    yellow)
        color=3
        ;;
    blue)
        color=4
        ;;
    magenta)
        color=5
        ;;
    cyan)
        color=6
        ;;
    white)
        color=7
        ;;
    *)
        echo "color is not set"
        exit 1
        ;;
    esac

    msg="${3} ${1} ${3}"
    edge=$(echo "${msg}" | sed "s/./${3}/g")
    tput setaf ${color}
    tput bold
    echo "${edge}"
    echo "${msg}"
    echo "${edge}"
    tput sgr 0
    echo
}

function newBannerColor() {
    case ${2} in
    black)
        color=0
        ;;
    red)
        color=1
        ;;
    green)
        color=2
        ;;
    yellow)
        color=3
        ;;
    blue)
        color=4
        ;;
    magenta)
        color=5
        ;;
    cyan)
        color=6
        ;;
    white)
        color=7
        ;;
    *)
        echo "color is not set"
        exit 1
        ;;
    esac

    # Set border width to 4th argument if provided, otherwise default to 10
    border_width=${4:-10}
    
    # Create border string with specified width
    border=$(printf "%0.s${3}" $(seq 1 $border_width))
    
    tput setaf ${color}
    tput bold
    echo "${border}"
    echo "${1}"  # Print the message as-is, without adding border characters
    echo "${border}"
    tput sgr 0
    echo
}