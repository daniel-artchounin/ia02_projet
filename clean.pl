% *** The predicates below allow us to clean some facts at the end of a game. ***


% To clean the positions at the end of the game.
cleanAll :- 	retractall((redAt(_,_))), 
				retractall((ocreAt(_,_))), 
				retractall((endOfGame)),
				clearKhan.

% To clean the Khan.
clearKhan :- retractall((khanAt(_,_))).
