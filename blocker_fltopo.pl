=put
Author: Kiran Vemuri
Description: Block services/websites based on the DNS queries.
why?: services now a days have multiple ip addresses linked to them. so if all the ip addresses listed in the dns server for that specific service are blocked, that service can be absolutely blocked on that network/ host of the network.

Website: www.kiranvemuri.info
compatibility : Floodlight opensource controller.
=cut


#!/usr/bin/perl -w
use strict;
use warnings;

#take service details as an input from arguments
my $network_name= $ARGV[0];
my $serv_name= $ARGV[1];


my @networks= split(",",$network_name);


#print @networks; 
#print $serv_name;
#use the linux dig utility to get all the DNS entries for that service, then grep to pick the ip addresses and save them to a local file.
system("dig +noall +answer ".$serv_name." | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > ipaddrlist.log");

my $filename = 'ipaddrlist.log';

# get the ip addresses from the list to an array. add efficiency by removing the concept of files
my @array = do { 
    open my $fh, "<", $filename
        or die "could not open $filename: $!";
    <$fh>;
};  

    
#removing the whitespaces from the array entries
my @iparray=grep(s/\s*$//g, @array);

#push flows to block the ip addresses in the array. flow name <f+ipaddress>

my @swdpid;
my $networkct=scalar(@networks);

for(my $i=0;$i<$networkct;$i++)
{
$swdpid[$i]=$networks[$i].",".`curl http://$networks[$i]:8080/wm/device/ | grep -o -E "([0-9a-z]{2}\:*){8}"`;
}


foreach my $dpid (@swdpid)
{
$dpid =~ s/^\s+//;
$dpid =~ s/\s+$//;
my @networkinfo= split(",",$dpid);

foreach my $val (@iparray)
{
#print $val;
print $networkinfo[1];
`curl -d '{"switch": "$networkinfo[1]", "name":"f$val", "cookie":"0", "priority":"32768","active":"true", "src-ip":"192.168.2.2", "dst-ip":"$val", "ether-type":"0x800", "actions":""}' http://$networkinfo[0]:8080/wm/staticflowentrypusher/json`;

}


}


