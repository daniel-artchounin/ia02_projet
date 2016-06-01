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
printPiece(X, Y) :- redKalista(I, J), 
					X=I, 
					Y=J, 
					write('(KR)'), 
					!. 
printPiece(X, Y) :- redAt(X, Y), 
					write('(SR)'), 
					!. 
printPiece(X, Y) :- ocreKalista(I, J), 
					X=I, 
					Y=J, 
					write('(KO)'), 
					!. 
printPiece(X, Y) :- ocreAt(X, Y), 
					write('(SO)'), 
					!. 
printPiece(_, _) :- write('    ').


% To print the Khan: it is used in the 'print1D' predicate
printKhan(X, Y) :- 	khanAt(X, Y), 
					write('*'), 
					!.
printKhan(_, _) :- 	write(' ').

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
printBoard :- 	write('    | 1      2      3      4      5      6'), nl,
			  	write('----|------------------------------------------'), nl,
				board(B), 
				print2D(B, 1, 1),
				nl.


% Displays a line of the board (with pieces):
% it is used in the 'print2D' predicate
print1D([], _, _).
print1D([TBoard|QBoard], I, J) :-	write(TBoard),
									printKhan(I, J),								 
									printPiece(I, J),									
									write(' '),
									NewJ is J + 1,
									print1D(QBoard, I, NewJ).


% Displays the board and the players pieces:
% it is used in the 'printBoard' predicate
print2D([], _, _).
print2D([TBoard|QBoard], I, J) :- 	write(' '), 
									write(I), 
									write('  | '),
									print1D(TBoard, I, J), 
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
				initBoard, % Initialization of the board			
				enterRedPiecesB, % The red player types initial position of his pieces
			 	enterOcrePiecesB, % The ocre player types initial position of his pieces
				redPlayerFirstTurn, % The first turn of the red player
				ocrePlayerFirstTurn, % The first turn of the ocre player
				oneTurn, % To manage every turn of the game
				cleanAll, % To clean pieces
				!.
choice(2) :- 	write('*** Humain vs Machine ***'), 
				nl,
				initBoard,
				enterRedPiecesB,
				machineEnterOcrePiecesB,
				redPlayerFirstTurn,
				machineOcrePlayerFirstTurn,
				oneHumanVsMachineTurn, % To manage every turn of the game
				cleanAll, % To clean pieces
				!.
choice(3) :- write('*** Machine vs Machine ***'), nl, !.
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


% To get a valid move from the user
typeValidMove(XOld, YOld, XNew, YNew, M) :-	repeat,
											write('* Pion à  déplacer *'),
											nl,
											readPostion(XOld, YOld),
											write('* Emplacement final du pion *'),
											nl,
											readPostion(XNew, YNew),
											element((XOld,YOld,XNew,YNew), M).


% To verify the validity of the emplacement of the new sbire.
verificationNewSbire(X, Y) :-	write('* Emplacement du nouveau sbire *'),
								nl,			
								readPostion(X, Y),
								noPiecesHere(X, Y).


% To insert a new red sbire.
insertNewSbire(r) :-	repeat,
						verificationNewSbire(X, Y),
						assertz((redAt(X, Y))),
						updateKhan(X, Y),
						printBoard.
% To insert a new ocre sbire.
insertNewSbire(o) :- 	repeat,
						verificationNewSbire(X, Y),
						assertz((ocreAt(X, Y))),
						updateKhan(X, Y),
						printBoard.


% To update the position of the Khan
updateKhan(X, Y) :-	clearKhan,
					assertz((khanAt(X, Y))).
						

% We set the position of a red piece
changeRedPiecePosition(X, Y) :- ocreKalista(I, J), % The ocre player has lost the game
								X=I, 
								Y=J, 
								retractall((ocreAt(X,Y))),
								assertz((redAt(X, Y))),
								assertz(endOfGame),
								write('*** Bravo joueur Rouge, vous avez GAGNE !!! ***'),
								nl,
								nl,
								nl,
								updateKhan(X, Y),
								!. 
changeRedPiecePosition(X, Y) :- ocreAt(X, Y), % The ocre player has lost a sbire
								retractall((ocreAt(X,Y))),
								assertz((redAt(X, Y))),
								updateKhan(X, Y),
								!.
changeRedPiecePosition(X, Y) :- assertz((redAt(X, Y))), % No ocre piece is lost
								updateKhan(X, Y).

% We set the position of an ocre piece
changeOcrePiecePosition(X, Y) :- 	redKalista(I, J), % The red player has lost the game
									X=I, 
									Y=J, 
									retractall((redAt(X,Y))),
									assertz((ocreAt(X, Y))),
									assertz(endOfGame),
									write('*** Bravo joueur Ocre, vous avez GAGNE !!! ***'),
									nl,
									nl,
									nl,
									updateKhan(X, Y),
									!. 
changeOcrePiecePosition(X, Y) :- 	redAt(X, Y), % The red player has lost a sbire
									retractall((redAt(X,Y))),
									assertz((ocreAt(X, Y))),
									updateKhan(X, Y),
									!. 
changeOcrePiecePosition(X, Y) :-	assertz((ocreAt(X, Y))), % No ocre piece is lost
									updateKhan(X, Y).

% To manage the red player first turn
redPlayerFirstTurn :- 	write('** Joueur ROUGE **'),
						nl,
						printBoard,	
						possibleRedMoves(M, 2),
						typeValidMove(X, Y, XNew, YNew, M), 
						retractall(redAt(X,Y)), % We erase the piece selected by the user
						changeRedPiecePosition(XNew, YNew),
						writeMove(X, Y, XNew, YNew),
						printBoard.

% To manage the ocre player first turn
ocrePlayerFirstTurn :- ocrePlayerTurn.

% To manage the ocre player (machine) first turn
machineOcrePlayerFirstTurn :- machineOcrePlayerTurn.

% To manage the choice of the red player when no piece could be moved
changePositionOrNewSbire(C) :- 	repeat,
								write('Vous ne pouvez obéir au KHAN.'), 
								nl,
								write('1. Déplacer une pièce sur une case de type différent de celle du KHAN'), 
								nl,
								write('2. Insérer un nouveau sbire'), 
								nl,
								write('Veuillez saisir votre choix (1.|2.) : '),
								read(Choice),
								nl,
								managePositionOrNewSbire(Choice, C).
							
managePositionOrNewSbire(1, r) :- 	write('* Déplacement de pièce sur une case de type différent de celle du KHAN *'), 
									nl, 
									clearKhan,
									printBoard,
									possibleRedMoves(M, 2),
									typeValidMove(X, Y, XNew, YNew, M), 
									retractall(redAt(X,Y)), % We erase the piece selected by the user
									changeRedPiecePosition(XNew, YNew),
									writeMove(X, Y, XNew, YNew),
									printBoard,
									!.
managePositionOrNewSbire(2, r) :- 	insertNewSbire(r),
									!.
managePositionOrNewSbire(_, r) :- 	write('Veuillez sélectionner une option valide.'),
									fail. 

managePositionOrNewSbire(1, o) :- 	write('* Déplacement de pièce sur une case de type différent de celle du KHAN *'), 
									nl,
									clearKhan,
									printBoard, 
									possibleOcreMoves(M, 2),
									typeValidMove(X, Y, XNew, YNew, M),
									retractall(ocreAt(X,Y)), % We erase the piece selected by the user
									changeOcrePiecePosition(XNew, YNew),
									writeMove(X, Y, XNew, YNew),
									printBoard,
									!.
managePositionOrNewSbire(2, o) :- 	insertNewSbire(o),
									!.
managePositionOrNewSbire(_, o) :- 	write('Veuillez sélectionner une option valide.'),
									fail. 

% We get all the red pieces
getRedPieces(RedPieces) :-	setof(
									(X,Y), 
									redAt(X, Y), 
									RedPieces
							),
							!.
getRedPieces([]).

% We get all the ocre pieces
getOcrePieces(OcrePieces) :-	setof(
									(X,Y), 
									ocreAt(X, Y), 
									OcrePieces
								),
								!. 
getOcrePieces([]).


% To manage the red player turn
redPlayerTurn :- 	endOfGame, % The game is finish 
					!.
redPlayerTurn :-	write('** Joueur ROUGE **'), % A piece could be moved
					nl,
					printBoard,							
					possibleRedMoves(M, 1),
					\+ empty(M),
					typeValidMove(X, Y, XNew, YNew, M), 
					retractall(redAt(X,Y)), % We erase the piece selected by the user
					changeRedPiecePosition(XNew, YNew),
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
					retractall(ocreAt(X,Y)), % We erase the piece selected by the user
					changeOcrePiecePosition(XNew, YNew),
					writeMove(X, Y, XNew, YNew),
					printBoard,
					!.
ocrePlayerTurn :-	getOcrePieces(P), % No piece could be moved  
					myLength(L, P),
					L \= 6,
					changePositionOrNewSbire(o),
					!.
ocrePlayerTurn :-	managePositionOrNewSbire(1, o).


machineOcrePlayerTurn :- 	endOfGame, % The game is finish
							!.
machineOcrePlayerTurn :-	write('** Joueur OCRE **'), % A piece could be moved
							nl,
							printBoard,
							possibleOcreMoves(Moves, 1),
							\+ empty(Moves),
							generateMove(o, Moves, (X,Y,XNew,YNew)),
							retractall(ocreAt(X,Y)), % We erase the piece selected by the user
							changeOcrePiecePosition(XNew, YNew),
							writeMove(X, Y, XNew, YNew),
							printBoard,
							!.
machineOcrePlayerTurn :-	getOcrePieces(P), % No piece could be moved  
							myLength(L, P),
							L \= 6,
							machineManagePosition(o),
							!.
machineOcrePlayerTurn :-	machineManagePosition(o).


machineManagePosition(r) :- 	write('* Déplacement de pièce sur une case de type différent de celle du KHAN  *'), 
								nl, 
								clearKhan,								
								possibleRedMoves(Moves, 2),
								generateMove(o, Moves, (X,Y,XNew,YNew)), 
								writeMove(X, Y, XNew, YNew),
								retractall(redAt(X,Y)), % We erase the piece of the machine
								changeOcrePiecePosition(XNew, YNew),
								printBoard,
								!.

writeMove(X, Y, XNew, YNew) :-	write('('), 
								write(X), 
								write(', '), 
								write(Y), 
								write(') --> ('), 
								write(XNew), 
								write(', '), 
								write(YNew), 
								write(')'),
								nl.


% To enter red pieces at the beginning of the game (interface).
enterRedPiecesB :- 	write('* Pose initiale des six pièces du joueur ROUGE *'),
					nl,
					enterPiecesB(1, 6, r).

% To enter ocre pieces at the beginning of the game (interface).
enterOcrePiecesB :- write('* Pose initiale des six pièces du joueur OCRE *'),
					nl,
					enterPiecesB(1, 6, o).

% To enter ocre pieces at the beginning of the game (interface).
machineEnterOcrePiecesB :-	write('* Pose initiale des six pièces du joueur OCRE *'),
							nl,
							machineEnterPiecesB(1, 6, o).

machineEnterPiecesB(1, N, C) :-	repeat, 
								write('Position Kalista'), 
								writePosition(1, 1),
								isValidAndStorePositionB(1, 1, C),
								printBoard,
								machineEnterPiecesB(2, N, C), 
								!.
machineEnterPiecesB(N, N, C) :-	repeat,				
								SbireNumber is N - 1,		
								write('Position Sbire '), 
								write(SbireNumber),
								writePosition(1, N),
								isValidAndStorePositionB(1, N, C),
								printBoard,				
								!.
machineEnterPiecesB(J, N, C) :-	repeat,											
								SbireNumber is J - 1,	 
								write('Position Sbire '), 
								write(SbireNumber),
								writePosition(1, 1),
								isValidAndStorePositionB(1, J, C),
								printBoard,
								NewJ is J + 1,
								machineEnterPiecesB(NewJ, N, C).


% To enter red pieces at the beginning of the game.
enterPiecesB(1, N, C) :-	repeat, 
							write('Position Kalista'), 
							readTestAndStorePostionB(C),
							printBoard,
							enterPiecesB(2, N, C), 
							!.
enterPiecesB(N, N, C) :-	repeat,				
							SbireNumber is N - 1,		
							write('Position Sbire '), 
							write(SbireNumber),
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

% To write a piece position 
writePosition(X, Y) :- 	nl,
						write('Ligne (x.) : '),
						write(X), 
						nl,
						write('Colonne (y.) : '),
						write(Y), 
						nl.

% To read a piece position 
readPostion(X, Y) :- 	nl,
						write('Ligne (x.) : '),
						read(X), 
						write('Colonne (y.) : '),
						read(Y), 
						nl.

noPiecesHere(X, Y) :-	\+ redAt(X, Y), 
			 			\+ ocreAt(X, Y).

% To test the validity of a red piece position at the 
% beginning of the game and perhaps store it.
isValidAndStorePositionB(X, Y, r) :-	noPiecesHere(X, Y), 
										X >= 5, 
										X =< 6, 
										Y >= 1, 
										Y =< 6,
										assertz((redAt(X, Y))).

% To test the validity of an ocre piece position at the 
% beginning of the game and perhaps store it.
isValidAndStorePositionB(X, Y, o) :-	noPiecesHere(X, Y), 
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
possibleRedMoves(F, 1) :- 	khanAt(X, Y),
							typeOfPlace(X, Y, KP),
							getRedPieces(RedPieces, KP), 
							possibleMoves(r, RedPieces, F, 1, KP).
possibleRedMoves(F, 2) :-	getRedPieces(RedPieces1, 1), 
							possibleMoves(r, RedPieces1, F1, 1, 1), 
							getRedPieces(RedPieces2, 2),
							possibleMoves(r, RedPieces2, F2, 1, 2), 
							getRedPieces(RedPieces3, 3), 
							possibleMoves(r, RedPieces3, F3, 1, 3), 
							concate(F1, F2, F3, F).

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
possibleOcreMoves(F, 1) :-	khanAt(X, Y),
							typeOfPlace(X, Y, KP),
							getOcrePieces(OcrePieces, KP),
							possibleMoves(o, OcrePieces, F, 1, KP).
possibleOcreMoves(F, 2) :-	getOcrePieces(OcrePieces1, 1), 
							possibleMoves(o, OcrePieces1, F1, 1, 1), 
							getOcrePieces(OcrePieces2, 2), 
							possibleMoves(o, OcrePieces2, F2, 1, 2), 
							getOcrePieces(OcrePieces3, 3), 
							possibleMoves(o, OcrePieces3, F3, 1, 3), 
							concate(F1, F2, F3, F).

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
								),
								!.
getRedPieces([], _).

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
								),
								!. 
getOcrePieces([], _).

% To check if a not last specific move is valid
isValidNotLastMove(X, Y, H) :- 	noPiecesHere(X, Y),
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
getMoves(X, Y, XNew, Y) :- 	XNew is X + 1.  
getMoves(X, Y, XNew, Y) :- 	XNew is X - 1.  
getMoves(X, Y, X, YNew) :-  YNew is Y + 1. 
getMoves(X, Y, X, YNew) :- 	YNew is Y - 1.

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
												possibleMoves(C, PossibleMoves, FinalMoves, JNew, N),
												!.
possibleMoves(_, _, [], _, _).



generateMove(r, Moves, BestMove) :- first(Moves, BestMove). % To be improved ...
generateMove(o, Moves, BestMove) :- first(Moves, BestMove). % To be improved ...


% To clean the positions at the end of the game.
cleanAll :- 	retractall((redAt(_,_))), 
				retractall((ocreAt(_,_))), 
				retractall((endOfGame)),
				clearKhan.

% To clean the Khan.
clearKhan :- retractall((khanAt(_,_))).
