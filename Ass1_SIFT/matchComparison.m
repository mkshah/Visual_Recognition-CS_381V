%%%% Match Comparison Function %%%
%
% Applies Nearest Neighbor test, Threshold Ratio test, RANSAC respectively
%
% Input: 2 images, their matrix of frames and descriptors; thresholds for 3
% tests - nearest neighbors test, ratio test, RANSAC test & #iterations for
% RANSAC
% 
% Output: matchMatrix after RANASC, best affine parameters(M & T), a flag
% that indicates whether it passed through RANSAC
%
%%%
function [ransac_flag, matchMatrix3, bestM, bestT] = matchComparison(im1, im2, f1, f2, d1, d2, n1, threshold_for_nearest_neighbour_test, threshold_for_ratio_test, threshold_for_ransac_test, iterations_for_ransac_test)

    matchMatrix = zeros(4,n1); % to store the indices plus first two sorted distances
    ransac_flag = 0;           % flag to indicate whether code went through RANSAC  
    matchMatrix3 = 0;          % Output Initialization
    bestM = 0;                 % Output Initialization
    bestT = 0;                 % Output Initialization
    
    %Iterating through all the descriptors in the template image &
    %finding their 1st two closese points & distances in given image an 
    %storing them in matchMatrix  
    for i=1:n1
        aSingleSIFTDescriptorFromTemplate = d1(:,i);
        dists = dist2(double(aSingleSIFTDescriptorFromTemplate)', double(d2)');
        [sortedDists, sortedIndices] = sort(dists, 'ascend');
        matchMatrix(:,i) = [i, sortedIndices(1), sortedDists(1), sortedDists(2)];          
    end
    
    %Showing Initial Mathces before applying any test
    fprintf('Showing Initial Matches. Type dbcont to continue.\n');
    showLinesBetweenMatches(im1, im2, f1, f2, matchMatrix);
    keyboard;
    
    % Applying Nearest Neighbour test
    matchMatrix1 = thresholded_nearest_neighbour_test(im1, im2, f1, f2, matchMatrix, threshold_for_nearest_neighbour_test);
    
    % Applying Threshold Ratio test
    % Output of first test is passed as input to this test
    matchMatrix2 = thresholded_ratio_test(im1, im2, f1, f2, matchMatrix1, threshold_for_ratio_test);
    
    % RANSAC will require minimum 3 points to preform test.
    % After performing Threshild Ratio Test, it ma be possible that less
    % than 3 points are remining. 
    % "IF" condition to perform this check. 
    if(size(matchMatrix2,2)>=3)
        % Applying RANSAC Test
        % Output of 2nd test is passed in this test 
        [matchMatrix3, bestM, bestT] = ransac_test(im1, im2, f1, f2, matchMatrix2, threshold_for_ransac_test, iterations_for_ransac_test);
        % Set ransac_lag to 1, as code passed through it.
        ransac_flag = 1;      
    end    
    % By default ransac_flag is set to zero. So no need to write else case
    
end