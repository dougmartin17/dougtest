#!/usr/bin/perl
# @author  Raju Matta (matta@tripadvisor.com)
# @purpose originally written as dump_meta_tags.pl under tr/scripts, but
# modified and setup as cron job to run SEO tests against the redesigned 
# pages

use Text::Wrap;
use Time::Local;
use CGI;

$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';

#my $location = "/var/www/html/matta";
my $location = 'C:\Documents and Settings\doug\My Documents\perl';
my $filename = "SEOdiffs.html";
my $app_tripadvisor_file = "/home/site/trsrc-MAINLINE/config/webserver/app_tripadvisor.xml";

# separator in the keywords list
$sep = ",";
    
my @servletColors= (
    "#CCFF66", "#DDDDFF"
);

# parameterize some of the IDs
# 321151 --> jurys boston (Boston)
# 89585 --> four seasons (Boston)
# 85383 --> Marriott's Cypress Harbour (Orlando)
$bostongeo = 60745; # boston
$geo = 34515; # orlando
$hotel = 85383; 
$attraction = 104795; # boston common
$attraction = 102412; # Seaworld Adventure Park, Orlando 
#$restaurant = 321952; # kashmir restaurant 
$restaurant = 321906; # kashmir restaurant 
$seafoodrestaurant = 321969; # legal sea foods boston

# site and server
my @siteary = (
    "livesite", "www.tripadvisor.com",
    "bunny", "bunny.tripadvisor.com"
);

# header texts
my @htexts = (
    "h1text",
    "h2text",
    "h3text",
    "h4text",
    "h5text"
);

# servlet and partial URL array
my @servletary = (
    "Hotel Review", "/Hotel_Review-g$geo-d$hotel", 1, "Reviewed by both teams",
    "Show user reviews (hotel)", "/ShowUserReviews-g$geo-d$hotel-r8602436", 2, "Reviewed by both teams",
    "Hotels", "/Hotels-g$geo", 3, "Reviewed by both teams",
    "Attraction Detail", "/Attraction_Review-g$geo-d$attraction", 4, "Reviewed by both teams",
    "Show user reviews (attraction)", "/ShowUserReviews-g$geo-d104604-r8538569", 5, "Reviewed by both teams",
    "Restaurants", "/Restaurants-g$geo", 6, "Reviewed by both teams",
    "Show user reviews (restaurants)", "/ShowUserReviews-g$bostongeo-d$restaurant-r8275079", 7, "Reviewed by both teams",
    "Restaurant Detail", "/Restaurant_Review-g$bostongeo-d$seafoodrestaurant", 8, "Reviewed by both teams",
    "Tourism", "/Tourism-g$geo", 9, "Reviewed by both teams",
    "Traveler Article", "/Travel-g147247-s208/Aruba:Caribbean:Weather.And.When.To.Go.html", 10, "Not reviewed",
    "Know Before You Go", "/AllReviews-g187514-Madrid.html", 11, "Not reviewed",
    "Smart Deals", "/SmartDeals-g$geo-Orlando_Florida-Hotel-Deals.html", 12, "Not reviewed",
    "Discount Hotels", "/Discount_Hotels-g$geo-Orlando_Florida.html", 13, "Not reviewed",
    "Cheap Vacations", "/Cheap_Vacations-g$geo-Orlando_Florida.html", 14, "Not reviewed",
    "Packages", "/Packages-g$geo-Vacation-Package-Discount-Orlando_Florida.html", 15, "Not reviewed",
    "Show Forum", "/ShowForum-g$geo-i19-Orlando_Florida.html", 16, "Not reviewed",
    "Travel", "/Travel-g297604-s203/Goa:India:History.html", 17, "Not reviewed",
    "Home",  "", 18, "Reviewed by both teams",
    #"Show Forum Topic", "/ShowTopic-g47991-i11006-k994267-Anyone_with_JFK_shuttle_info_please-Kennedy_New_York.html", 19, "Reviewed by both teams",
    #"Flights", "/Flights-g34515-Orlando_Florida-Cheap_Discount_Airfares.html", 20, "Reviewed by both teams",
);

&printIndex(*servletary);
&mailIndex();

sub printIndex() 
{
    local (*servletary) = @_;
    print ">$location\\$filename";
    open INDEX, ">$location\\$filename" or die $!;
    my $stream = *INDEX;
    print $stream
    "<html>
    <head>
    <title>SEO comparison</title>
    </head>
    <body>
    <h1>SEO comparison of site redesigned pages</h1>";

    &printCompletedServletsHeader($stream);

    print $stream
    "<h3>Other SEO checks</h3>
    <a href=\"http://starfish.tripadvisor.com/matta/nofollowexceptions.html\">No Follow Exceptions</a><br>
    <a href=\"http://starfish.tripadvisor.com/matta/clearlinksdifference.html\">Clear links that are in either sites but not in both</a><br><br>
    ";

    &printTableHeaders($stream);
    &printSEOData($stream);
}

sub printSEOData()
{
    my ($stream) = @_;
    my $row = 0;
    # start the looping
    while (@servletary > 0)
    {
        $rowcolor = $servletColors[$row++ % 2 ];
        $servlet=shift(@servletary);
        $partialUrl=shift(@servletary);
        $id=shift(@servletary);
        $status=shift(@servletary);

        print "\n" . "------------- " . $servlet . " -------------";
        print "\n" . "partial URL -->" . $partialUrl . " (" . $status . ")";

        local $/;   # Set input to "slurp" mode.
        
        my @sitearytmp = @siteary;
        foreach (@sitearytmp) 
        {
            $site = shift (@sitearytmp);	
            $host = shift (@sitearytmp);	
            print "\n" . "     site & host --> " . $site . " & " . $host;
            print "\n" . "     --------------------------------------------\n";;

            $cmd = "wget -q -O - 'http://$host" . $partialUrl . "'";
            open(IN, "$cmd|") || die "cannot run $cmd: $!\n";
    
            my $doc = <IN>;            
            close IN;

            ($titletext) = $doc =~ /(?:<title>)?([^<>]+)<\/title>/igs;
            $escapedTitleText = CGI::escapeHTML($titletext);

            ($keywordstext) = $doc =~ /<meta name="?keywords"? content=((?:[\"][^\"]+[\"]?)|(?:[\'][^\']+[\']?)|(?:[A-Za-z0-9_\-]+))/igs; 
            $keywordstext =~ s/^[\'\"](.*)[\'\"]$/$1/g;
            $escapedKeywordsText = CGI::escapeHTML($keywordstext);

            # create this list.  we will need to check on page keywords
            # storing in a hash - easier to de-dup 
            %keywordsMap = map { ($_, 1 ) } split(/$sep /, lc($keywordstext));
            @listKeywords = keys %keywordsMap;

            @sortedListKeywords = sort {uc($a) cmp uc($b)} @listKeywords;

            my @keywordCount; 

            # docText holds no tags
            my $docText = $doc;
            $docText =~ s/\<[^\>]*\>/ /gs; 
            foreach (@sortedListKeywords) {
                my $words = $_;
                chomp $words; 
                $count = 0; 
                while ($docText =~ m/\b($words)\b/igs) {
                    $count++;
                }
                #print "     Keyword <" . $words . "> --> " . $count . "\n";
                push(@keywordCount,$words . " - " . $count);
            }

            ($descriptiontext) = $doc =~ /<meta name="?description"? content=((?:[\"][^\"]+[\"]?)|(?:[\'][^\']+[\']?)|(?:[A-Za-z0-9_\-]+))/igs; 
            $descriptiontext =~ s/^[\'\"](.*)[\'\"]$/$1/g;
            $escapedDescriptionText = CGI::escapeHTML($descriptiontext);

            @h1text = $doc =~ /\<h1[^\>]*\>(.+?)\<\/h1\>/igs;
            @h2text = $doc =~ /\<h2[^\>]*\>(.+?)\<\/h2\>/igs;
            @h3text = $doc =~ /\<h3[^\>]*\>(.+?)\<\/h3\>/igs;
            @h4text = $doc =~ /\<h4[^\>]*\>(.+?)\<\/h4\>/igs;
            @h5text = $doc =~ /\<h5[^\>]*\>(.+?)\<\/h5\>/igs;

            $url = "http://" . $host . $partialUrl;
            print $stream "\n";
            print $stream
            "<tr><td colspan=10><b>$servlet</b> - <a name=\"$id\" href=\"$url\">$url</a></td>
            <tr bgcolor=\"$rowcolor\" style=\"color:black;\">
            <td>$escapedTitleText</td>
            <td>$escapedKeywordsText</td>";


            &printKeywordCounts($stream, @keywordCount);

            print $stream "<td>$escapedDescriptionText</td>";
            
            &printHValues($stream, @h1text);
            &printHValues($stream, @h2text);
            &printHValues($stream, @h3text);
            &printHValues($stream, @h4text);
            &printHValues($stream, @h5text);

            print $stream "</tr>\n\n";
        }
    }
    print $stream "</table>\n";
    print $stream "</body></html>\n";

    close INDEX;
}

sub printTableHeaders()
{
    my ($stream) = @_;
    print $stream "<table border=1>";
    print $stream
    "<tr bgcolor=\"#FF99CC\" style=\"font-weight:bold;\">
    <th>Title</th>
    <th>Keywords</th>
    <th>Keyword Count</th>
    <th>Description</th>
    <th>H1</th>
    <th>H2</th>
    <th>H3</th>
    <th>H4</th>
    <th>H5</th>
    </tr>\n\n";
}


sub printCompletedServletsHeader()
{
    my ($stream) = @_;
    my $row = 0;
    print $stream "<h3>Completed Servlets are:</h3>";
    # start the looping
    for (my $sl = 0; $sl < @servletary; $sl += 4)
    {
        $servlet=$servletary[$sl];
        $id=$servletary[$sl+2];
        $status=$servletary[$sl+3];

        print $stream "
        <a href=\"#$id\">$servlet ($status)</a><br>";
    }
}

sub printKeywordCounts()
{
    my($stream,@keywordCount) = @_;
    print $stream "<td>";
    $n = 0;
    while ($keywordCount[$n]) {
        print $stream "<div style=\"line-height: 0.8em; border-bottom: 1px solid black\">$keywordCount[$n]</div>";
        $n++;
    }
    print $stream "</td>";
}

sub printHValues()
{
    my($stream,@htext) = @_;
    print $stream "<td>";
    $n = 0;
    while (@htext[$n]) {
        #$text = CGI::escapeHTML(@htext[$n]);
        print $stream "<div style=\"line-height: 0.8em; border-bottom: 1px solid black\">@htext[$n]</div>";
        $n++;
    }
    print $stream "</td>";
}

sub mailIndex()
{
    # mail the output
    open INPUT, "<$location/$filename" or die $!;
    undef $/;
    my $content = <INPUT>;
    #print $content;
    close INPUT;
    $/ = "\n";     #Restore for normal behaviour later in script

    open (OUT,"|/usr/sbin/sendmail -t");
    print OUT "From: root\@tripadvisor.com\n";
    #print(OUT "To: seo\@tripadvisor.com, flafleur\@tripadvisor.com, wasche\@tripadvisor.com, sdessureau\@tripadvisor.com, bbarkley\@tripadvisor.com, sugata\@tripadvisor.com, kpados\@tripadvisor.com, ccolebourn\@tripadvisor.com\n");
    print(OUT "To: matta\@tripadvisor.com\n");
    print(OUT "Subject: Redesign SEO testing\n");
    print(OUT "Mime-Version: 1.0\n");
    print(OUT "Content-Type:text/html; charset=\"iso-8859-1\"\n");
    print(OUT "\n");
    print(OUT "<h5>Also available <a
href='http://starfish.tripadvisor.com/matta/SEOdiffs.html'>here</a></h5>");
    print(OUT "$content");
    close(OUT);

};

exit 0;
