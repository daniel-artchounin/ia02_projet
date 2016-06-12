% *** The predicates below allow us to manipulate lists. ***


% To get all the elements in a list
% Use:
% | ?- getElement([1,2,3], X).
% 
% X = 1 ? ;
% 
% X = 2 ? ;
% 
% X = 3 ? ;
% 
% no
getElement([T|_], T).
getElement([_|Q], X) :- getElement(Q, X).

% To get the first element of a list
head(T, [T|_]). 

% To get the tail of a list
tail(Q, [_|Q]). 

% To get the check if an element is
% the first element of a list
first([H|_], H).

% To get the check if a list is
% empty.
empty([]).

% To print the content of a list
myPrint([]).
myPrint([H|Q]) :-   write(H), 
                    write(' '), 
                    myPrint(Q).

% To check if an element appears at least 
% one time in a list
element(X, [X|_]) :- !.
element(X, [_|Q]) :- element(X, Q).

% To check if an element is the last element 
% of a list or to get it.
myLast(X, [X]) :- !.
myLast(X, [_|Q]) :- myLast(X, Q).

% To get the length of list.
myLength(0, []) :- !.
myLength(Long, [_|Q]) :-    myLength(L, Q), 
                            Long is L + 1.


times(_, [], 0) :-  !.
times(X, [X|Q], NB) :-  times(X, Q, N), 
                        NB is N + 1, !.
times(X, [_|Q], NB) :-  times(X, Q, NB).


% To concatenate 3 lists
% Use:
% | ?- concate([1,2], [3,4], [5,6], L).
% 
% L = [1,2,3,4,5,6]
% 
% yes
concate(X, Y, Z, L) :-  concate(X, Y, XY), 
                        concate(XY, Z, L).

% To concate 2 lists
concate([], L, L).
concate([T|Q], L, [T|R]) :- concate(Q, L, R).

% To invert a list
invert([], []) :- !.
invert([T|Q], R) :- invert(Q, OldR), 
                    concate(OldR,[T], R).

% To split a list into two list 
% (used in 'mySort' predicate)
partition(_, [], [], []) :- !.
partition(X, [H|Q], [H|L1Old], L2) :-   H =< X, 
                                        partition(X, Q, L1Old, L2).
partition(X, [H|Q], L1, [H|L2Old]) :-   H > X, 
                                        partition(X, Q, L1, L2Old).


% To sort a list.
mySort([], []) :-   !.
mySort([H|Q], R) :- partition(H, Q, L1, L2), 
                    mySort(L1, L1Tri), 
                    mySort(L2, L2Tri), 
                    concate(L1Tri, [H|L2Tri], R).

% First predicate to check if a list 
% is a sublist of another list. 
subList([], _) :- !.
subList([H|Q], L2) :-   element(H, L2), 
                        subList(Q, L2).

% Second predicate to check if a list 
% is a sublist of another list.
subList2([], _).
subList2([X|Q], [X|R]) :-   subList2(Q, R), !.
subList2([X|Q], [_|R]) :-   subList2([X|Q], R), !.

% To pull the first hit of an element in a list
pullElement(_, [], []).
pullElement(X, [X|Q], Q) :- !.
pullElement(X, [T|Q], [T|R]) :- X\=T, 
                                pullElement(X, Q, R).

% To pull all the hits of an element in a list
pullElements(_, [], []).
pullElements(X, [X|Q], R) :-    pullElements(X, Q, R), !.
pullElements(X, [T|Q], [T|R]) :-    X\=T, 
                                    pullElements(X, Q, R).

% To generate the union of two lists
union([], L, L).
union([H|T], L, R) :-   element(H, L), 
                        union(T, L, R), 
                        !.
union([H|T], L, [H|R]) :-   \+element(H, L), 
                            union(T, L, R).

% To generate the intersection of two lists
intersection([], _, []).
intersection([H|T], L, [H|R]) :-    element(H, L), 
                                    intersection(T, L, R), !.
intersection([H|T], L, R) :-    \+element(H, L), 
                                intersection(T, L, R).
                                
% This predicate allows us to flatten a list
% Examples:
% [1, 3, [5, [6, 7]]] gives us [1, 3, 5, 6, 7]
% [1, 2, [3]] gives us [1, 2, 3]
% [[1, 2, [3, 4]], [3, 5]]] gives us [1, 2, 3, 4, 3, 5]
% This predicate doesn't work when we want to check if
% a list is the flat list of another one
% Example:
% [[1, 3], 5] is the flat list of [[[1, 3], 5] 
flat([], []).
flat([[T|Q1]|Q2], Res) :-	flat([T|Q1], Q1Res), 
							flat(Q2, Q2Res), 
							concate(Q1Res, Q2Res, Res), !.
flat([T|Q], [T|Res]) :- 	flat(Q, Res).
