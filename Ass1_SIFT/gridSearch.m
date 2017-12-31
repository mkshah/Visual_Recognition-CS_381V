%%%% Grid Search - To find the optimum fonfiguration of Hyper-parameters %%%
% 
% Runs detectObject.m file for various configurations of hyperparameters
% and given true labels for the images, selects one which gives the best 
% classification (object Present/Absent) result.
%
%%%
function gridSearch()
    
    threshold_for_nearest_neighbour_test_range = [0.7 0.75 0.8 0.85];       % values for threshold for nearest_neighbour_test
    threshold_for_ratio_test_range = [0.5 0.55 0.6 0.65 0.7];               % values for threshold for ratio_test
    threshold_for_ransac_test_range = [1e-5 1e-7 1e-10];                    % values for threshold for ransac_test
    iterations_for_ransac_test_range = [4000 6000];                         % values for iterations for ransac_test
    threshold_for_inliers_range = [2 3 4];                                  % values for threshold for inliers for final object detection
    
    % Manually assigned true labels
    scenes_true = [1 1 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0];
    
    % finding positves and negatives in them
    idx = (scenes_true()==1); 
    p = length(scenes_true(idx));
    n = length(scenes_true(~idx));
    
    % update for best parameters found
    best_fm = 0; 
    best_threshold_for_nearest_neighbour_test = 0;
    best_threshold_for_ratio_test = 0;
    best_iterations_for_ransac_test = 0;
    best_threshold_for_inliers = 0;
    
    % Iteration number
    itr = 0;
    
    % Nested for loops to pass through all configurations
    for i=1:length(threshold_for_nearest_neighbour_test_range)
        for j=1:length(threshold_for_ratio_test_range)
            for m=1:length(threshold_for_ransac_test_range);
                for k=1:length(iterations_for_ransac_test_range);
                    for l=1:length(threshold_for_inliers_range);
                        % update the iteration and print
                        itr = itr + 1;
                        fprintf('\n\n %d th Configuration running... \n\n',itr);
                        
                        % calculate predicted labels (0/1) using detectObject script 
                        scenes_predicted = detectObject(threshold_for_nearest_neighbour_test_range(i),threshold_for_ratio_test_range(j),threshold_for_ransac_test_range(m), iterations_for_ransac_test_range(k), threshold_for_inliers_range(l));                                   
                        
                        % Calculating f_measure
                        tp = sum(scenes_true(idx)==scenes_predicted(idx));
                        tn = sum(scenes_true(~idx)==scenes_predicted(~idx));
                        fp = n-tn;
                        precision = tp/(tp+fp);
                        recall = tp/p;
                        f_measure = 2*((precision*recall)/(precision + recall));
                        
                        % Updating best parameters
                        if(f_measure>best_fm)
                            best_fm = f_measure;
                            best_threshold_for_nearest_neighbour_test = threshold_for_nearest_neighbour_test_range(i);
                            best_threshold_for_ratio_test = threshold_for_ratio_test_range(j);
                            best_iterations_for_ransac_test = iterations_for_ransac_test_range(k);
                            best_threshold_for_inliers = threshold_for_inliers_range(l);                     
                        end
                        
                    end
                end
            end
        end
    end
    
    % Display best configuration..
    fprintf('%f %f %f %f %f \n\n', best_fm, best_threshold_for_nearest_neighbour_test, best_threshold_for_ratio_test, best_iterations_for_ransac_test, best_threshold_for_inliers );
    
end