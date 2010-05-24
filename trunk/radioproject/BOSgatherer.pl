use strict;
use HTML::TreeBuilder;
use LWP::Simple;

# PERL MODULE for DB access
use DBI;

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
      my $newlp = convertLastPlayed($lp);
      print "converted lastplayed time: $newlp\n";
      print "Title: [$title]\n";
      print "\n";
   }
} # end foreach my $r (@rRows)
   
   
   
#$we = $wTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Description/i }

####let's try DB
my $db = openDBconnection();
runDBcommand($db);
closeDBconnection($db);
###end of db stuff

####DATABASE connect/stuff
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
   my $dbh = DBI->connect("dbi:mysql:$database:$host:$port;", $user,$pw)
    or die "Connecting from Perl to MySQL database failed: $DBI::errstr";
    
    return $dbh;
}

sub closeDBconnection
{
   my $dbh = shift(@_);
   
   # Close the connection
   $dbh->disconnect or die $DBI::errstr;
}

sub runDBcommand
{
   my $dbh = shift(@_);
      # Prepare the SQL statement
      my $sth= $dbh->prepare("SELECT * from t_playlists;")
      or return $DBI::errstr;
   
      # Send the statement to the server
      $sth->execute();
   
      my $numRows = $sth->rows;
      print "Rows returned: $numRows\n";
   
      my @row;
      while ( @row = $sth->fetchrow_array )
      {
      print "@row\n";
      }
}



#convert the last played time we get from BOS to the mysql DATETIME format of 1900-01-01 00:00:00
sub convertLastPlayed
{
   my $timestamp = shift(@_);

   $timestamp =~ /(\d+)\/(\d+)\/(\d+) @ (\d+):(\d+) (\w{2})/;
   my $month = $1;
   my $day = $2;
   my $year = $3;
   
   my $hour = $4;
   my $minutes = $5;
   my $ampm = $6;
   
   if($ampm eq 'pm')
   {
      #convert to 24 hour clock
      $hour = $hour + 12;
   }
   
   
   my $newdate = sprintf("%4d-%02d-%02d %02d:%02d:00", $year,$month,$day,$hour,$minutes);
   
   
   return $newdate;
}