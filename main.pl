% *** The predicates below allow us to launch the game. ***


:- include('./list.pl').
:- include('./matrix.pl').


% Definition of the board linked to the side of the player
% Use:
% | ?- defineBoardEast.
% 
% yes
:- dynamic(board/1).
board([
		[2, 3, 1, 2, 2, 3], 
		[2, 1, 3, 1, 3, 1], 
		[1, 3, 2, 3, 1, 2], 
		[3, 1, 2, 1, 3, 2], 
		[2, 3, 1, 3, 1, 3], 
		[2, 1, 3, 2, 2, 1]
]).
defineBoardWest :- 	board(C), 
					rotateMatrixAC(C, B), 
					retract(board(C)), 
					asserta(board(B)).
defineBoardNorth :-	defineBoardWest, 
					board(C), 
					rotateMatrixAC(C, B), 
					retract(board(C)), 
					asserta(board(B)).
defineBoardEast :- 	board(C), 
					rotateMatrixC(C, B), 
					retract(board(C)), 
					asserta(board(B)).

% Dust: it will be deleted soon
% defineBoardNorth([[1, 2, 2, 3, 1, 2], [3, 1, 3, 1, 3, 2], [2, 3, 1, 2, 1, 3], [2, 1, 3, 2, 3, 1], [1, 3, 1, 3, 1, 2], [3, 2, 2, 1, 3, 2]]).
% defineBoardWest([[3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3], [3, 1, 3, 1, 3, 1], [2, 2, 1, 3, 2, 2]]).
% defineBoardEast([[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]]).


% Pieces position definition:
:- dynamic(redAt/2).
:- dynamic(ocreAt/2).
:- dynamic(khanAt/2).
:- dynamic(endOfGame/0).

% To get the position of the kalistas
redKalista(X, Y) :- redAt(X, Y), !.
ocreKalista(X, Y) :- ocreAt(X, Y), !.


% Choice of the side of the player
% Use:
% | ?- sideChoice(e).
% 
% yes
sideChoice(s). % Default board
sideChoice(n) :- defineBoardNorth.
sideChoice(o) :- defineBoardWest.
sideChoice(e) :- defineBoardEast.


% To print a piece: it is used in the 'print1D' predicate
printPiece(X, Y) :- redKalista(I, J), X=I, Y=J, write('KR'), !. 
printPiece(X, Y) :- redAt(X, Y), write('SR'), !. 
printPiece(X, Y) :- ocreKalista(I, J), X=I, Y=J, write('KO'), !. 
printPiece(X, Y) :- ocreAt(X, Y), write('SO'), !. 
printPiece(_, _) :- write('  ').


% To print the Khan: it is used in the 'print1D' predicate
printKhan(X, Y) :- khanAt(X, Y), write('*'), !.
printKhan(_, _) :- write(' ').

% Prints the board
% Use:
% | ?- printBoard.                           
% 2/    3/    1/    2/    2/    3/    
% 2/KO  1/SO  3/SO  1/SO  3/SO  1/SO  
% 1/    3/    2/    3/    1/    2/    
% 3/    1/    2/    1/    3/    2/    
% 2/KR* 3/SR  1/SR  3/SR  1/SR  3/SR  
% 2/    1/    3/    2/    2/    1/    
% 
% yes
printBoard :- 	write('* Plateau *'),
				nl, 
				board(B), 
				print2D(B, 1, 1),
				nl.


% Displays a line of the board (with pieces):
% it is used in the 'print2D' predicate
print1D([], _, _).
print1D([TBoard|QBoard], I, J) :-	write(TBoard), 
									write('/'), 									 
									printPiece(I, J),
									printKhan(I, J),									
									write(' '),
									NewJ is J + 1,
									print1D(QBoard, I, NewJ).


% Displays the board and the players pieces:
% it is used in the 'printBoard' predicate
print2D([], _, _).
print2D([TBoard|QBoard], I, J) :- 	print1D(TBoard, I, J), 
									nl, 
									NewI is I + 1,
									print2D(QBoard, NewI, J). 


% Initialization of the board: we should modify it
% Use:
% | ?- initBoard.
% Sélectionner votre position (n./s./o./e.) : e.
% 2/2 3/3 1/1 2/2 2/2 3/3 
% 2/2 1/1 3/3 1/1 3/3 1/1 
% 1/1 3/3 2/2 3/3 1/1 2/2 
% 3/3 1/1 2/2 1/1 3/3 2/2 
% 2/2 3/3 1/1 3/3 1/1 3/3 
% 2/2 1/1 3/3 2/2 2/2 1/1 
% 
% yes
% 
initBoard :- 	printBoard,
				write('* Orientation du tapis selon le choix du joueur ROUGE *'),
				nl,
				write('Position (n./s./o./e.) : '), 
				read(PlayerPos),
				nl,
				initBoard(PlayerPos).

initBoard(PlayerPos) :-	write('* Sélection du bord '),
						write(PlayerPos),
						write(' par le joueur ROUGE *'),
						nl,
						sideChoice(PlayerPos), 
						printBoard.


% We get type of a place in the position board (1, 2 or 3)
% Use: 
% | ?- typeOfPlace(6, 1, P).
% 
% P = 1
% 
% yes
typeOfPlace(I, J, P) :-	board(B),
						typeOfPlace(I, J, B, P).
typeOfPlace(1, 1, [H|_], H) :-	\+ myLength(_, H), 
								!.
typeOfPlace(1, 1, [H|_], E) :- 	typeOfPlace(1, 1, H, E),
								!.
typeOfPlace(1, J, [H|_], E) :-	typeOfPlace(J, 1, H, E), 
								!.
typeOfPlace(I, J, [_|Q], E) :-	IPrime is I - 1, 
								typeOfPlace(IPrime, J, Q, E).


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
				initBoard,				
				enterRedPiecesB,
			 	enterOcrePiecesB,
				oneTurn,	
				cleanPositions,
				!.
choice(2) :- write('*** Humain vs Machine ***'), nl, !.
choice(3) :- write('*** Machine vs Machine ***'), nl, !.
choice(4) :- write('Au revoir'), !.
choice(_) :- write('Veuillez sélectionner une option valide.'). 


oneTurn :- 	repeat,			
			printBoard,
			redPlayerTurn,
			ocrePlayerTurn,
			endOfGame.

redPlayerTurn :- 	endOfGame, 
					!.
redPlayerTurn :-	write('* Joueur ROUGE *'),
					nl,
					printBoard,				
					possibleRedMoves(M),
					write('Pion à déplacer (X,Y). : '),
					readPostion(XOld, YOld),
					write('Emplacement final du pion (X,Y). : '),
					readPostion(XNew, YNew).

ocrePlayerTurn :- 	endOfGame, 
					!.
ocrePlayerTurn :- 	write('* Joueur OCRE *'),
					nl,
					printBoard,
					possibleOcreMoves(M),
					write('Pion à déplacer (X,Y). : '),
					readPostion(XOld, YOld),
					write('Emplacement final du pion (X,Y). : '),
					readPostion(XNew, YNew).

% To enter red pieces at the beginning of the game (interface).
enterRedPiecesB :- 	write('* Pose initiale des six pièces du joueur ROUGE *'),
					nl,
					enterPiecesB(1, 6, r).

% To enter ocre pieces at the beginning of the game (interface).
enterOcrePiecesB :- write('* Pose initiale des six pièces du joueur OCRE *'),
					nl,
					enterPiecesB(1, 6, o).

% To enter red pieces at the beginning of the game.
enterPiecesB(1, N, C) :-	repeat, 
							write('Position Kalista'), 
							readTestAndStorePostionB(C),
							printBoard,
							enterPiecesB(2, N, C), 
							!.
enterPiecesB(N, N, C) :-	repeat,				
							SbireNumber is N - 1,		
							write('Position Sbire '), write(SbireNumber),
							readTestAndStorePostionB(C),
							printBoard,				
							!.
enterPiecesB(J, N, C) :-	repeat,											
							SbireNumber is J - 1,	 
							write('Position Sbire '), 
							write(SbireNumber),
							readTestAndStorePostionB(C),
							printBoard,
							NewJ is J + 1,
							enterPiecesB(NewJ, N, C).

% To read, test and perhaps store a piece position 
% typed by a user at the beginning of the game.
readTestAndStorePostionB(C) :-	readPostion(X, Y),
								isValidAndStorePositionB(X, Y, C).

% To read a piece position 
readPostion(X, Y) :- 	nl,
						write('Ligne (x.) : '),
						read(X), 
						write('Colonne (y.) : '),
						read(Y), 
						nl.

% To test the validity of a red piece position at the 
% beginning of the game and perhaps store it.
isValidAndStorePositionB(X, Y, r) :-	\+ redAt(X, Y), 
										\+ ocreAt(X, Y), 
										X >= 5, 
										X =< 6, 
										Y >= 1, 
										Y =< 6,
										assertz((redAt(X, Y))).

% To test the validity of an ocre piece position at the 
% beginning of the game and perhaps store it.
isValidAndStorePositionB(X, Y, o) :-	\+ redAt(X, Y), 
										\+ ocreAt(X, Y), 
										X >= 1, 
										X =< 2, 
										Y >= 1, 
										Y =< 6,
										assertz((ocreAt(X, Y))).


% To do some tests with the possible moves...
myPrint2([]).
myPrint2([(X,Y,XNew,YNew)|Q]) :-	write(X), 
									write('*'), 
									write(Y), 
									write(' || '), 
									write(XNew), 
									write('*'), 
									write(YNew), 
									nl, 
									myPrint2(Q).


% To get the red pieces possible moves
% Use:
% | ?- possibleRedMoves.
% 5*1 || 3*1
% 5*1 || 4*2
% 5*1 || 6*2
% 5*6 || 3*6
% 5*6 || 4*5
% 5*6 || 6*5
% 
% yes
possibleRedMoves(F) :- 	khanAt(X, Y),
						typeOfPlace(X, Y, KP),
						getRedPieces(RedPieces, KP), 
						possibleMoves(r, RedPieces, F, 1, KP), 
						myPrint2(F), 
					!.
possibleRedMoves(F) :-		getRedPieces(RedPieces1, 1), 
						possibleMoves(r, RedPieces1, F1, 1, 1), 
						getRedPieces(RedPieces2, 2), 
						possibleMoves(r, RedPieces2, F2, 1, 2), 
						getRedPieces(RedPieces3, 3), 
						possibleMoves(r, RedPieces3, F3, 1, 3), 
						concate(F1, F2, F3, F),
						myPrint2(F).

% To get the ocre pieces possible moves
% Use:
% | ?- possibleOcreMoves.   
% 2*1 || 1*1
% 2*1 || 3*1
% 2*3 || 1*3
% 2*3 || 3*3
% 2*5 || 1*5
% 2*5 || 3*5
% 
% yes
possibleOcreMoves(F) :-	khanAt(X, Y),
						typeOfPlace(X, Y, KP),
						getOcrePieces(OcrePieces, KP),
						possibleMoves(o, OcrePieces, F, 1, KP), 
						myPrint2(F), 
						!.
possibleOcreMoves(F) :-	getOcrePieces(OcrePieces1, 1), 
						possibleMoves(o, OcrePieces1, F1, 1, 1), 
						getOcrePieces(OcrePieces2, 2), 
						possibleMoves(o, OcrePieces2, F2, 1, 2), 
						getOcrePieces(OcrePieces3, 3), 
						possibleMoves(o, OcrePieces3, F3, 1, 3), 
						concate(F1, F2, F3, F),
						myPrint2(F).

% To get the red pieces on a type of place (1, 2 or 3)
% | ?- redOn(X, Y, 3).
% 
% X = 5
% Y = 3 ? ;
% 
% X = 5
% Y = 5 ? ;
% 
% no
redOn(X, Y, P) :- 	redAt(X, Y), 
					typeOfPlace(X, Y, P). 

% To get the ocre pieces on a type of place (1, 2 or 3)
% | ?- ocreOn(X, Y, 3).
% 
% X = 2
% Y = 2 ? ;
% 
% X = 2
% Y = 4 ? ;
% 
% X = 2
% Y = 6
% 
% yes
ocreOn(X, Y, P) :- 	ocreAt(X, Y), 
					typeOfPlace(X, Y, P).

% To make a list of all red pieces on a type of place (1, 2 or 3)
% Use:
% | ?- getRedPieces(L, 3). 
% 
% L = [(5,3,5,3,[]),(5,5,5,5,[])]
% 
% yes
getRedPieces(RedPieces, P) :-	setof(
									(X,Y,X,Y,[]), 
									redOn(X, Y, P), 
									RedPieces
								).

% To make a list of all ocre pieces on a type of place (1, 2 or 3)
% Use:
% | ?- getOcrePieces(L, 3).
% 
% L = [(2,2,2,2,[]),(2,4,2,4,[]),(2,6,2,6,[])]
% 
% yes
getOcrePieces(OcrePieces, P) :- setof(
									(X,Y,X,Y,[]), 
									ocreOn(X, Y, P), 
									OcrePieces
								). 

% To check if a not last specific move is valid
isValidNotLastMove(X, Y, H) :- 	\+ redAt(X, Y),
								\+ ocreAt(X, Y),
								isValidHistoryMove(X, Y, H).

% To check if a last specific move (for a red piece) is valid
isValidLastMove(r, X, Y, H) :- 	\+ redAt(X, Y),
								isValidHistoryMove(X, Y, H).

% To check if a last specific move (for an ocre piece) is valid
isValidLastMove(o, X, Y, H) :- 	\+ ocreAt(X, Y),
								isValidHistoryMove(X, Y, H).								

% To check if a specific move is not already in the history
isValidHistoryMove(X, Y, H) :-	X =< 6,
								X >= 1,
								Y =< 6,
								Y >= 1,
								\+ element((X, Y), H).


% To get all the elements in a list
% Use:
% | ?- getElement([1,2,3], X).
% 
% X = 1 ? ;
% 
% X = 2 ? ;
% 
% X = 3 ? ;
% 
% no
getElement([T|_], T).
getElement([_|Q], X) :- getElement(Q, X).


% To get all the potential possible moves from a place of the board
% Use: 
% | ?- getMoves(2,2, XNew, YNew).
% 
% XNew = 3
% YNew = 2 ? ;
% 
% XNew = 1
% YNew = 2 ? ;
% 
% XNew = 2
% YNew = 3 ? ;
% 
% XNew = 2
% YNew = 1
% 
% yes
getMoves(X, Y, XNew, YNew) :- 	XNew is X + 1,  
								YNew is Y.
getMoves(X, Y, XNew, YNew) :- 	XNew is X - 1,  
								YNew is Y.
getMoves(X, Y, XNew, YNew) :- 	XNew is X, 
								YNew is Y + 1. 
getMoves(X, Y, XNew, YNew) :- 	XNew is X, 
								YNew is Y - 1.

% To get all specific not last valid moves from a place of the board:
% it is used in the 'possibleMoves' predicate
getValidMove(Moves, XOld, YOld, X, Y, H, XNew, YNew) :-	getElement(Moves, (XOld,YOld,X,Y,H)),
														getMoves(X, Y, XNew, YNew),
														isValidNotLastMove(XNew, YNew, H).

% To get all specific last valid moves from a place of the board:
% it is used in the 'possibleMoves' predicate
getValidLastMove(C, Moves, XOld, YOld, XNew, YNew) :-	getElement(Moves, (XOld,YOld,X,Y,H)),
														getMoves(X, Y, XNew, YNew),
														isValidLastMove(C, XNew, YNew, H).


% To make a list of all possible (full) moves from a list of places in the board:
% it is used in the 'possibleRedMoves' and 'possibleOcreMoves' predicates
possibleMoves(C, Moves, FinalMoves, N, N) :-	setof(
												(XOld,YOld,XNew,YNew), 
												getValidLastMove(C, Moves, XOld, YOld, XNew, YNew), 
												FinalMoves
												), 
												!.
possibleMoves(C, Moves, FinalMoves, J, N) :- 	setof(
												(XOld,YOld,XNew,YNew,[(X,Y)|H]), 
												getValidMove(Moves, XOld, YOld, X, Y, H, XNew, YNew), 
												PossibleMoves
												), 
												JNew is J + 1,
												possibleMoves(C, PossibleMoves, FinalMoves, JNew, N).


generateMove(r, Move). % Comming soon...
generateMove(o, Move). % Comming soon...


% To clean the positions at the end of the game.
cleanPositions :- retractall(redAt(_,_)), retractall(ocreAt(_,_)), retractall(khanAt(_,_)).
