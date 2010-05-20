use strict;
use HTML::TreeBuilder;
use LWP::Simple;

my $TITLECLASS = "sTWBOS";
my $LASTPLAYEDCLASS = "sDtWBOS";
my $BANDCLASS = "sAWBOS";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = sprintf "%02d/%02d/%4d %02d:%02d:%02d\n", $mon+1,$mday,$year+1900,$hour,$min,$sec;

my $rURL = "http://www.wbos.biz/lastplayed.aspx";
print "Start time: $timestamp\n";

my $rTree = HTML::TreeBuilder->new;


#get the html and create the tree

my $rContent = get($rURL);
$rTree->parse($rContent);

my @rRows = $rTree->find('td');
foreach my $r (@rRows)
{
   
   my @t = $r->look_down('class' => $BANDCLASS);
   my $band = $t[0] ? $t[0]->as_trimmed_text : '';
      
   my @t = $r->look_down('class' => qr/$LASTPLAYEDCLASS/);
   my $lp = $t[0] ? $t[0]->as_trimmed_text : '';
   
   
   my @t = $r->look_down('class' => qr/$TITLECLASS/);
   my $title = $t[0] ? $t[0]->as_trimmed_text : '';
   
   
   if($lp & $band & $title)
   {
      print "Band: [$band]\n";
      print "Last played: [$lp]\n";
      print "Title: [$title]\n";
   }
} # end foreach my $r (@rRows)
   
   
   
#$we = $wTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Description/i }



####DATABASE connect/stuff
#!/usr/bin/perl

# PERL MODULE
use Mysql;

# CONFIG VARIABLES
$host = "localhost";
$database = "playlistproject";
$tablename = "playlists";
#i've created this user in the db, not sure on permissions.
$user = "dbuser";
$pw = "dbuser_pw";

# PERL MYSQL CONNECT
#$connect = Mysql->connect($host, $database, $user, $pw);