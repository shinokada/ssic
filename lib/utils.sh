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

# Usage: bannerColor "my title" "red" "*"
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