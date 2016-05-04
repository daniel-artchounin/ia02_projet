% Sélection d un plateau
defineBoardSud([[2, 3, 1, 2, 2, 3], [2, 1, 3, 1, 3, 1], [1, 3, 2, 3, 1, 2], [3, 1, 2, 1, 3, 2], [2, 3, 1, 3, 1, 3], [2, 1, 3, 2, 2, 1]]).
defineBoardNord([[1, 2, 2, 3, 1, 2], [3, 1, 3, 1, 3, 2], [2, 3, 1, 2, 1, 3], [2, 1, 3, 2, 3, 1], [1, 3, 1, 3, 1, 2], [3, 2, 2, 1, 3, 2]]).
defineBoardOuest([[3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3], [3, 1, 3, 1, 3, 1], [2, 2, 1, 3, 2, 2]]).
defineBoardEst([[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]]).

% Sélection de postions
definePositions([['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', '']]).

% Choix du choix cote
choixCote('Nord', B) :- defineBoardNord(B).
choixCote('Sud', B) :- defineBoardSud(B).
choixCote('Ouest', B) :- defineBoardOuest(B).
choixCote('Est', B) :- defineBoardEst(B).

% Affichage du plateau de jeu
imprime_2d([], []).
imprime_2d([TBoard|QBoard], [TPos|QPos]) :- imprime(TBoard, TPos), nl, imprime_2d(QBoard, QPos). 

% Affichage d une ligne
imprime([], []).
imprime([TBoard|QBoard], [TPos|QPos]) :- write(TBoard), write('/'), write(TPos), write(' '), imprime(QBoard, QPos).

% Génération du plateau de jeu initial
initBoard(C, B, P) :- choixCote(C, B), definePositions(P), imprime_2d(B, P).

% Concatenation of two lists
concate([], L, L).
concate([T|Q], L, [T|R]) :- concate(Q, L, R). 

% Read a one dimension list
read1DList(J, N, T) :- J < N, write(J), write(') Entrez un nombre :'), nl, NewJ is J + 1, read(X), read1DList(NewJ, N, Y), concate([X], Y, T).
read1DList(J, N, T) :- J =:= N, write(J), write(') Entrez un nombre :'), nl, read(X), T = [X].

% Read a two dimensions list
read2DList(I, M, N, T) :- I < M, write('*** Ligne '), write(I), nl, NewI is I + 1, read1DList(1, N, Line), read2DList(NewI, M, N, Y), concate([Line], Y, T).
read2DList(I, M, N, T) :- I =:= M, write('*** Ligne '), write(I), nl, read1DList(1, N, Line), T=[Line].