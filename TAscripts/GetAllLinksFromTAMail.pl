#start by checking for options
use Getopt::Std;
%options=();
getopts("s:",\%options);
#s is the string to search subject for
print "Search string: $options{s}\n" if defined $options{s};
my $searchstring = (defined $options{s}) ? $options{s}: undef;
print "string: [$searchstring]\n";

#for sending the e-mail
use Net::SMTP;

#for getting the imapmails
use Mail::IMAPClient;
use IO::Socket::SSL;

#for getting links final destinations
use HTML::Parser;
use LWP::UserAgent; #needed for getFinalURL function

my @messages = (); 
if (! $searchstring){@messages = manuallySelectEmail();}
else {@messages = getAllMessagesBySubject($searchstring)};


print "Parsing the e-mail (this may take some time) ...\n";
#$message =~ /(TA_VER_ID.+TA_VER_ID)/;
#print "this id: $1\n";

my $emailText = "";
$emailText .= "<html><head><title>Doug's Script results</title>\n
	<style>
	td{overflow:hidden; width: 300px; border-style: dotted;}
	td div:hover{overflow:visible; background-color:lightgrey;}  </style>\n
	</head>\n<body><h2>Script Results</h2>";

foreach my $m (@messages)
{
   print "processing ".$m->{subject}."...\n";
   my $p = new parseHTMLForLinks;

   $emailText .= "<h2>" . $m->{subject} . "</h2>\n";
   $emailText .= "<table border='1' style='table-layout: fixed; width: 300px;'>";

   #TIMESTAMP FOR TESTING --REMOVE
   ($sec,$min,$hour,$mday,$mon,$year,$wday,
   $yday,$isdst)=localtime(time);
   printf "Start parse: %4d-%02d-%02d %02d:%02d:%02d\n",
   $year+1900,$mon+1,$mday,$hour,$min,$sec;

   $p->parse($m->{messagetext});

   #TIMESTAMP FOR TESTING --REMOVE
   ($sec,$min,$hour,$mday,$mon,$year,$wday,
   $yday,$isdst)=localtime(time);
   printf "\nEnd Parse: %4d-%02d-%02d %02d:%02d:%02d\n",
   $year+1900,$mon+1,$mday,$hour,$min,$sec;


   $emailText .= $p->getParsedText();
   $emailText .= "</table><br>\n";

   #reset parseHTMLForLinks for next pass. 
   $p->reset();   
}

$emailText .= "</body>\n</html>";

print "Finished parsing the e-mail.\n";

print "Sending the e-mail,..\n";
sendTAMail ('Dougs Script <dmartin+from@tripadvisor.com>', 'dmartin+to@tripadvisor.com', 'doug test subject', $emailText);
print "Sent the e-mail.\n";

print "\nDone\n";

#end program
exit 0;


#+##########################################
#Start Functions
############################################

#+##########################################
#Return all messages that contain the search string in the subject
############################################
sub getAllMessagesBySubject
{
	my ($search) = @_;
		
	my $imapclient = connectToIMAP();

	$imapclient->select('INBOX') or die 'select(INBOX): ' . $imapclient->LastError();


	my $mc = $imapclient->message_count('INBOX');
	print "There are $mc messages in the INBOX\n";

	#have to check for 0 messages here.
	my @msgs = $imapclient->messages or die "Could not get messages: $@\n";

	my @matchedMessages = ();

	foreach my $msgNum (@msgs)
	{
      
		my $headers = $imapclient->parse_headers($msgNum, "Subject") or die 'parse_headers: '. $imapclient->LastError();

		my $subj = join(' ', @{$headers->{'Subject'}} );
		if( $subj =~ /$search/ )
		{
			print "MATCHED: $subj\n";
			my $mt = $imapclient->message_string($msgNum) or die 'message_string: '. $imapclient->LastError();

         #we are sending a hash back with a subject and the message text
         push @matchedMessages, {subject => $subj, messagetext => $mt};
		}
		
	
	}

	disconnectIMAP($imapclient);

	return @matchedMessages;

}

#+##########################################
#This function allows user to select message manually
#This is used when -s STRINGVAL is not used on command line
############################################
sub manuallySelectEmail
{
	#run sub to get headers
	my @taMsgs = getTAHeaders();

	print "Enter a message number above: ";
	my $resp = <STDIN>;
	chomp $resp;
	print "You selected [$resp]\n";

	if ($resp =~ /[^\d]/) { print STDERR "did not provide a numeric response"; }

	print "fetching actual id of " . $taMsgs[$resp] . "\n";

	#run sub to get actual message and return it.
	return getTAMessage($taMsgs[$resp]);
}

#+##########################################
#Get the individual message content as specified
############################################
sub getTAMessage
{
	my ($messageNumber) = @_;	

	my $imapclient = connectToIMAP();

	$imapclient->select('INBOX') or die 'select(INBOX): ' . $imapclient->LastError();

	my $mt = $imapclient->message_string($messageNumber) or die 'message_string: '. $imapclient->LastError();

	return $mt;
}

#+##########################################
#Here we capture the current messages in the inbox
############################################
sub getTAHeaders
{
	my $imapclient = connectToIMAP();
	
	$imapclient->select('INBOX') or die 'select(INBOX): ' . $imapclient->LastError();
	
	
	my $mc = $imapclient->message_count('INBOX');
	print "There are $mc messages in the INBOX\n";
	
#have to check for 0 messages here.
	my @msgs = $imapclient->messages or die "Could not get messages: $@\n";

	my $count = 0;

	#first we display all the messages
	foreach my $m (@msgs)
	{
		my $headers = $imapclient->parse_headers($m, "Subject") or die 'parse_headers: '. $imapclient->LastError();

	#	my $mt = $imapclient->message_string($m) or die 'message_string: '. $imapclient->LastError();

		#This might be ugly but we get a reference to an array which 
		#we than join (in case there is two subj for some reason)
		printf ("Msg %-3d: ",$count);
		print join(' ', @{$headers->{'Subject'}} ) . "\n";

		$count++;	
	}

	disconnectIMAP($imapclient);
	
	return @msgs;
}





#+##########################################
#This will send a message. Pass the From, To, subject, data
############################################
sub sendTAMail
{
	my ($from, $to, $subject, @data) = @_;


	print "Sending a mail from:$from\nto:$to\n\n";


	my $smtp = Net::SMTP->new ("webmail.tripadvisor.com") or die "unable to create SMTP\n";

	$smtp->mail($from) or die "unable to set from\n";

	$smtp->recipient($to) or die "unable to set recip\n";

	$smtp->data() or die "unable to start data send";

	#create message headers
	$smtp->datasend("Content-Type: text/html\nFrom: $from\nTo: $to\nSubject: link summary e-mail\n\n");
	
	$smtp->datasend( join('\n', @data) ) or die "unable to send data\n";

	$smtp->dataend() or die "unable to end data send";

	$smtp->quit;
}

#+##########################################
#Connect to TA IMAP server
############################################
sub connectToIMAP
{
	# Connect to the IMAP server via SSL and get rid of server greeting message
	my $socket = IO::Socket::SSL->new(
	   PeerAddr => 'webmail.tripadvisor.com',
	   PeerPort => 993,
	  )
	  or die "socket(): $@";
	my $greeting = <$socket>;
	my ($id, $answer) = split /\s+/, $greeting;
	die "problems logging in: $greeting" if $answer ne 'OK';


	# Build up a client attached to the SSL socket and login
	$client = Mail::IMAPClient->new(
	   Socket   => $socket,
	   User     => 'outlook@tripadvisor.com',
	   Password => 'hemway',
	  )
	  or die "new(): $@";

	$client->State(Mail::IMAPClient::Connected());
	$client->login() or die 'login(): ' . $client->LastError();
	
	return $client
}

#+##########################################
#Disconnect from TA IMAP server
############################################
sub disconnectIMAP
{
	my ($client) = @_;

	# Say bye
	$client->logout();
	
}


#+##########################################
#All below this is for creating a html parser that returns links
############################################
package parseHTMLForLinks;

#local( $| ) = ( 1 );

my $a_flag = 0;
my $a_text = "";
my $parsedText = "";

#reset the variables for another parsing.
sub reset
{
   $a_flag = 0;
   $a_text = "";
   $parsedText = "";
}

#this returns the text that we have parsed the links out of (and put into a table)
sub getParsedText
{
	return $parsedText;
}

use base "HTML::Parser";

sub start
{
	my ($self, $tag, $attr, $attrseq, $origtext) = @_;
	#if($origtext =~ /<a/){ print $origtext . "\n";}
	if ($a_flag) {$a_text .= $origtext;}
	
	if ($tag =~ /^a$/i)
	{
		$a_flag = 1;
		my $URL = $attr->{href};
		$a_text .= "<tr><td><div><a href='$URL'>$URL</a></div></td>";
		
		my $endURL = getFinalURL($URL);
		if($endURL)
		{
			$a_text .= "<td><div><a href='$endURL'>$endURL</a></div></td>";
		}
		else
		{
			$a_text .= "<td><div><font style='color: red; font-size: 120%;'>UNABLE TO RESOLVE LINK</font></div></td>";
		}
		$a_text .= "<td><div>";
	}
} #end start

sub text {
	my ($self, $text) = @_;
	#print $text;
	if ($a_flag)
	{
		$a_text .= $text;
	}
} #end text

sub end
{
	my ($self, $tag, $origtext) = @_;
	#print $origtext;
	
	if ($tag =~ /^a$/i)
	{
		#print "++ $tag ++\n";
		#print "$a_text</div></td></tr>\n\n";
		$parsedText .= "$a_text</div></td></tr>\n\n";
		$a_flag = 0;
		$a_text = "";
	}
	if ($a_flag) {$a_text .= $origtext;}
print STDOUT ".";
} #end end

#+##########################################
#This returns the final URL after going through redirects
############################################
sub getFinalURL
{
	#get URL that was passed.
	my ($URL) = @_; 

	$ua = LWP::UserAgent->new();
	my $response = $ua->head($URL);
		
	#get the base URL from last request
	
	($response->is_success ) ? return $response->base : return undef;
}


