/*
Coordinates and superposition management.



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 2.0, 30/12/13
% */


%% box_volume(-Volume)
% get the volume of a box
box_volume(Volume):-
	box_dimensions(Size),
	volume_of_(Size, Volume).
	
%% volume_of_object(+Id, -Volume)
% get the volume of the object of number Id
volume_of_object(Id, Volume):-
	object(Id, Size),
	volume_of_(Size, Volume).
	
%% volume_of_(+size, -Volume)
volume_of_(size(Heigth, Length, Width), Volume):-
	Volume is Heigth*Length*Width.
	
%% in_box_bounds(+Placement)
% succeeds if the object Id, put at position X, Y, Z does fit in the box
in_box_bounds(placement(Id, coordinates(X, Y, Z))):-
	object(Id, size(Height, Length, Width)),
	box_dimensions(size(Box_height,Box_length,Box_depth)),
	in_limit(Height,Box_height,X),
	in_limit(Length,Box_length,Y),
	in_limit(Width,Box_depth,Z).
	
%% in_limit(+Dimension, +Limit, -Coordinate)
% unifies Coordinate with an integer such that 
% 0< Coordinate + Dimension <= Limit
in_limit(Dimension, Limit, Coordinate):-
	Max is Limit+1-Dimension,
	between(1, Max, Coordinate).

%% no_superposition(+Placement, +List_of_placements)
% checks that no objects are at the same place.
no_superposition(_, []).
no_superposition(placement(Id, coordinates(X, Y, Z)), [placement(_, coordinates(X2, _, _))|Blocks]):-
	object(Id, size(Height, _, _)),
	X+Height-1<X2,
	no_superposition(placement(Id, coordinates(X, Y, Z)), Blocks).
no_superposition(placement(Id, coordinates(X, Y, Z)), [placement(_, coordinates(_, Y2, _))|Blocks]):-
	object(Id, size(_, Length, _)),
	Y+Length<Y2,
	no_superposition(placement(Id, coordinates(X, Y, Z)), Blocks).
no_superposition(placement(Id, coordinates(X, Y, Z)), [placement(Id2, coordinates(X2, _, _))|Blocks]):-
	object(Id2, size(Height2, _, _)),
	X>X2+Height2-1,
	no_superposition(placement(Id, coordinates(X, Y, Z)), Blocks).
no_superposition(placement(Id, coordinates(X, Y, Z)), [placement(Id2, coordinates(_, Y2, _))|Blocks]):-
	object(Id2, size(_, Length2, _)),
	Y>Y2+Length2-1,
	no_superposition(placement(Id, coordinates(X, Y, Z)), Blocks).
	
%% is_not_under_bigger(+Id, +Coordinates, +Blocks)
% succeeds if no bigger object is on the object Id
% it could happen because the objects can be put at any position, they "doesn't enter by the top"
% it represent the fact that the objects could be put in a different order, and doesn't change the properties of the solution
% the realistic placement order could be retrieved by sorting the list of placements by increasing X coordinate.
is_not_under_bigger(_, []).
is_not_under_bigger(placement(Id, Coordinates), [placement(Id2, Coordinates2)|Placements]):-
	not((is_on(placement(Id2, Coordinates2), placement(Id, Coordinates))
		, is_volume_smaller(Id,Id2))),
	is_not_under_bigger(placement(Id, Coordinates), Placements).

	
%% has_a_support(+Placement, +Placements)
% succeeds if the item of number Id is not put on a smaller item, and doesn't float in the air.
has_a_support(placement(_, coordinates(1, _, _)), _).
has_a_support(placement(Id, Coordinates), [placement(Id2, Coordinates2)|_]):-
	is_volume_smaller_or_equal_than(Id,Id2),
	is_on(placement(Id, Coordinates), placement(Id2, Coordinates2)).
has_a_support(Placement, [_|Placements]):-
	has_a_support(Placement, Placements).

%% is_on(+Placement, +Placement)
% succeeds if the first object is situated on top of the second one
is_on(placement(Id, coordinates(X, Y, _)), placement(Id2, coordinates(XX, YY, _))):-
	object(Id, size(_, Length, _)),
	object(Id2, size(H, L, _)),
	X is XX+H,
	between(1, Length, Bottom_part),
	Bottom_part+Y-1>= YY,
	Bottom_part+Y-1=< YY+L-1.

%% is_volume_smaller_or_equal_than(+Id,+Id2)
% succeeds if object of ID Id has a volume smaller or equal to the one of object Id2.
is_volume_smaller_or_equal_than(Id,Id2):-
	volume_of_object(Id, Volume),
	volume_of_object(Id2, Volume2),
	Volume =< Volume2.
	
%% is_volume_smaller(+Id,+Id2)
% succeeds if object of ID Id has a volume smaller to the one of object Id2.
is_volume_smaller(Id,Id2):-
	volume_of_object(Id, Volume),
	volume_of_object(Id2, Volume2),
	Volume < Volume2.

%% is_inside(+Coordinates, +Placements,-Id)
% checks if the point of coordinates Coordinates is inside another object.
% Id contains the Id of the item that contains the point.
is_inside(coordinates(X, Y, Z), [placement(Id, coordinates(XX, YY, ZZ))|_], Id):-
	X>=XX,
	Y>=YY, 
	Z>=ZZ,
	object(Id, size(Height, Length, Width)),
	X<XX+Height,
	Y<YY+Length, 
	Z<ZZ+Width, !.
is_inside(coordinates(X, Y, Z), [_|Placements], Id):-
	is_inside(coordinates(X, Y, Z), Placements, Id).
	

%% max(+X,+Y,-Max)
% maximum of two numbers
max(X,Y,Max) :-
    X > Y,!,
    Max = X.
        
max(_,Y,Max) :-
    Max = Y.
	
%% unused_spaces(+Box, -Volume)
% calculate unused space volume in a box
unused_spaces(box(Placements), Volume):-
	box_volume(Box_volume),
	volume_of_placements(Placements, Content_volume),
	Volume is Box_volume-Content_volume.
	
%% unused_spaces(+State, -Volume)
% calculate unused space volume of a state
unused_spaces(state([], _), 0).
unused_spaces(state([Head|Tail], _), Cost):-
	unused_spaces(Head, Cost1),
	unused_spaces(state(Tail, _), Cost2),
	Cost is Cost1+Cost2.
	
	
%% volume_of_placements(+List, -Volume)
% return the volume of the objects placed in the box
volume_of_placements(List, Volume):-
	volume_of_placements(List, 0, Volume).
	
%% volume_of_placements(+List, +Accumulator, -Volume)
% return the volume of the objects placed in the box
volume_of_placements([], Final_volume, Final_volume).
volume_of_placements([placement(Id, _)|Rest], Current_volume, Final_volume):-
	volume_of_object(Id, Object_volume),
	New_volume is Current_volume+Object_volume,
	volume_of_placements(Rest, New_volume, Final_volume).
	
%% remaining_volume(+State, -Volume)
% calculate the volume of the objects yet to be placed
remaining_volume(state(_, Ids), Volume):-
	objects_volume(Ids, Volume).

%% objects_volume(+List, -Volume)
% calculate the volume of the objects whose ids have been given
objects_volume(List, Volume):-
	objects_volume(List, 0,Volume).
	
%% objects_volume(+List, +Accumulator,-Volume)
% calculate the volume of the objects whose ids have been given
objects_volume([], Volume, Volume).
objects_volume([Head|Tail], Volume, Final_volume):-
	volume_of_object(Head, Object_volume),
	New_volume is Volume+Object_volume,
	objects_volume(Tail, New_volume, Final_volume).
	
%% weigth_difference_between_boxes(+State, -Difference)
% unifies Difference with the difference between the weight of the boxes
weigth_difference_between_boxes(state([Box1, Box2], _), Difference):-
	weigth_difference_between_boxes(Box1, Box2, Difference).
	
%% weigth_difference_between_boxes(+Box1, +Box2, -Difference)
% unifies Difference with the difference between the weight of the boxes
weigth_difference_between_boxes(box(Placements1), box(Placements2), Difference):-
	volume_of_placements(Placements1, Volume_of_content_of_box_1),
	volume_of_placements(Placements2, Volume_of_content_of_box_2),
	Difference is abs(Volume_of_content_of_box_1-Volume_of_content_of_box_2).