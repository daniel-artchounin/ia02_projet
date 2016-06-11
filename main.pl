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
start :-	repeat, 
			menu, 
			!.

% To display the menu and manage the choice of the user.
menu :- 	write('1. Humain vs Humain'), nl,
			write('2. Humain vs Machine'), nl,
			write('3. Machine vs Machine'), nl,
			write('4. Bye'), nl,
			write('Veuillez saisir votre choix (1.|2.|3.|4.) : '),
			read(Choice), nl, 
			choice(Choice), nl.

% To manage the choice of the user.
choice(1) :- 	hSep, 
				write('*** Humain vs Humain ***'), 
				hSep, 
				nl, 
				start(h, h),
				!.
choice(2) :- 	hSep, 
				write('*** Humain vs Machine ***'), 
				hSep, 
				nl,
				start(h, m),
				!.
choice(3) :- 	hSep, 
				write('*** Machine vs Machine ***'), 
				hSep, 
				nl,
				start(m, m),
				!.
choice(4) :-	hSep, 
				write('Au revoir'), 
				hSep, 
				!.
choice(_) :- 	hSep, write('Veuillez selectionner une option valide.'), hSep, nl,
				fail.

% To start the game, whether the player is human or IA
% T1 : Type du premier joueur
% T2 : Type du deuxième joueur
start(T1, T2) :-	initBoard(T1), % Initialization of the board
					enterPiecesB(T1, r), % The red player/IA sets initial position of his pieces
					enterPiecesB(T2, o), % The ocre player/IA sets initial position of his pieces
					playerInfo(r, T1),
					playerTurn(r, T1, 2), % The first turn of red player/AI: no need to obey to Khan as it doesn't exist yet
					playerInfo(o, T2),
					printBoard,
					playerTurn(o, T2, 1), % The first turn of ocre player/AI
					turn(T1, T2), % To manage every turn of the game
					cleanAll.


% To manage turns until the end of the game.
turn(T1, T2) :- 	repeat,
					printBoard,
					playerInfo(r, T1),
					playerTurn(r, T1, 1), % Red player turn
					printBoard,
					playerInfo(o, T2),
					playerTurn(o, T2, 1), % Ocre player turn
					endOfGame,
					!.


% To manage a specific turn.
playerTurn(_, _, _) :-	endOfGame, % Game is over.
						!.

% Basic turn (the game is not finished)
% T: type of the player
% C: color of the player
% MoveType: 1 if it should obey to the Khan, 2 otherwise
playerTurn(C, T, MoveType) :-	nl, % Standard move		
								possibleMoves(M, MoveType, C, _),
								\+ empty(M), % Will be empty if MoveType = 1 and no piece can obey to the Khan
								handleMoveRequest(T, C, X, Y, XNew, YNew, M), 
								writeMove(X, Y, XNew, YNew),
								changePiecePosition(X, Y, XNew, YNew, C),
								!.

playerTurn(C, T, _) :- 	getPieces(P, C), % Impossible to obey to the Khan 
						\+ length(P, 6), % Player has already lost a piece
						changePositionOrNewSbire(C, T), % Undefined for the machine.
						!.

playerTurn(C, T, _) :-	managePositionOrNewSbire(1, C, T). % Player has all his pieces.
