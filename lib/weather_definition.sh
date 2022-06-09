parser_definition_weather() {
    setup REST plus:true help:usage abbr:true -- \
        "Usage: ${2##*/} [options...] [arguments...]" ''
    msg -- 'Create Simple-icons for Svelte' ''
    msg -- 'Options:'
    
    disp :usage -h --help
}
