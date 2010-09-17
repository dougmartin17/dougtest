use strict;
use HTML::TreeBuilder;
use LWP::Simple;

my $debug = 0;

####this is the file to write output to
my $outputfile = 'comparefooters.html'; 

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = sprintf "%02d/%02d/%4d %02d:%02d:%02d\n", $mon+1,$mday,$year+1900,$hour,$min,$sec;

#$tree = HTML::TreeBuilder->new;
my $rootURLr = 'rabbit.tripadvisor.com';
my $rootURLw = 'www.tripadvisor.com';

my $errorCount = 0;

my @pages = (
      '/Tourism-g60745-Boston_Massachusetts-Vacations.html',
      '/Hotels-g60745-Boston_Massachusetts-Hotels.html',
      '/SmartDeals-g60745-Boston_Massachusetts-Hotel-Deals.html',
      '/AllReviews-g60745-Boston_Massachusetts.html',
      '/Attractions-g60745-Activities-Boston_Massachusetts.html',
      '/Restaurants-g60745-Boston_Massachusetts.html',
      '/LocalMaps-g60745-Boston-Area.html',
      '/LocalMaps-g60745-d114134-The_Lenox_Hotel-Area.html',
      '/LocationPhotos-g60745-Boston_Massachusetts.html',
      '/LocationPhotos-g60745-d321151-Jurys_Boston_Hotel-Boston_Massachusetts.html#18756198',
      '/ShowForum-g60745-i48-Boston_Massachusetts.html',
      '/Discount_Hotels-g60745-Boston_Massachusetts.html',
      '/Cheap_Vacations-g60745-Boston_Massachusetts.html',
      '/Packages-g60745-Vacation-Package-Discount-Boston_Massachusetts.html',

   '/Flights-g60745-Boston_Massachusetts-Cheap_Discount_Airfares.html',
   '/Flights-g49022-o31310-Phoenix_to_Charlotte.html',
   '/Flights'
);

#prep output html file
open (OUT, ">$outputfile");
print OUT "<html>\n";
print OUT "<head>\n";
print OUT "<title>Rabbit/WWW Footer Flag Link comparision</title>\n";
print OUT "<style>
      table{background-color: #F0F0F0;}
      
      tr.URL{background-color: #ddffff}
      tr.alt{background-color: #ddffdd}
      td.diff{background-color: #ff5555}
      td{vertical-align: top; text-align: left;}
      div.error{position:absolute; top:50px; left:100px;}
      font.error{border: 3px solid black; font-size: 32px; color: red; background-color: yellow}
      
      </style>\n";
print OUT "</head>";
print OUT "<body>$timestamp<br>\n";

print OUT "Comparing <b>$rootURLr</b> and <b>$rootURLw</b><br>\n";


#iterate through the pages specified
foreach my $page (@pages)
{

print "Working on $page\n";
print OUT "<h2>$page</h2>\n";
   my $rURL = "http://$rootURLr$page";
   my $wURL = "http://$rootURLw$page";
   
   my $rTree = HTML::TreeBuilder->new;
   my $wTree = HTML::TreeBuilder->new;


   #get the html and create the tree
   #rabbit first
   my $rContent = get($rURL);
   $rTree->parse($rContent);
   #then www
   my $wContent = get($wURL);
   $wTree->parse($wContent);

my $re = $rTree->look_down(sub { $_[0]->tag() eq 'ul' and $_[0]->attr('id') =~ /Flags/i }  );
my $we = $wTree->look_down(sub { $_[0]->tag() eq 'ul' and $_[0]->attr('id') =~ /FLAGS/i }  );
   
   #get number of links
   my @wLinks = $we->find('a');
   my @rLinks = $re->find('a');
   
   print "w: number of links: " . scalar(@wLinks) . "\n";
   print "r: number of links: " . scalar(@rLinks) . "\n";



print OUT "<table border='1'>\n";

#This will get the largerest number of links (to include for new flags)
my $num = $#wLinks > $#rLinks ? $#wLinks : $#rLinks;

my $wwwString = "<tr class='URL'><th>WWW</th>";
my $rabbitString = "<tr class='URL'><th>Rabbit</th>";
foreach my $n (0..$num)
{
   
   my $wwwRes = @wLinks[$n]->attr('href') if @wLinks[$n];
   my $rabRes = @rLinks[$n]->attr('href') if @rLinks[$n];
   $rabRes =~ s/-rabbit//;
   $rabRes =~ s/rabbit-//;
   $rabRes =~ s/rabbit/www/;
   
   if($wwwRes ne $rabRes)
   {
      $wwwString .= "<td class='diff'>";
      $rabbitString .= "<td class='diff'>";
      $errorCount++;
   }
   else
   {
      $wwwString .= "<td>";
      $rabbitString .= "<td>";
   }
 
   $wwwString .= $wwwRes;
   $rabbitString .= $rabRes;
 
   $wwwString .= "</td>";
   $rabbitString .= "</td>";
}
$wwwString .= "</tr>";
$rabbitString .= "</tr>";

#display the href rows
print OUT "$wwwString\n$rabbitString\n";


#now do the title/alt text rows

$wwwString = "<tr class='alt'><th>WWW</th>";
$rabbitString = "<tr class='alt'><th>Rabbit</th>";
foreach my $n (0..$num)
{
   
   my $wwwRes = @wLinks[$n]->attr('title') if @wLinks[$n];
   my $rabRes = @rLinks[$n]->attr('title') if @rLinks[$n];
   
   if($wwwRes ne $rabRes)
   {
      $wwwString .= "<td class='diff'>";
      $rabbitString .= "<td class='diff'>";
      $errorCount++;
   }
   else
   {
      $wwwString .= "<td>";
      $rabbitString .= "<td>";
   }
 
   $wwwString .= $wwwRes;
   $rabbitString .= $rabRes;
 
   $wwwString .= "</td>";
   $rabbitString .= "</td>";

}
$wwwString .= "</tr>";
$rabbitString .= "</tr>";

#display the href rows
print OUT "$wwwString\n$rabbitString\n";

print OUT "</table>\n";

print "Done with $page\n\n";
} #end of page loop.


if($errorCount > 0)
{
   my $msg = $errorCount >= 2 ? "FOUND $errorCount ERRORS" : "FOUND AN ERROR";
   print OUT "<div class='error'><font class='error'>$msg</font></div>";
}

print OUT "</body>\n</html>\n";

close(OUT);

0; #end of main script.
