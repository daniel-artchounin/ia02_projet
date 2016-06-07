% *** The predicates below are some utilities used during the game. ***

% Management of a request of move by the human
handleMoveRequest(h, _, X, Y, XNew, YNew, M) :- typeValidMove(X, Y, XNew, YNew, M).
% Management of a request of move by the machine
handleMoveRequest(m, C, X, Y, XNew, YNew, M) :- generateMove(C, M, (X, Y, XNew, YNew)).

% Management of an exception
% E: exception
% T: Error message
handleException(E, T) :- 	write('Erreur : '),
							write(E), 
							nl,
							write(T), 
							nl,
							fail.

% Displays player's name and type.
playerInfo(r, h) :-	hSep, 
					write('**                       Joueur ROUGE                     **'), 
					hSep.
playerInfo(o, h) :-	hSep, 
					write('**                       Joueur OCRE                      **'), 
					hSep.
playerInfo(r, m) :-	hSep, 
					write('**                         IA ROUGE                       **'), 
					hSep.
playerInfo(o, m) :-	hSep, 
					write('**                         IA OCRE                        **'), 
					hSep.

% Hozizontal separation
hSep :-	nl, 
		write('------------------------------------------------------------'), 
		nl.

% To get a valid move from the user
% M: List of all possible moves
typeValidMove(XOld, YOld, XNew, YNew, M) :-	repeat,
											write('* Pion a deplacer *'), nl,
											readPosition(XOld, YOld),
											write('* Emplacement final du pion *'), nl,
											readPosition(XNew, YNew),
											element((XOld, YOld, XNew, YNew), M),
											!.

% To write the details of a move in the command line.
writeMove(X, Y, XNew, YNew) :-	write('Deplacement : ('), 
								write(X), 
								write(', '), 
								write(Y), 
								write(') --> ('), 
								write(XNew), 
								write(', '), 
								write(YNew), 
								write(')'),
								nl.


% To write a piece position in the command line. 
writePosition(X, Y) :- 	nl,
						write('Ligne (x.) : '),
						write(X), 
						nl,
						write('Colonne (y.) : '),
						write(Y), 
						nl.


% To read a piece position in the command line.
readPosition(X, Y) :- 	repeat, nl,
						write('Ligne (x.) : '),
						catch(read(X), E, handleException(E, 'Erreur de lecture de la ligne.')),
						write('Colonne (y.) : '),
						catch(read(Y), E, handleException(E, 'Erreur de lecture de la colonne.')),
						nl,
						!.


% ******************************************************************************
% To do some tests with the possible moves... -> Should be removed of course !!!
% ******************************************************************************
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


% To get the possible moves of specific colored player
% based on the Khan's position
possibleMoves(F, 1, C) :-	khanAt(X, Y), 
							typeOfPlace(X, Y, P), % We get the type of the place of the Khan
							getPieces(Pieces, C, P), % Returns a list of pieces moves on themselves
							possibleMoves(C, Pieces, F, 1, P),
							!.

% To get the possible moves of specific colored player
% not based on the Khan's position:
% we generate all moves.
possibleMoves(F, 2, C) :-	getPieces(P1, C, 1),
							possibleMoves(C, P1, F1, 1, 1),
							getPieces(P2, C, 2),
							possibleMoves(C, P2, F2, 1, 2),
							getPieces(P3, C, 3),
							possibleMoves(C, P3, F3, 1, 3),
							concate(F1, F2, R1),
							concate(R1, F3, F).


% To check if a not last specific move is valid
isValidNotLastMove(X, Y, H) :- 	\+ pieceAt(X, Y), % No piece during the travel
								isValidHistoryMove(X, Y, H).


% To check if a last specific move (for a red piece) is valid
isValidLastMove(C, X, Y, H) :- 	\+ pieceAt(X, Y, C), % No piece of the color of the player at the end of travel
								isValidHistoryMove(X, Y, H).


% To check if a specific move is not already in the history and not out of board bounds.
isValidHistoryMove(X, Y, H) :-	X =< 6,
								X >= 1,
								Y =< 6,
								Y >= 1,
								\+ element((X, Y), H).


% To get all the potential next possible positions from a place of the board, whether they are valid or not.
getNextPositions(X, Y, XNew, Y) :- 	XNew is X + 1.  
getNextPositions(X, Y, XNew, Y) :- 	XNew is X - 1.  
getNextPositions(X, Y, X, YNew) :-  YNew is Y + 1. 
getNextPositions(X, Y, X, YNew) :- 	YNew is Y - 1.


% To get all specific not last valid moves from a place of the board:
% it is used in the 'possibleMoves' predicate
getValidMove(Moves, XOld, YOld, X, Y, H, XNew, YNew) :-	getElement(Moves, (XOld, YOld, X, Y, H)),
														getNextPositions(X, Y, XNew, YNew),
														isValidNotLastMove(XNew, YNew, H). % We verify that the future position is valid


% To get all specific last valid moves from a place of the board: (via setof)
% it is used in the 'possibleMoves' predicate
getValidLastMove(C, Moves, XOld, YOld, XNew, YNew) :-	getElement(Moves, (XOld, YOld, X, Y, H)), % We get an intermediate move
														getNextPositions(X, Y, XNew, YNew), % We get a possible position
														isValidLastMove(C, XNew, YNew, H). % We verify that the last move is valid


% To make a list of all possible (full) moves from a list of places in the board:
% it is used in the other possibleMoves predicate
possibleMoves(C, Moves, FinalMoves, N, N) :-	setof( % Last move
													(XOld, YOld, XNew, YNew), 
													getValidLastMove(C, Moves, XOld, YOld, XNew, YNew), 
													FinalMoves
												), 
												!.
possibleMoves(C, Moves, FinalMoves, J, N) :- 	setof( % Not last move
													(XOld, YOld, XNew, YNew, [(X, Y)|H]), 
													getValidMove(Moves, XOld, YOld, X, Y, H, XNew, YNew), 
													PossibleMoves
												), 
												JNew is J + 1,
												possibleMoves(C, PossibleMoves, FinalMoves, JNew, N),
												!.
possibleMoves(_, _, [], _, _).

% Predicate to find a way to the opposite Kalista from a list of position: used to insert a sbire (AI).
findMoveToKalista([(X, Y)|_], X, Y, C) :-	typeOfPlace(X, Y, P),
											otherPlayer(C, C2),
											possibleMoves(C, [(X, Y, X, Y, [])], F, 1, P),
											kalista(XK, YK, C2),
											element((X, Y, XK, YK), F),
											!.
findMoveToKalista([_|T], X1, Y1, C) :- 		findMoveToKalista(T, X1, Y1, C).

% ******************************************************************************
% To be improved ...
% ******************************************************************************
generateMove(_, Moves, BestMove) :- first(Moves, BestMove). 
