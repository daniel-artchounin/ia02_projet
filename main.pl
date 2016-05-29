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
% On utilisera asserta et assertz pour discriminer 
% la Khalista et les sbires (la Khalista sera en 
% tête de la base de fait, et les sbires en queue).
redKhalista(X, Y) :- redAt(X, Y), !. % Idea
ocreKhalista(X, Y) :- ocreAt(X, Y), !. % Idea


% Choice of the side of the player
% Use:
% | ?- sideChoice(e).
% 
% yes
sideChoice(s). % Default board
sideChoice(n) :- defineBoardNorth.
sideChoice(o) :- defineBoardWest.
sideChoice(e) :- defineBoardEast.


% Displays a line of the board (with pieces)
% Use:
% | ?- print1D([1,2],[a,r]). 
% 1/a 2/r 
% 
% yes
print1D([], []).
print1D([TBoard|QBoard], [TPos|QPos]) :-	write(TBoard), 
											write('/'), 
											write(TPos), 
											write(' '), 
											print1D(QBoard, QPos).


% Displays the board and the players pieces
% Use:
% | ?- print2D([[1,2],[3,4]], [[a,b],[c,d]]).
% 1/a 2/b 
% 3/c 4/d 
% 
% yes
print2D([], []).
print2D([TBoard|QBoard], [TPos|QPos]) :-	print1D(TBoard, TPos), 
											nl, 
											print2D(QBoard, QPos). 


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

possibleMoves(r, PossibleMoveList).
possibleMoves(o, PossibleMoveList).

generateMove(r, Move).
generateMove(o, Move).
