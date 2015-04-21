/*
A program to solve the block stacking problem, with two boxes.



@Author Helain Schoonjans heschoon@ulb.ac.be 
@Version 4.0, 11/01/13
% */


%% EXISTING TAGS:
% [ROTATE]
% [TODO]

%Load some code...
:-
	[constants],
	[initialisation],
	[interface], 
	[geometry], 
	[algorithm],
	[evaluation].


% REMINDER:
% Change the working directory
working_directory(_, 'C:\\Users\\Heschoon\\Dropbox\\ULB\\Declarative programming').


%% start
% entry point of the program
start:-
	welcome,
	ask_for_data_file,
	%ask_for_rotation,
	ask_for_criterion,
	run(Goal),
	display_state(Goal).