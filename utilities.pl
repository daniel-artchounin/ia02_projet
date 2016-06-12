% *** The predicates below are some utilities used during the game. ***


% Management of a request of move by a human
handleMoveRequest(h, _, X, Y, XNew, YNew, M) :- 
    typeValidMove(X, Y, XNew, YNew, M).
% Management of a request of move by a machine
handleMoveRequest(m, C, X, Y, XNew, YNew, M) :- 
    generateMove(C, M, (X, Y, XNew, YNew)).

% Management of an exception
% E: exception
% T: Error message
handleException(E, T) :-    write('Erreur : '),
                            write(E), 
                            nl,
                            write(T), 
                            nl,
                            fail.

% Displays player's name and type.
playerInfo(_, _) :- endOfGame.  
playerInfo(r, h) :- 
    hSep, 
    write('**                       Joueur ROUGE                     **'), 
    hSep.
playerInfo(o, h) :- 
    hSep, 
    write('**                       Joueur OCRE                      **'), 
    hSep.
playerInfo(r, m) :- 
    hSep, 
    write('**                         IA ROUGE                       **'), 
    hSep.
playerInfo(o, m) :- 
    hSep, 
    write('**                         IA OCRE                        **'), 
    hSep.

% Hozizontal separation.
hSep :- 
    nl, 
    write('------------------------------------------------------------'), 
    nl.

% To get a valid move from the user
% M: list of all possible moves
typeValidMove(XOld, YOld, XNew, YNew, M) :- 
    repeat,
    write('* Pion a deplacer *'), nl,
    readPosition(XOld, YOld),
    write('* Emplacement final du pion *'), nl,
    readPosition(XNew, YNew),
    element((XOld, YOld, XNew, YNew), M),
    !.

% To write the details of a move in the command line.
writeMove(X, Y, XNew, YNew) :-  
    write('Deplacement : ('), 
    write(X), 
    write(', '), 
    write(Y), 
    write(') --> ('), 
    write(XNew), 
    write(', '), 
    write(YNew), 
    write(')'),
    nl.


% To write a piece position in the command line. 
writePosition(X, Y) :-  
    nl,
    write('Ligne (x.) : '),
    write(X), 
    nl,
    write('Colonne (y.) : '),
    write(Y), 
    nl.


% To read a piece position in the command line.
readPosition(X, Y) :-   
repeat, nl,
write('Ligne (x.) : '),
catch(
    read(X), 
    E, 
    handleException(E, 'Erreur de lecture de la ligne.')
),
write('Colonne (y.) : '),
catch(
    read(Y), 
    E, 
    handleException(E, 'Erreur de lecture de la colonne.')
),
nl,
!.


% To get the possible moves of the player with 
% a specific color based on the Khan's position
possibleMoves(F, 1, C, H) :-   
    khanAt(X, Y), 
    % We get the type of the place of the Khan
    typeOfPlace(X, Y, P), 
    % Returns a list of pieces moves on themselves
    getPieces(Pieces, C, P), % 
    % Returns a list of pieces moves on themselves
    possibleMoves(C, Pieces, F, H, 1, P),
    !.

% To get the possible moves of the player with 
% a specific color not based on the Khan's 
% position: we generate all moves.
possibleMoves(F, 2, C, H) :-    
    getPieces(P1, C, 1),
    possibleMoves(C, P1, F1, H1, 1, 1),
    getPieces(P2, C, 2),
    possibleMoves(C, P2, F2, H2, 1, 2),
    getPieces(P3, C, 3),
    possibleMoves(C, P3, F3, H3, 1, 3),
    concate(F1, F2, R1),
    concate(R1, F3, F),
    concate(H1, H2, TH1),
    concate(TH1, H3, H).


% To check if a not last specific move is valid
isValidNotLastMove(X, Y, H) :-  
    % No piece during the travel
    \+ pieceAt(X, Y), 
    isValidHistoryMove(X, Y, H).


% To check if a last specific move is valid
isValidLastMove(C, X, Y, H) :-  
    % No piece of the color of 
    % the player at the end of 
    % the travel
    \+ pieceAt(X, Y, C),
    isValidHistoryMove(X, Y, H).


% To check if a specific move is not already 
% in the history and not out of board bounds.
isValidHistoryMove(X, Y, H) :-  
    X =< 6,
    X >= 1,
    Y =< 6,
    Y >= 1,
    \+ element((X, Y), H).


% To get all the potential next possible positions 
% from a place of the board, whether they are valid 
% or not.
getNextPositions(X, Y, XNew, Y) :-  
    XNew is X + 1.  
getNextPositions(X, Y, XNew, Y) :-  
    XNew is X - 1.  
getNextPositions(X, Y, X, YNew) :-  
    YNew is Y + 1. 
getNextPositions(X, Y, X, YNew) :-  
    YNew is Y - 1.


% To get all specific not last valid moves 
% from a place of the board: it is used in 
% the 'possibleMoves' predicate
% We also update the history of the move
getValidMove(Moves, XOld, YOld, NewH, XNew, YNew) :-    
    getElement(Moves, (XOld, YOld, X, Y, H)),
    getNextPositions(X, Y, XNew, YNew),
    % We verify that the future position is valid
    isValidNotLastMove(XNew, YNew, H),
    % We update the history
    concate(H, [(X, Y)], NewH). 


% To get all specific last valid moves 
% from a place of the board (using setof): 
% it is used in the 'possibleMoves' predicate
% We also update the history of the move
getValidLastMove(C, Moves, XOld, YOld, NewH, XNew, YNew) :- 
    % We get an intermediate move
    getElement(Moves, (XOld, YOld, X, Y, H)),
    % We get a possible position
    getNextPositions(X, Y, XNew, YNew),
    % We verify that the last move is valid
    isValidLastMove(C, XNew, YNew, H), 
    % We update the history
    concate(H, [(X, Y), (XNew, YNew)], NewH). 


% To make a list of all possible (full) moves 
% from a list of places in the board: it is 
% used in the other 'possibleMoves' predicate
% C: The color of the user
% Moves: a list with some elements having this 
% strucutre (Xi, Yi, Xc, Yc, H), where (Xi, Yi) 
% is the initial position, where (Xc, Yc) is the 
% current position and H a list containing the
% path to go to (Xc, Yc) (excluded) from (Xi, Yi),
% FinalMoves: a list with some elements having 
% this structure (Xi, Yi, Xf, Yf) where 
% (Xi, Yi, Xf, Yf) represents a move from (Xi, Yi) 
% to (Xf, Yf)
% H: a list with some elements (each element 
% is a list) containing the corresponding history 
% of each move mentionned above
% J: iterator
% N: To know that we should manage the last move
possibleMoves(C, Moves, FinalMoves, H, N, N) :- 
    setof( % Last move
        (XOld, YOld, XNew, YNew, TmpH), 
        getValidLastMove(C, Moves, XOld, YOld, TmpH, XNew, YNew), 
        TmpFinalMoves
    ),
    separate5Uples(TmpFinalMoves, FinalMoves, H),
                                                !.
possibleMoves(C, Moves, FinalMoves, H, J, N) :- 
    setof( % Not last move
        (XOld, YOld, XNew, YNew, TmpH), 
        getValidMove(Moves, XOld, YOld, TmpH, XNew, YNew), 
        PossibMoves
    ), 
    JNew is J + 1,
    possibleMoves(C, PossibMoves, FinalMoves, H, JNew, N),
    !.
possibleMoves(_, _, [], [], _, _).

% The goal of this predicate is to separate the 
% moves and the history of each move to make two 
% lists based on this separation
separate5Uples(Moves, FinalMoves, History) :- 
    % Interface: the two temp lists are used 
    % to increase efficiency
    separate5Uples(Moves, [], [], FinalMoves, History). 
separate5Uples([], FinalMoves,  History, FinalMoves, History) :- !.
separate5Uples(
    [(Xi, Yi, Xf, Yf, H)|QTmpFinalMoves], 
    TmpFinalMoves, 
    TempH, 
    FinalMoves, 
    History
) :-    
    separate5Uples(
        QTmpFinalMoves, 
        [(Xi, Yi, Xf, Yf)|TmpFinalMoves],  
        [H|TempH], 
        FinalMoves, 
        History
    ),
    !.
separate5Uples(
    [_|QTmpFinalMoves], 
    TmpFinalMoves, 
    TempH, 
    FinalMoves, 
    History
) :-
    separate5Uples(
        QTmpFinalMoves, 
        TmpFinalMoves,  
        TempH, 
        FinalMoves, 
        History
    ).


% Predicate to find a way to the opposite Kalista 
% using a list of initial position(s): used by AI.
% C: color of the player who attacks.
findMoveToKalista([(X, Y)|_], X, Y, C) :-   
    typeOfPlace(X, Y, P),
    otherPlayer(C, C2),
    possibleMoves(C, [(X, Y, X, Y, [])], F, _, 1, P),
    kalista(XK, YK, C2),
    element((X, Y, XK, YK), F),
    !.
findMoveToKalista([_|T], X1, Y1, C) :-  
    findMoveToKalista(T, X1, Y1, C).

% Iterate over a history of moves (i.e. lists 
% of positions (tuples)) and throw all those 
% which don't lead to the position specified 
% by (X, Y).
filterHistoryToPos([], [], _, _) :- 
    % End of history
    !. 
filterHistoryToPos([H|T], [HF|P], X, Y) :-  
    flat(H, HF),
    myLast((X, Y), H), 
    filterHistoryToPos(T, P, X, Y),
    !. % Way found
filterHistoryToPos([_|T], P, X, Y) :-
    % Way not found   
    filterHistoryToPos(T, P, X, Y). 


% This predicate simulates a move and check if 
% our Kalista is ==> immediatly <== (taking Khan 
% into account) in danger.
isMoveDangerous((XF, YF, XT, YT), C) :- 
    kalista(XF, YF, C), % For Kalista
    khanAt(X, Y), % Memory of Khan's position
    % Should we restore the original position ?
    (pieceAt(XF, YF) -> Restore = y ; Restore = n), 
    moveDangerous((XF, YF, XT, YT, X, Y), C, k, Restore),
    % Here is the important thing: if we find a danger, 
    % we check if it's not already the case in the 
    % current state, otherwise, we consider that the 
    % move is not dangerous.
    \+ moveDangerous((XF, YF, XF, YF, X, Y), C, k, Restore), 
    !.

isMoveDangerous((XF, YF, XT, YT), C) :-
    % For sbire (it's also important to check it) 
    \+ kalista(XF, YF, C), 
    khanAt(X, Y), % Memory of Khan's position
    % Should we restore the original position ?
    (pieceAt(XF, YF) -> Restore = y ; Restore = n), 
    moveDangerous((XF, YF, XT, YT, X, Y), C, s, Restore),
    % Here is the important thing: if we find a danger, 
    % we check if it's not already the case in the 
    % current state, otherwise, we consider that the 
    % move is not dangerous.
    \+ moveDangerous((XF, YF, XF, YF, X, Y), C, s, Restore), 
    !.

% Internal predicate used by moveDangerous: 
% it checks if the simulated move is dangerous, 
% based on the Khan's position
% C: our color
% (X, Y): final position of our move
moveDangerousAccordingKhan(C, X, Y) :-  
    otherPlayer(C, C2),
    kalista(XK, YK, C),
    % Type of the arrival place
    typeOfPlace(X, Y, P), 
    % Opposite pieces on the same type of places
    % as the arrival place
    getPiecesOnType(C2Pieces, C2, P), 
    empty(C2Pieces), % Khan doesn't matter
    % All opposite moves
    possibleMoves(F, 2, C, _), 
    % Yes, the move is dangerous (indirect move)
    element((_, _, XK, YK), F), 
    !.

moveDangerousAccordingKhan(C, X, Y) :-  
    otherPlayer(C, C2),
    % Type of the arrival place
    typeOfPlace(X, Y, P), 
    % Opposite pieces on the same type of places
    % as the arrival place
    getPiecesOnType(C2Pieces, C2, P),
    \+ empty(C2Pieces), % Khan matters
    % Yes, the move is dangerous (direct move)
    findMoveToKalista(C2Pieces, _, _, C2). 

restorePiece(XF, YF, _, _, C, PT, y) :- 
    % Get piece to its original state.
    setPieceAt(XF, YF, C, PT). 
% Useful for testing insertions ! 
% (piece wasn't on the board)
restorePiece(_, _, _, _, _, _, n). 

% Internal predicate used by 'isMoveDangerous'.
% (XF, YF, XT, YT, KX, KY) : (X initial, Y initial, 
% X final, Y final, KX Khan's memory, KY Khan's 
% memory)
% C: our color
% PT: Kalista ou sbire moved ? (k/s)
% Restore: should we restore the placed piece ? 
% Should be 'y' if we want to => force <= a restore! 
moveDangerous((XF, YF, XT, YT, KX, KY), C, PT, Restore) :- 
    clearAt(XF, YF, C), % We simulate the move
    setPieceAt(XT, YT, C, PT),
    updateKhan(XT, YT), 
    % Test situation
    moveDangerousAccordingKhan(C, XT, YT),
    % Restore the previous state 
    clearAt(XT, YT, C), 
    updateKhan(KX, KY),
    restorePiece(XF, YF, XT, YT, C, PT, Restore),
    !.

moveDangerous((XF, YF, XT, YT, KX, KY), C, PT, Restore) :-  
    % Cleaning in case of failure.
    clearAt(XT, YT, C), 
    updateKhan(KX, KY),
    restorePiece(XF, YF, XT, YT, C, PT, Restore),
    fail.

% Get an estimation of the distance to 
% the C-colored Kalista (no matter the 
% validity of way)
distanceToKalista(X, Y, C, D) :-    
    kalista(XK, YK, C),
    D is (X - XK) * (X - XK) + (Y - YK) * (Y - YK).

% The predicate checks if the other player 
% has sbire on the same type of places as 
% (X, Y) and can perform a move from it.
hasSbireSameType(X, Y, C) :-    
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    typeOfPlace(X, Y, P),
    getElement(C2Pieces, (XC2, YC2)),
    typeOfPlace(XC2, YC2, P2),
    P = P2,
    possibleMoves(C, [(XC2, YC2, XC2, YC2, [])], F, _, 1, P2),
    % Can the player perform a move from that position ?
    \+ empty(F). 

% Predicate to find the minimum of 
% a simple nested list based on the 
% first element.
minimumFirstSubList([X], X).
minimumFirstSubList([[D1|T1],[D2|T2]|T], N) :- 
    (D1 > D2 -> 
        minimumFirstSubList([[D2|T2]|T], N)
    ;
        minimumFirstSubList([[D1|T1]|T], N)
    ).

% I. The best move is the one which allow 
% us to take the opposite kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2), 
    kalista(XK, YK, C2),
    element((X, Y, XK, YK), Moves),
    BestMove = (X, Y, XK, YK),
    nl, 
    write('Job done.'), 
    nl, 
    !.

% II. If our Kalista is threatened by one or 
% several moves, we should try to move a sbire 
% to block the move. It is a special case as 
% it is unlikely to happen in most situations, 
% but this is the optimal defensive move instead 
% of moving the Kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    % Other player has a direct way to our Kalista 
    % (no care about Khan's position)
    findMoveToKalista(C2Pieces, _, _, C2), 
    % We get all his possible moves AND moves history
    possibleMoves(_, 2, C2, H), 
    % What is the exact position of our Kalista ?
    kalista(XK, YK, C), 
    % Which positions are part of moves to go to 
    % our Kalista ?
    filterHistoryToPos(H, R, XK, YK), 
    % All positions in a non-nested list
    flat(R, R2), 
    % We get a possible move that we can perform 
    % (backtracking will try several positions)
    getElement(Moves, (XF, YF, XT, YT)),    
    % We won't block the move with our Kalista... 
    % Just have a look to the next predicate 
    XF \= XK,
    YF \= YK,
    % Can the move block the way to our Kalista ?
    memberchk((XT, YT), R2), 
    % Has the blocking been efficient ?
    \+ isMoveDangerous((XF, YF, XT, YT), C), 
    % If so, we set the blocking.
    BestMove = (XF, YF, XT, YT), 
    nl, 
    write('Body blocked !'), 
    nl, 
    !.

% III. If our Kalista is threatened and that 
% the way can't be blocked, we try to move our 
% Kalista to a place where NO opposite sbire could 
% move, ==> without taking care of Khan's 
% position <==: it's the optimal move for 
% Kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2), 
    % We get the other player pieces
    getPieces(C2Pieces, C2),
    % We look if it's possible for him 
    % to hit our kalista
    findMoveToKalista(C2Pieces, _, _, C2), 
    % If it's the case, we get all the potential 
    % moves of the other user
    possibleMoves(F2, 2, C2, _), 
    kalista(XK, YK, C),
    % We get a move of our kalista
    getElement(Moves, (XK, YK, XDest, YDest)), 
    % Then, we check if the other player could hit 
    % our kalista at this new position (in the future, 
    % not especially next turn)
    \+ element((_, _, XDest, YDest), F2), 
    % If it's not the case, we will move our kalista
    BestMove = (XK, YK, XDest, YDest), 
    nl, write('Not today !'), nl, 
    !.

% IV. If our Kalista is threatened, with no sbire blocking 
% possibilities and no global safe place, we try to move 
% our Kalista at a place where no opposite sbire can reach 
% it ==> for the next turn <==, i.e. from a place which has 
% the same type as the future position of Kalista (because 
% of Khan). This is the least optimal defensive move.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2), 
    % We get the other player pieces
    getPieces(C2Pieces, C2), 
    % We look if it's possible for him to hit our kalista
    findMoveToKalista(C2Pieces, _, _, C2), 
    kalista(XK, YK, C),
    % We get a move of our kalista
    getElement(Moves, (XK, YK, XDest, YDest)), 
    % Has the defense been efficient ?
    \+ isMoveDangerous((XK, YK, XDest, YDest), C), 
    % If it's not the case, we will move our kalista
    BestMove = (XK, YK, XDest, YDest), 
    nl, write('Maybe later...'), nl, 
    !.

% V. If we get here, there are two possibilities:
% We are not able to move our kalista, we will 
% probably loose the game, or we don't need to move 
% our kalista (that's cool...)
% In the last case, we try to place a Sbire on a 
% free position which can hit the Kalista in a 
% future turn.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C),
    % We get a move
    getElement(Moves, (Xi, Yi, XDest, YDest)), 
    % We tend to not move our kalista
    \+ getElement([(XK, YK)], (Xi, Yi)), 
    % We will try to not hit an opposite sbire
    \+ getElement(C2Pieces, (XDest, YDest)), 
    % We look if it's possible for us to hit 
    % the opposite kalista quickly
    findMoveToKalista([(XDest, YDest)], _, _, C), 
    % If we move, we hope that Kalista won't be 
    % in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest),
    nl, write('Care.'), nl, 
    !.

% VI. We can't efficiently place our sbire, so we will 
% try to move a sbire without hitting an opposite sbire.
% Here, we start to generate the least bad move. We 
% don't want the other player to disobey to the Khan.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C),
    setof(
        % All moves having these properties
        [D, Xi, Yi, XDest, YDest], 
        (
            % We get a move
            getElement(Moves, (Xi, Yi, XDest, YDest)), 
            % We tend to not move our kalista
            \+ getElement([(XK, YK)], (Xi, Yi)), 
            % We will try to not hit an opposite sbire
            \+ getElement(C2Pieces, (XDest, YDest)), 
            % If we move, we hope that Kalista won't 
            % be in danger next move.
            \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
            % The other player has at least a piece on the 
            % same type of place as our destination.
            hasSbireSameType(XDest, YDest, C), 
            % Calculate distance to opposite Kalista
            distanceToKalista(XDest, YDest, C2, D) 
        ),
        L
    ),
    minimumFirstSubList(L, [D, Xi, Yi, XDest, YDest]),
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, 
    write('We\'ll just get closer.'), 
    nl, 
    !.

% VII. At this point, we can't move a sbire to a free 
% position without letting the other player disobey 
% to the Khan. So we will hit an opposite sbire. 
% Nevertheless, we try to take an opposite sbire 
% which brings us closer to the opposite Kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C), 
    % We get a move
    getElement(Moves, (Xi, Yi, XDest, YDest)), 
    % We tend to not move our kalista
    \+ getElement([(XK, YK)], (Xi, Yi)), 
    % Will we hit an opposite sbire ?
    element((XDest, YDest), C2Pieces), 
    % We look if it's possible for us to hit the 
    % opposite kalista quickly
    findMoveToKalista([(XDest, YDest)], _, _, C), 
    % If we move, we hope that Kalista won't be 
    % in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('Eaten for a good reason.'), nl,
    !.

% VIII. We can't take a sbire which brings us close
% to the Kalista or move to a free position. So, we 
% perform the first possible move (of a sbire) making 
% the other player obey to Khan.
generateMove(C, Moves, BestMove) :- 
    first(Moves, BestMove),
    getElement(Moves, (Xi, Yi, XDest, YDest)),
    kalista(XK, YK, C),
    % We tend to not move our kalista
    \+ getElement([(XK, YK)], (Xi, Yi)), 
    hasSbireSameType(XDest, YDest, C),
    % If we move, we hope that Kalista 
    % won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest),
    nl, write('You shall obey to Khan.'), nl,
    !.

% IX. We move a sbire on a free position. At this point,
% we know that our fellow will disobey to Khan.
generateMove(C, Moves, BestMove) :- 
    kalista(XK, YK, C), 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    % We get a move
    getElement(Moves, (Xi, Yi, XDest, YDest)), 
    % We tend to not move our kalista
    \+ getElement([(XK, YK)], (Xi, Yi)), 
    % We will try to not hit an opposite sbire  
    \+ getElement(C2Pieces, (XDest, YDest)), 
    % If we move, we hope that Kalista 
    % won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('You may disobey to Khan.'), nl, 
    !.

% X. Well, we'll hit an opposite sbire without 
% reward for the next player. Maybe next time ?
generateMove(C, Moves, BestMove) :- 
    kalista(XK, YK, C), 
    % We get a move
    getElement(Moves, (Xi, Yi, XDest, YDest)),
    % We tend to not move our kalista 
    \+ getElement([(XK, YK)], (Xi, Yi)),   
    % We know that it's not possible to not 
    % hit an opposite sbire We know that it's 
    % not possible for us to hit the opposite 
    % kalista quickly. If we move, we hope that
    % Kalista won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('I\'m just angry.'), nl, 
    !.

% XI. If we are here, it means that we must move 
% our kalista (there is no other possibility)
% Consequently, we will try to move our Kalista 
% at a global safe place (no care about Khan's 
% type of place) without eating a sbire.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C), 
    % We get a move
    getElement(Moves, (XK, YK, XDest, YDest)), 
    % We will try to not hit an opposite sbire  
    \+ getElement(C2Pieces, (XDest, YDest)), 
    possibleMoves(F2, 2, C2, _),
    % Then, we check if the other player can hit 
    % our kalista quickly
    \+ element((_, _, XDest, YDest), F2),
    % If it's not the case, we will move our kalista 
    BestMove = (XK, YK, XDest, YDest), 
    nl, write('The Kalista moves far away.'), nl, 
    !.

% XII. It's not possible to move our Kalista 
% at a safe place not only for the next turn.
% Consequently, we will try to move our Kalista 
% at a safe place only for the next turn without 
% eating a sbire.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C), 
    % We get a move
    getElement(Moves, (XK, YK, XDest, YDest)), 
    % We will try to not hit an opposite sbire 
    \+ getElement(C2Pieces, (XDest, YDest)), 
    % We check that the player won't be able 
    % to take our Kalista next turn
    \+ isMoveDangerous((XK, YK, XDest, YDest), C), 
    % If it's not the case, we will move our Kalista
    BestMove = (XK, YK, XDest, YDest), 
    nl, write('The Kalista is afraid.'), nl, 
    !.

% XIII. We can't move our Kalista without 
% taking a sbire, so we take one.
generateMove(C, Moves, BestMove) :- 
    kalista(XK, YK, C), 
     % We get a move
    getElement(Moves, (XK, YK, XDest, YDest)),
    BestMove = (XK, YK, XDest, YDest), 
    nl, 
    write('The Kalista is confused.'), 
    nl, 
    !.

% XIV. Damn. We really don't know what to do. 
% So we randomly perform the first possible 
% move.
generateMove(_, Moves, BestMove) :- 
    first(Moves, BestMove),
    nl, 
    write('Randomness.'), 
    nl.
