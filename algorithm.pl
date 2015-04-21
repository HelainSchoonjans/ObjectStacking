/*
Miscellaneous tools for everything.



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 4.0, 11/12/13
% */


	
%% fill_boxes(+Blocks, +Boxes, -Final_boxes)
% fills thes Boxes with the Blocks, and returns the resulting Final_boxes
fill_boxes([], Boxes, Boxes).
fill_boxes([Block|Blocks], Boxes, Final_boxes):-
	put(Block, Boxes, New_boxes),
	fill_boxes(Blocks, New_boxes, Final_boxes).
	
%% put(+Block_id, +Boxes, -New_boxes)
% put the block of Block_id into one of the boxes,
% or remove the block if it can't be done
% There is no more box, the block is ignored
put(_, [], []).
% the block fits into the box
put(Block, [Box|Boxes], [New_box|Boxes]):-
	put_in_box(Block, Box, New_box).
% the block is rotated to fit
% TAG:[ROTATE]
put(Id, [Box|Boxes], [New_box|Boxes]):-
	rotation_activated,
	retract(object(Id, Size)),
	rotate(Size, New_size),
	assert(object(Id, New_size)),
	put_in_box(Id, Box, New_box).
% the block can't fit, the next box is tried.
put(Block, [Box|Boxes], [Box|New_boxes]):-
	put(Block, Boxes, New_boxes).
	
%% rotate(+Size, -New_size).
% exchange the dimensions of the block
% TAG:[ROTATE]
rotate(size(Height, Length, Width), size(Length, Height, Width)).
	
%% put_in_box(+Id, +Box, -New_box))
% tries to put the object in the Box, and return the resulting New_box
% must ensure the placement fits into the box bounds, 
% 	that no objects are at the same place and
%	that they aren't on a smaller object.
put_in_box(Id, box(Blocks), box([placement(Id, coordinates(X, Y, Z))|Blocks])):-
	in_box_bounds(placement(Id, coordinates(X, Y, Z))),
	no_superposition(placement(Id, coordinates(X, Y, Z)), Blocks),
	has_a_support(placement(Id, coordinates(X, Y, Z)), Blocks),
	is_not_under_bigger(placement(Id, coordinates(X, Y, Z)), Blocks).
	
	
%% run(-Results)
% initialise the algorithm and runs it.
run(Results):-
	initialize_starting_state(State),
	search_bstf([State], Results).
	

%% search_bstf(+States, -Goal, CAgenda)
% optimal best-first search, inspired from the reference book, chapter 5 and 6
search_bstf([],[]).
search_bstf([Goal|_],Goal):-
	goal(Goal).
search_bstf([Current|Rest],Goal):-
	children(Current,Children),
	add_bstf(Children,Rest,New_agenda),
	search_bstf(New_agenda,Goal).
	
%% goal(+Goal)
% succeeds if the state is a goal state: no more boxes can be placed.
% there is no more objects to place in the boxes.
goal(state(_, [])).
	
%% add_bstf(+A,+B,-C) 
% C contains the elements of A and B
% (B and C sorted according to eval/2)
add_bstf([],Agenda,Agenda).
add_bstf([Child|Children],OldAgenda,NewAgenda):-
	add_one(Child,OldAgenda,TmpAgenda),
	add_bstf(Children,TmpAgenda,NewAgenda).
% add_one(S,A,B) <- B is A with S inserted acc. to eval/2
add_one(Child,OldAgenda,NewAgenda):-
	eval(Child,Value),
	add_one(Value,Child,OldAgenda,NewAgenda).
add_one(_,Child,[],[Child]).
% if the child has a lower distance, put it first
add_one(Value,Child,[Node|Rest],[Child,Node|Rest]):-
	eval(Node,V),
	is_better_than(Value, V),!.
add_one(Value,Child,[Node|Rest],[Node|NewRest]):-
	add_one(Value,Child,Rest,NewRest).
	
%% children(+Node, -Children)
% gives the possible successors of the Node.
% in the context of a block stacking algorithm, a successor is the state where one more object has been put in the boxes.
children(Node, Children):-
	setof(Child, (child(Node, Child)), Children).
	
%% child(+State, -New_state)
% unifies New_state with a successor node of State, by placing one more block.
child(state(Boxes, Objects), state(New_boxes, New_objects)):-
	select_biggest_objects(Objects, Biggest_objects),
	remove_similar(Biggest_objects, List),!,
	member(Element, List),
	put(Element, Boxes, New_boxes),
	select(Element, Objects, New_objects).

	
%% select_biggest_objects(+Objects, -Biggest_objects)
% unifies Biggest_objects with the biggest objects of Objects
% takes advantage of the fact that the objects of Objects are sorted by decreasing size
select_biggest_objects([], []).
select_biggest_objects([Head|Tail], [Head|Biggests]):-
	volume_of_object(Head, Volume),
	select_objects_of_volume(Tail, Biggests, Volume).
	
%% select_objects_of_volume(+List, -New_list, +Volume)
% unifies New_list with the list of objects of List of volume Volume
select_objects_of_volume([], [], _).
select_objects_of_volume([Head|Tail], [Head|Biggests], Volume):-
	volume_of_object(Head, Volume),!,
	select_objects_of_volume(Tail, Biggests, Volume).
select_objects_of_volume([_|Tail], Biggests, Volume):-
	select_objects_of_volume(Tail, Biggests, Volume).
	
%% remove_similar(+Id_list, -New_id_list)
% unifies New_id_list with non-homomophic objects of Id_list
remove_similar([], []).
remove_similar([Head|Tail], [Head|New_list]):-
	remove_similar_from_list(Head, Tail, New_objects),
	remove_similar(New_objects, New_list).
	
%% remove_similar_from_list(+Id, +Id_list, -New_id_list)
% removes from Id_list the elements with the same shape as the block of id Id
% unifies the resulting list with New_id_list
remove_similar_from_list(_, [], []).
remove_similar_from_list(Id, [Head|Tail], New_list):-
	is_similar_to_block(Id, Head),!,
	remove_similar_from_list(Id, Tail, New_list).
remove_similar_from_list(Id, [Head|Tail], [Head|New_list]):-
	remove_similar_from_list(Id, Tail, New_list).
	
%% is_similar_to_block(+Id, +Id2)
% succeeds if block of id Id has the same shape as the block of Id2
is_similar_to_block(Id, Id2):-
	object(Id, size(X, _, _)),
	object(Id2, size(X, _, _)).