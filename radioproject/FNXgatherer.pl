#this script probably needs to run every 20 minutes or so.
use strict;
use LWP::Simple;

#for parsing the XML we retrieve from FNX
use XML::Simple;


# PERL MODULE for DB access
use DBI;

my $TITLECLASS = "sTWBOS";
my $LASTPLAYEDCLASS = "sDtWBOS";
my $BANDCLASS = "sAWBOS";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = sprintf "%02d/%02d/%4d %02d:%02d:%02d\n", $mon+1,$mday,$year+1900,$hour,$min,$sec;
print "Start time: $timestamp\n";

#random number is to prevent caching.
my $rndNumber = int(rand(100000));
my $rURL = 'http://playerservices.streamtheworld.com/public/nowplaying?mountName=WFNXFM&numberToFetch=10&nocache=' .$rndNumber;


#get the html page
my $rContent = get($rURL);


# create object
my $xml = new XML::Simple;

# read XML file
my $data = $xml->XMLin($rContent);

#iterate through the elements in XML.
foreach my $e (@{$data->{'nowplaying-info'}})
{
   
   #get individual parts out of the timestamp
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($e->{timestamp});
   #reformat the time to mysql datetime
   my $newtime = sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year + 1900,$mon,$mday,$hour,$min,$sec);
   
   print "time: " . $newtime, "\n";
   print "mount: " .$e->{mountName}, "\n";
   print "band name: " .$e->{property}->{track_artist_name}->{content}, "\n";
   print "song title: " .$e->{property}->{cue_title}->{content}, "\n";
   print "\n"
}

print @{$data->{'nowplaying-info'}}." songs\n";