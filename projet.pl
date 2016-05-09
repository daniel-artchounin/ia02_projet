% Concatenation of two lists
% Use:
% | ?- concate([1,2], [3,4], L).
% 
% L = [1,2,3,4]
% 
% yes
concate([], L, L).
concate([T|Q], L, [T|R]) :- concate(Q, L, R).


% 90 degree anticlockwise vector rotation
% Use:
% | ?- rotateVectorAC([1, 2, 3, 4], R).
% 
% R = [[4],[3],[2],[1]]
% 
% yes
rotateVectorAC([], []) :- !.
rotateVectorAC([X|Q], T) :- rotateVectorAC(Q, T1), concate(T1, [[X]], T). 


% 90 degree clockwise vector rotation
% Use:
% | ?- rotateVectorC([1, 2, 3, 4], R).
% 
% R = [[1],[2],[3],[4]]
% 
% yes
rotateVectorC([], []) :- !.
rotateVectorC([X|Q], T) :- rotateVectorC(Q, T1), concate([[X]], T1, T). 


% Concatenation of two matrices
% Use:
% | ?- concateMatrix([[1,2],[3,4]], [[1,2],[3,4]], M).                                                                                           
% M = [[1,2,1,2],[3,4,3,4]]
% 
% yes
concateMatrix([], [], []) :- !.
concateMatrix(X1, [], X1) :- !.
concateMatrix([], X1, X1) :- !.
concateMatrix([X1|X2], [Y1|Y2], M) :- concateMatrix(X2, Y2, M2), concate(X1, Y1, L1), concate([L1], M2, M).


% 90 degree anticlockwise square matrix rotation
% Use:
% | ?- rotateMatrixAC([[1,2,3],[4,5,6],[7,8,9]], M). 
% 
% M = [[3,6,9],[2,5,8],[1,4,7]]
% 
% yes
rotateMatrixAC([], []) :- !.
rotateMatrixAC([X|Q], M) :- rotateMatrixAC(Q, RQ), rotateVectorAC(X, RX), concateMatrix(RX, RQ, M).


% 90 degree clockwise square matrix rotation
% Use:
% | ?- rotateMatrixC([[1,2,3],[4,5,6],[7,8,9]], M). 
% 
% M = [[7,4,1],[8,5,2],[9,6,3]]
% 
% yes
rotateMatrixC([], []) :- !.
rotateMatrixC([X|Q], M) :- rotateMatrixC(Q, RQ), rotateVectorC(X, RX), concateMatrix(RQ, RX, M).


% Defininition of the board linked to the side of the player
% Use:
% | ?- defineBoardEast(B).
% 
% B = [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]]
% 
% yes
:- dynamic(board/1).
board([[2, 3, 1, 2, 2, 3], [2, 1, 3, 1, 3, 1], [1, 3, 2, 3, 1, 2], [3, 1, 2, 1, 3, 2], [2, 3, 1, 3, 1, 3], [2, 1, 3, 2, 2, 1]]).
defineBoardWest :- board(C), rotateMatrixAC(C, B), retract(board(C)), asserta(board(B)).
defineBoardNorth :- defineBoardWest, board(C), rotateMatrixAC(C, B), retract(board(C)), asserta(board(B)).
defineBoardEast :- board(C), rotateMatrixC(C, B), retract(board(C)), asserta(board(B)).


% Dust:
% defineBoardNorth([[1, 2, 2, 3, 1, 2], [3, 1, 3, 1, 3, 2], [2, 3, 1, 2, 1, 3], [2, 1, 3, 2, 3, 1], [1, 3, 1, 3, 1, 2], [3, 2, 2, 1, 3, 2]]).
% defineBoardWest([[3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3], [3, 1, 3, 1, 3, 1], [2, 2, 1, 3, 2, 2]]).
% defineBoardEast([[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]]).


% Position definition:
:- dynamic(red_at/2).
:- dynamic(ocre_at/2).
% On utilisera asserta et assertz pour discriminer la Khalista et les sbires (la Khalista sera en tête de la base de fait, et les sbires en queue).
r_khalista(X, Y) :- red_at(X, Y), !. %Idée


% Choice of the side of the player
% Use:
% | ?- sideChoice(e).
% 
% B = [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]]
% 
% yes
sideChoice(n) :- defineBoardNorth.
sideChoice(s). % Default board
sideChoice(o) :- defineBoardWest.
sideChoice(e) :- defineBoardEast.


% Displays a line of the board (with pieces)
% Use:
% | ?- print1D([1,2],[a,r]). 
% 1/a 2/r 
% 
% yes
print1D([], []).
print1D([TBoard|QBoard], [TPos|QPos]) :- write(TBoard), write('/'), write(TPos), write(' '), print1D(QBoard, QPos).


% Displays the board and the players pieces
% Use:
% | ?- print2D([[1,2],[3,4]], [[a,b],[c,d]]).
% 1/a 2/b 
% 3/c 4/d 
% 
% yes
print2D([], []).
print2D([TBoard|QBoard], [TPos|QPos]) :- print1D(TBoard, TPos), nl, print2D(QBoard, QPos). 


% Displays the board and the players pieces (based on the side of the player)
% Use:
% | ?- printBoard(e, [[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]], [['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', '']]).
% 2/ 3/ 1/ 2/ 2/ 3/ 
% 2/ 1/ 3/ 1/ 3/ 1/ 
% 1/ 3/ 2/ 3/ 1/ 2/ 
% 3/ 1/ 2/ 1/ 3/ 2/ 
% 2/ 3/ 1/ 3/ 1/ 3/ 
% 2/ 1/ 3/ 2/ 2/ 1/ 
% 
% yes
printBoard(n, B, P) :- rotateMatrixC(B, BPrime), rotateMatrixC(BPrime, BSecond), rotateMatrixC(P, PPrime), rotateMatrixC(PPrime, PSecond), print2D(BSecond, PSecond).
printBoard(s, B, P) :- print2D(B, P).
printBoard(o, B, P) :- rotateMatrixC(B, BPrime), rotateMatrixC(P, PPrime), print2D(BPrime, PPrime).
printBoard(e, B, P) :- rotateMatrixAC(B, BPrime), rotateMatrixAC(P, PPrime), print2D(BPrime, PPrime).


% Read a one dimension list: we will probably not use it
% Use:
% | ?- read1D(1, 2, T).
% 1) Entrez un nombre :
% 1.
% 2) Entrez un nombre :
% 2.
% 
% T = [1,2] ?
read1D(J, N, T) :- J < N, write(J), write(') Entrez un nombre :'), nl, NewJ is J + 1, read(X), read1D(NewJ, N, Y), concate([X], Y, T).
read1D(J, N, T) :- J =:= N, write(J), write(') Entrez un nombre :'), nl, read(X), T = [X].


% Read a two dimensions list: we will probably not use it
% Use:
% | ?- read2D(1, 2, 2, T). 
% *** Ligne 1
% 1) Entrez un nombre :
% 1.
% 2) Entrez un nombre :
% 2.
% *** Ligne 2
% 1) Entrez un nombre :
% 3.
% 2) Entrez un nombre :
% 4.
% 
% T = [[1,2],[3,4]] ?
read2D(I, M, N, T) :- I < M, write('*** Ligne '), write(I), nl, NewI is I + 1, read1D(1, N, Line), read2D(NewI, M, N, Y), concate([Line], Y, T).
read2D(I, M, N, T) :- I =:= M, write('*** Ligne '), write(I), nl, read1D(1, N, Line), T=[Line].


% Initialization of the board: we should modify it
% Use:
% | ?- initBoard(B, P).
% Sélectionner votre position (n/s/o/e) :e.
% 2/ 3/ 1/ 2/ 2/ 3/ 
% 2/ 1/ 3/ 1/ 3/ 1/ 
% 1/ 3/ 2/ 3/ 1/ 2/ 
% 3/ 1/ 2/ 1/ 3/ 2/ 
% 2/ 3/ 1/ 3/ 1/ 3/ 
% 2/ 1/ 3/ 2/ 2/ 1/ 
% 
% B = [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]]
% P = [['','','','','',''],['','','','','',''],['','','','','',''],['','','','','',''],['','','','','',''],['','','','','','']]
% 
% yes
initBoard(B, P) :- write('Sélectionner votre position (n/s/o/e) :'), read(PlayerPos), sideChoice(PlayerPos, B), definePositions(P), printBoard(PlayerPos, B, P).


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
getPosition(I, J) :- read(I), read(J), I >= 1, I =< 6, J >= 1, J =< 6. 


% We get a piece in the position board
% Use: 
% | ?- pieceAt(1, 4, [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]], E).
% 
% E = 1
% 
% yes
pieceAt(1, 1, [H|_], H) :- !.
pieceAt(1, J, [H|_], E) :- pieceAt(J, 1, H, E), !.
pieceAt(I, J, [_|Q], E) :- IPrime is I - 1, pieceAt(IPrime, J, Q, E).
