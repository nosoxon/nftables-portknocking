# nftables portknocking generator

Autogenerator for nftables [port knocking](https://en.wikipedia.org/wiki/Port_knocking)
implementation. Accepts arbitrary number of ports.

## Usage
Set ports in [knocking.m4](knocking.m4), then run
``` sh
$ m4 knocking.m4 > knocking.nft
```

## Sample Output
```
# knock code = 3530,28980,11566,2594,13745,28571

table ip knocking {
    set step-1 { type ipv4_addr; flags timeout; timeout 3s; }
    set step-2 { type ipv4_addr; flags timeout; timeout 3s; }
    set step-3 { type ipv4_addr; flags timeout; timeout 3s; }
    set step-4 { type ipv4_addr; flags timeout; timeout 3s; }
    set step-5 { type ipv4_addr; flags timeout; timeout 3s; }
    set clients { type ipv4_addr; flags timeout; timeout 3s; }

    chain input {
        type filter hook input priority -10;
        policy accept;

        iif lo return
        iif $if_wan goto if_wan
    }

    chain if_wan {
        tcp dport $ports_knock_tcp goto knocked
        tcp dport 3530 add @step-1 { ip saddr }
        tcp dport 28980 ip saddr @step-1 add @step-2 { ip saddr }
        tcp dport 11566 ip saddr @step-2 add @step-3 { ip saddr }
        tcp dport 2594 ip saddr @step-3 add @step-4 { ip saddr }
        tcp dport 13745 ip saddr @step-4 add @step-5 { ip saddr }
        tcp dport 28571 ip saddr @step-5 add @clients { ip saddr }
    }

    chain knocked {
        ct state { established, related } accept
        ip saddr @clients accept
        drop
    }
}
```

## References
* [nftables Wiki](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page)
* [`nft` man page](https://www.netfilter.org/projects/nftables/manpage.html)
