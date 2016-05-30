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


% Dust:
% defineBoardNorth([[1, 2, 2, 3, 1, 2], [3, 1, 3, 1, 3, 2], [2, 3, 1, 2, 1, 3], [2, 1, 3, 2, 3, 1], [1, 3, 1, 3, 1, 2], [3, 2, 2, 1, 3, 2]]).
% defineBoardWest([[3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3], [3, 1, 3, 1, 3, 1], [2, 2, 1, 3, 2, 2]]).
% defineBoardEast([[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]]).


% Pieces position definition:
:- dynamic(redAt/2).
:- dynamic(ocreAt/2).
:- dynamic(khanAt/2).

% On utilisera asserta et assertz pour discriminer 
% la Kalista et les sbires (la Kalista sera en 
% tête de la base de fait, et les sbires en queue).
redKalista(X, Y) :- redAt(X, Y), !. % Idea
ocreKalista(X, Y) :- ocreAt(X, Y), !. % Idea


% Choice of the side of the player
% Use:
% | ?- sideChoice(e).
% 
% yes
sideChoice(s). % Default board
sideChoice(n) :- defineBoardNorth.
sideChoice(o) :- defineBoardWest.
sideChoice(e) :- defineBoardEast.

printPiece(X, Y) :- redKalista(I, J), X=I, Y=J, write('KR'), !. 
printPiece(X, Y) :- redAt(X, Y), write('SR'), !. 
printPiece(X, Y) :- ocreKalista(I, J), X=I, Y=J, write('KO'), !. 
printPiece(X, Y) :- ocreAt(X, Y), write('SO'), !. 
printPiece(_, _) :- write('  ').

printKhan(X, Y) :- khanAt(X, Y), write('*'), !.
printKhan(_, _) :- write(' ').

print2D :- board(B), print2D(B, 1, 1).


% Displays a line of the board (with pieces)
% Use:
% | ?- print1D([1,2],[a,r]). 
% 1/a 2/r 
% 
% yes
print1D([], _, _).
print1D([TBoard|QBoard], I, J) :-	write(TBoard), 
									write('/'), 									 
									printPiece(I, J),
									printKhan(I, J),									
									write(' '),
									NewJ is J + 1,
									print1D(QBoard, I, NewJ).


% Displays the board and the players pieces
% Use:
% | ?- print2D([[1,2],[3,4]], [[a,b],[c,d]]).
% 1/a 2/b 
% 3/c 4/d 
% 
% yes
print2D([], _, _).
print2D([TBoard|QBoard], I, J) :- 	print1D(TBoard, I, J), 
									nl, 
									NewI is I + 1,
									print2D(QBoard, NewI, J). 


% Initialization of the board: we should modify it
% Use:
% | ?- initBoard.
% Sélectionner votre position (n/s/o/e) :e.
% 2/2 3/3 1/1 2/2 2/2 3/3 
% 2/2 1/1 3/3 1/1 3/3 1/1 
% 1/1 3/3 2/2 3/3 1/1 2/2 
% 3/3 1/1 2/2 1/1 3/3 2/2 
% 2/2 3/3 1/1 3/3 1/1 3/3 
% 2/2 1/1 3/3 2/2 2/2 1/1 
% 
% yes
% 
initBoard :-	write('Sélectionner votre position (n/s/o/e) :'), 
				read(PlayerPos), 
				sideChoice(PlayerPos), 
				board(B),
				print2D(B, B).


% We get a position in the board typed by the user
% Use: 
% | ?- getPosition(I, J).
% 1.
% 6.
% 
% I = 1
% J = 6
% 
% yes
getPosition(I, J) :-	read(I), 
						read(J), 
						I >= 1, 
						I =< 6, 
						J >= 1, 
						J =< 6. 


% We get a piece in the position board
% Use: 
% | ?- pieceAt(1, 4, [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]], E).
% 
% E = 1
% 
% yes
pieceAt(1, 1, [H|_], H) :- !.
pieceAt(1, J, [H|_], E) :-	pieceAt(J, 1, H, E), 
							!.
pieceAt(I, J, [_|Q], E) :-	IPrime is I - 1, 
							pieceAt(IPrime, J, Q, E).


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

% To display the menu and manage the choice the user.
menu :- 	write('1. Humain vs Humain'), nl,
			write('2. Humain vs Machine'), nl,
			write('3. Machine vs Machine'), nl,
			write('4. Bye'), nl,
			write('Veuillez saisir votre choix : (1.|2.|3.|4.)'), nl,
			read(Choice), nl, choice(Choice),
			Choice=4, nl.

% To manage the choice of the user.
choice(1) :- write('*** Humain vs Humain ***'), nl, !.
choice(2) :- write('*** Humain vs Machine ***'), nl, !.
choice(3) :- write('*** Machine vs Machine ***'), nl, !.
choice(4) :- write('Au revoir'), !.
choice(_) :- write('Veuillez sélectionner une option valide.'). 


% To enter red pieces at the beginning of the game (interface).
enterRedPiecesB :- enterPiecesB(1, 6, r).

% To enter ocre pieces at the beginning of the game (interface).
enterOcrePiecesB :- enterPiecesB(1, 6, o).

% To enter red pieces at the beginning of the game.
enterPiecesB(1, N, C) :-	repeat, 
							write('Position Kalista'), 
							readTestAndStorePostionB(C),
							enterPiecesB(2, N, C), !.
enterPiecesB(J, N, C) :-	J < N,
							repeat,											
							SbireNumber is J - 1,	 
							write('Position Sbire '), 
							write(SbireNumber),
							readTestAndStorePostionB(C),
							NewJ is J + 1,
							enterPiecesB(NewJ, N, C), !.
enterPiecesB(N, N, C) :-	repeat,				
							SbireNumber is N - 1,		
							write('Position Sbire '), write(SbireNumber),
							readTestAndStorePostionB(C).

% To read, test and perhaps store a piece position 
% typed by a user at the beginning of the game.
readTestAndStorePostionB(C) :-	readPostionB(X, Y),
								isValidAndStorePositionB(X, Y, C).

% To read a piece position 
readPostionB(X, Y) :- 	nl,
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


% To clean the positions at the end of the game.
cleanPositions :- retractall(redAt(_,_)), retractall(ocreAt(_,_)), retractall(khanAt(_,_)).

myPrint2([]).
myPrint2([(X,Y,XNew,YNew)|Q]) :- write(X), write('*'), write(Y), write('*'), write(XNew), write('*'), write(YNew), nl, myPrint2(Q).

getRedPieces(RedPieces) :- setof((X,Y,X,Y,[]), redAt(X, Y), RedPieces).
getOcrePieces(OcrePieces) :- setof((X,Y,X,Y,[]), ocreAt(X, Y), OcrePieces). 

possibleRedMoves :-	getRedPieces(RedPieces), 
					possibleMoves(RedPieces, F, 1, 3), myPrint2(F). % We should manage the number of possible steps and correct a last step problem
possibleOcreMoves :-	getOcrePieces(OcrePieces),
						possibleMoves(OcrePieces, F, 1, 3).  % We should manage the number of possible steps and correct a last step problem

isValidNotLastMove(X, Y, H) :- 	\+ redAt(X, Y),
								\+ ocreAt(X, Y),
								isValidHistoryMove(X, Y, H).
								
isValidHistoryMove(X, Y, H) :-	X =< 6,
								X >= 1,
								Y =< 6,
								Y >= 1,
								\+ element((X, Y), H).
	
getElement([T|_], T).
getElement([_|Q], X) :- getElement(Q, X).

getMoves(X, Y, XPrime, YPrime) :- 	XPrime is X + 1,  
									YPrime is Y.
getMoves(X, Y, XPrime, YPrime) :- 	XPrime is X - 1,  
									YPrime is Y.
getMoves(X, Y, XPrime, YPrime) :- 	XPrime is X, 
									YPrime is Y + 1. 
getMoves(X, Y, XPrime, YPrime) :- 	XPrime is X, 
									YPrime is Y - 1.

getValidMove(Moves, XOld,YOld, X, Y, H, XNew, YNew) :-	getElement(Moves, (XOld,YOld,X,Y,H)),
														getMoves(X, Y, XNew, YNew),
														isValidNotLastMove(XNew, YNew, H).

getValidLastMove(Moves, XOld,YOld, XNew, YNew) :-	getElement(Moves, (XOld,YOld,X,Y,H)),
													getMoves(X, Y, XNew, YNew),
													isValidHistoryMove(XNew, YNew, H).

possibleMoves(Moves, FinalMoves, N, N) :-	setof(
												(XOld,YOld,XPrime,YPrime), 
												getValidLastMove(Moves, XOld, YOld, XPrime, YPrime), 
												FinalMoves
											), !.

possibleMoves(Moves, FinalMoves, J, N) :- 	setof(
												(XOld,YOld,XPrime,YPrime,[(X,Y)|H]), 
												getValidMove(Moves, XOld, YOld, X, Y, H, XPrime, YPrime), 
												PossibleMoves
											), 
											JNew is J+1,
											possibleMoves(PossibleMoves, FinalMoves, JNew, N).

generateMove(r, Move).
generateMove(o, Move).
