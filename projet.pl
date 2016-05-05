% Concatenation of two lists
% | ?- concate([1,2], [3,4], L).
% 
% L = [1,2,3,4]
% 
% yes
concate([], L, L).
concate([T|Q], L, [T|R]) :- concate(Q, L, R).

% 90 degree anticlockwise vector rotation
% Use:
% | ?- rotateVector([1, 2, 3, 4], R).
% 
% R = [[4],[3],[2],[1]]
% 
% yes
rotateVector([], []) :- !.
rotateVector([X|Q], T) :- rotateVector(Q, T1), concate(T1, [[X]], T). 

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
% | ?- rotateMatrix([[1,2,3],[4,5,6],[7,8,9]], M). 
% 
% M = [[3,6,9],[2,5,8],[1,4,7]]
% 
% yes
rotateMatrix([], []) :- !.
rotateMatrix([X|Q], M) :- rotateMatrix(Q, RQ), rotateVector(X, RX), concateMatrix(RX, RQ, M).

% Defininition of the board linked to the side of the player
% Use:
% | ?- defineBoardEast(B).
% 
% B = [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]]
% 
% yes
defineBoardSouth([[2, 3, 1, 2, 2, 3], [2, 1, 3, 1, 3, 1], [1, 3, 2, 3, 1, 2], [3, 1, 2, 1, 3, 2], [2, 3, 1, 3, 1, 3], [2, 1, 3, 2, 2, 1]]).
defineBoardWest(B) :- defineBoardSouth(C), rotateMatrix(C, B).
defineBoardNorth(B) :- defineBoardWest(C), rotateMatrix(C, B).
defineBoardEast(B) :- defineBoardNorth(C), rotateMatrix(C, B).

% Dust:
% defineBoardNorth([[1, 2, 2, 3, 1, 2], [3, 1, 3, 1, 3, 2], [2, 3, 1, 2, 1, 3], [2, 1, 3, 2, 3, 1], [1, 3, 1, 3, 1, 2], [3, 2, 2, 1, 3, 2]]).
% defineBoardWest([[3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3], [3, 1, 3, 1, 3, 1], [2, 2, 1, 3, 2, 2]]).
% defineBoardEast([[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]]).

% Position definition: we should modify it
definePositions([['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', '']]).

% Choice of the side of the player
% Use:
% | ?- sideChoice(e, B).
% 
% B = [[2,2,3,1,2,2],[1,3,1,3,1,3],[3,1,2,2,3,1],[2,3,1,3,1,2],[2,1,3,1,3,2],[1,3,2,2,1,3]]
% 
% yes
sideChoice(n, B) :- defineBoardNorth(B).
sideChoice(s, B) :- defineBoardSouth(B).
sideChoice(o, B) :- defineBoardWest(B).
sideChoice(e, B) :- defineBoardEast(B).

% Displays a line of the board
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
initBoard(B, P) :- write('Sélectionner votre position (n/s/o/e) :'), read(PlayerPos), sideChoice(PlayerPos, B), definePositions(P), sideChoice(s, BoardPrint), print2D(BoardPrint, P).

% Read a one dimension list
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

% Read a two dimensions list
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