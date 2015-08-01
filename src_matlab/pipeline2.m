function [ error_rate, pvalue ] = pipeline2( data, labels, ...
  leave_out, number_of_permutations, k_fold, k_fold_test )
%PIPELINE2 "Cross-validation + cross-test"
%   Result: hyper-parameters but no parameters
%   Uses functions cross_validation, classification and
%   shuffle_within_partition

% Sizes
n = size(data,1);
n_train = n - floor(n * leave_out);
n_test = n - n_train;

% Splitting the data and labels
data_train = data(1:n_train, :);
data_test = data(n_train+1:end, :);
labels_train = labels(1:n_train);
labels_test = labels(n_train+1:end, :);

% Cross-validation
[best_hyper_parameters, first_partitioning] = ...
  cross_validation(data_train, labels_train, k_fold);

% Random partitions for the cross-testing
second_partitioning = crossvalind('Kfold', labels_test, k_fold_test);

% Counting correct classifications
correct = 0;

% Cross-testing
for ii = 1:k_fold_test
  
  % Indeces for test and train
  test_id = (second_partitioning == ii);
  train_id = ~test_id;
  
  % Combining train and some of the test data for training
  data_train_combined = [data_train; data_test(train_id,:)];
  labels_train_combined = [labels_train; labels_test(train_id,:)];
  
  % Data and labels for testing
  data_test_temp = data_test(test_id,:);
  labels_test_temp_shuffled = labels_test(test_id, :);
  
  % Classifying the data
  correct = correct + classification(data_train_combined, ...
    labels_train_combined, data_test_temp, labels_test_temp_shuffled, ...
    best_hyper_parameters);
end

% Error rate (first output)
error_rate = (n_test - correct) / n_test;

%
% Permutation test
%

% Number of correct classifications of all the permutations
correct = zeros(number_of_permutations, 1);

for i_perm = 1:number_of_permutations

  % Shuffle labels within each partition
  labels_train_shuffled = shuffle_within_partition(labels_train, ...
    first_partitioning);
  
  % Cross-validation
  best_hyper_parameters = cross_validation(data_train,...
      labels_train_shuffled, k_fold, first_partitioning);
    
  % Shuffle test labels within each partition
  labels_test_shuffled = shuffle_within_partition(labels_test, ...
    second_partitioning);

  % Cross-testing accuracy for each fold
  for ii = 1:k_fold_test

    % Indeces for test and train
    test_id = (second_partitioning == ii);
    train_id = ~test_id;

    % Combining train and some of the test data for training
    data_train_combined = [data_train; data_test(train_id,:)];
    labels_train_combined_shuffled = [labels_train_shuffled; ...
      labels_test_shuffled(train_id,:)];

    % Data and labels for testing
    data_test_temp = data_test(test_id,:);
    labels_test_temp_shuffled = labels_test_shuffled(test_id, :);

    % Classifying the data
    correct(i_perm) = correct(i_perm) + classification(data_train_combined, ...
      labels_train_combined_shuffled, data_test_temp, ...
      labels_test_temp_shuffled, best_hyper_parameters);
  end

end

% Error rate + adding noise for "<" sign
error_rate_perm = (n_test - correct) / n_test;
error_rate_perm = error_rate_perm + 0.000001 * randn(size(error_rate_perm));

pvalue = sum(error_rate_perm < error_rate) / number_of_permutations;

end