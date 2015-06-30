cd('src_matlab');

experiment_name = 'test_eeg_fix';
number_of_runs = 2;
total_number_of_runs = 4;
data_location = '../data/data_eeg.mat';
fix_x = 50;
p_value = 0.01;
leave_out = [10, 90] / 100;

main2_fix_x( data_location, experiment_name, fix_x, leave_out, ...
  0, number_of_runs )
main2_fix_x( data_location, experiment_name, fix_x, leave_out, ...
  1, number_of_runs )

combine_results(total_number_of_runs, experiment_name)

% In R: 
% source("main2_fix_x.r")
% main2_fix_x("test1_fix_x", 0.01)

