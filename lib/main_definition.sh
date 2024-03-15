# shellcheck disable=SC1083
parser_definition() {
    setup REST help:usage abbr:true -- \
        "Usage: ${2##*/} [command] [options...] [arguments...]"
    msg -- '' 'Options:'
    disp :usage -h --help
    disp VERSION --version

    msg -- '' 'Commands: '
    msg -- 'Use command -h for a command help.'
    cmd ant -- "Create Ant Design icons."
    cmd ant-next -- "Create Ant Design icons for next version."
    cmd awesome -- "Create Awesome icons."
    cmd awesome-next -- "Create Awesome icons next version."
    cmd bootstrap -- "Create Bootstrap files."
    cmd box -- "Create Boxicons icons."
    cmd circle-flags -- "Create Circle-flags."
    cmd coreui -- "Create Coreui-icons."
    cmd crypto -- "Create Crypto icons."
    cmd css -- "Create CSS.gg icons."
    cmd evil -- "Create Evil icons."
    cmd feather -- "Create Feathericons."
    cmd file -- "Create file-icons."
    cmd flags -- "Create country flag icons."
    cmd flag-icons -- "Create country flag icons from https://github.com/lipis/flag-icons/tree/main/flags/4x3."
    cmd flowbite -- "Create Flowbite-icons"
    cmd flowbite-next -- "Create Flowbite-svelte-icons next version"
    cmd heros -- "Create Heroicons v-1."
    cmd heros2 -- "Create Heroicons v-2."
    cmd ion -- "Create Ionicons."
    cmd lucide -- "Create Lucide-icons."
    cmd material -- "Create Material-design-icons from https://github.com/Templarian/MaterialDesign."
    cmd google-material-design -- "Create Material-design-icons from https://github.com/marella/material-design-icons/tree/main/svg."
    cmd oct -- "Create Octicons."
    cmd radix -- "Create Radix-icons."
    cmd remix -- "Create Remixicons."
    cmd simple -- "Create Simple-icons."
    cmd supertiny -- "Create SuperTinyIcons."
    cmd supertiny-next -- "Create SuperTinyIcons-next."
    cmd tabler -- "Create Tabler-icons."
    cmd teeny -- "Create Teeny-icons."
    cmd twemoji -- "Create Twemoji-icons."
    cmd weather -- "Create Weather-icons."
    # cmd text_example -- "Print different type of texts."
    # cmd create -- "Create this and that."

    msg -- '' "Examples:
    
    hero 
    $SCRIPT_NAME hero
    version
    $SCRIPT_NAME --version
    Display help:
    $SCRIPT_NAME -h | --help
"
}
