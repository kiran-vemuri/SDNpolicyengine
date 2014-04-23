=put
Author: Kiran Vemuri
Description: enable services/websites based on the DNS queries. to be used along with the blocker application.
why?: services now a days have multiple ip addresses linked to them. so if all the ip addresses listed in the dns server for that specific service are blocked, that service can be absolutely blocked on that network/ host of the network.

Website: www.kiranvemuri.info 
compatibility : Floodlight opensource controller.
=cut



#!/usr/bin/perl -w
use strict;
use warnings;

#pass the service/website name to be blocked as an argument
my $network_name= $ARGV[0];
my $serv_name= $ARGV[1];

my @networks= split(",",$network_name);

#use the linux dig utility to get all the ip addresses related to that service and save them to a log file
system("dig +noall +answer ".$serv_name." | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > ipaddrlist.log");

my $filename = 'ipaddrlist.log';

# read the contents of the log file into an array

my @array = do {
    open my $fh, "<", $filename
        or die "could not open $filename: $!";
    <$fh>;
};

my @iparray=grep(s/\s*$//g, @array);

#push flows to enable all the ip addresses of the service that are blocked usong the blocker application. flow name <f+ipaddress>

foreach my $val2 (@networks)
{

foreach my $val (@iparray)
{
#print $val;
`curl -X DELETE -d '{"name":"f$val"}' http://$val2:8080/wm/staticflowentrypusher/json`
}
}

