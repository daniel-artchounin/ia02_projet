% *** The predicates below allow us to manage the board. ***


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
defineBoardWest :-  board(C), 
                    rotateMatrixAC(C, B), 
                    retract(board(C)), 
                    asserta(board(B)).
defineBoardNorth :- defineBoardWest, 
                    board(C), 
                    rotateMatrixAC(C, B), 
                    retract(board(C)), 
                    asserta(board(B)).
defineBoardEast :-  board(C), 
                    rotateMatrixC(C, B), 
                    retract(board(C)), 
                    asserta(board(B)).


% Choice of the side of the player
% Use:
% | ?- sideChoice(e).
% 
% yes
sideChoice(s). % Default board
sideChoice(n) :- defineBoardNorth.
sideChoice(o) :- defineBoardWest.
sideChoice(e) :- defineBoardEast.


% Prints the board
printBoard :-   
    nl, 
    write('        1        2        3        4        5        6'), 
    nl,
    write('    +--------+--------+--------+--------+--------+--------+'), 
    nl,
    board(B), 
    print2D(B, 1, 1),
    nl.


% Displays a line of the board (with pieces):
% it is used in the 'print2D' predicate
print1D([], _, _) :-    
    nl, 
    write('    +--------+--------+--------+--------+--------+--------+').
print1D([TBoard|QBoard], I, J) :-   write(TBoard),
                                    printKhan(I, J),                                 
                                    printPiece(I, J),                                   
                                    write(' | '),
                                    NewJ is J + 1,
                                    print1D(QBoard, I, NewJ).


% Displays the board and the players pieces:
% it is used in the 'printBoard' predicate
print2D([], _, _).
print2D([TBoard|QBoard], I, J) :-   write(' '), 
                                    write(I), 
                                    write('  | '),
                                    print1D(TBoard, I, J), 
                                    nl, 
                                    NewI is I + 1,
                                    print2D(QBoard, NewI, J). 


% Initialization of the board by a human
initBoard(h) :- 
        printBoard,
        write('* Orientation du tapis selon le choix du joueur ROUGE *'),
        nl,
        write('Position (n./s./o./e.) : '), 
        read(PlayerPos),
        nl,
        write('* Selection du bord '),
        write(PlayerPos),
        write(' par le joueur ROUGE *'),
        nl,
        sideChoice(PlayerPos), 
        printBoard.


% Initialization of the board by AI
initBoard(m) :- 
        printBoard,
        write('* Orientation du tapis selon le choix de l\'IA ROUGE *'),
        nl,
        write('Position (n./s./o./e.) : '), 
        PlayerPos = n,
        nl,
        write('* Selection du bord '),
        write(PlayerPos),
        write(' par le joueur ROUGE *'),
        nl,
        sideChoice(PlayerPos), 
        printBoard.


% We get the type of a place in the board (1, 2 or 3)
typeOfPlace(I, J, P) :- board(B),
                        nth(I, B, Rows), % Build-in predicate
                        nth(J, Rows, P). % Build-in predicate

% To get the free positions of a line of the board
% (used in 'freePosition' predicate)
freePosition1D(X, Y, X, Y) :-   Y =< 6, 
                                \+ pieceAt(X, Y).
freePosition1D(X, Y, X1, X2) :- Y =< 6, 
                                YNew is Y + 1, 
                                freePosition1D(X, YNew, X1, X2).
                     
% To get the free positions of the board           
freePosition(X, Y, X1, X2) :-   X =< 6, 
                                freePosition1D(X, Y, X1, X2).
freePosition(X, Y, X1, X2) :-   X =< 6, 
                                XNew is X + 1, 
                                freePosition(XNew, Y, X1, X2).
