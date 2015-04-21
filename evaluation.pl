/*
evaluation tools for the heuristics



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 4.0, 11/01/13
 %*/


%% fill_boxes_heuristic(+State, -Total_cost)
% returns the estimate of the total cost for reaching the goal
fill_boxes_heuristic(State, Total_cost):-
	h(State, Cost_to_reach_goal),
	g(State, Actual_state_cost),
	Total_cost is Cost_to_reach_goal+Actual_state_cost.
	
%% balance_boxes_heuristic(+State, -Total_cost)
% returns the estimate of the total cost for reaching the goal when balancing the boxes
balance_boxes_heuristic(State, Total_cost):-
	g_balancing_boxes(State, Actual_state_cost),
	h_balancing_boxes(State, Distance),
	Total_cost is Distance+Actual_state_cost.
	
	
%% h(+State, -Cost)
% heuristic estimate the cost of reaching the state goal from the state
% the cost is here the volume of the unfilled spaces: the less empty spaces we have, the closer we are to a solution.
h(State, Cost):-
	unused_spaces(State, Cost).

%% g(+State, -Cost)
% actual cost of reaching the state
% the cost is here the volume that won't be filled later, for any placement of the remaining blocks.
% it can happen if the volume of the remaining blocks to put is inferior to the empty volume in the boxes
% or if the remaining spaces are just under a block bigger than the remaining ones
g(State, Cost):-
	unused_spaces(State, Unused_spaces),
	remaining_volume(State, Remaining_volume_to_place),
	Unfillable_volume is Unused_spaces-Remaining_volume_to_place,
	number_of_crushed_spaces(State, Number_of_crushed_spaces),
	max(Unfillable_volume, Number_of_crushed_spaces, Cost).
	
%% g_balancing_boxes(+State, -Cost)
% heuristic estimate the cost of reaching the state goal from actual state
% the cost is here the unbalance that can't be corrected:
% the unbalance in volume that will remain in the best case between the boxes, after all objects have been placed.
g_balancing_boxes(State, Cost):-
	remaining_volume(State, Volume_of_remaining_objects),
	weigth_difference_between_boxes(State, Box_difference),
	Uncorrectible_difference is Box_difference-Volume_of_remaining_objects,
	max(Uncorrectible_difference, 0, Cost).
	
%% h_balancing_boxes(+State, -Cost)
% heuristic estimate the cost of reaching the state goal from the state
% the cost is here the volume of the unfilled spaces, plus the difference between the two boxes' weigth.
h_balancing_boxes(State, Distance):-
	unused_spaces(State, Spaces),
	weigth_difference_between_boxes(State, Box_difference),
	Distance is Box_difference+Spaces.
	
	
%% number_of_crushed_spaces(+State, -Number)
% computes the number of spaces that can't be filled, because they are under a block bigger than any block left
number_of_crushed_spaces(state(Boxes, []), Number):-
	number_of_crushed_spaces_of_boxes(Boxes, 0, 0, Number).
number_of_crushed_spaces(state(Boxes, [Object|_]), Number):-
	volume_of_object(Object, Volume_of_biggest_object_yet_to_place),
	number_of_crushed_spaces_of_boxes(Boxes, 0, Volume_of_biggest_object_yet_to_place, Number).
	
%% number_of_crushed_spaces_of_boxes(+Boxes, +Accumulator, +Volume, -Number)
% unifies the number of crushed spaces with Number
% Volume is here the volume of the heaviest object yet to place.
number_of_crushed_spaces_of_boxes([], Result, _, Result).
number_of_crushed_spaces_of_boxes([Box|Boxes], Current_value, Volume, Number):-
	number_of_crushed_spaces_of_box(Box, Volume, Box_number_crushed_spaces),
	Next_value is Current_value+Box_number_crushed_spaces,
	number_of_crushed_spaces_of_boxes(Boxes, Next_value, Volume, Number).
	
%% number_of_crushed_spaces_of_box(+Box, +Volume, -Number)
% unifies the number of crushed spaces with Number
% Volume is here the volume of the heaviest object yet to place.
number_of_crushed_spaces_of_box(box(Content), Volume, Number):-
	number_of_crushed_spaces_of_content(Content, Content, Volume, 0, Number).
	
%% number_of_crushed_spaces_of_content(+Remaining, +Content, +Volume, +Accumulator, -Number).
% unifies the number of crushed spaces with Number
% Volume is here the volume of the heaviest object yet to place.
% Content is the placements in the box
% Remaining contains the objects yet to analyse
number_of_crushed_spaces_of_content([], _, _, Number, Number).
number_of_crushed_spaces_of_content([Placement|Placements], Content, Volume, Current_number, Number):-
	number_of_crushed_spaces_of_placement(Placement, Content, Volume, Placement_crushed_spaces_number),
	Next_number is Current_number+Placement_crushed_spaces_number,
	number_of_crushed_spaces_of_content(Placements, Content, Volume, Next_number, Number).
	
%% number_of_crushed_spaces_of_placement(+Placement, +Content, +Volume, -Number)
% unifies Number with the number of free (crushed) spaces under Placement
% an object at the bottom of the box never crushes spaces
number_of_crushed_spaces_of_placement(placement(_, coordinates(1, _, _)), _, _, 0):-
	!.
number_of_crushed_spaces_of_placement(placement(Id, coordinates(XX, YY, ZZ)), Placements, _, Number):-
	object(Id, size(_, Length, Width)),
	Bottom_surface is Length*Width,
	X is XX-1,
	Max_Y is YY-1+Length,
	Max_Z is ZZ-1+Width,
	findall(Id2, (between(YY, Max_Y, Y), between(ZZ, Max_Z, Z), is_inside(coordinates(X, Y, Z), Placements, Id2)), Occupied_spaces),
	length(Occupied_spaces, Occupied_spaces_volume),
	Number is Bottom_surface-Occupied_spaces_volume.
	
	
	

	
	
	
	