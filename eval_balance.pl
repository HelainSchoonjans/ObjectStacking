/*
heuristics when the goal is to balance the boxes



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 3.0, 7/01/13
 % */

%% eval(+State, -Total_cost)
% returns the estimate of the total cost for reaching the goal
% this cost is made of two heuristics: 
% Balancing_heuristic is the unbalance that can't be corrected
% Filling_heuristic is the heuristic for filling the boxes
eval(State, balance_heuristic(Balance_heuristic, Filling_heuristic)):-
	balance_boxes_heuristic(State, Balance_heuristic),
	fill_boxes_heuristic(State, Filling_heuristic).
	

%% is_better_than(+Heuristic, +Heuristic)
% succeeds if the first heuristic is better than the second one
is_better_than(balance_heuristic(Cost1, _), balance_heuristic(Cost2, _)):-
	Cost1 < Cost2,
	!.
is_better_than(balance_heuristic(Cost1, Filling_heuristic1), balance_heuristic(Cost2, Filling_heuristic2)):-
	Cost1 = Cost2,
	Filling_heuristic1 <Filling_heuristic2.