
var dice1 = 0, dice2 = 0;

var runningCount = 0;
function newGame()
{

}

function newGamePageLoad()
{
	//alert("Welcome, Starting a new game.\nDice are being rolled for you...");
	rollBothDice();
}

function confirmSelection (t)
{
	tiles = window.document.getElementById("tiles").getElementsByTagName("div");
	for(var i=0; i<tiles.length; i++)
	{
		if(tiles[i].className == 'selected')
		{
			tiles[i].className = 'used';
		}
	}
	runningCount = 0;
	t.style.visibility = 'hidden';
}

function selectTile (t)
{
	if (t.className == 'used')
	{
		exit;
	}
	if (t.className == 'selected')
	{
		runningCount = runningCount - parseInt(t.innerHTML);
		t.className = '';
	}
	else
	{
		runningCount = runningCount + parseInt(t.innerHTML);
		t.className = 'selected';
	}
	window.document.getElementById("runningCount").innerHTML = runningCount;
	if (runningCount== dice1+dice2)
	{
		window.document.getElementById("confirm").style.visibility = "visible";
	}
	else
	{
		window.document.getElementById("confirm").style.visibility = "hidden";
	}

}

function rollBothDice (t)
{
	var num1=Math.floor(Math.random()*6)+1;
	var num2=Math.floor(Math.random()*6)+1;
	window.document.getElementById("die1").innerHTML = num1;
	window.document.getElementById("die2").innerHTML = num2;
	window.document.getElementById("total").innerHTML = num1+num2;
	dice1 = num1;
	dice2 = num2;
}

function rollOneDie(t)
{
	var num1=Math.floor(Math.random()*6)+1;
	window.document.getElementById("die1").innerHTML = num1;
	window.document.getElementById("die2").innerHTML = "X";
	window.document.getElementById("total").innerHTML = num1;

	t.disabled = true;

	dice1 = num1;
	dice2 = undef;
}
