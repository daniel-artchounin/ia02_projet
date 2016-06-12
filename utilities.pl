% *** The predicates below are some utilities used during the game. ***

% Management of a request of move by the human
handleMoveRequest(h, _, X, Y, XNew, YNew, M) :- 
	typeValidMove(X, Y, XNew, YNew, M).
% Management of a request of move by the machine
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
playerInfo(r, h) :- hSep, 
                    write('**                       Joueur ROUGE                     **'), 
                    hSep.
playerInfo(o, h) :- hSep, 
                    write('**                       Joueur OCRE                      **'), 
                    hSep.
playerInfo(r, m) :- hSep, 
                    write('**                         IA ROUGE                       **'), 
                    hSep.
playerInfo(o, m) :- hSep, 
                    write('**                         IA OCRE                        **'), 
                    hSep.

% Hozizontal separation
hSep :- 
    nl, 
    write('------------------------------------------------------------'), 
    nl.

% To get a valid move from the user
% M: List of all possible moves
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
writePosition(X, Y) :-  nl,
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
catch(read(X), E, handleException(E, 'Erreur de lecture de la ligne.')),
write('Colonne (y.) : '),
catch(read(Y), E, handleException(E, 'Erreur de lecture de la colonne.')),
nl,
!.


% ******************************************************************************
% To do some tests with the possible moves... -> Should be removed of course !!!
% ******************************************************************************
myPrint2([]).
myPrint2([(X,Y,XNew,YNew)|Q]) :-    write(X), 
                                    write('*'), 
                                    write(Y), 
                                    write(' || '), 
                                    write(XNew), 
                                    write('*'), 
                                    write(YNew), 
                                    nl, 
                                    myPrint2(Q).


% To get the possible moves of specific colored player
% based on the Khan's position
possibleMoves(F, 1, C, H) :-   
    khanAt(X, Y), 
    % We get the type of the place of the Khan
    typeOfPlace(X, Y, P), 
    % Returns a list of pieces moves on themselves
    getPieces(Pieces, C, P), % 
    % Returns a list of pieces moves on themselves
    possibleMoves(C, Pieces, F, H, 1, P),
    !.

% To get the possible moves of specific colored player
% not based on the Khan's position:
% we generate all moves.
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
    \+ pieceAt(X, Y), % No piece during the travel
    isValidHistoryMove(X, Y, H).


% To check if a last specific move 
% (for a red piece) is valid
isValidLastMove(C, X, Y, H) :- 	
    \+ pieceAt(X, Y, C), % No piece of 
    % the color of the player at the end of travel
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
% from a place of the board, whether they are valid or not.
getNextPositions(X, Y, XNew, Y) :- 	XNew is X + 1.  
getNextPositions(X, Y, XNew, Y) :- 	XNew is X - 1.  
getNextPositions(X, Y, X, YNew) :-  YNew is Y + 1. 
getNextPositions(X, Y, X, YNew) :- 	YNew is Y - 1.


% To get all specific not last valid moves from a place of the board:
% it is used in the 'possibleMoves' predicate
% We also update the history of the move
getValidMove(Moves, XOld, YOld, NewH, XNew, YNew) :-	
    getElement(Moves, (XOld, YOld, X, Y, H)),
    getNextPositions(X, Y, XNew, YNew),
    % We verify that the future position is valid
    isValidNotLastMove(XNew, YNew, H),
    concate(H, [(X, Y)], NewH). % We update the history


% To get all specific last valid moves from a place 
% of the board: (via setof)
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
% from a list of places in the board:
% it is used in the other possibleMoves predicate
% C: The color of the user
% Moves: a list with some elements having 
% this strucutre (Xi, Yi, Xc, Yc, H),
% where (Xi, Yi) is the initial position, 
% where (Xc, Yc) is the current position
% and H a list containing the path to go 
% to (Xc, Yc) (excluded) from (Xi, Yi),
% FinalMoves: a list with some elements having 
% this structure (Xi, Yi, Xf, Yf)
% where (Xi, Yi, Xf, Yf) represents a move 
% from (Xi, Yi) to (Xf, Yf)
% H: a list with some elements (each element is a list) 
% containing the corresponding history for each move 
% mentionned above
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

% The goal of this predicate is to separate the moves and
% the history of each move and make two lists
% based on this separation
separate5Uples(Moves, FinalMoves, History) :- 
    % Interface: the two temp lists are used to increase efficiency
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

% Predicate to find a way to the opposite Kalista using a list of initial position(s): used by AI.
% C : color which attacks.
findMoveToKalista([(X, Y)|_], X, Y, C) :-	
    typeOfPlace(X, Y, P),
    otherPlayer(C, C2),
    possibleMoves(C, [(X, Y, X, Y, [])], F, _, 1, P),
    kalista(XK, YK, C2),
    element((X, Y, XK, YK), F),
    !.
findMoveToKalista([_|T], X1, Y1, C) :- 		findMoveToKalista(T, X1, Y1, C).

% Iterate over a history of moves (i.e. lists of positions (tuples)) 
% and throw all those which don't lead to the position specified by (X, Y).
filterHistoryToPos([], [], _, _) :- !. % End of history
filterHistoryToPos([H|T], [HF|P], X, Y) :- 	
    flatten(H, HF),
    myLast((X, Y), H), 
    filterHistoryToPos(T, P, X, Y),
    !. % Way found
filterHistoryToPos([_|T], P, X, Y) :-   filterHistoryToPos(T, P, X, Y). % Way not found

% This predicate simulate a move and check if our Kalista 
% is ==> immediatly <== (taking Khan into account) in danger.
isMoveDangerous((XF, YF, XT, YT), C) :- 
    kalista(XF, YF, C), % For Kalista
    khanAt(X, Y), % Memory of Khan's position
    % Should we restore the original position ?
    (pieceAt(XF, YF) -> Restore = y ; Restore = n), 
    moveDangerous((XF, YF, XT, YT, X, Y), C, k, Restore),
    % Here is the important thing : if we find a danger, 
    % we check that there is NOT in current state, 
    % otherwise the move is not dangerous itself
    \+ moveDangerous((XF, YF, XF, YF, X, Y), C, k, Restore), 
    !.

isMoveDangerous((XF, YF, XT, YT), C) :- 
    \+ kalista(XF, YF, C), % For common sbire (important to check)
    khanAt(X, Y), % Memory of Khan's position
    % Should we restore the original position ?
    (pieceAt(XF, YF) -> Restore = y ; Restore = n), 
    moveDangerous((XF, YF, XT, YT, X, Y), C, s, Restore),
    % Here is the important thing : if we find a danger, 
    % we check that there is NOT in current state, 
    % otherwise the move is not dangerous itself
    \+ moveDangerous((XF, YF, XF, YF, X, Y), C, s, Restore), 
    !.

% Internal predicate used by moveDangerous : check if simulated move 
% if dangerous, according Khan situations
% C : Our color
% (X, Y) : Final position of our move
moveDangerousAccordingKhan(C, X, Y) :- 	
    otherPlayer(C, C2),
    kalista(XK, YK, C),
    typeOfPlace(X, Y, P), % Type de place d'arrivée
    getPiecesOnType(C2Pieces, C2, P), % Pièces adverses sur le même type que la pièce d'arrivée
    empty(C2Pieces), % Khan doesn't matter
    possibleMoves(F, 2, C, _), % All opposite moves
    element((_, _, XK, YK), F), % Yes, the move is dangerous. (indirect move)
    !.

moveDangerousAccordingKhan(C, X, Y) :- 	
    otherPlayer(C, C2),
    typeOfPlace(X, Y, P), % Type de place d'arrivée
     % Pièces adverses sur le même type que la pièce d'arrivée
    getPiecesOnType(C2Pieces, C2, P),
    \+ empty(C2Pieces), % Khan matters
    % Yes, the move is dangerous (direct move)
    findMoveToKalista(C2Pieces, _, _, C2). 

restorePiece(XF, YF, _, _, C, PT, y) :- 
    setPieceAt(XF, YF, C, PT). % Get piece to its original state.
% Useful for testing insertions ! (piece wasn't on the board)
restorePiece(_, _, _, _, _, _, n). 

% Internal predicate used by isMoveDangerous.
% (XF, YF, XT, YT, KX, KY) : (X initial, Y initial, 
% X final, Y final, X mémoire du Khan, Y mémoire du Khan)
% C : Our color
% PT : Kalista ou sbire déplacé ? (k / s)
% Restore : should we restore the placed piece ? 
% Should be 'y' if we want to => force <= a restore! 
moveDangerous((XF, YF, XT, YT, KX, KY), C, PT, Restore) :- 
    clearAt(XF, YF, C), % We simulate the move
    setPieceAt(XT, YT, C, PT),
    updateKhan(XT, YT), 
    moveDangerousAccordingKhan(C, XT, YT), % Test situation
    clearAt(XT, YT, C), % Restore the previous state
    updateKhan(KX, KY),
    restorePiece(XF, YF, XT, YT, C, PT, Restore),
    !.

moveDangerous((XF, YF, XT, YT, KX, KY), C, PT, Restore) :- 	
    clearAt(XT, YT, C), % Cleaning in case of failure.
    updateKhan(KX, KY),
    restorePiece(XF, YF, XT, YT, C, PT, Restore),
    fail.

% Get a estimation a distance to C-Kalista (no matter the validity of way)
distanceToKalista(X, Y, C, D) :- 	
    kalista(XK, YK, C),
    D is (X - XK) * (X - XK) + (Y - YK) * (Y - YK).

% The predicate checks if the other player has sbire on 
% the same case type as (X, Y) and can perform a move from it.
hasSbireSameType(X, Y, C) :-	
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    typeOfPlace(X, Y, P),
    getElement(C2Pieces, (XC2, YC2)),
    typeOfPlace(XC2, YC2, P2),
    P = P2,
    possibleMoves(C, [(XC2, YC2, XC2, YC2, [])], F, _, 1, P2),
    \+ empty(F). % Can the player perform a move from that position ?

% Predicate to find the minimum of a simple nested list based on the first element.
minimumFirstSubList([X], X).
minimumFirstSubList([[D1|T1],[D2|T2]|T], N) :- 
    (D1 > D2 -> 
        minimumFirstSubList([[D2|T2]|T], N)
    ;
        minimumFirstSubList([[D1|T1]|T], N)
    ).

% I. The best move is the one which allow us to take the opposite kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2), 
    kalista(XK, YK, C2),
    element((X, Y, XK, YK), Moves),
    BestMove = (X, Y, XK, YK),
    nl, write('Job done.'), nl, 
    !.

% II. If our Kalista is threatened by an or several moves, we should try to 
% move a sbire to block the move. It is a special case as it is unlikely 
% to happen in most situations, but this is the
% optimal defensive move instead of moving the Kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    % Other player has a direct way to our Kalista (no matter what is Khan's position)
    findMoveToKalista(C2Pieces, _, _, C2), 
    possibleMoves(_, 2, C2, H), % We get all his possible moves AND moves history
    kalista(XK, YK, C), % What is the exact position of our Kalista ?
    filterHistoryToPos(H, R, XK, YK), % Which positions are part of moves which go to our Kalista ?
    flatten(R, R2), % All positions in a non-nested list
    getElement(Moves, (XF, YF, XT, YT)), % We get a possible move 
    % that we can perform (backtracking will try several positions)
    XF \= XK,
    YF \= YK, % We won't block a move with Kalista... see next predicate.
    memberchk((XT, YT), R2), % Can the move block the way to our Kalista ?
    \+ isMoveDangerous((XF, YF, XT, YT), C), % Has the blocking been effective ?
    BestMove = (XF, YF, XT, YT), % If so, we set the blocking.
    nl, write('Body blocked !'), nl, 
    !.

% III. If our Kalista is threatened and that the way can't be blocked, 
% we try to move our Kalista to a place where NO opposite sbire could move,
% ==> regardless of Khan's position <== : optimal move for Kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2), 
    getPieces(C2Pieces, C2), % We get the other player pieces
    findMoveToKalista(C2Pieces, _, _, C2), % We look if it's possible for him to hit our kalista
    possibleMoves(F2, 2, C2, _), % If it's the case, we get all the potential moves of the other user
    kalista(XK, YK, C),
    getElement(Moves, (XK, YK, XDest, YDest)), % We get a move of our kalista
    % Then, we check if the other player could hit 
    % our kalista at this new position (in the future, 
    % not especially next turn)
    \+ element((_, _, XDest, YDest), F2), 
    BestMove = (XK, YK, XDest, YDest), % If it's not the case, we will move our kalista
    nl, write('Not today !'), nl, 
    !.

% IV. If our Kalista is threatened, with no sbire blocking possibilities and no global safe place,
% we try to move our Kalista at a place where no opposite sbire can reach it ==> for the next turn <==, 
% i.e. from a place which has the same type as the future position of Kalista (because of Khan).
% This is the least optimal defensive move.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2), 
    getPieces(C2Pieces, C2), % We get the other player pieces
    findMoveToKalista(C2Pieces, _, _, C2), % We look if it's possible for him to hit our kalista
    kalista(XK, YK, C),
    getElement(Moves, (XK, YK, XDest, YDest)), % We get a move of our kalista
    \+ isMoveDangerous((XK, YK, XDest, YDest), C), % Has the defense been effective ?
    BestMove = (XK, YK, XDest, YDest), % If it's not the case, we will move our kalista
    nl, write('Maybe later...'), nl, 
    !.

% V. If we get here, there are two possibilities:
% We are not able to move our kalista, we will probably loose the game, or
% We don't need to move our kalista (that's cool...)
% In this case, we try to place a Sbire on a free position which can hit the Kalista in a future turn.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C),
    getElement(Moves, (Xi, Yi, XDest, YDest)), % We get a move
    \+ getElement([(XK, YK)], (Xi, Yi)), % We tend to not move our kalista
    \+ getElement(C2Pieces, (XDest, YDest)), % We will try to not hit an opposite sbire
    % We look if it's possible for us to hit the opposite kalista quickly
    findMoveToKalista([(XDest, YDest)], _, _, C), 
    % If we move, we hope that Kalista won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest),
    nl, write('Care.'), nl, 
    !.

% VI. We can't efficiently place our sbire, so we will move a sbire without hitting an opposite sbire.
% Here we start to generate the least bad move. We don't want the other player to disobey to the Khan.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C),
    setof(
        [D, Xi, Yi, XDest, YDest], % All moves having these properties
        (
            getElement(Moves, (Xi, Yi, XDest, YDest)), % We get a move
            % We tend to not move our kalista
            \+ getElement([(XK, YK)], (Xi, Yi)), 
            % We will try to not hit an opposite sbire
            \+ getElement(C2Pieces, (XDest, YDest)), 
            % If we move, we hope that Kalista won't be in danger next move.
            \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
            % The other player has case of the same type as our destination.
            hasSbireSameType(XDest, YDest, C), 
            % Calculate distance to opposite Kalista
            distanceToKalista(XDest, YDest, C2, D) 
        ),
    	L
    ),
    minimumFirstSubList(L, [D, Xi, Yi, XDest, YDest]),
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('We\'ll just get closer.'), nl, 
    !.

% VII. At this point, we can't move a sbire 
% to a free position without letting 
% the other player disobey to the Khan.
% So we will hit an opposite sbire. 
% In spite of everything we try to take 
% an opposite sbire which brings us 
% closer to the opposite Kalista.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C), 
    getElement(Moves, (Xi, Yi, XDest, YDest)), % We get a move
    \+ getElement([(XK, YK)], (Xi, Yi)), % We tend to not move our kalista
    element((XDest, YDest), C2Pieces), % Will we hit an opposite sbire ?
    % We look if it's possible for us to hit the opposite kalista quickly
    findMoveToKalista([(XDest, YDest)], _, _, C), 
    % If we move, we hope that Kalista won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('Eaten for a good reason.'), nl,
    !.

% VIII. We can't take a sbire which brings us close to Kalista or move to a free position.
% So we perform the first possible move (of a sbire) making the other player obey to Khan.
generateMove(C, Moves, BestMove) :- 
    first(Moves, BestMove),
    getElement(Moves, (Xi, Yi, XDest, YDest)),
    kalista(XK, YK, C),
    \+ getElement([(XK, YK)], (Xi, Yi)), % We tend to not move our kalista
    hasSbireSameType(XDest, YDest, C),
    % If we move, we hope that Kalista won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest),
    nl, write('You shall obey to Khan.'), nl,
    !.

% IX. We move a sbire on a free position. At this point we know that our fellow will disobey to Khan.
generateMove(C, Moves, BestMove) :- 
    kalista(XK, YK, C), 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    getElement(Moves, (Xi, Yi, XDest, YDest)), % We get a move
    % We tend to not move our kalista
    \+ getElement([(XK, YK)], (Xi, Yi)), 
    % We will try to not hit an opposite sbire  
    \+ getElement(C2Pieces, (XDest, YDest)), 
    % If we move, we hope that Kalista won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('You may disobey to Khan.'), nl, 
    !.

% X. Well, we'll hit an opposite sbire without reward. Maybe next time ?
generateMove(C, Moves, BestMove) :- 
    kalista(XK, YK, C), 
    getElement(Moves, (Xi, Yi, XDest, YDest)), % We get a move
    \+ getElement([(XK, YK)], (Xi, Yi)), % We tend to not move our kalista	
    % We know that it's not possible to not hit an opposite sbire
    % We know that it's not possible for us to hit the opposite kalista quickly
    % If we move, we hope that Kalista won't be in danger next move.
    \+ isMoveDangerous((Xi, Yi, XDest, YDest), C), 
    BestMove = (Xi, Yi, XDest, YDest), 
    nl, write('I\'m just angry.'), nl, 
    !.

% XI. If we are here, it means that we must move our kalista 
% (there is no other possibility)
% Consequently, we will try to move our Kalista 
% at a global safe place (no matter what type is Khan) 
% without eating a sbire.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C), 
    getElement(Moves, (XK, YK, XDest, YDest)), % We get a move
    % We will try to not hit an opposite sbire  
    \+ getElement(C2Pieces, (XDest, YDest)), 
    possibleMoves(F2, 2, C2, _),
    % Then, we check if the other player can hit our kalista quickly
    \+ element((_, _, XDest, YDest), F2), 
    BestMove = (XK, YK, XDest, YDest), % If it's not the case, we will move our kalista
    nl, write('The Kalista moves far away.'), nl, 
    !.

% XII. It's not possible to move our Kalista 
% at a safe place not only for the next turn
% Consequently, we will try to move our Kalista 
% at a safe place only for the next turn without eating a sbire.
generateMove(C, Moves, BestMove) :- 
    otherPlayer(C, C2),
    getPieces(C2Pieces, C2),
    kalista(XK, YK, C), 
    getElement(Moves, (XK, YK, XDest, YDest)), % We get a move
    \+ getElement(C2Pieces, (XDest, YDest)), % We will try to not hit an opposite sbire	
    \+ isMoveDangerous((XK, YK, XDest, YDest), C), % We check that the player won't be able to take our Kalista next turn
    BestMove = (XK, YK, XDest, YDest), % If it's not the case, we will move our kalistha
    nl, write('The Kalista is afraid.'), nl, 
    !.

% XIII. We can't move our Kalista without taking a sbire, so we take one.
generateMove(C, Moves, BestMove) :- 
    kalista(XK, YK, C), 
    getElement(Moves, (XK, YK, XDest, YDest)), % We get a move
    BestMove = (XK, YK, XDest, YDest), % If it's not the case, we will move our kalistha
    nl, write('The Kalista is confused.'), nl, 
    !.

% XIV. Damn. We really don't know what to do. 
% So we randomly perform the first possible move.
generateMove(_, Moves, BestMove) :- 
    first(Moves, BestMove),
    nl, write('Randomness.'), nl.
