/*
Tools for initial setup.



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 3.0, 08/01/13
% */

%% initialize(-Sorted_list, -Boxes)
% generates a list of blocks sorted by volume, and
% 	the empty boxes boxes.
% no backtracking after initialization.
initialize_starting_state(state(Boxes, Sorted_list)):-
	list_id(List),
	quick_sort(List, Sorted_list),
	generate_boxes(Boxes).
	
	
%% list_id(-List)
% collects the object's IDs
list_id(Ids):-
	findall(Id, object(Id, _), Ids).

%modified quick_sort from the documentation: http://kti.mff.cuni.cz/~bartak/prolog/sorting.html
%used to sort the objects by size
quick_sort(List,Sorted):-q_sort(List,[],Sorted).
q_sort([],Acc,Acc).
q_sort([H|T],Acc,Sorted):-
	pivoting(H,T,L1,L2),
	q_sort(L1,Acc,Sorted1),q_sort(L2,[H|Sorted1],Sorted).
   
pivoting(_,[],[],[]).
pivoting(H,[X|T],[X|L],G):-
	volume_of_object(X, Volume_x),
	volume_of_object(H, Volume_h),
	Volume_x=<Volume_h,pivoting(H,T,L,G).
pivoting(H,[X|T],L,[X|G]):-
	volume_of_object(X, Volume_x),
	volume_of_object(H, Volume_h),
	Volume_x>Volume_h,pivoting(H,T,L,G).
	
%% generate_boxes(-List_of_boxes)
% generate boxes to use
generate_boxes(List_of_boxes):-
	number_of_boxes(Quantity),
	generate_boxes(Quantity, List_of_boxes).
	
%% generate_boxes(+Number_of_boxes, -List)
% returns List, a list of Number_of_boxes boxes.
generate_boxes(0, []).
generate_boxes(Number_of_boxes, [box([])|Boxes]):-
	New_number_of_boxes is Number_of_boxes-1,
	generate_boxes(New_number_of_boxes, Boxes).