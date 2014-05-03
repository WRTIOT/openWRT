#!/bin/sh

usersfile=/etc/freeradius2/users.6LoWPAN

AddUser ()
{
    mac=$1
    key=` echo $mac | awk '{ p=""; for(i=length($1)-1; i>0;i-=2) { p = p "00"; p = p substr($1,i,2) } print p; }'`

    echo "Adding $mac to users"    
    echo "" >> $usersfile                                              
    echo "$mac Cleartext-Password := \"$mac\"" >> $usersfile           
    echo "      Vendor-Specific = \"0x00006DE96412$key\"" >> $usersfile
}        


ParseLine()
{
    mac=` echo $1 | awk '{ FS="[" } { print $2 }' | awk '{ FS="]"} { print $1 }' | awk '{ FS="/" } { print $1 }'`

    grep $mac $usersfile
    [[ $? -ne 0 ]] && AddUser $mac
    killall -HUP radiusd
}



/usr/bin/tail -f /var/log/radius.log |
while read -r line
do
    echo $line
    case $line in
    *incorrect*) ParseLine "$line"
    esac
done
exit
