use strict;
use HTML::TreeBuilder;
use LWP::Simple;

#use display: none and display: show to hide data that is the same...

#$tree = HTML::TreeBuilder->new;
my $rootURLr = 'rabbit.tripadvisor.com';
my $rootURLw = 'www.tripadvisor.com';

my @tags = ('h1', 'h2', 'h3', 'h4', 'h5');

my @pages = (
   #generic
   '/VacationRentals-g60745',
   '/VacationRentalReview-g60745-d1436494-Spacious_North_End_Apartment-Boston_Massachusetts.html',
   #EU
   '/VacationRentals-g187323',
   '/VacationRentalReview-g187323-d1444056-Near_River_Spree_Tiergarten-Berlin.html',
   #apartments
   '/VacationRentals-g187147',
   #villas
   '/VacationRentals-g147262',
   #cabins
   '/VacationRentals-g44160',
   #beach
   '/VacationRentals-g30753'
#   '/',
#   #all boston LHN links
#   '/BusinessCenter',
#   '/BusinessCenter-g60745-Boston_Massachusetts.html',
#   '/BusinessCenter-g60745-t2-Boston_Massachusetts.html',
#   '/BusinessCenter-g60745-t3-Boston_Massachusetts.html',
#   '/BusinessCenter-g60745-t4-Boston_Massachusetts.html',
#
#   '/Hotels-g60745-Boston_Massachusetts-Hotels.html',
#   '/Flights-g60745-Boston_Massachusetts-Cheap_Discount_Airfares.html',
#   '/SmartDeals-g60745-Boston_Massachusetts-Hotel-Deals.html',
#   '/AllReviews-g60745-Boston_Massachusetts.html',
#   '/Attractions-g60745-Activities-Boston_Massachusetts.html',
#   '/Restaurants-g60745-Boston_Massachusetts.html',
#   '/LocalMaps-g60745-Boston-Area.html',
#   '/LocationPhotos-g60745-Boston_Massachusetts.html',
#   '/LocationPhotos-g60745-d321151-Jurys_Boston_Hotel-Boston_Massachusetts.html#18756198',
#   '/VideoGallery-g60745-Boston_Massachusetts.html',
#   '/ShowForum-g60745-i48-Boston_Massachusetts.html',
#   '/Discount_Hotels-g60745-Boston_Massachusetts.html',
#   '/Cheap_Vacations-g60745-Boston_Massachusetts.html',
#   '/Packages-g60745-Vacation-Package-Discount-Boston_Massachusetts.html',
#   #end of boston LHN links
#   
#   #Jurys Boston Hotel
#   '/Hotel_Review-g60745-d321151-Reviews-Jurys_Boston_Hotel-Boston_Massachusetts.html',
#   
#   #Atlantic Fish Company
#   '/Restaurant_Review-g60745-d321906-Reviews-Atlantic_Fish_Company-Boston_Massachusetts.html',
#   
#   #Freedom Trail
#   'http://rabbit.tripadvisor.com/Attraction_Review-g60745-d104604-Reviews-Freedom_Trail-Boston_Massachusetts.html',
#   
#   #Jurys review: "Great Hotel... Loved it!!!"
#   '/ShowUserReviews-g60745-d321151-r22578860-Jurys_Boston_Hotel-Boston_Massachusetts.html'

);
   my %wResults = ( 
      h1 => undef,
      h2 => undef,
      h3 => undef,
      h4 => undef,
      h5 => undef,
      numberoflinks => undef,
      pagesize => undef,
      title => undef,
      keywords => undef,
      description => undef
      );

   my %rResults = ( 
      h1 => undef,
      h2 => undef,
      h3 => undef,
      h4 => undef,
      h5 => undef,
      numberoflinks => undef,
      pagesize => undef,
      title => undef,
      keywords => undef,
      description => undef
      );

#start html output
print "<html><head>
<style>
td { width: 500px; vertical-align: top; }
tr { width: 100px; }
table{background-color: #F0F0F0;}
</style>
<title>SEO Comparison Results</title>
</head>
<body>";

#iterate through the pages specified
foreach my $page (@pages)
{


   my $rURL = "http://$rootURLr$page";
   my $rTree = HTML::TreeBuilder->new;
   
   #get the header info (used to get page length)
   my ($content_type, $rPS, $modified_time, $expires, $server) = head($rURL);
   $rResults{pagesize} = $rPS;
   
   #get the html and create the tree
   #rabbit first
   my $rContent = get($rURL);
   $rTree->parse($rContent);
 
   
   #get Meta keywords
   my $re = $rTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Keywords/i }  );
   $rResults{keywords} = $re->{content};
   
   #get meta description   
   $re = $rTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Description/i }  );
   $rResults{description} = $re->{content};


   #get title
   $rContent =~ /<title>(.+)<\/title>/;
   $rResults{title} = $1;
   #strip out production or prerelease
   $rResults{title} =~ s/PRODUCTION: |PRERELEASE: //;
   
   #get number of links
   my @rLinks = $rTree->find('a');

   $rResults{numberoflinks} = scalar(@rLinks);

   foreach my $tag (@tags)
   {
      #gather all the elments of the tag
      my @rElements = $rTree->find($tag);
      
      #we are going to create an array of results to deal with later
      #we are using +++ to split on later, we need to add first one to avoid trimming the first element later
      $rResults{$tag} = shift(@rElements)->as_trimmed_text if (@rElements);
      foreach my $e (@rElements)
      {
         $rResults{$tag} .= "+++" . $e->as_trimmed_text; 
      }

   }

   #delete trees for this page

#before we print results let's santize all the data to eliminate differences in #'s
sanatizeResults(\%rResults);

######
#print out results
######

   print "<h1>$page</h1>\n";
   #start the table
   print "<table border='1'>\n";

   
   #create the heading
   print "<tr><th>&nbsp;</th><th>$rootURLr</th></tr>";

   #print document length first
   #should be smaller than 50,000
   if ($rResults{pagesize} > 50000)
   {
      print "<tr bgcolor='red'>";
   }
   elsif ($rResults{pagesize} != $wResults{pagesize})
   {
      print "<tr bgcolor='yellow'>";
   }
   else
   {
      print "<tr>";
   }
   print "<th>Document Length</th><td>$rResults{pagesize}</td></tr>\n";
   
   #print number of links
   #Should also set a margin of error for red link if difference >10 or so.
   if($rResults{numberoflinks} > 250)
   {
      print "<tr bgcolor='red'>";
   }
   else
   {
      print "<tr>";
   }
   print "<th>Number Of Links</th><td>$rResults{numberoflinks}</td></tr>\n";
   print "<tr><th>Meta Description</th><td>$rResults{description}</td></tr>\n";
   print "<tr><th>Meta Keywords</th><td>$rResults{keywords}</td></tr>\n";
   print "<tr><th>Title</th><td>$rResults{title}</td></tr>\n";
   
   ###Print tags here
   foreach my $tag (@tags)
   {
      print "<tr><th>$tag</th><td>";

      #for now we are replacing the delimiters with breaklines.
      $rResults{$tag} =~ s/\+\+\+/<br>/g;
      print $rResults{$tag};
      print "</td></tr>";
   }
   
   
   #End table for current page
   print "</table>\n";
   
   #delete trees for this page
   $rTree->delete;
}#end foreachpage.


print "</body></html>";



exit 0; #end of script


##########
#This function changes any numbers (that uses , or . seperator) to the string XXX
##########

sub sanatizeResults
{
   my ($hashRef) = @_;
   $$hashRef{description} =~ s/[\d]+[,\.]?[\d]+/XXX/g;
   $$hashRef{keywords} =~ s/[\d]+[,\.]?[\d]+/XXX/g;
   $$hashRef{title} =~ s/[\d]+[,\.]?[\d]+/XXX/g;

   foreach my $tag (@tags)
   {
      $$hashRef{$tag} =~ s/[\d]+[,\.]?[\d]+/XXX/g;
   }
}

sub printTags
{
   my ($e, @rElements, @wElements);
   foreach my $tag (@tags)
   {
         #if the arrays don't match, then flag with yellow background
         #( join(",", @wElements) eq join(",", @rElements) ) ? print "<tr>" : print "<tr bgcolor='yellow'>";
         print "<tr><th>$tag</th>";
         
         #first www
         print "<td>";
         my $i = 0;
         if(! @wElements) { print "&nbsp;";}
         foreach my $e (@wElements)
         {
            $i % 2 ? print "<font color='red'>" : print "<font color='blue'>";
            print $e->as_trimmed_text . "<br>";
            print "</font>";
            $i++;
         }
         print "</td>\n";
         
         
         #now rabbit
         print "<td>";
         my $i = 0;
         if(! @rElements) { print "&nbsp;";}
         foreach my $e (@rElements)
         {
            $i % 2 ? print "<font color='red'>" : print "<font color='blue'>";
            print $e->as_trimmed_text . "<br>";
            print "</font>";
            $i++;
         }
         print "</td>\n";
         
         #end this tag's row
         print "</tr>\n";
         
      }#end foreach $tag
}