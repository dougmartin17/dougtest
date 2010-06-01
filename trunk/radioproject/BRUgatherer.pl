#this script probably needs to run every 20 minutes or so.
use strict;
use LWP::Simple;

#for parsing the XML we retrieve from FNX
use XML::Simple;

# PERL MODULE for DB access
use DBI;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = sprintf "%02d/%02d/%4d %02d:%02d:%02d\n", $mon+1,$mday,$year+1900,$hour,$min,$sec;
print "Start time: $timestamp\n";

#random number is to prevent caching.

my $rURL = 'http://www.yes.com/ajax/log.php?s=9a08fa8afcabe4182809743baa722ad45a6b52e6&h=14&d=2Latest/current';


#get the html page
my $rContent = get($rURL);

my @entries = split('},{',$rContent);
foreach my $e (@entries)
{

   #fetch all the elements we care about:
   $e =~ /time":"([^"]+)"/;
   my $time = $1;
   print "time: $time\n";
   
   $e =~ /date":"([^"]+)"/;
   my $date = $1;
   print "date: $date\n";
   
   $e =~ /"by":"([^"]+)"/;
   my $bandname = $1;
   print "band: $bandname\n";
   
   $e =~ /"title":"([^"]+)"/;
   my $title = $1;
   print "titl: $title\n";
   
   #now we need to form the datetime element
   $date =~ /(\d+)..(\d+)..(\d+)/;
   my $y = $3;
   my $d = $2;
   my $mon = $1;
   
   $time =~ /(\d+):(\d+)/;
   my $h = $1;
   my $min = $2;
   
   my $datetime = sprintf("%4d-%02d-%02d %02d:%02d:00", $y, $mon, $d, $h, $min);
   
   print "newd: $datetime\n";
   
   print "-----\n";
}



