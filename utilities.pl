% *** The predicates below are some utilities used during the game. ***

% Gestion d'une demande de mouvement pour la machine ou l'humain
handleMoveRequest(m, _, X, Y, XNew, YNew, M) :- typeValidMove(X, Y, XNew, YNew, M).
handleMoveRequest(h, C, X, Y, XNew, YNew, M) :- generateMove(C, M, (X, Y, XNew, YNew)).

% To get a valid move from the user
typeValidMove(XOld, YOld, XNew, YNew, M) :-	repeat,
											write('* Pion à  déplacer *'),
											nl,
											readPosition(XOld, YOld),
											write('* Emplacement final du pion *'),
											nl,
											readPosition(XNew, YNew),
											element((XOld,YOld,XNew,YNew), M).


% To write the details of a move in the command line.
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


% To write a piece position 
writePosition(X, Y) :- 	nl,
						write('Ligne (x.) : '),
						write(X), 
						nl,
						write('Colonne (y.) : '),
						write(Y), 
						nl.


% To read a piece position 
readPosition(X, Y) :- 	nl,
						write('Ligne (x.) : '),
						read(X), 
						write('Colonne (y.) : '),
						read(Y), 
						nl.


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

% Dispatch des mouvements possibles
possibleMoves(F, N, r) :- possibleRedMoves(F, N).
possibleMoves(F, N, o) :- possibleOcreMoves(F, N).

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


% To check if a not last specific move is valid
isValidNotLastMove(X, Y, H) :- 	\+ pieceAt(X, Y),
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
