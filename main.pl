% *** The predicates below allow us to launch the game. ***


% Includes
:- include('./list.pl').
:- include('./matrix.pl').
:- include('./board.pl').
:- include('./beginning.pl').
:- include('./clean.pl').
:- include('./pieces.pl').
:- include('./utilities.pl').


% To start the game.
% Use:
% | ?- start.
% 1) Humain vs Humain
% 2) Humain vs Machine
% 3) Machine vs Machine
% 4) Bye
% Veuillez saisir votre choix : (1/2/3/4)
% 4.
% 
% Au revoir
% 
% yes
start :- repeat, menu, !.

% To display the menu and manage the choice of the user.
menu :- 	write('1. Humain vs Humain'), nl,
			write('2. Humain vs Machine'), nl,
			write('3. Machine vs Machine'), nl,
			write('4. Bye'), nl,
			write('Veuillez saisir votre choix (1.|2.|3.|4.) : '),
			read(Choice), nl, 
			choice(Choice),
			Choice=4, nl.

% To manage the choice of the user.
choice(1) :- 	write('*** Humain vs Humain ***'), 
				nl, 
				initBoard(u), % Initialization of the board			
				enterRedPiecesB, % The red player types initial position of his pieces
			 	enterOcrePiecesB, % The ocre player types initial position of his pieces
				redPlayerFirstTurn, % The first turn of the red player
				ocrePlayerFirstTurn, % The first turn of the ocre player
				oneTurn, % To manage every turn of the game
				cleanAll, % To clean pieces
				!.
choice(2) :- 	write('*** Humain vs Machine ***'), 
				nl,
				initBoard(u),
				enterRedPiecesB,
				machineEnterOcrePiecesB,
				redPlayerFirstTurn,
				machineOcrePlayerFirstTurn,
				oneHumanVsMachineTurn, % To manage every turn of the game
				cleanAll, % To clean pieces
				!.
choice(3) :- 	write('*** Machine vs Machine ***'), 
				nl,
				initBoard(m),
				machineEnterRedPiecesB,
				machineEnterOcrePiecesB, 
				machineRedPlayerFirstTurn,
				machineOcrePlayerFirstTurn,
				oneMachineVsMachineTurn, % To manage every turn of the game
				cleanAll, % To clean pieces
				!.
choice(4) :- write('Au revoir'), !.
choice(_) :- write('Veuillez sélectionner une option valide.'). 

% To manage one turn of the human vs human mode
oneTurn :- 	repeat,	
			redPlayerTurn, % To manage the red player turn
			ocrePlayerTurn, % To manage the ocre player turn
			endOfGame.

% To manage one turn of the human vs machine mode
oneHumanVsMachineTurn :-	repeat,	
							redPlayerTurn, % To manage the red player turn
							machineOcrePlayerTurn, % To manage the ocre player (machine) turn
							endOfGame.

oneMachineVsMachineTurn :- 	repeat,	
							machineRedPlayerTurn, % To manage the red player (machine) turn
							machineOcrePlayerTurn, % To manage the ocre player (machine) turn
							endOfGame.


% To manage the red player turn
redPlayerTurn :- 	endOfGame, % The game is finish 
					!.
redPlayerTurn :-	write('** Joueur ROUGE **'), % A piece could be moved
					nl,
					printBoard,							
					possibleRedMoves(M, 1),
					\+ empty(M),
					typeValidMove(X, Y, XNew, YNew, M), 
					changeRedPiecePosition(X, Y, XNew, YNew),
					writeMove(X, Y, XNew, YNew),
					printBoard,
					!.
redPlayerTurn :-	getRedPieces(P), % No piece could be moved 
					myLength(L, P),
					L \= 6,
					changePositionOrNewSbire(r),
					 !.
redPlayerTurn :-	managePositionOrNewSbire(1, r).


% To manage the ocre player turn
ocrePlayerTurn :- 	endOfGame, % The game is finish
					!.
ocrePlayerTurn :- 	write('** Joueur OCRE **'), % A piece could be moved
					nl,
					printBoard,
					possibleOcreMoves(M, 1),
					\+ empty(M),
					typeValidMove(X, Y, XNew, YNew, M),
					changeOcrePiecePosition(X, Y, XNew, YNew),
					writeMove(X, Y, XNew, YNew),
					printBoard,
					!.
ocrePlayerTurn :-	getOcrePieces(P), % No piece could be moved  
					myLength(L, P),
					L \= 6,
					changePositionOrNewSbire(o),
					!.
ocrePlayerTurn :-	managePositionOrNewSbire(1, o).


% To manage the red player turn (AI)
machineRedPlayerTurn :- 	endOfGame, % The game is finish
							!.
machineRedPlayerTurn :-		write('** Joueur ROUGE **'), % A piece could be moved
							nl,
							printBoard,
							possibleRedMoves(Moves, 1),
							\+ empty(Moves),
							generateMove(r, Moves, (X,Y,XNew,YNew)),
							changeRedPiecePosition(X, Y, XNew, YNew),
							writeMove(X, Y, XNew, YNew),
							printBoard,
							!.
machineRedPlayerTurn :-		getRedPieces(P), % No piece could be moved  
							myLength(L, P),
							L \= 6,
							machineManagePosition(r),
							!.
machineRedPlayerTurn :-		machineManagePosition(r).


% To manage the ocre player turn (AI)
machineOcrePlayerTurn :- 	endOfGame, % The game is finish
							!.
machineOcrePlayerTurn :-	write('** Joueur OCRE **'), % A piece could be moved
							nl,
							printBoard,
							possibleOcreMoves(Moves, 1),
							\+ empty(Moves),
							generateMove(o, Moves, (X,Y,XNew,YNew)),
							changeOcrePiecePosition(X, Y, XNew, YNew),
							writeMove(X, Y, XNew, YNew),
							printBoard,
							!.
machineOcrePlayerTurn :-	getOcrePieces(P), % No piece could be moved  
							myLength(L, P),
							L \= 6,
							machineManagePosition(o),
							!.
machineOcrePlayerTurn :-	machineManagePosition(o).
