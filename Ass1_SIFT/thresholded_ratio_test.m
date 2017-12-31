%%% Thresholded Ratio Test %%%
%
% Input: 2 images & their frme matices, matchMatrix, threshold for ratio
% between 1st & 2nd closest distances
% 
% Output: matchMatrix after Threshold Ratio Test
%
%%%

function matchMatrix_thresholded = thresholded_ratio_test(im1, im2, f1, f2, matchMatrix, threshold)

    % Updating the 4th row in matchMatrix to contain ratio of first & second
    % closest distances
    matchMatrix(4,:) = matchMatrix(3,:)./matchMatrix(4,:);
    
    % Removing columns from matchMatrix that did not pass the test
    matchMatrix_thresholded = matchMatrix(:,matchMatrix(4,:)<=threshold);

    % Display..
    fprintf('Showing Thresholded ratio test. %d survived.. Type dbcont to continue.\n', size(matchMatrix_thresholded,2));
    showLinesBetweenMatches(im1, im2, f1, f2, matchMatrix_thresholded);
    keyboard;

end