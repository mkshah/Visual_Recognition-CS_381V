%%% Nearest Neighbor Test %%%
%
% Input: 2 images & their frme matices, matchMatrix, threshold to be
% multipled with Mean Distance 
% 
% Output: matchMatrix after Nearest Neighbor Test
%
%%%

function matchMatrix_thresholded = thresholded_nearest_neighbour_test(im1, im2, f1, f2, matchMatrix, threshold)

    % Calculating Mean Distance
    meanDistance = mean(matchMatrix(3,:));
    
    % Removing columns from matchMatrix that did not pass the test
    matchMatrix_thresholded = matchMatrix(:,matchMatrix(3,:)<=threshold*meanDistance);

    % Display..
    fprintf('Showing Thresholded nearest neighbors. %d survived.. Type dbcont to continue.\n', size(matchMatrix_thresholded,2));
    showLinesBetweenMatches(im1, im2, f1, f2, matchMatrix_thresholded);
    keyboard;

end