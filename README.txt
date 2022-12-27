GCC Version: gcc (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0

#            Systems and Security PLH519
#           
#         	Topic: Ad-blocking mechanism
#
#      Author: Nikolaos Papoutsakis 2019030206


In this assignment, we created a simple adblock script using `iptables` command.
We had to find the domains that exist both on domainName and domainName2 and save 
their ips using the `dig` command in the ipaddresssame file. All the others were
saved in ipaddressdiff file.

For testing first run the command:
	
	1. sudo bash adblock.sh -domains
			or
	   chmod +x adblock.sh -> to give execute priviledge
	   sudo ./adblock.sh -domains
	 
And then, use:

	2. sudo ./adblock.sh -ipssame -> for dropping
			or
	   sudo ./adblock.sh -ipsdiff -> for rejecting


Now, adblock rules are created, u can save them using -save, load them using -load
and reset using -reset.

We noticed that if the script did its work, we cannot establish a connection with the
domains on the file, because the packets are dropped or rejected!
Also, we tried to connect in gr.k24.net(e.g.) and the ads were gone.

Not all of the ads disapper. That's because some of them could be ipv6 and for that
we had to use `ip6tables`. Finally, sometimes very popular sites cannot be adblocked 
because they might have some strong mechanism that detects our script and ignores it.