%%%% Detecting Object %%%
%
% Cycles through all the images given, calls matchComparison for each of
% them and decides whether object is present or not. If it is present, draws 
% a rectangle around it in the given image 
%
% Input: thresholds for 3 tests - nearest neighbors test, ratio test, RANSAC 
% test; #iterations for RANSAC; threshold on #inliers that should be
% present to classify image positive (containing template object)
% 
% Output: Prediction on each of the images,whether it contains object or
% not
%
%%%
function scenespredicted = detectObject(threshold_for_nearest_neighbour_test, threshold_for_ratio_test, threshold_for_ransac_test, iterations_for_ransac_test, threshold_for_inliers)
 
    % scan template 
    templatename = 'object-template.jpg';
    
    % scan images
    scenenames = {'object-template-rotated.jpg', 'scene1.jpg', 'scene2.jpg', 'sc3.jpg', 'sc4.jpg', 'sc5.jpg', 'sc6.jpg', 'sc7.jpg', 'sc8.jpg', 'sc9.jpg', 'sc10.jpg', 'sc11.jpg', 'sc12.jpg', 'sc13.jpg', 'sc14.jpg', 'sc15.jpg', 'sc16.jpg'};
    
    % vector storing prediction for all images
    scenespredicted = zeros(1,length(scenenames));
    
    im1 = im2single(rgb2gray(imread(templatename)));
    [f1, d1] = vl_sift(im1);
    n1 = size(d1,2);
    
    % iterating through all the images
    for scenenum = 1:length(scenenames)
        
        fprintf('Reading image %s for the scene to search....\n', scenenames{scenenum});
        im2 = im2single(rgb2gray(imread(scenenames{scenenum})));
        [f2, d2] = vl_sift(im2);
        
        % Call to matchComparison
        [ransac_flag, matchMatrix_thresholded, bestM, bestT] = matchComparison(im1, im2, f1, f2, d1, d2, n1, threshold_for_nearest_neighbour_test, threshold_for_ratio_test, threshold_for_ransac_test, iterations_for_ransac_test);
        
        % Check if #inliers is greater than threshold 
        if(ransac_flag==1 && size(matchMatrix_thresholded,2)>threshold_for_inliers)
           
           % Case where Object is detected 
           fprintf('Object Detected! \n\n');  
           scenespredicted(1,scenenum) = 1;
           
           % Drawing rectangle around it
           clf;
           subplot(1,2,1);
           imshow(im1);
           axis equal ; axis off ; axis tight ;
           subplot(1,2,2);
           imshow(im2);
           axis equal ; axis off ; axis tight ;
           hold on;
           
           % Finding affine transformation of 4 corners 
           [h, w] = size(im1);
           Rect1 = [1 w 1 w; 1 1 h h];
           Rect2 = bestM*Rect1 + repmat(bestT,1,4);
           disp(Rect2);
           drawRectangle(Rect2, 'green');
           keyboard;
           
        else
            
           % Case where object is not detected
           fprintf('Object Not Found! \n\n');
           scenespredicted(1,scenenum) = 0;
           keyboard;
           
        end
    end
end