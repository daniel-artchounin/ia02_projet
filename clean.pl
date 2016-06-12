% *** The predicates below allow us to clean some facts at the end of a game. ***


% To clean the positions at the end of a game.
cleanAll :- retractall((redAt(_,_))), 
            retractall((ocreAt(_,_))), 
            retractall(endOfGameR),
            retractall(endOfGameO),
            clearKhan.

% To clean the Khan.
clearKhan :-    retractall((khanAt(_,_))).

% To clean a specific piece.
clearAt(X, Y) :-    retractall(redAt(X, Y)),    
                    retractall(ocreAt(X, Y)).
% To clean a specific red piece.
clearAt(X, Y, r) :- retractall(redAt(X, Y)).
% To clean a specific ocre piece.
clearAt(X, Y, o) :- retractall(ocreAt(X, Y)).
