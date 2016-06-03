% *** The predicates below allow us to manage the pieces of the game. ***


% Pieces position definition:
:- dynamic(redAt/2).
:- dynamic(ocreAt/2).
:- dynamic(khanAt/2).
:- dynamic(endOfGame/0).

% To get the position of the kalistas (first position in facts list)
redKalista(X, Y) :- redAt(X, Y), !.
ocreKalista(X, Y) :- ocreAt(X, Y), !.

% General predicate to get a Kalista.
kalista(X, Y, r) :- redKalista(X, Y).
kalista(X, Y, o) :- ocreKalista(X, Y).

% General predicate to get a piece.
pieceAt(X, Y) :- redAt(X, Y).
pieceAt(X, Y) :- ocreAt(X, Y).

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
verificationNewSbire(X, Y) :-	write('* Emplacement du nouveau sbire *'),
								nl,			
								readPosition(X, Y),
								\+ pieceAt(X, Y).


% To insert a new sbire.
insertNewSbire(C) :- 	repeat,
						verificationNewSbire(X, Y),
						sbireAt(X, Y, C),
						updateKhan(X, Y),
						printBoard.

% To update the position of the Khan
updateKhan(X, Y) :-	clearKhan,
					assertz(khanAt(X, Y)).
						

% To update the position of a piece
updatePosition(_, _, XNew, YNew, _) :- 	updateKhan(XNew, YNew), % Mise à jour systmétique du Khan et effacement de la pièce d'arrivée
										clearAt(XNew, YNew). 
updatePosition(XOld, YOld, XNew, YNew, C) :- 	clearAt(XOld, YOld),  % Déplacement de la Kalista si elle existe
												kalista(XOld, YOld, C), 
												kalistaAt(XNew, YNew, C), 
												!.
updatePosition(XOld, YOld, XNew, YNew, C) :- 	clearAt(XOld, YOld), % Déplacement du sbire par défaut
												sbireAt(XNew, YNew, C).

% We set the position of piece
changePiecePosition(XOld, YOld, XNew, YNew, C) :- 	updatePosition(XOld, YOld, XNew, YNew, C). % Déplacement systématique
% Cas particuliers complémentaires 
changePiecePosition(_, _, XNew, YNew, r) :-	ocreKalista(XNew, YNew), % The ocre player has lost the game							
											assertz(endOfGame),
											write('*** Bravo joueur Rouge, vous avez GAGNE !!! ***'),
											nl, nl, nl.

changePiecePosition(_, _, XNew, YNew, o) :- redKalista(XNew, YNew), % The red player has lost the game
											assertz(endOfGame),
											write('*** Bravo joueur Ocre, vous avez GAGNE !!! ***'),
											nl, nl, nl.


% To manage the choice of a player when no piece could be moved
changePositionOrNewSbire(C) :- 	repeat,
								write('Vous ne pouvez pas obéir au KHAN.'), nl,
								write('1. Déplacer une pièce sur une case de type différent de celui du KHAN'), nl,
								write('2. Insérer un nouveau sbire'), nl,
								write('Veuillez saisir votre choix (1.|2.) : '),
								read(Choice), nl,
								managePositionOrNewSbire(Choice, C, h).

% Déplacement d'une pièce en désobéissant au Khan (humain ou machine)
% C : couleur
% T : type de joueur (IA / Humain)
managePositionOrNewSbire(1, C, T) :-	write('* Déplacement de pièce sur une case de type différent de celui du KHAN *'), nl,
										printBoard,
										possiblesMoves(M, 2, C),
										handleMoveRequest(T, C, X, Y, XNew, YNew, M),
										changePiecePosition(X, Y, XNew, YNew, C),
										writeMove(X, Y, XNew, YNew),
										printBoard,
										!.

% Insertion d'un nouveau sbire suite à blocage du Khan (humain ou machine)
% ==================== TODO : Traiter le cas de la machine (T = m) ====================
managePositionOrNewSbire(2, C, T) :- 	insertNewSbire(C),
										!.
managePositionOrNewSbire(_, _) :- 	write('Veuillez sélectionner une option valide.'),
									fail. 

% We get all the red pieces
getRedPieces(RedPieces) :- setof((X, Y), redAt(X, Y),  RedPieces).

% We get all the ocre pieces
getOcrePieces(OcrePieces) :- setof((X,Y), ocreAt(X, Y), OcrePieces).


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
