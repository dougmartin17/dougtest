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
my $rndNumber = int(rand(100000));
my $rURL = 'http://playerservices.streamtheworld.com/public/nowplaying?mountName=WFNXFM&numberToFetch=10&nocache=' .$rndNumber;


#get the html page
my $rContent = get($rURL);


# create object
my $xml = new XML::Simple;

# read XML file
my $data = $xml->XMLin($rContent);

#open DB connection
my $db = openDBconnection();

#iterate through the elements in XML.
foreach my $e (@{$data->{'nowplaying-info'}})
{
   
   #get individual parts out of the timestamp
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($e->{timestamp});
   #reformat the time to mysql datetime
   my $newtime = sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year + 1900,$mon+1,$mday,$hour,$min,$sec);

   my $band = $e->{property}->{track_artist_name}->{content};
   my $title = $e->{property}->{cue_title}->{content};

   print "time: " . $newtime, "\n";
   print "band name: " .$band, "\n";
   print "song title: " .$title, "\n";
   print "\n";


   $band =~ s/'/./g;
   $title =~ s/'/./g;
   
#apparently there can be ads so we need a null check on band name
   if($band)
   {
      dbInsertData($db, $band, $title, $newtime);
   }

}

#close the db connection
closeDBconnection($db);

print "Finished running\n";


####DATABASE connect/stuff
sub dbInsertData
{
   my ($dbh, $b, $t, $lp) = @_;

      # Prepare the SQL statement
my $cmd = "insert into t_playlists (bandname,songtitle,timestamp,station)
			values('$b','$t','$lp','wfnx');";
#print "SQL command: " . $cmd."\n";
      my $sth= $dbh->prepare($cmd)
      or return $DBI::errstr;
   
      # Send the statement to the server
      $sth->execute() or return $DBI::errstr;

}
sub openDBconnection
{
   # CONFIG VARIABLES
   my $host = "192.168.1.69";
         
   my $port = 3306;
   my $database = "playlistproject";
   my $tablename = "playlists";
   #i've created this user in the db, not sure on permissions.
   my $user = "dbuser";
   my $pw = "dbuser_pw";
   $user='root';
   $pw='black';

   # PERL MYSQL CONNECT
   #$connect = Mysql->connect($host, $database, $user, $pw);
   my $dbh = DBI->connect("dbi:mysql:$database:host=:$host:port=$port;", $user,$pw)
    or die "Connecting from Perl to MySQL database failed: $DBI::errstr";
    
    return $dbh;
}

sub closeDBconnection
{
   my $dbh = shift(@_);
   
   # Close the connection
   $dbh->disconnect or die $DBI::errstr;
}
