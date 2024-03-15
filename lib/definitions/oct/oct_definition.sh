parser_definition_oct() {
  setup REST plus:true help:usage abbr:true -- \
    "Usage: ${2##*/} [options...] [arguments...]" ''
  msg -- 'getoptions basic example' ''
  msg -- 'Options:'

  disp :usage -h --help
}
