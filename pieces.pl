% *** The predicates below allow us to manage the pieces of the game. ***


% Pieces position definition:
:- dynamic(redAt/2).
:- dynamic(ocreAt/2).
:- dynamic(khanAt/2).
:- dynamic(endOfGame/0).

% To get the position of the kalistas
redKalista(X, Y) :- redAt(X, Y), !.
ocreKalista(X, Y) :- ocreAt(X, Y), !.


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
						

% To update the position of a piece
updatePosition(XOld, YOld, XNew, YNew, r) :-	redKalista(I, J),
												retractall(redAt(XOld,YOld)),
												XOld=I, 
												YOld=J, 
												asserta((redAt(XNew, YNew))),
												!.
updatePosition(_, _, XNew, YNew, r) :-	assertz((redAt(XNew, YNew))).

updatePosition(XOld, YOld, XNew, YNew, o) :-	ocreKalista(I, J),
												retractall(ocreAt(XOld,YOld)),
												XOld=I, 
												YOld=J, 
												asserta((ocreAt(XNew, YNew))),
												!.
updatePosition(_, _, XNew, YNew, o) :-	assertz((ocreAt(XNew, YNew))).

% We set the position of a red piece
changeRedPiecePosition(XOld, YOld, XNew, YNew) :-	ocreKalista(I, J), % The ocre player has lost the game
													XNew=I, 
													YNew=J, 
													retractall((ocreAt(XNew,YNew))),
													updatePosition(XOld, YOld, XNew, YNew, r),													
													assertz(endOfGame),
													write('*** Bravo joueur Rouge, vous avez GAGNE !!! ***'),
													nl,
													nl,
													nl,
													updateKhan(XNew, YNew),
													!. 
changeRedPiecePosition(XOld, YOld, XNew, YNew) :-	ocreAt(XNew, YNew), % The ocre player has lost a sbire
													retractall((ocreAt(XNew,YNew))),
													updatePosition(XOld, YOld, XNew, YNew, r),
													updateKhan(XNew, YNew),
													!.
changeRedPiecePosition(XOld, YOld, XNew, YNew) :-	updatePosition(XOld, YOld, XNew, YNew, r), % No ocre piece is lost
													updateKhan(XNew, YNew).

% We set the position of an ocre piece
changeOcrePiecePosition(XOld, YOld, XNew, YNew) :- 	redKalista(I, J), % The red player has lost the game
													XNew=I, 
													YNew=J, 
													retractall((redAt(XNew,YNew))),
													updatePosition(XOld, YOld, XNew, YNew, o),
													assertz(endOfGame),
													write('*** Bravo joueur Ocre, vous avez GAGNE !!! ***'),
													nl,
													nl,
													nl,
													updateKhan(XNew, YNew),
													!. 
changeOcrePiecePosition(XOld, YOld, XNew, YNew) :- 	redAt(XNew, YNew), % The red player has lost a sbire
													retractall((redAt(XNew,YNew))),
													updatePosition(XOld, YOld, XNew, YNew, o),
													updateKhan(XNew, YNew),
													!. 
changeOcrePiecePosition(XOld, YOld, XNew, YNew) :-	updatePosition(XOld, YOld, XNew, YNew, o), % No ocre piece is lost
													updateKhan(XNew, YNew).


% To manage the choice of a player when no piece could be moved
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
									changeRedPiecePosition(X, Y, XNew, YNew),
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
									changeOcrePiecePosition(X, Y, XNew, YNew),
									writeMove(X, Y, XNew, YNew),
									printBoard,
									!.
managePositionOrNewSbire(2, o) :- 	insertNewSbire(o),
									!.
managePositionOrNewSbire(_, o) :- 	write('Veuillez sélectionner une option valide.'),
									fail.


% To manage a move from a place which type is different than the place of the KHAN
machineManagePosition(r) :- 	write('* Déplacement de pièce sur une case de type différent de celle du KHAN  *'), 
								nl, 
								clearKhan,								
								possibleRedMoves(Moves, 2),
								generateMove(r, Moves, (X,Y,XNew,YNew)), 
								writeMove(X, Y, XNew, YNew),
								changeRedPiecePosition(X, Y, XNew, YNew),
								printBoard,
								!.


% To manage a move from a place which type is different than the place of the KHAN
machineManagePosition(o) :- 	write('* Déplacement de pièce sur une case de type différent de celle du KHAN  *'), 
								nl, 
								clearKhan,								
								possibleOcreMoves(Moves, 2),
								generateMove(o, Moves, (X,Y,XNew,YNew)), 
								writeMove(X, Y, XNew, YNew),
								changeOcrePiecePosition(X, Y, XNew, YNew),
								printBoard,
								!.


% To check if there is no piece on a place.
noPiecesHere(X, Y) :-	\+ redAt(X, Y), 
			 			\+ ocreAt(X, Y).


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
