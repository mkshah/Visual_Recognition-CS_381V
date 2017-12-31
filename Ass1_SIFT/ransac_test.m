%%% RANSAC Implementation %%%
%
% Input: 2 images & their frme matices, matchMatrix, threshold for distance
% to be considered as inliner, #iterations
%
% Output: matchMatrix after RANSAC, best Affine parameters(M & T)
%
%%%

function [matchMatrix_thresholded, bestM, bestT] = ransac_test(im1, im2, f1, f2, matchMatrix, threshold, iterations)

    bestcnt = 0;                    % best count for #inliers
    bestM = zeros(2,2);             % best affine parameters
    bestT = zeros(2,1);             %  "      "       "
    bestdist = zeros(1, size(matchMatrix,2));                 % Corresponding best Distance Vector
    Xt = [f1(1,matchMatrix(1,:)); f1(2,matchMatrix(1,:))];    % Coordinates in template image 
    Xta = [f2(1,matchMatrix(2,:)); f2(2,matchMatrix(2,:))];   % Coordinates in given image

    % Ransac iterations
    for j = 1:iterations
        
        % Randoml shuffel
        randomIndices = randperm(size(matchMatrix,2));
        
        % Storing x-y coordinates of first 3 points in template from it    
        x1 = f1(1,matchMatrix(1,randomIndices(1)));
        y1 = f1(2,matchMatrix(1,randomIndices(1)));
        x2 = f1(1,matchMatrix(1,randomIndices(2)));
        y2 = f1(2,matchMatrix(1,randomIndices(2)));
        x3 = f1(1,matchMatrix(1,randomIndices(3)));
        y3 = f1(2,matchMatrix(1,randomIndices(3)));
        
        % Storing x-y coordinates of corresponding 3 points in given image from it
        x1a = f2(1,matchMatrix(2,randomIndices(1)));
        y1a = f2(2,matchMatrix(2,randomIndices(1)));
        x2a = f2(1,matchMatrix(2,randomIndices(2)));
        y2a = f2(2,matchMatrix(2,randomIndices(2)));
        x3a = f2(1,matchMatrix(2,randomIndices(3)));
        y3a = f2(2,matchMatrix(2,randomIndices(3)));

        % Storing them in form of matrix so that Matrix Equation Ax = B can
        % be solved
        A = [x1 y1 0 0 1 0; 0 0 x1 y1 0 1; x2 y2 0 0 1 0; 0 0 x2 y2 0 1; x3 y3 0 0 1 0; 0 0 x3 y3 0 1];
        B = [x1a; y1a; x2a; y2a; x3a; y3a];
        % X = [m1; m2; m3; m4; t1; t2];
        X = pinv(A)*B; 
        % Storing Affine parameters in appropriate form
        m1 = X(1); m2 = X(2); m3 = X(3); m4 = X(4); t1 = X(5); t2 = X(6);
        M = [m1 m2; m3 m4];
        T = [t1; t2];

        % Calculating predicted coordinates in given image
        Xtb = M*Xt + repmat(T,1,size(matchMatrix,2));
        
        % Calculating distance between actual and predicted coordinates
        % in given image
        diff =(Xta-Xtb);
        diff = diff.*diff;
        dist = sqrt(sum(diff));
        
        % Counting #inliers
        cnt = sum(dist<=threshold) ;

        % updating the best count & best affine parameters
        if(cnt>bestcnt)
            bestcnt = cnt;
            bestM = M;
            bestT= T;
            bestdist = dist;
        end
        
    end
    
    % Removing columns from matchMatrix that did not pass RANSAC test
    matchMatrix_thresholded = matchMatrix(:,bestdist(:)<=threshold);
    
    % Display..
    fprintf('Showing RANSAC test. %d survived.. Type dbcont to continue.\n', size(matchMatrix_thresholded,2));
    showLinesBetweenMatches(im1, im2, f1, f2, matchMatrix_thresholded);
    keyboard;
                               
end