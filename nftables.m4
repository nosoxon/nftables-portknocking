divert(`-1')

## general
define(`forloop', `ifelse(eval(`($2) <= ($3)'), `1',
    `pushdef(`$1')_forloop(eval(`$2'), eval(`$3'),
        `define(`$1',', `)$4')popdef(`$1')')')
define(`_forloop',
    `$3`$1'$4`'ifelse(`$1', `$2', `',
        `$0(incr(`$1'), `$2', `$3', `$4')')')

define(`_nl', `
')

define(`indent', `substr(patsubst(`$1', `^', `_indent(`$2')'), len(_indent(`$2')))')
define(`_indent', `ifelse(eval(`($1) > 0'), `1', `indentation`'$0(decr(`$1'))', `')')
define(`indentation', `    ')

define(`signature', `## $1 $2')

## port knocking
define(`_knockset', `set $1 { type ipv4_addr; flags timeout; timeout 3s; }')
define(`_knocksets',
    `forloop(`i', `1', eval(`$#' - 1), `_knockset(`step-i')_nl')_knockset(`clients')')
define(`knocksets', `_knocksets(knock_ports)')

define(`knockrule', `tcp dport $1 ifelse(`$#', `3', `ip saddr @$3 ')add @$2 { ip saddr }')
define(`_knocksteps', `_nl`'knockrule(`$2',
    ifelse(`$#', `2',
        ``clients', `step-$1')',
        ``step-`'incr($1)', `step-$1')_knocksteps(incr($1), shift(shift($@)))')')
define(`_knockrules', `knockrule(`$1', `step-1')_knocksteps(`1', shift($@))')
define(`knockrules', `_knockrules(knock_ports) \_nl`'indentation`'log prefix "$1: "')
define(`knockrules_silent', `_knockrules(knock_ports)')

define(`knock_ports', `define(`knock_ports', `$@')')

divert`'dnl
