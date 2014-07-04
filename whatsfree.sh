#!/usr/bin/env bash
# Daniel Compton
# 04/2014
# Daniel Compton
# www.commonexploits.com
# contact@commexploits.com
# Twitter = @commonexploits
# Tested on Bactrack 5 & Kali Nessus version 4 & 5

# Script begins
#===============================================================================

VERSION="0.1"

clear
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo -e "	WhatsFree $VERSION "
echo ""
echo -e "	Find what IP addresses are free"
echo ""
echo -e "\e[00;32m#############################################################\e[00m"

#Dependency checking

#Check for nmap
which nmap>/dev/null
if [ $? -eq 0 ]
        then
                echo ""
else
                echo ""
       		echo -e "\e[01;31m[!]\e[00m Unable to find the required nmap program, install and try again"
        exit 1
fi

#Check for arp-scan
which arp-scan>/dev/null
if [ $? -eq 0 ]
        then
                echo ""
else
                echo ""
       		echo -e "\e[01;31m[!]\e[00m Unable to find the required arp-scan program, install and try again"
        exit 1
fi

# Check if root
if [[ $EUID -ne 0 ]]; then
        echo ""
        echo -e "\e[01;31m[!]\e[00m This program must be run as root. Run again with 'sudo'"
        echo ""
        exit 1
fi

echo ""
echo -e "\e[01;32m[-]\e[00m The following Interfaces are available"
echo ""
	ifconfig -a | grep -o "eth.*" |cut -d " " -f1
echo ""
echo -e "\e[1;31m-------------------------------------------------------\e[00m"
echo -e "\e[01;31m[?]\e[00m Enter the interface to scan from as the source"
echo -e "\e[1;31m-------------------------------------------------------\e[00m"
read INT

ifconfig | grep -i -w $INT >/dev/null

if [ $? = 1 ]
	then
		echo ""
		echo -e "\e[1;31m Sorry the interface you entered does not exist! - check and try again."
		echo ""
		exit 1
fi
# bring up interface
ifconfig $INT up >/dev/null
echo ""
echo -e "\e[1;31m-------------------------------------------------------\e[00m"
echo -e "\e[01;31m[?]\e[00m Enter the IP range i.e 10.10.10.0/24"
echo -e "\e[1;31m-------------------------------------------------------\e[00m"
echo ""
read IPRANGE
IPLIST=$(nmap -sL $IPRANGE -n | cut -d " " -f 5 |grep [0-9] |egrep -v '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.255' |egrep -v '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.0' >iplist.txt)
IPLIVE=$(arp-scan --interface $INT $IPRANGE | grep [0-9] |egrep '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}' |awk '{print $1}' >iplive.txt)
IPUP=$(cat iplive.txt)
if [ -z $IPUP 2>/dev/null ]
then
	echo ""
	echo -e "\e[01;31m[!]\e[00m There does not seem to be any live hosts from running an arp-scan"
	echo ""
	rm iplive.txt 2>/dev/null
	rm iplist.txt 2>/dev/null
	exit 1
else
echo ""
echo -e "\e[1;32m------------------------------------------------------------------------------\e[00m"
echo -e "\e[01;32m[+]\e[00m The following IP addresses are free on the range $IPRANGE"
echo -e "\e[1;32m------------------------------------------------------------------------------\e[00m"
echo ""
grep -v -f iplive.txt iplist.txt
echo ""
rm iplive.txt 2>/dev/null
rm iplist.txt 2>/dev/null
fi
exit 0
