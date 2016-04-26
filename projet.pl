defineBoardSud([[2, 3, 1, 2, 2, 3], [2, 1, 3, 1, 3, 1], [1, 3, 2, 3, 1, 2], [3, 1, 2, 1, 3, 2], [2, 3, 1, 3, 1, 3], [2, 1, 3, 2, 2, 1]]).
defineBoardNord([[1, 2, 2, 3, 1, 2], [3, 1, 3, 1, 3, 2], [2, 3, 1, 2, 1, 3], [2, 1, 3, 2, 3, 1], [1, 3, 1, 3, 1, 2], [3, 2, 2, 1, 3, 2]]).
defineBoardOuest([[3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3], [3, 1, 3, 1, 3, 1], [2, 2, 1, 3, 2, 2]]).
defineBoardEst([[2, 2, 3, 1, 2, 2], [1, 3, 1, 3, 1, 3], [3, 1, 2, 2, 3, 1], [2, 3, 1, 3, 1, 2], [2, 1, 3, 1, 3, 2], [1, 3, 2, 2, 1, 3]]]).
definePositions([['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', ''], ['', '', '', '', '', '']]).

choixCote('Nord', B) :- defineBoardNord(B).
choixCote('Sud', B) :- defineBoardSud(B).
choixCote('Ouest', B) :- defineBoardOuest(B).
choixCote('Est', B) :- defineBoardEst(B).

imprime_2d([], []).
imprime_2d([TBoard|QBoard], [TPos|QPos]) :- imprime(TBoard, TPos), nl, imprime_2d(QBoard, QPos).
imprime([], []).
imprime([TBoard|QBoard], [TPos|QPos]) :- write(TBoard), write('/'), write(TPos), write(' '), imprime(QBoard, QPos).

initBoard :- defineBoard(B), 
			 definePositions(P), 
			 imprime_2d(B, P).