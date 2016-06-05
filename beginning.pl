% *** The predicates below allow us to manage the beginning of the game. ***


% To enter red pieces at the beginning of the game (interface).
enterPiecesB(h, r) :- 	hSep, write('* Pose initiale des six pieces du joueur ROUGE *'), hSep,
						nl,
						enterPlayerPiecesB(0, 6, r),
						!.

% To enter ocre pieces at the beginning of the game (interface).
enterPiecesB(h, o) :- 	hSep, write('* Pose initiale des six pieces du joueur OCRE *'), hSep,
						nl,
						enterPlayerPiecesB(0, 6, o),
						!.


% To enter red pieces at the beginning of the game (interface).
enterPiecesB(m, r) :-	hSep, write('* Pose initiale des six pieces du l\'IA ROUGE *'), hSep,
						nl,
						enterMachinePiecesB(0, 6, 6, 5, r),
						!.

% To enter ocre pieces at the beginning of the game (interface).
enterPiecesB(m, o) :-	hSep, write('* Pose initiale des six pieces de l\'IA OCRE *'), hSep,
						nl,
						enterMachinePiecesB(0, 6, 1, 2, o),
						!.



% To enter red pieces at the beginning of the game.
enterPlayerPiecesB(0, N, C) :-	repeat, 
								write('Position Kalista'),
								readPosition(X, Y), 
								storePositionB(X, Y, C), nl, %La Kalista est en premier dans la base de faits
								printBoard,
								enterPlayerPiecesB(1, N, C), 
								!.
enterPlayerPiecesB(N, N, _) :- !.
enterPlayerPiecesB(J, N, C) :-	repeat,				
								write('Position Sbire '), 
								write(J),
								readPosition(X, Y),
								storePositionB(X, Y, C), nl,
								printBoard,
								NewJ is J + 1,
								enterPlayerPiecesB(NewJ, N, C).

% X1 : Index of first line of pieces. 
% X2 : Index of second line of pieces.
% C : Type of player.
enterMachinePiecesB(0, N, X1, X2, C) :-	write('Position Kalista'),
										typeOfPlace(X1, J, 2), %On place la Kalista sur la première ligne, case de type 2
										writePosition(X1, J),
										storePositionB(X1, J, C), nl,
										printBoard,
										typeOfPlace(X2, J1, 1), %Case de type 1 sur la deuxième ligne
										setof((X1, J3), typeOfPlace(X1, J3, 3), R1), %Cases de type 3 sur la première ligne
										setof((X2, J3), typeOfPlace(X2, J3, 3), R2), %Cases de type 3 sur la deuxième ligne
										concate(R1, [(X2, J1)|R2], Res), %Res contient exactement 5 éléments
										enterMachinePiecesB(1, N, Res, C), 
										!.
enterMachinePiecesB(N, N, _, _) :-	!.
enterMachinePiecesB(J, N, [(X, Y)|T], C) :-	write('Position Sbire '), 
											write(J),
											writePosition(X, Y),
											storePositionB(X, Y, C), nl,
											printBoard,
											NewJ is J + 1,
											enterMachinePiecesB(NewJ, N, T, C).

% To test and perhaps store a piece position 
% typed by a user at the beginning of the game.
storePositionB(X, Y, C) :-	\+ pieceAt(X, Y),
							Y >= 1, 
							Y =< 6,
							isValidPositionB(X, Y, C),
							sbireAt(X, Y, C).


% To test the validity of a red piece position at the 
% beginning of the game.
isValidPositionB(X, _, r) :-	X >= 5, 
								X =< 6.

% To test the validity of an ocre piece position at the 
% beginning of the game.
isValidPositionB(X, _, o) :-	X >= 1, 
								X =< 2.