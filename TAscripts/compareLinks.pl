use strict;
use HTML::TreeBuilder;
use LWP::Simple;

my $debug = 0;

####this is the file to write output to
my $outputfile = 'comparelinks.html'; 

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestamp = sprintf "%02d/%02d/%4d %02d:%02d:%02d\n", $mon+1,$mday,$year+1900,$hour,$min,$sec;

#$tree = HTML::TreeBuilder->new;
my $rootURLr = 'rabbit.tripadvisor.com';
my $rootURLw = 'www.tripadvisor.com';

#use testServerPrefix so we can strip the dev info from URLs
my $testServerPrefix = 'rabbit';

#$testServerPrefix = 'web02mr';
$rootURLr = $testServerPrefix.'.tripadvisor.com';


#my $rootURLr = 'rabbit.tripadvisor.de';

my @pages = (
#'/Hotels-g32655-Los_Angeles_California-Hotels.html',
#'/Hotels-g186338-London_England-Vacations.html',
#'/Hotels-g48333-Oneonta_New_York-Hotels.html',
#'/Hotels-g191-United_States-Hotels.html'

#'/Hotel_Review-g31310-d73943-Reviews-Royal_Palms_Resort_and_Spa-Phoenix_Arizona.html',
#'/Hotel_Review-g60763-d224221-Reviews-Library_Hotel-New_York_City_New_York.html',
#'/Hotel_Review-g186338-d188961-Reviews-Hotel_41-London_England.html',
#'/ShowUserReviews-g186338-d188961-r75627314-Hotel_41-London_England.html',
#'/ShowUserReviews-g60763-d224221-r76699221-Library_Hotel-New_York_City_New_York.html',
#'/ShowUserReviews-g31310-d73943-r75783544-Royal_Palms_Resort_and_Spa-Phoenix_Arizona.html'

#   '/members/martind1',
   '/members-reviews/martind1',
   '/members-photos/martind1',
   '/members-videos/martind1',
   '/members-forums/martind1',
   '/members-inside/martind1',
   '/members-golists/martind1',
   
   
   #all boston LHN links
   '/BusinessCenter',
   '/BusinessCenter-g60745-Boston_Massachusetts.html',
   '/BusinessCenter-g60745-t2-Boston_Massachusetts.html',
   '/BusinessCenter-g60745-t3-Boston_Massachusetts.html',
   '/BusinessCenter-g60745-t4-Boston_Massachusetts.html',

   '/ShowForum-g60745-Boston_Massachusetts.html',
   #.fr showtopic
#   '/ShowTopic-g60763-i5-k2509575-Ou_voir_des_stars_a_New_York_et_autres_bonnes_adresses-New_York_City_New_York.html',
   '/ShowTopic-g60745-i48-k2597505-Boston_fall_colors_coast_drive_central_location-Boston_Massachusetts.html',
   '/ForumHome',
   '/ShowTopic-g60745-i48-k2591982-Hotel_Commonwealth_or_Nine_Zero-Boston_Massachusetts.html',
   
   '/Tourism-g60745-Boston_Massachusetts-Vacations.html',
	'/Hotels-g60745-Boston_Massachusetts-Hotels.html',
	'/Flights-g60745-Boston_Massachusetts-Cheap_Discount_Airfares.html',
	'/SmartDeals-g60745-Boston_Massachusetts-Hotel-Deals.html',
	'/AllReviews-g60745-Boston_Massachusetts.html',
	'/Attractions-g60745-Activities-Boston_Massachusetts.html',
	'/Restaurants-g60745-Boston_Massachusetts.html',
	'/LocalMaps-g60745-Boston-Area.html',
	'/LocationPhotos-g60745-Boston_Massachusetts.html',
   '/LocationPhotos-g60745-d1201116-Fairmont_Battery_Wharf-Boston_Massachusetts.html#23285825',
	'/VideoGallery-g60745-Boston_Massachusetts.html',
	'/ShowForum-g60745-i48-Boston_Massachusetts.html',
	'/Discount_Hotels-g60745-Boston_Massachusetts.html',
	'/Cheap_Vacations-g60745-Boston_Massachusetts.html',
	'/Packages-g60745-Vacation-Package-Discount-Boston_Massachusetts.html',
	#end of boston LHN links
   
   '/Travel-g60763-s401/New-York-City:New-York:Family.Travel.html',
   '/Travel-g60763-s201/New-York-City:New-York:Architecture.html',
   
	#Jurys Boston Hotel
	'/Hotel_Review-g60745-d321151-Reviews-Jurys_Boston_Hotel-Boston_Massachusetts.html',
	
	#Atlantic Fish Company
	'/Restaurant_Review-g60745-d321906-Reviews-Atlantic_Fish_Company-Boston_Massachusetts.html',
	
	#Freedom Trail
	'/Attraction_Review-g60745-d104604-Reviews-Freedom_Trail-Boston_Massachusetts.html',
	
	#Jurys review: "Great Hotel... Loved it!!!"
	'/ShowUserReviews-g60745-d321151-r22578860-Jurys_Boston_Hotel-Boston_Massachusetts.html',
   
   #vegas hotels page
   #'/Hotels-g45963-Las_Vegas_Nevada-Hotels.html',
   
   '/Tourism-g45963-Las_Vegas_Nevada-Vacations.html',
   
   '/Tourism-g41747-Norwell_Massachusetts-Vacations.html',
   '/Hotels-g48333-Oneonta_New_York-Hotels.html',

   
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
   
      #generic Vacation Rental stuff.
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
   
   '/'
);

#prep output html file
open (OUT, ">$outputfile");
print OUT "<html>\n";
print OUT "<head>\n";
print OUT "<title>Rabbit/WWW Link comparision</title>\n";
print OUT "<style>
      table{background-color: #F0F0F0;}
      tr#ok{display: none;}
      tr.nomatch{background-color: yellow}
      tr.bigchange{background-color: red}
      td.link{width: 500px;}
      td.data{width: 100px; text-align: right;}
      div.showhide{text-align:center; text-decoration:underline; cursor:pointer; padding:3px; font-size:20px; border: 1px solid; width:150px; background-color:#EDEDED;}
      
      span.showhide{background-color: #bdbdbd; 
         border: 2px solid #736F6E;
         font-size: 18px;}
      </style>\n";
      
print OUT "<script>
var state='none';
function showAlikeRows(t)
{
   if(state=='none')
   {
    state='table-row';
    t.innerHTML='HIDE alike rows';
   }
   else
   {
    state='none';
    t.innerHTML='SHOW alike rows';
   }

   sheets=document.styleSheets;
   for (var s=0;s<sheets.length;s++)
   {
      a=sheets[s].cssRules;



      //a=document.styleSheets[0].cssRules;

      for (var i in a)
      {

         if(a[i].selectorText == 'tr#ok' )
         {
            a[i].style.setProperty('display',state,'');
         }

      } //End for rules
   } //End for sheets

} //end showAlikeRows

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
} //end ShowHideTOC

</script>\n";

print OUT "</head>";
print OUT "<body>$timestamp<br>\n";


#show/hide TOC button
print OUT "<span class='showhide' onclick='ShowHideTOC(this)'>HIDE Table of Contents</span><br><br>";

printTableOfContents();


#display a show/hide button for alike rows
print OUT "<br><div class='showhide' onclick='showAlikeRows(this)'>SHOW alike rows</div><br>\n";

#iterate through the pages specified
foreach my $page (@pages)
{

print "Working on $page\n";
print OUT "<a name='$page' />\n";
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
   
   #get number of links
   my @wLinks = $wTree->find('a');
   my @rLinks = $rTree->find('a');
   
   print "w: number of links: " . scalar(@wLinks) . "\n";
   print "r: number of links: " . scalar(@rLinks) . "\n";
   
   my %wHash = parseLinks(@wLinks);
   my %rHash = parseLinks(@rLinks);
   my @masterHash = GetMasterLinkList(%wHash, %rHash);

   print OUT "WWW: number of links: " . scalar(@wLinks) . "<br>";
   print OUT "Rabbit: number of links: " . scalar(@rLinks) . "<br>";
   
   print OUT "<table border='1'>\n";

   print OUT "<tr>";
   print OUT "<th>Link</th>\n";
   print OUT "<th>$rootURLw</th>\n";
   print OUT "<th>$rootURLr</th>\n";
   print OUT "</tr>";

   foreach my $k ( sort @masterHash)
   {
      if ( !$wHash{$k} || !$rHash{$k} )
      {
         print OUT "<tr class='bigchange'>";
      }
#      elsif ( abs($wHash{$k}-$rHash{$k}) )
#      {
#         
#      }
      elsif ($wHash{$k} != $rHash{$k})
      {
         print OUT "<tr class='nomatch'>";
      }
      else
      {
         print OUT "<tr id='ok'>";
      }
      print OUT "<td class='link'>$k</td>";
      print OUT "<td class='data'>" . ($wHash{$k} || 'n/a') . "</td>";

      print OUT "<td class='data'>" . ($rHash{$k} || 'n/a') . "</td>";

      print OUT "</tr>";

   } #end foreach (masterhash)

   print OUT "</table>\n";

print "Done with $page\n\n";
} #end of page loop.

print OUT "</body>\n</html>\n";

close(OUT);

0; #end of main script.



#########################
# Subroutines
#########################

sub parseLinks
{
   my (@links) = @_;
   my %linkHash = ();
   foreach my $l (@links)
   {
      my $link = $l->attr('href');
         
      print "Original Link: $link\n" if $debug;
      #if it is an empty or nonexistent href
      if( ! $l->attr('href') )
      {
         $link = '!nohref!';
         my $linktext = $l->as_HTML();
         chomp( $linktext);
         print "!! no href!: [" . $linktext."]\n";
      }
      #if it is a relative link just get servlet name
      elsif ($link =~ /^\/(\w+-?)/ ) 
      {
            $link = $1;
      } #end elsif
      else #otherwise use the whole URL
      {
         if($link =~ /^(http:\/\/[\w\.-]+\/\w*)-?/)
         {$link = $1;}
                           
         $link =~ s/$testServerPrefix-//;
         $link =~ s/-$testServerPrefix//;
         $link =~ s/$testServerPrefix/www/;
         
         if($link =~ /doubleclick\.net/) {$link = 'doubleclick';}
      } #end else
      
      #if it has a nofollow then we tack that on the end
      if ( $l->attr('rel') )
      {
         $link = "$link+NOFOLLOW";
      }      
      $linkHash{$link}++;
      print "     End Link: $link\n" if $debug;

   } #end foreach
      
      

   return %linkHash;
} #end parseLinks




sub GetMasterLinkList
{
   my (%hash1, %hash2) = @_;
   my %masterHash = %hash1;
   foreach my $k (keys %hash2)
   {
      $hash1{$k}++;
   } #end foreach
   
   return keys(%masterHash);
} #end sub


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