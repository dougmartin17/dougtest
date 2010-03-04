var p1scores, p2scores;

function runme()
{
var randomNumber = Math.floor(Math.random()*100);
window.alert( "New Random Number is " + randomNumber);
}

function resetScores()
{
	for(var i=14; i<=20; i++)
	{
		p1scores[i]=0;
		p2scores[i]=0;
		window.alert(i);
	}
}

function updateScores()
{

}

function tryThis(ref, score)
{
	window.alert(ref.id + '-blah-' + score);
}