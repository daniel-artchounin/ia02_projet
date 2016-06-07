% *** The predicates below allow us to manage the pieces of the game. ***


% Pieces position definition
:- dynamic(redAt/2).
:- dynamic(ocreAt/2).
:- dynamic(khanAt/2).
:- dynamic(endOfGame/0).

% To get or to check the position of the kalistas (first position in the dynamic base)
redKalista(X, Y) :-	redAt(X1, Y1), 
					!, 
					X = X1, 
					Y = Y1.
ocreKalista(X, Y) :- ocreAt(X1, Y1), 
					!, 
					X = X1, 
					Y = Y1.

% General predicate to get a Kalista.
kalista(X, Y, r) :- redKalista(X, Y).
kalista(X, Y, o) :- ocreKalista(X, Y).

% General predicate to get a piece.
pieceAt(X, Y) :- redAt(X, Y).
pieceAt(X, Y) :- ocreAt(X, Y).
pieceAt(X, Y, r) :- redAt(X, Y).
pieceAt(X, Y, o) :- ocreAt(X, Y).

% Predicate to get the other player
otherPlayer(r, o).
otherPlayer(o, r).

% General predicates to insert a new piece / kalista.
sbireAt(X, Y, r) :- assertz(redAt(X, Y)).
sbireAt(X, Y, o) :- assertz(ocreAt(X, Y)).
kalistaAt(X, Y, r) :- asserta(redAt(X, Y)).
kalistaAt(X, Y, o) :- asserta(ocreAt(X, Y)).


% To print a piece: it is used in the 'print1D' predicate
printPiece(X, Y) :- redKalista(X, Y),
					write('(KR)'), 
					!. 
printPiece(X, Y) :- redAt(X, Y), 
					write('(SR)'), 
					!. 
printPiece(X, Y) :- ocreKalista(X, Y),
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

% To verify the validity of the emplacement of the new sbire.
verificationNewSbire(X, Y) :-	hSep, 
								write('* Emplacement du nouveau sbire *'), 
								hSep, 
								nl,			
								readPosition(X, Y),
								\+ pieceAt(X, Y).


% To insert a new sbire for a human during the game.
insertNewSbire(C, h, X, Y) :- 	repeat,
								verificationNewSbire(X, Y),
								sbireAt(X, Y, C),
								updateKhan(X, Y),
								printBoard,
								!.

% ******************************************************************************
% To be improved ?
% ******************************************************************************

% To insert a new sbire for a machine during the game.
insertNewSbire(C, m, X, Y) :-		setof(
										(X1, X2), 
										freePosition(1, 1, X1, X2), 
										L
									), 
									findMoveToKalista(L, X, Y, C), % We get the first empty position which leads us to the opposite Kalista if it exists.
									sbireAt(X, Y, C),
									updateKhan(X, Y),
									printBoard,
									!.

% To update the position of the Khan
updateKhan(X, Y) :-	clearKhan,
					assertz(khanAt(X, Y)).
						

% To update the position of a piece
move(XOld, YOld, XNew, YNew, C) :- 				updateKhan(XNew, YNew), % Systematic update of the Khan and erasing of the arrival piece
												clearAt(XNew, YNew),
												updatePosition(XOld, YOld, XNew, YNew, C).

updatePosition(XOld, YOld, XNew, YNew, C) :- 	kalista(XOld, YOld, C), % Move of the kalista if it's a Kalista
												clearAt(XOld, YOld),
												kalistaAt(XNew, YNew, C), 
												!.

updatePosition(XOld, YOld, XNew, YNew, C) :- 	clearAt(XOld, YOld), % Move of the sbire by default
												sbireAt(XNew, YNew, C).

% The red player has won
changePiecePosition(_, _, XNew, YNew, r) :-	ocreKalista(XNew, YNew), % The ocre player has lost the game							
											asserta(endOfGame),
											hSep, 
											write('*** Bravo joueur Rouge, vous avez GAGNE !!! ***'), hSep,
											nl, nl, nl, 
											!.

% The ocre player has won
changePiecePosition(_, _, XNew, YNew, o) :- redKalista(XNew, YNew), % The red player has lost the game
											asserta(endOfGame),
											hSep, 
											write('*** Bravo joueur Ocre, vous avez GAGNE !!! ***'), hSep,
											nl, nl, nl,
											!.
% We set the position of the piece
changePiecePosition(XOld, YOld, XNew, YNew, C) :- move(XOld, YOld, XNew, YNew, C).


% To manage the choice of a player when no piece could be moved
changePositionOrNewSbire(C, h) :- 	repeat, 
									hSep,
									write('Vous ne pouvez pas obeir au KHAN.'), nl,
									write('1. Deplacer une piece sur une case de type different de celui du KHAN'), nl,
									write('2. Inserer un nouveau sbire'), nl,
									write('Veuillez saisir votre choix (1.|2.) : '),
									hSep,
									read(Choice), 
									nl,
									managePositionOrNewSbire(Choice, C, h),
									!.

% If no piece could be moved and AI has already lost a piece,
% first, it tries to insert a sbire such as it can find an immediate way to opposite Kalista.
% If it's not possible, it moves a piece.
changePositionOrNewSbire(C, m) :- managePositionOrNewSbire(_, C, m).


% Move of a piece without obeying to the Khan (human or machine)
% C : color
% T : type of player (AI / Human)
% Insertion d'un nouveau sbire suite à blocage du Khan (humain ou machine)
managePositionOrNewSbire(2, C, T) :- 	hSep, 
										write('* Insertion d\'un nouveau sbire *'), hSep, nl,
										insertNewSbire(C, T, X, Y),
										write((X, Y)), nl,
										!.

managePositionOrNewSbire(1, C, T) :-	hSep, 
										write('* Deplacement de type different de celui du KHAN *'), hSep, nl,
										possibleMoves(M, 2, C),
										handleMoveRequest(T, C, X, Y, XNew, YNew, M),
										changePiecePosition(X, Y, XNew, YNew, C),
										writeMove(X, Y, XNew, YNew),
										!.

managePositionOrNewSbire(_, _) :- 	write('Veuillez sélectionner une option valide.'),
									fail. 

% We get all pieces of a specific color.
getPieces(Pieces, C) :- setof(
							(X, Y), 
							pieceAt(X, Y, C),  
							Pieces
						),
						!.
getPieces([], _). % To manage the case there are no pieces

% To make a list of all specific colored pieces on a type of place (1, 2 or 3): the built list's aim is to be used to perform a move.
% Use:
% | ?- getPieces(L, 3, r). 
% 
% L = [(5,3,5,3,[]),(5,5,5,5,[])]
% 
% yes
getPieces(Pieces, C, P) :- 	setof(
								(X, Y, X, Y, []), 
								pieceOn(X, Y, P, C), 
								Pieces
							),
							!.
getPieces([], _, _). % To manage the case there are no pieces

% To get a colored piece on a type of place (1, 2 or 3)
pieceOn(X, Y, P, C) :- 	pieceAt(X, Y, C), 
						typeOfPlace(X, Y, P). 
