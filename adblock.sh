#!/bin/bash
# You are NOT allowed to change the files' names!
domainNames="domainNames.txt"
domainNames2="domainNames2.txt"
IPAddressesSame="IPAddressesSame.txt"
IPAddressesDifferent="IPAddressesDifferent.txt"
adblockRules="adblockRules"

function adBlock() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-domains"  ]; then
        # Find different and same domains in ‘domainNames.txt’ and ‘domainsNames2.txt’ files 
        # and write them in “IPAddressesDifferent.txt and IPAddressesSame.txt" respectively

        # Store common urls in variable
        same_domains=`grep -f domainNames.txt domainNames2.txt`

        # Get the ips of the same domains and store them in IPAddressesSame
        while read line1 || [ -n "$line1" ];
        do 
            dig +short $line1 | grep '^[.0-9]*$' >> $IPAddressesSame
      
        done <<< "$same_domains"

        # Store the domains that differ
        unique_domains=`sort domainNames.txt domainNames2.txt | uniq -u`

        # Get the ips of the different domains and store them in IPAddressesDifferent
        while read line2 || [ -n "$line2" ];
        do 
            dig +short $line2 | grep '^[.0-9]*$' >> $IPAddressesDifferent
      
        done <<< "$unique_domains"       

        true
            
    elif [ "$1" = "-ipssame"  ]; then
        # Configure the DROP adblock rule based on the IP addresses of $IPAddressesSame file.
        
        # iptables -A [chain] -p [protocol] -s [source IP] --dport [destination port] -j DROP
        while read -r line || [ -n "$line" ];
        do 
            if [ "$line" != "" ]; then
                iptables -A INPUT -s $line -j DROP
                iptables -A FORWARD -s $line -j DROP
                iptables -A OUTPUT -s $line -j DROP
            fi
        done < $IPAddressesSame

        true

    elif [ "$1" = "-ipsdiff"  ]; then
        # Configure the REJECT adblock rule based on the IP addresses of $IPAddressesDifferent file.
        
        # iptables -A [chain] -p [protocol] -s [source IP] --dport [destination port] -j DROP
        while read -r line || [ -n "$line" ];
        do 
            if [ "$line" != "" ]; then
                iptables -A INPUT -s $line -j REJECT
                iptables -A FORWARD -s $line -j REJECT
                iptables -A OUTPUT -s $line -j REJECT
            fi
        done < $IPAddressesDifferent

        true
        
    elif [ "$1" = "-save"  ]; then
        # Save rules to $adblockRules file.
        iptables-save > $adblockRules
        true
        
    elif [ "$1" = "-load"  ]; then
        # Load rules from $adblockRules file.
        iptables-restore < $adblockRules
        true
        
    elif [ "$1" = "-reset"  ]; then
        # Reset rules to default settings (i.e. accept all).
        # iptables -P INPUT ACCEPT
        # iptables -P FORWARD ACCEPT
        # iptables -P OUTPUT ACCEPT

        # -F flush chain
        iptables -F

        # -X delete chain
        # iptables -X
        # rm IPAddressesSame.txt IPAddressesDifferent.txt
        true
  
    elif [ "$1" = "-list"  ]; then
        # List current rules.
        # --list flag shows all the rules in the chain
        # --line numbers used to specify each line 
        # --numeric to print IPs and ports in numeric format
        iptables --list --line-numbers --numeric
        true
        
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple adblock mechanism. It rejects connections from specific domain names or IP addresses using iptables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -domains\t  Configure adblock rules based on the domain names of '$domainNames' file.\n"
        printf "  -ipssame\t  Configure the DROP adblock rules based on the IP addresses of $IPAddressesSame file.\n"
	    printf "  -ipsdiff\t  Configure the REJECT adblock rules based on the IP addresses of $IPAddressesDifferent file.\n"
        printf "  -save\t\t  Save rules to '$adblockRules' file.\n"
        printf "  -load\t\t  Load rules from '$adblockRules' file.\n"
        printf "  -list\t\t  List current rules.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

adBlock $1
exit 0
