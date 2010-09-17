use strict;
use HTML::TreeBuilder;
use LWP::Simple;

####this is the file to write output to
my $outputfile = 'compareseodata.html'; 

#we use this for the tag splitting
my $DELIMETER = ":::";
my $MAXPAGESIZE = '185000';
my $MAXLINKS = '250';

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = sprintf "%02d/%02d/%4d %02d:%02d:%02d\n", $mon+1,$mday,$year+1900,$hour,$min,$sec;

#$tree = HTML::TreeBuilder->new;
my $rootURLr = 'rabbit.tripadvisor.com';
my $rootURLw = 'www.tripadvisor.com';

my @tags = ('h1', 'h2', 'h3', 'h4', 'h5');

#+##############################################################################################
#Pages listed for testing
#########################
my @pages = (

   #Boston LHN Links   
   '/Tourism-g60745-Boston_Massachusetts-Vacations.html',
   '/Hotels-g60745-Boston_Massachusetts-Hotels.html',
   '/Flights-g60745-Boston_Massachusetts-Cheap_Discount_Airfares.html',
   '/SmartDeals-g60745-Boston_Massachusetts-Hotel-Deals.html',
   '/AllReviews-g60745-Boston_Massachusetts.html',
   '/Attractions-g60745-Activities-Boston_Massachusetts.html',
   '/Restaurants-g60745-Boston_Massachusetts.html',
   '/LocalMaps-g60745-Boston-Area.html',
   '/LocalMaps-g60745-d114134-The_Lenox_Hotel-Area.html',
   '/LocationPhotos-g60745-Boston_Massachusetts.html',
   '/LocationPhotos-g60745-d321151-Jurys_Boston_Hotel-Boston_Massachusetts.html#18756198',
   '/VideoGallery-g60745-Boston_Massachusetts.html',
   '/ShowForum-g60745-i48-Boston_Massachusetts.html',
   '/Discount_Hotels-g60745-Boston_Massachusetts.html',
   '/Cheap_Vacations-g60745-Boston_Massachusetts.html',
   '/Packages-g60745-Vacation-Package-Discount-Boston_Massachusetts.html',
   #end of boston LHN links
   
   '/Travel-g60745-c116275/Boston:Massachusetts:Ams.Free.Boston.Tours.html',
   
   
   #do new york LNH links as well for better coverage
   '/Tourism-g60763-New_York_City_New_York-Vacations.html',
   '/Hotels-g60763-New_York_City_New_York',
   '/Flights-g60763-New_York_City_New_York',
   '/SmartDeals-g60763-New_York_City_New_York',
   '/AllReviews-g60763-New_York_City_New_York',
   '/Attractions-g60763-New_York_City_New_York',
   '/Restaurants-g60763-New_York_City_New_York',
   '/LocalMaps-g60763-New_York_City_New_York',
   '/LocationPhotos-g60763-New_York_City_New_York',
   '/LocationPhotos-g60763-New_York_City_New_York',
   '/VideoGallery-g60763-New_York_City_New_York',
   '/ShowForum-g60763-New_York_City_New_York',
   '/Discount_Hotels-g60763-New_York_City_New_York',
   '/Cheap_Vacations-g60763-New_York_City_New_York',
   '/Packages-g60763-New_York_City_New_York',
   '/VacationRentals-g60763-Reviews-New_York_City_New_York-Vacation_Rentals.html',
   #end NYC LHN links
   #nyc A_R, R_R, H_R and /SUR page
   '/Hotel_Review-g60763-d113317-Reviews-Casablanca_Hotel-New_York_City_New_York.html',
   '/ShowUserReviews-g60763-d113317-r46878290-Casablanca_Hotel-New_York_City_New_York.html',
   '/Restaurant_Review-g60763-d778986-Reviews-Patzeria_Perfect_Pizza_Inc-New_York_City_New_York.html',
   '/ShowUserReviews-g60763-d778986-r46630090-Patzeria_Perfect_Pizza_Inc-New_York_City_New_York.html',
   '/Attraction_Review-g60763-d1174408-Reviews-Real_New_York_Tours-New_York_City_New_York.html',
   '/ShowUserReviews-g60763-d1174408-r46774304-Real_New_York_Tours-New_York_City_New_York.html',


   #B&Bs
   '/Hotels-g60745-c2-Boston_Massachusetts-Hotels.html',
   #Specialty lodging
   '/Hotels-g60745-c3-Boston_Massachusetts-Hotels.html',

   '/members/martind1',
   '/members-reviews/martind1',
   '/members-photos/martind1',
   '/members-videos/martind1',
   '/members-forums/martind1',
   '/members-inside/martind1',
   '/members-golists/martind1',
   
   
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
   '/VacationRentals-g30753',   
   

   '/BusinessCenter',
   '/BusinessCenter-g60745-Boston_Massachusetts.html',
   '/BusinessCenter-g60745-t2-Boston_Massachusetts.html',
   '/BusinessCenter-g60745-t3-Boston_Massachusetts.html',
   '/BusinessCenter-g60745-t4-Boston_Massachusetts.html',


   '/ForumHome',
   '/ShowForum-g60745-Boston_Massachusetts.html', 
   '/ShowTopic-g60745-i48-k2801549-Driving_fears_around_South_Station-Boston_Massachusetts.html',

   #USA hotels page
   '/Hotels-g191-United_States-Hotels.html',
   #massachusetts hotels
   '/Hotels-g28942-Massachusetts-Hotels.html',

   
	#Jurys Boston Hotel
	'/Hotel_Review-g60745-d321151-Reviews-Jurys_Boston_Hotel-Boston_Massachusetts.html',

	#Atlantic Fish Company
	'/Restaurant_Review-g60745-d321906-Reviews-Atlantic_Fish_Company-Boston_Massachusetts.html',
	
	#Freedom Trail
	'/Attraction_Review-g60745-d104604-Reviews-Freedom_Trail-Boston_Massachusetts.html',
	
	#Jurys review: "Great Hotel... Loved it!!!"
	'/ShowUserReviews-g60745-d321151-r22578860-Jurys_Boston_Hotel-Boston_Massachusetts.html',



'/'   #always end with empty test so that we don't need to worry about missing commas
); #end of pages array
#+##############################################################################################

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

open (OUT, ">$outputfile");
#start html output
print OUT "<html><head>

<style>
td { width: 500px; vertical-align: top; }
tr { width: 100px; }
tr.nomatch{background-color: yellow} 
tr.alert{background-color: red}
font.nomatch{background-color: yellow}
table{background-color: #F0F0F0;}
span.showhide{background-color: #bdbdbd; 
   border: 2px solid #736F6E;
   font-size: 18px;
   }
</style>

<script>
function ShowHideTOC(t)
{
   currVal = document.getElementById('TOC').style.display;

   if (currVal == 'none')
   {
      document.getElementById('TOC').style.display = '';
      t.innerHTML = 'HIDE Table of Contents';
   }
   else
   {
      document.getElementById('TOC').style.display = 'none';
      t.innerHTML = 'SHOW Table of Contents';
   }
}
</script>

<title>SEO Factors Comparison Results</title>
</head>
<body>";

print OUT "$timestamp<br>\n";

#show/hide TOC button
print OUT "<span class='showhide' onclick='ShowHideTOC(this)'>HIDE Table of Contents</span><br>";

printTableOfContents();

#message to console to show starting
print "Beginning to analyze pages...\n";

#iterate through the pages specified
foreach my $page (@pages)
{

   #another message for console
   print "Working with $page\n";
   
	my $rURL = "http://$rootURLr$page";
	my $wURL = "http://$rootURLw$page";
	
   my	$rTree = HTML::TreeBuilder->new;
   my	$wTree = HTML::TreeBuilder->new;
	
	#get the header info (used to get page length)
	my ($content_type, $rPS, $modified_time, $expires, $server) = head($rURL);
	my ($content_type, $wPS, $modified_time, $expires, $server) = head($wURL);
   $rResults{pagesize} = $rPS;
   $wResults{pagesize} = $wPS;
   
	#get the html and create the tree
	#rabbit first
	my $rContent = get($rURL);
	$rTree->parse($rContent);
	#then www
	my $wContent = get($wURL);
	$wTree->parse($wContent);
	
	
	#get Meta keywords
	my $we = $wTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Keywords/i }  );
	my $re = $rTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Keywords/i }  );
   $wResults{keywords} = $we->{content};
   $rResults{keywords} = $re->{content};
   
	#get meta description	
	$we = $wTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Description/i }  );
	$re = $rTree->look_down(sub { $_[0]->tag() eq 'meta' and $_[0]->attr('name') =~ /Description/i }  );
   $wResults{description} = $we->{content};
   $rResults{description} = $re->{content};


	#get title
	$wContent =~ /<title>(.+)<\/title>/;
   $wResults{title} = $1;
   $rContent =~ /<title>(.+)<\/title>/;
   $rResults{title} = $1;
   #strip out production or prerelease
   $wResults{title} =~ s/PRODUCTION: |PRERELEASE: //;
   $rResults{title} =~ s/PRODUCTION: |PRERELEASE: //;
   
	#get number of links
   my @wLinks = $wTree->find('a');
   my @rLinks = $rTree->find('a');

   $wResults{numberoflinks} = scalar(@wLinks);
   $rResults{numberoflinks} = scalar(@rLinks);

	foreach my $tag (@tags)
	{
		#gather all the elments of the tag
		my @wElements = $wTree->find($tag);
		my @rElements = $rTree->find($tag);
      
      #we are going to create an array of results to deal with later
      #we are using +++ to split on later, we need to add first one to avoid trimming the first element later
      $wResults{$tag} = shift(@wElements)->as_trimmed_text if (@wElements);
      foreach my $e (@wElements)
      {
         $wResults{$tag} .= $DELIMETER . $e->as_trimmed_text;   
      }
      $rResults{$tag} = shift(@rElements)->as_trimmed_text if (@rElements);
      foreach my $e (@rElements)
      {
         $rResults{$tag} .= $DELIMETER . $e->as_trimmed_text; 
      }

   }

	#delete trees for this page

#before we print results let's santize all the data to eliminate differences in #'s
sanatizeResults(\%wResults);
sanatizeResults(\%rResults);

#message for console
print "Writing output for $page...\n";

######
#print out results
######

   print OUT "<a name='$page' />\n";
   print OUT "<h1>$page</h1>\n";
	#start the table
   print OUT "<table border='1'>\n";

   
	#create the heading
   print OUT "<tr><th>&nbsp;</th><th>$rootURLw</th><th>$rootURLr</th></tr>";
   #print document length first
   #should be smaller than 50,000
   ($rResults{pagesize} > $MAXPAGESIZE) ? print OUT "<tr class='alert'>" : print OUT "<tr>";

   
   print OUT "<th>Document Length</th><td>$wResults{pagesize}</td><td>$rResults{pagesize}</td></tr>\n";
   #print number of links
   #Should also set a margin of error for red link if difference >10 or so.
   ($rResults{numberoflinks} > $MAXLINKS) ? print OUT "<tr class='alert'>" : print OUT "<tr>";
   
   print OUT "<th>Number Of Links</th><td>$wResults{numberoflinks}</td><td>$rResults{numberoflinks}</td></tr>\n";
   
   ($wResults{description} eq $rResults{description}) ? print OUT "<tr>" : print OUT "<tr class='nomatch'>";
   print OUT "<th>Meta Description</th><td>$wResults{description}</td><td>$rResults{description}</td></tr>\n";
   
   ($wResults{keywords} eq $rResults{keywords}) ? print OUT "<tr>" : print OUT "<tr class='nomatch'>";
   print OUT "<th>Meta Keywords</th><td>$wResults{keywords}</td><td>$rResults{keywords}</td></tr>\n";

   ($wResults{title} eq $rResults{title} ) ? print OUT "<tr>" : print OUT "<tr class='nomatch'>";
   print OUT "<th>Title</th><td>$wResults{title}</td><td>$rResults{title}</td></tr>\n";
   
   ###Print tags here
   foreach my $tag (@tags)
   {
      print OUT "<tr><th>$tag</th><td>";
      #we run though w and check it against r
      foreach my $t ( split($DELIMETER,$wResults{$tag}) )
      {
         ($rResults{$tag} =~ /\Q$t\E/) ? print OUT "$t<br>" : print OUT "<font class='nomatch'>$t</font><br>";
      }
      print OUT "</td><td>";
      #we run though r and check it against w list.
      foreach my $t ( split($DELIMETER,$rResults{$tag}) )
      {
         ($wResults{$tag} =~ /\Q$t\E/) ? print OUT "$t<br>" : print OUT "<font class='nomatch'>$t</font><br>";
      }
      print OUT "</td></tr>";
   }
   
	
	#End table for current page
   print OUT "</table>\n";

#message for console for done with page.
print "Done outputting for $page\n";

   #delete trees for this page
   $rTree->delete;
   $wTree->delete;
   %wResults = ( 
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

    %rResults = ( 
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
}#end foreachpage.


print OUT "</body></html>";

close(OUT);

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

sub printTableOfContents
{
   my $numOfPages = $#pages + 1;
   
   print OUT "<table id='TOC' border=1><th colspan='4'>Table Of Contents</th>\n";
   for(my $i=0; $i < $numOfPages; $i += 4) 
   #foreach my $p (@pages)
   {
      print OUT "<tr>";
      print OUT "<td width='25%'><a href='#".$pages[$i]."'>$pages[$i]</a></td>";
      print OUT "<td width='25%'><a href='#".$pages[$i+1]."'>$pages[$i+1]</a></td>";
      print OUT "<td width='25%'><a href='#".$pages[$i+2]."'>$pages[$i+2]</a></td>";
      print OUT "<td width='25%'><a href='#".$pages[$i+3]."'>$pages[$i+3]</a></td>";
      print OUT "</tr>";
   }
   print OUT "</table>\n";
}