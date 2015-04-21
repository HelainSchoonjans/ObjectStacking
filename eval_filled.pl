/*
heuristics when the goal is to fill the boxes



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 3.0, 7/01/13
 %*/


%% eval(+State, -Total_cost)
% returns the estimate of the total cost for reaching the goal
eval(State, Total_cost):-
	fill_boxes_heuristic(State, Total_cost).
	
%% is_better_than(+Cost, +Cost2)
% succeeds if the first heuristic is better than the second one
is_better_than(Cost, Cost2):-
	Cost < Cost2.



