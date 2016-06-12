% *** The predicates below allow us to manipulate matrices. ***


% 90 degree anticlockwise vector rotation
% Use:
% | ?- rotateVectorAC([1, 2, 3, 4], R).
% 
% R = [[4],[3],[2],[1]]
% 
% yes
rotateVectorAC([], []) :- !.
rotateVectorAC([X|Q], T) :- 
    rotateVectorAC(Q, T1), 
    concate(T1, [[X]], T). 


% 90 degree clockwise vector rotation
% Use:
% | ?- rotateVectorC([1, 2, 3, 4], R).
% 
% R = [[1],[2],[3],[4]]
% 
% yes
rotateVectorC([], []) :- !.
rotateVectorC([X|Q], T) :-  
    rotateVectorC(Q, T1), 
    concate([[X]], T1, T). 


% Concatenation of two matrices
% Use:
% | ?- concateMatrix([[1,2],[3,4]], [[1,2],[3,4]], M). 
% M = [[1,2,1,2],[3,4,3,4]]
% 
% yes
concateMatrix([], [], []) :- !.
concateMatrix(X1, [], X1) :- !.
concateMatrix([], X1, X1) :- !.
concateMatrix([X1|X2], [Y1|Y2], M) :-   
    concateMatrix(X2, Y2, M2), 
    concate(X1, Y1, L1), 
    concate([L1], M2, M).


% 90 degree anticlockwise square matrix rotation
% Use:
% | ?- rotateMatrixAC([[1,2,3],[4,5,6],[7,8,9]], M). 
% 
% M = [[3,6,9],[2,5,8],[1,4,7]]
% 
% yes
rotateMatrixAC([], []) :- !.
rotateMatrixAC([X|Q], M) :- rotateMatrixAC(Q, RQ), 
                            rotateVectorAC(X, RX), 
                            concateMatrix(RX, RQ, M).


% 90 degree clockwise square matrix rotation
% Use:
% | ?- rotateMatrixC([[1,2,3],[4,5,6],[7,8,9]], M). 
% 
% M = [[7,4,1],[8,5,2],[9,6,3]]
% 
% yes
rotateMatrixC([], []) :- !.
rotateMatrixC([X|Q], M) :-  rotateMatrixC(Q, RQ), 
                            rotateVectorC(X, RX), 
                            concateMatrix(RQ, RX, M).
