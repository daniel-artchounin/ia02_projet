% *** The predicates below allow us to manipulate lists. ***


head(T, [T|_]). 


tail(Q, [_|Q]). 


first([H|_], H).


empty([]).


myPrint([]).
myPrint([H|Q]) :- write(H), write(' '), myPrint(Q).


element(X, [X|_]) :- !.
element(X, [_|Q]) :- element(X, Q).


myLast(X, [X]) :- !.
myLast(X, [_|Q]) :- myLast(X, Q).


myLength(0, []) :- !.
myLength(Long, [_|Q]) :- myLength(L, Q), Long is L + 1.


times(_, [], 0) :- !.
times(X, [X|Q], NB) :- times(X, Q, N), NB is N + 1, !.
times(X, [_|Q], NB) :- times(X, Q, NB).


% To concatenate 3 lists
% Use:
% | ?- concate([1,2], [3,4], [5,6], L).
% 
% L = [1,2,3,4,5,6]
% 
% yes
concate(X, Y, Z, L) :- 	concate(X, Y, XY), 
						concate(XY, Z, L).

concate([], L, L).
concate([T|Q], L, [T|R]) :- concate(Q, L, R).


invert([], []) :- !.
invert([T|Q], R) :- invert(Q, OldR), concate(OldR,[T], R).


partition(_, [], [], []) :- !.
partition(X, [H|Q], [H|L1Old], L2) :- H =< X, partition(X, Q, L1Old, L2).
partition(X, [H|Q], L1, [H|L2Old]) :- H > X, partition(X, Q, L1, L2Old).


mySort([], []) :- !.
mySort([H|Q], R) :- partition(H, Q, L1, L2), mySort(L1, L1Tri), mySort(L2, L2Tri), concate(L1Tri, [H|L2Tri], R).


subList([], _) :- !.
subList([H|Q], L2) :- element(H, L2), subList(Q, L2).


% L1 -> [1, 7] L2 -> [8, 3, 1, 2, 7, 20] OK
% L1 -> [1, 7] L2 -> [8, 3, 7, 2, 1, 20] NO
% L1 -> [1, 7] L2 -> [8, 1, 3] NO
% L1 -> [1] L2 -> [] NO
% L1 -> [1, 7] L2 -> [8, 3, 1, 1, 1, 2, 7, 20] NO
subList2([], _).
subList2([X|Q], [X|R]) :- subList2(Q, R), !.
subList2([X|Q], [_|R]) :- subList2([X|Q], R), !.


pullElement(_, [], []).
pullElement(X, [X|Q], Q) :- !.
pullElement(X, [T|Q], [T|R]) :- X\=T, pullElement(X, Q, R).


pullElements(_, [], []).
pullElements(X, [X|Q], R) :- pullElements(X, Q, R), !.
pullElements(X, [T|Q], [T|R]) :- X\=T, pullElements(X, Q, R).


union([], L, L).
union([H|T], L, R) :- element(H, L), union(T, L, R), !.
union([H|T], L, [H|R]) :- \+element(H, L), union(T, L, R).


intersection([], _, []).
intersection([H|T], L, [H|R]) :- element(H, L), intersection(T, L, R), !.
intersection([H|T], L, R) :- \+element(H, L), intersection(T, L, R).			
