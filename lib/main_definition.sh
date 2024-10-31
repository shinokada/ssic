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
    cmd ant-v2 -- "Create Ant Design icons for Svelte 5 Runes mode version."
    cmd awesome -- "Create Awesome icons."
    cmd awesome-v2 -- "Create Awesome icons v2 version."
    cmd bootstrap -- "Create Bootstrap files."
    cmd bootstrap-v2 -- "Create Bootstrap files for Svelte 5 Runes mode version."
    cmd box -- "Create Boxicons icons."
    cmd circle-flags -- "Create Circle-flags."
    cmd coreui -- "Create Coreui-icons."
    cmd crypto -- "Create Crypto icons."
    cmd css -- "Create CSS.gg icons."
    cmd evil -- "Create Evil icons."
    cmd feather -- "Create Feathericons."
    cmd file -- "Create file-icons."
    cmd flags -- "Create country flag icons."
    cmd flags-v2 -- "Create country flag icons for Svelte 5 Runes mode version."
    cmd flag-icons -- "Create country flag icons from https://github.com/lipis/flag-icons/tree/main/flags/4x3."
    cmd flag-icons-v2 -- "Create country flag icons for Svelte 5 Runes mode version."
    cmd flowbite -- "Create Flowbite-icons"
    cmd flowbite-v2 -- "Create Flowbite-svelte-icons v2 version"
    cmd heros -- "Create Heroicons v-1."
    cmd heros-next -- "Create Heroicons v-1 for next version."
    cmd heros2 -- "Create Heroicons v-2."
    cmd heros2-v2 -- "Create Heroicons v2 v2."
    cmd ion -- "Create Ionicons."
    cmd ion-v2 -- "Create Ionicons for Svelte 5 Runes mode version."
    cmd lucide -- "Create Lucide-icons."
    cmd lucide-v2 -- "Create Lucide-icons for Svelte 5 Runes mode version."
    cmd material -- "Create Material-design-icons from https://github.com/Templarian/MaterialDesign."
    cmd google-material-design -- "Create Material-design-icons from https://github.com/marella/material-design-icons/tree/main/svg."
    cmd oct -- "Create Octicons."
    cmd radix -- "Create Radix-icons."
    cmd radix-v2 -- "Create Radix-icons for Svelte 5 Runes mode version."
    cmd remix -- "Create Remixicons."
    cmd remix-v2 -- "Create Remixicons for Svelte 5 Runes mode version."
    cmd simple -- "Create Simple-icons."
    cmd supertiny -- "Create SuperTinyIcons."
    cmd supertiny-v2 -- "Create SuperTinyIcons-v2."
    cmd tabler -- "Create Tabler-icons."
    cmd tabler-v2 -- "Create Tabler-icons for Svelte 5 Runes mode version."
    cmd tabler-outline-v2 -- "Create Tabler outline icons for Svelte 5 Runes mode version."
    cmd tabler-filled-next -- "Create Tabler filled icons for next version."
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
