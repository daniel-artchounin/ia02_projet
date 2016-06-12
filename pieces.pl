% *** The predicates below allow us to manage the pieces of the game. ***


% Pieces position definition
:- dynamic(redAt/2).
:- dynamic(ocreAt/2).
:- dynamic(khanAt/2).
% Red player has lost
:- dynamic(endOfGameR/0).
% % Ocre player has lost
:- dynamic(endOfGameO/0).

% Has one of the player won ?
endOfGame :- endOfGameR.
endOfGame :- endOfGameO.

% To get or to check the position of the kalistas 
% (first position in the dynamic facts base)
redKalista(X, Y) :- % If red player has lost, 
                    % he has no Kalista anymore
                    \+ endOfGameR, 
                    redAt(X1, Y1), 
                    !, 
                    X = X1, 
                    Y = Y1.
ocreKalista(X, Y) :-    % If ocre player has lost, 
                        % he has no Kalista anymore
                        \+ endOfGameO,
                        ocreAt(X1, Y1), 
                        !, 
                        X = X1, 
                        Y = Y1.

% General predicate to get a Kalista.
kalista(X, Y, r) :- redKalista(X, Y).
kalista(X, Y, o) :- ocreKalista(X, Y).

% General predicate to get a piece.
pieceAt(X, Y) :- redAt(X, Y).
pieceAt(X, Y) :- ocreAt(X, Y).
pieceAt(X, Y, r) :- redAt(X, Y).
pieceAt(X, Y, o) :- ocreAt(X, Y).

% Predicate to get the other player
otherPlayer(r, o).
otherPlayer(o, r).

% General predicates 
% to insert a new sbire / kalista.
sbireAt(X, Y, r) :- assertz(redAt(X, Y)), !.
sbireAt(X, Y, o) :- assertz(ocreAt(X, Y)), !.

kalistaAt(X, Y, r) :- asserta(redAt(X, Y)), !.
kalistaAt(X, Y, o) :- asserta(ocreAt(X, Y)), !.

setPieceAt(X, Y, C, s) :- sbireAt(X, Y, C), !.
setPieceAt(X, Y, C, k) :- kalistaAt(X, Y, C).

% To print a piece: 
% it is used in the 'print1D' predicate
printPiece(X, Y) :- redKalista(X, Y),
                    write('(KR)'), 
                    !. 
printPiece(X, Y) :- redAt(X, Y), 
                    write('(SR)'), 
                    !. 
printPiece(X, Y) :- ocreKalista(X, Y),
                    write('(KO)'), 
                    !. 
printPiece(X, Y) :- ocreAt(X, Y), 
                    write('(SO)'), 
                    !. 
printPiece(_, _) :- write('    ').


% To print the Khan: 
% it is used in the 'print1D' predicate
printKhan(X, Y) :-  khanAt(X, Y), 
                    write('*'), 
                    !.
printKhan(_, _) :-  write(' ').

% To verify the validity of the emplacement of a new sbire.
verificationNewSbire(X, Y) :-   
    hSep, 
    write('* Emplacement du nouveau sbire *'), 
    hSep, 
    nl,         
    readPosition(X, Y),
    \+ pieceAt(X, Y).


% To insert a new sbire for a human during the game.
insertNewSbire(C, h, X, Y) :-   
    write('* Insertion d\'un nouveau sbire *'), 
    hSep, 
    nl,
    repeat,
    verificationNewSbire(X, Y),
    sbireAt(X, Y, C),
    updateKhan(X, Y),
    printBoard,
    !.

% To insert a new sbire for a machine during the game.
insertNewSbire(C, m, X, Y) :-       
    setof(
        (X1, X2), 
        freePosition(1, 1, X1, X2), 
        L
    ), 
    % We get the first empty position which leads us 
    % to the opposite Kalista if it exists.
    findMoveToKalista(L, X, Y, C), 
    % We won't put a new sbire 
    % which makes the Khan 
    % threaten our Kalista.
    \+ isMoveDangerous((X, Y, X, Y), C), 
    hSep, 
    write('* Insertion d\'un nouveau sbire *'), 
    hSep, 
    nl,
    sbireAt(X, Y, C),
    updateKhan(X, Y),
    write('Nouveau sbire insere : '), 
    write((X, Y)), 
    nl,
    !.

% To update the position of the Khan
updateKhan(X, Y) :- clearKhan,
                    assertz(khanAt(X, Y)).
                        

% To update the position of a piece
move(XOld, YOld, XNew, YNew, C) :- 
    % Systematic update of the Khan and 
    % erasing of the arrival piece                
    updateKhan(XNew, YNew), 
    clearAt(XNew, YNew),
    updatePosition(XOld, YOld, XNew, YNew, C).

updatePosition(XOld, YOld, XNew, YNew, C) :-
    % Move of the kalista if it's a kalista    
    kalista(XOld, YOld, C), 
    clearAt(XOld, YOld),
    kalistaAt(XNew, YNew, C), 
    !.

updatePosition(XOld, YOld, XNew, YNew, C) :- 
    % Move of the sbire by default   
    clearAt(XOld, YOld), 
    sbireAt(XNew, YNew, C).

% The red player has won
changePiecePosition(XOld, YOld, XNew, YNew, r) :-   
    % The ocre player has lost the game   
    ocreKalista(XNew, YNew),  
    move(XOld, YOld, XNew, YNew, r),                        
    asserta(endOfGameO),
    hSep, 
    write('*** Bravo joueur Rouge, vous avez GAGNE !!! ***'), 
    hSep,
    nl, 
    printBoard,
    !.

% The ocre player has won
changePiecePosition(XOld, YOld, XNew, YNew, o) :-   
    % The red player has lost the game
    redKalista(XNew, YNew), 
    move(XOld, YOld, XNew, YNew, o),
    asserta(endOfGameR),
    hSep, 
    write('*** Bravo joueur Ocre, vous avez GAGNE !!! ***'), 
    hSep,
    nl,
    printBoard,
    !.

% We set the position of the piece
changePiecePosition(XOld, YOld, XNew, YNew, C) :- 
    move(XOld, YOld, XNew, YNew, C).

% To manage the choice of a player 
% when no piece could be moved
changePositionOrNewSbire(C, h) :-   
    repeat, 
    hSep,
    write('Vous ne pouvez pas obeir au KHAN.'), 
    nl,
    write('1. Deplacer une piece sur une case de type different de celui du KHAN'), 
    nl,
    write('2. Inserer un nouveau sbire'), 
    nl,
    write('Veuillez saisir votre choix (1.|2.) : '),
    hSep,
    read(Choice), 
    nl,
    managePositionOrNewSbire(Choice, C, h),
    !.

% If no piece could be moved and 
% AI has already lost a piece.
% First, it checks if it's possible 
% to hit the kalista by simply moving 
% a piece. If so, we perform that move.
% If it's not the case, it tries to 
% insert a sbire such as it can find 
% an immediate way to opposite Kalista.
% If it's also not possible, 
% it moves a piece.
changePositionOrNewSbire(C, m) :-   
    possibleMoves(Moves, 1, C, _),
    otherPlayer(C, C2), 
    kalista(XK, YK, C2),
    element((_, _, XK, YK), Moves),  
    % Eat that Kalista !                               
    managePositionOrNewSbire(1, C, m), 
    !.
changePositionOrNewSbire(C, m) :-   
    % Tries to insert a sbire such as 
    % we can eat that Kalista !
    managePositionOrNewSbire(2, C, m), 
    !.
changePositionOrNewSbire(C, m) :-   
    % Well, just move a piece at best place.
    managePositionOrNewSbire(1, C, m),
    !.

% Move of a piece without obeying 
% to the Khan (human or machine)
% C: color
% T: type of player (AI/Human)
% Insertion of a new sbire 
% because it's impossible to 
% obey to the Khan (AI/Human)
managePositionOrNewSbire(2, C, T) :-    
    insertNewSbire(C, T, _, _),
    !.

managePositionOrNewSbire(1, C, T) :-    
    hSep, 
    write('* Deplacement de type different de celui du KHAN *'), 
    hSep,
    possibleMoves(M, 2, C, _),
    handleMoveRequest(T, C, X, Y, XNew, YNew, M), 
    writeMove(X, Y, XNew, YNew),
    changePiecePosition(X, Y, XNew, YNew, C),
    !.

managePositionOrNewSbire(_, _) :-   
    write('Veuillez sélectionner une option valide.'),
    fail. 

% We get all pieces of a specific color 
% on a specific type of place.
getPiecesOnType(Pieces, C, P) :- 
    setof(
        (X, Y),
        pieceOn(X, Y, P, C), 
        Pieces
    ),
    !.
% No pieces color/type matching.
getPiecesOnType([], _, _). 

% We get all pieces of a specific color.
getPieces(Pieces, C) :- setof(
                            (X, Y), 
                            pieceAt(X, Y, C),  
                            Pieces
                        ),
                        !.
% To manage the case when there is no piece
getPieces([], _). 

% To make a list of all specific colored pieces 
% on a type of place (1, 2 or 3).
% ===> That special formatting should be used 
% only for the "possibleMoves" predicate !
getPieces(Pieces, C, P) :-  
    setof(
        (X, Y, X, Y, []), 
        pieceOn(X, Y, P, C), 
        Pieces
    ),
    !.
% To manage the case when there is no piece
getPieces([], _, _). 

% To get a specific colored piece on 
% a specific type of place (1, 2 or 3)
pieceOn(X, Y, P, C) :-  pieceAt(X, Y, C), 
                        typeOfPlace(X, Y, P). 
