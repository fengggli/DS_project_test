<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<%--  <c:set var="user" value="${userModel}" scope="session"></c:set>--%>
<fmt:setBundle basename="com.cs537.nl.resources.FiveInARow"/>
<html>
<head>

	<title>
		Five In a Row
	</title>
	
	<!-- Bootstrap Core CSS -->
    <link href="http://www.tutorialspoint.com/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/css/form.css" rel="stylesheet">
	<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
	<link href="${pageContext.request.contextPath}/css/main.css" rel="stylesheet">
	
	<!-- jQuery -->
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js" type="text/javascript"></script>
	<!-- <script type="application/javascript" src="https://api.ipify.org?format=jsonp&callback=getIP"></script> -->
</head>
<body>
	
	<form id="game" action="${pageContext.request.contextPath}/GameController" method="post">
	
	<input type="hidden" id="playerName" value="${user.firstname }"/>
	
		<nav class="navbar navbar-inverse">
  			<div class="container-fluid">
   	 			<div class="navbar-header">
      				<a class="navbar-brand" href="#">Welcome ${user.firstname }!</a>
    			</div>
    			
    			<ul class="nav navbar-nav navbar-right">
      				<li><a href="javascript:logout();"><span class="glyphicon glyphicon-log-out"></span> Logout</a></li>
   	 			</ul>
   	 			
  			</div>
		</nav>
		
		<br>
		<br>
		<br>
		
		<table id="grid">
		
		<tr>
			<td>
				<table id="gomoku">
				<caption id="gameStatus" align="top" style="color: white; font-size: 20px; margin-bottom: 20px">Waiting for an opponent to join!</caption>
					<c:forEach var="i" begin="0" end="18">
						<tr>
							<c:forEach var="j" begin="0" end="18">
								<td id="${i }-${j }" >&nbsp;</td>
							</c:forEach>
						</tr>
					</c:forEach>	
				</table>
			</td>
			
			<td>
				<div id="result">
					Result
						<div id="score">
							<span id="BLACK">0</span><span class="delimiter">:</span><span id="RED">0</span>
						</div>
						<div>
							<span id="namePlayer1">Player 1</span><span class="delimiter"></span><span id="namePlayer2">Player 2</span>
						</div>
				</div>
				
				<div id="control">
					<input type="button" style="color: white; background-color: black" id="startNewGameButton" value="Start New Game" onclick="startNewGame();">
				</div>

			</td>
		</tr>
	</table>
		
	<input type="hidden" id="selection" name="selection">
	<input type="hidden" id="gameEnd" name="gameEnd">
	
	</form>
	
	<script type="text/javascript">
	
	var WAITING_FOR_OPPONENT = "Waiting for an opponent to join the game!"
	var OPPONENT_DISCONNECTED = "OPPONENT HAS DISCONNECTED. CLICK ON START NEW GAME TO CONTINUE"

	var MESSAGE_SETUP = "SETUP";
	var MESSAGE_CHANCE = "CHANCE";
	var MESSAGE_MOVE_UPDATE = "MOVE_UPDATE";
	var MESSAGE_WINNER = "WINNER";
	var MESSAGE_TIE = "TIE";
	var MESSAGE_LOGOUT = "LOGOUT"
	var MESSAGE_NEW_GAME = "NEW_GAME";
	
	var GAME_YOUR_TURN = "YOUR_TURN";
	var GAME_OPPONENT_TURN = "OPPONENT_TURN";
	
	var PLAYER_BLACK = "BLACK";
	var PLAYER_RED   = "RED";
	
	var WINNER_MESSAGE = "YOU WON! CLICK ON START NEW GAME TO CONTINUE";
	var LOSER_MESSAGE = "YOU LOST! CLICK ON START NEW GAME TO CONTINUE"
	var TIE_MESSAGE = "The game ended in a TIE! Well Played!"
	
	//var websocket = new WebSocket("ws://localhost:8080/fiveinarow/gamesocket");
	var websocket;
	websocket = new WebSocket("ws://localhost:8080/FiveInARow/gamesocket");
	
	var winner;
	var loser;
	


	// Disable the table until game starts
	disableTable();

	var gameId;
	var player;
	var opponent;
	
	var playerName = document.getElementById("playerName");
	
	var gameStatus = document.getElementById("gameStatus");
	
	var playerBlack = document.getElementById("namePlayer1");
	var playerRed = document.getElementById("namePlayer2");
	
	var gameButton = document.getElementById("startNewGameButton");
	
	var gameEnd = document.getElementById("gameEnd");
	
	gameButton.disabled = true;
	
	var i;
	var j;
	
	var d;
	
	var time_1;
	var time_2;
	var flag = 0;
	
	websocket.onopen = function onOpenEvent(msg){
		gameStatus.innerHTML = WAITING_FOR_OPPONENT;
	}
	

	websocket.onmessage = function onMessageEvent(msg){
		
		//alert("A message has been received!");
		
		var message = JSON.parse(msg.data);
		
		// Setting the game id and player colors
		if(message.messageType == MESSAGE_SETUP){
			
			gameId = message.gameId;
			player = message.player;
			
			//alert("Game ID = "+gameId);
			//alert("Player color = "+player);
			
			if(player == PLAYER_BLACK){
				opponent = PLAYER_RED;
				playerBlack.innerHTML = playerName.value;
				i = 0;
				j = 0;
				console.log("I am player black");
				//playerRed.innerHTML = "Opponent";
			}else{
				opponent = PLAYER_BLACK;
				//playerBlack.innerHTML = "Opponent";
				playerRed.innerHTML = playerName.value;
				i = 0;
				j = 1;
				console.log("I am player red");
			}
			
		}
		
		
		// Server sends the details to the players regarding who starts the game
		if(message.messageType == MESSAGE_CHANCE){
			if(message.status == GAME_YOUR_TURN){
				gameStatus.innerHTML = GAME_YOUR_TURN;
				enableTable();
				
				
				// don't need to click
				
				setTimeout(function(){
					play(i,j);
					
					// add timer start here
					d = new Date();
					time_1 = d.getTime();
					flag = 1;
					
					// next position
					i += Math.floor((j+2)/19);
					j = (j+2)%19;
					console.log("player" + player + " placed in (" +  i + "," + j + ")");
			    }, 1000); 
				
			
			}else{
				
				// timer end here
				if(flag == 1){
					d = new Date();
					time_2 = d.getTime();
					var h = d.getHours();
				    var m = d.getMinutes();
				    var s = d.getSeconds();
					console.log("time2 "+ h+":"+m+":"+s);
					
					console.log("time1:" + time_1 + " time eclapsed: " + (time_2-time_1) + " milliseconds");
					
					//we want to get the average
					console.log("# " + (time_2-time_1));
				}
				gameStatus.innerHTML = GAME_OPPONENT_TURN;
				disableTable();
			}	
		}
		
		
		if(message.messageType == MESSAGE_MOVE_UPDATE){
			var cell = document.getElementById(message.x+"-"+message.y);
			if(player == PLAYER_BLACK){
				cell.innerHTML="<img src='${pageContext.request.contextPath}/images/red.png'/>";
			}else{
				cell.innerHTML="<img src='${pageContext.request.contextPath}/images/black.png'/>";
			}
		}
		
		if(message.messageType == MESSAGE_WINNER){
			
			winner = document.getElementById(player);
			loser = document.getElementById(opponent);
			
			if(player == message.player){
				gameStatus.innerHTML = WINNER_MESSAGE;
				var score = winner.innerHTML;
				score++;
				winner.innerHTML = score;
				
			}else{
				gameStatus.innerHTML = LOSER_MESSAGE;
				var score = loser.innerHTML;
				score++;
				loser.innerHTML = score;
			}
			gameEnd.value = "gameEnd";
			gameButton.disabled = false;
		}
		
		if(message.messageType == MESSAGE_TIE){
			gameStatus.innerHTML = TIE_MESSAGE;
		}
		
	}
	
	function play(a,b){
		// Get the cell for the corresponding row and col
		var cell = document.getElementById(a+"-"+b);
		console.log("try to access  in (" + a + "," + b, ")");
		
		if(cell.innerHTML=="&nbsp;"){
			console.log("place in (" + a + "," + b, ")");
			// Disable the table for current player
			disableTable();
			//gameStatus.innerHTML = GAME_OPPONENT_TURN;
			if(player == PLAYER_BLACK){
				cell.innerHTML="<img src='${pageContext.request.contextPath}/images/black.png'/>";
			}else{
				cell.innerHTML="<img src='${pageContext.request.contextPath}/images/red.png'/>";
			}
			// Need to send the information to websocket
			sendMessage(a, b, MESSAGE_MOVE_UPDATE);
		}
	}
	
	function sendMessage(a, b, message_type){
		var message = {gameId: gameId, player: player, x: a, y:b, messageType: message_type};
		var formattedMessage = JSON.stringify(message);
		websocket.send(formattedMessage);
	}
	
	function disableTable() {
		 for(var i=0; i<19; i++){
			 for(var j=0; j<19; j++){
				 document.getElementById(i+"-"+j).style.pointerEvents = 'none';
			 }
		 }  
		/*var columns = document.getElementsByTagName("td");
		  for(var i=0;i<columns.length;i++){
			  columns[i].style.pointerEvents = 'none';
		  } */
	 }
	
	 function enableTable() {
		 for(var i=0; i<19; i++){
			 for(var j=0; j<19; j++){
				 document.getElementById(i+"-"+j).style.pointerEvents = 'auto';
			 }
		 }
		/*  var columns = document.getElementsByTagName("td");
		  for(var i=0;i<columns.length;i++){
			  columns[i].style.pointerEvents = 'auto';
		  }  */
	 }
	 
	 function startNewGame() {
		 resetGame();
		 sendMessage(0, 0, MESSAGE_NEW_GAME);
	 }
	 
	 function resetGame() {
		 gameStatus.innerHTML = WAITING_FOR_OPPONENT;
		 playerBlack.innerHTML = "Player 1";
		 playerRed.innerHTML = "Player 2";
		 winner.innerHTML = 0;
		 loser.innerHTML = 0;
		 
		 resetTable();
		 
	 }
	 
	 function resetTable(){
		 for(var i=0; i<19; i++){
			 for(var j=0; j<19; j++){
				 document.getElementById(i+"-"+j).innerHTML = "&nbsp;";
			 }
		 }
	 }
	
	function logout(){
		var selection = document.getElementById("selection");
		selection.value = "logout";
		sendMessage(0, 0, MESSAGE_LOGOUT);
		websocket.close();
		document.getElementById("game").submit();
	}
	
/* 	function getIP(json) {
	    alert("My public IP address is: ", json.ip);
	  } */
	
	
	</script>
	
	
</body>
</html>