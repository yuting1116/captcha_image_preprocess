function [img, sigleBbox, singleDigitCnt] = get_single_digit(img)
singleDigitCnt = 0;
sigleBbox = [];
temp = watershed_seg(img);
stats=regionprops('Table',temp,{'Area', 'BoundingBox'});

for i = 1:length(stats.Area)
    padding = 2;  % Change this value to control how much the bounding box extends
    boundingBox = stats.BoundingBox(i,:);
    % Adjust the bounding box to expand it outward
    x = boundingBox(1) - padding;
    y = boundingBox(2) - padding;
    w = boundingBox(3) + 2 * padding; 
    h = boundingBox(4) + 2 * padding;
    % Ensure the new coordinates stay within the bounds of the image
    x = max(x, 1);
    y = max(y, 1);
    w = min(w, size(img, 2) - x);
    h = min(h, size(img, 1) - y);
    % Perform the crop using the expanded bounding box
    singleDigit = imcrop(img, [x, y, w, h]);
    singleDigit = imclearborder(singleDigit);
%     figure;imshow(singleDigit);
    
    single_skel= bwskel(singleDigit>0,'MinBranchLength',30);
    single_skel_len =  sum(single_skel(:));
    branchPoint = sum(bwmorph(single_skel,'branchpoints'),'all');
    if (stats.Area(i) > 1600 && branchPoint < 5 && single_skel_len <300)
        
        img(temp == i) = 0;
%         figure;imshow(img);title('sdfsd')
        singleDigitCnt = singleDigitCnt  + 1;
        sigleBbox(singleDigitCnt,:) = boundingBox;
    end
end

end

