/*
Tools to display data structures and interact with the user.



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 2.0, 30/12/13
% */


%% display_boxes(+Boxes)
% display the content of the boxes textually
display_boxes([]).
display_boxes([Box|Boxes]):-
	display_box(Box),
	display_boxes(Boxes).
	
%% display_box(+Box)
% display a box Box textually
display_box(box(Content)):-
	write('---'), nl, write('Box'), nl, write('---'), nl,
	display_content(Content).
	
%% display_content(+Box)
% display the content of a box textually
display_content([]):-nl.
display_content([Placement|Placements]):-
	display_placement(Placement),
	display_content(Placements).
	
%% display_placement(+Placement)
%display the position of an object in a box
display_placement(placement(Id, Coordinate)):-
	write('Object number '), write(Id), 
	write(' put at '), 
	write(Coordinate),
	write('.'),nl.
	
%% draw_boxes(+Boxes)
% draw the boxes visually
draw_boxes([]).
draw_boxes([Box| Boxes]):-
	draw_box(Box),
	draw_boxes(Boxes).
	
%% draw_box(+Box)
% draw the box visually
draw_box(box(Contents)):-
	write('Box:'),nl,write('---'), nl,
	draw_levels(Contents).
	
	
%% draw_levels(+Contents)
% draw the levels of a box
draw_levels(Contents):-
	box_dimensions(size(Height,_,_)),
	draw_level(Contents, Height).
	
%% draw_level(+Contents, +Level)
% draw the level Level
draw_level(_, Bottom):-
	Bottom<1,
	draw_bottom.
draw_level(Contents, Level):-
	write('|\t'),
	draw_level_content(Contents, Level, 1),
	write('|'),nl,
	New_level is Level-1,
	draw_level(Contents, New_level).
	
%% draw_bottom
% draws the bottom of a box.
draw_bottom:-
	box_dimensions(size(_,Length,_)),
	write('\\\t'), draw_line(Length, '-\t'), write('/'),nl.
	
%% draw_line(+Length, +Character)
% draws a line of length Length made of character Character.
draw_line(Length, _):-
	Length<1.
draw_line(Length, Character):-
	write(Character),
	New_length is Length-1,
	draw_line(New_length, Character).
	
%% draw_level_content(+Contents, +X, +Y)
% draw the content of the box at postion X, Y
draw_level_content(_, _, End):-
	box_dimensions(size(_,Length,_)),
	End > Length.
%if object is at that spot, print the object number on his length
draw_level_content(Contents, X, Y):-
	is_inside(coordinates(X, Y, 1), Contents, Id),
	object(Id, size(_,Length,_)),
	string_concat(Id, '\t', Concat),
	draw_line(Length, Concat),
	Y_next is Y+Length,
	draw_level_content(Contents, X, Y_next).
%else just print a space
draw_level_content(Contents, X, Y):-
	draw_line(1, ' \t'),
	Y_next is Y+1,
	draw_level_content(Contents, X, Y_next).
	
%% erase 
% clean the console
erase :-
	draw_line(80, '\n').
	
%% write_title 
% displays the name of the program
write_title :-
    write('Block stacking'),nl,
    write('--------------'),nl
    ,nl.

%% get_file_name(-File_name) 
% gets the name of the data file to use from user input
get_file_name(Final_file_name):-
    read_file_name(File_name_with_extension),
    get_file_name(File_name_with_extension, Final_file_name).
%% get_file_name(+File_name, -Final_file_name)
% returns File_name if it's the name of a valid file.
% else asks recursively another file name.
% [Note 1]: valid file selected, no backtracking allowed.
get_file_name(File_name, Final_file_name):-
	% [Note 1]
    access_file(File_name, read),!, 
    File_name = Final_file_name. 
get_file_name(_, Final_file_name):-
	erase,
	write('Error.'), nl,nl,
    write('Either this file does not exist or you don\'t have '),
	write('the permissions to access it!'),nl,nl,
    read_file_name(File_name_with_extension),
    get_file_name(File_name_with_extension, Final_file_name).
    
%% read_file_name(-File_name)
% asks a a file name to the user and return it.
read_file_name(File_name_with_extension):-
    %get the name of the file from user
    write('Please enter the name of the data file, without the extension.'),nl,
    read(File_name),
    string_concat(File_name, '.pl', File_name_with_extension).

%% load_file(+File_name)
% loads the clauses contained in the file File_name.
load_file(File_name_with_extension):-
    %load the data file
    write('Loading of file '), write(File_name_with_extension),nl,
    compile(File_name_with_extension),
    write('Done.'),nl,nl.
	
%% welcome
welcome:-
	erase,
    write_title.
	
%% ask_for_data_file
% get the name of the data file and loads it
ask_for_data_file:-
    get_file_name(File_name),
    load_file(File_name).
	
%% display_results(+Results)
%displays the results of the computation
display_results(Boxes):-
	erase,
	write('Processing... DONE!'),nl,nl,
	display_results_menu(Boxes).
	
%% display_results_answer(+Answer, +Results)
% display the Results the way the user want them
display_results_answer('a', Boxes):-
	display_boxes(Boxes),
	display_results_continue,
	display_results_menu(Boxes).
display_results_answer('b', Boxes):-
	draw_boxes(Boxes),
	display_results_continue,
	display_results_menu(Boxes).
display_results_answer('c', _):-
	write('Goodbye. Happy New Year!. :)'),nl,nl.
	
	
%% display_results_menu(+Results)
% gives the user the choice of how to display the Results
display_results_menu(Boxes):-
	write('What do you want to do?'),nl,
	write('a. See the results in text.'),nl,
	write('b. See the results in a graphical representation.'),nl,
	write('c. Terminate the application.'),nl,
	write('[a/b/c]'),nl,nl,
	read(Answer),
	display_results_answer(Answer, Boxes).
	
%% display_results_continue
% wait for user input
display_results_continue:-
	write('Continue?'),nl,
	write('Press any key...'),nl,
	read(_),
	erase.
	
	
%% ask_for_criterion
% interacts with the use to determine which criteron he wants to use.
ask_for_criterion:-
	erase,
	ask_for_criterion_question.

%% ask_for_criterion_question
% asks the user a criterion
ask_for_criterion_question:-
	write('Please choose a criterion:'),nl,
	write('a. Fill the box and minimize the unused spaces.'),nl,
	write('b. Balance the weigths between containers.'),nl,
	write('[fill/balance]'),nl,
	read(Answer),
	ask_for_criterion_answer(Answer).
	
	
%% ask_for_criterion_answer(+Answer)
% deal with the user's choice of criterion
ask_for_criterion_answer('fill'):-
	compile(eval_filled).
ask_for_criterion_answer('balance'):-
	compile(eval_balance).
ask_for_criterion_answer(_):-
	erase,
	write('Error.'),nl,nl,
	write('Invalid criterion. Please choose again.'),nl,nl,
	ask_for_criterion_question.
	
%% ask_for_rotation
% asks if the user want to enable block rotation
ask_for_rotation:-
	erase,
	write('Do you want to allow the algorithm to rotate the blocks?'),nl,
	write('[yes/no]'),nl,
	read(Answer),
	ask_for_rotation_answer(Answer).
	
%% ask_for_rotation_answer(+Answer)
% deal with the user's choice
ask_for_rotation_answer('yes'):-assert(rotation_activated).
ask_for_rotation_answer('no').
ask_for_rotation_answer(_):-
	write('Error.'),nl,nl,
	write('Invalid answer. Please choose again.'),nl,
	ask_for_rotation.
	
%% display_state(+State)
% interacts with the user to display the solution found.
display_state(state(Boxes, _)):-
	write("The number of empty spaces is :"),
	unused_spaces(state(Boxes, _), Value),
	write(Value),nl,
	display_results(Boxes).
