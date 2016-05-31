% *** We will probably not use the predicates below. ***


% Read a one dimension list.
% Use:
% | ?- read1D(1, 2, T).
% 1) Entrez un nombre :
% 1.
% 2) Entrez un nombre :
% 2.
% 
% T = [1,2] ?
read1D(J, N, T) :-	J < N, 
					write(J), 
					write(') Entrez un nombre :'), 
					nl, 
					NewJ is J + 1, 
					read(X), 
					read1D(NewJ, N, Y), 
					concate([X], Y, T).
read1D(J, N, T) :-	J =:= N, 
					write(J), 
					write(') Entrez un nombre :'), 
					nl,
					read(X), 
					T = [X].


% Read a two dimensions list.
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
read2D(I, M, N, T) :-	I < M, 
						write('*** Ligne '), 
						write(I), 
						nl, 
						NewI is I + 1, 
						read1D(1, N, Line), 
						read2D(NewI, M, N, Y), 
						concate([Line], Y, T).
read2D(I, M, N, T) :-	I =:= M, 
						write('*** Ligne '), 
						write(I), 
						nl, 
						read1D(1, N, Line), 
						T = [Line].


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
printBoard(n, B, P) :-	rotateMatrixC(B, BPrime), 
						rotateMatrixC(BPrime, BSecond), 
						rotateMatrixC(P, PPrime), 
						rotateMatrixC(PPrime, PSecond), 
						print2D(BSecond, PSecond).
printBoard(s, B, P) :- print2D(B, P).
printBoard(o, B, P) :-	rotateMatrixC(B, BPrime), 
						rotateMatrixC(P, PPrime), 
						print2D(BPrime, PPrime).
printBoard(e, B, P) :-	rotateMatrixAC(B, BPrime), 
						rotateMatrixAC(P, PPrime), 
						print2D(BPrime, PPrime).


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
