include(`nftables.m4')dnl
knock_ports(3530, 28980, 11566, 2594, 13745, 28571)dnl
signature(`core.sgpd.xyz', `/etc/nftables/knocking.nft')

`#' knock code = knock_ports

table ip knocking {
    indent(knocksets, 1)

    chain input {
        type filter hook input priority -10;
        policy accept;

        iif lo return
        iif $if_wan goto if_wan
    }

    chain if_wan {
        tcp dport $ports_knock_tcp goto knocked
        indent(knockrules_silent, 2)
    }

    chain knocked {
        ct state { established, related } accept
        ip saddr @clients accept
        drop
    }
}
