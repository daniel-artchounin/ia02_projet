% *** The predicates below allow us to manage the beginning of the game. ***


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


% To enter ocre pieces at the beginning of the game (interface).
machineEnterOcrePiecesB :-	write('* Pose initiale des six pièces du joueur OCRE *'),
							nl,
							machineEnterPiecesB(1, 6, o).

% To enter red pieces at the beginning of the game (interface).
machineEnterRedPiecesB :-	write('* Pose initiale des six pièces du joueur ROUGE *'),
							nl,
							machineEnterPiecesB(1, 6, r).

machineEnterPiecesB(1, N, o) :-	repeat, 
								write('Position Kalista'), 
								writePosition(1, 1),
								isValidAndStorePositionB(1, 1, o),
								printBoard,
								machineEnterPiecesB(2, N, o), 
								!.
machineEnterPiecesB(N, N, o) :-	repeat,				
								SbireNumber is N - 1,		
								write('Position Sbire '), 
								write(SbireNumber),
								writePosition(1, N),
								isValidAndStorePositionB(1, N, o),
								printBoard,				
								!.
machineEnterPiecesB(J, N, o) :-	repeat,											
								SbireNumber is J - 1,	 
								write('Position Sbire '), 
								write(SbireNumber),
								writePosition(1, J),
								isValidAndStorePositionB(1, J, o),
								printBoard,
								NewJ is J + 1,
								machineEnterPiecesB(NewJ, N, o).

machineEnterPiecesB(1, N, r) :-	repeat, 
								write('Position Kalista'), 
								writePosition(6, 1),
								isValidAndStorePositionB(6, 1, r),
								printBoard,
								machineEnterPiecesB(2, N, r), 
								!.
machineEnterPiecesB(N, N, r) :-	repeat,				
								SbireNumber is N - 1,		
								write('Position Sbire '), 
								write(SbireNumber),
								writePosition(6, N),
								isValidAndStorePositionB(6, N, r),
								printBoard,				
								!.
machineEnterPiecesB(J, N, r) :-	repeat,											
								SbireNumber is J - 1,	 
								write('Position Sbire '), 
								write(SbireNumber),
								writePosition(6, J),
								isValidAndStorePositionB(6, J, r),
								printBoard,
								NewJ is J + 1,
								machineEnterPiecesB(NewJ, N, r).


% To read, test and perhaps store a piece position 
% typed by a user at the beginning of the game.
readTestAndStorePostionB(C) :-	readPostion(X, Y),
								isValidAndStorePositionB(X, Y, C).


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


% To manage the red player first turn
redPlayerFirstTurn :- 	write('** Joueur ROUGE **'),
						nl,
						printBoard,	
						possibleRedMoves(M, 2),
						typeValidMove(X, Y, XNew, YNew, M), 
						changeRedPiecePosition(X, Y, XNew, YNew),
						writeMove(X, Y, XNew, YNew),
						printBoard.

% To manage the ocre player first turn
ocrePlayerFirstTurn :- ocrePlayerTurn.


% To manage the red player (machine) first turn
machineRedPlayerFirstTurn :-	write('** Joueur ROUGE **'),
								nl,
								printBoard,						
								possibleRedMoves(Moves, 2),
								generateMove(r, Moves, (X,Y,XNew,YNew)),
								changeRedPiecePosition(X, Y, XNew, YNew),
								writeMove(X, Y, XNew, YNew),
								printBoard.

% To manage the ocre player (machine) first turn
machineOcrePlayerFirstTurn :- machineOcrePlayerTurn.
