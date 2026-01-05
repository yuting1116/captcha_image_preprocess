function [digitBox] = cutBox_skel2(K, branchPoint, idx, cluster_centers, bbox, img, isFirst, isLast,skel)

if K == 1
    digitBox(1,:) = [bbox(1),bbox(2),bbox(3) - bbox(1),bbox(4)-bbox(2)];
    return
end

proj_skel = sum(skel,1);
emptyPoints = find(proj_skel(bbox(1)+20:bbox(3)-20) == 0) + bbox(1) + 19;

x = bbox(1);
y =  bbox(2);
h = bbox(4)-bbox(2);
w = bbox(3)-bbox(1);

if isFirst
    rightLine = (cluster_centers(2) + cluster_centers(1))/2;
    leftLine = bbox(1);
elseif isLast
    rightLine = bbox(3);
    leftLine = (cluster_centers(K-1) +  cluster_centers(K))/2;
else
    rightLine = (cluster_centers(idx+1) +  cluster_centers(idx))/2;
    leftLine = (cluster_centers(idx) +  cluster_centers(idx-1))/2;
end

breakLineR = 0;
breakLineL = 0;
boundary = 10;
[rows, cols] = find(branchPoint);
cols = cat(1, cols, emptyPoints');
indices_right = find(cols > (rightLine - boundary) & cols < (rightLine + boundary));
indices_left= find(cols > (leftLine - boundary) & cols < (leftLine + boundary));

start = leftLine + bbox(1);
fixRatio = 1.5;
if ~isempty(indices_right)
    breakLineR = detect_near_branchpnt(indices_right, rightLine, fixRatio, start, w, h, cols);
else
%     if ~isLast
%         [~,closestBPIdx] = min(abs(cols - rightLine));
%         if abs(cols(closestBPIdx) - rightLine) < 30
%             breakLineR = cols(closestBPIdx);
%         else
%             breakLineR = 0;
%         end
%     end
end
if ~isempty(indices_left)
    breakLineL = detect_near_branchpnt(indices_left, leftLine, fixRatio, start, w, h, cols);
else
%     if ~isFirst
%         [~,closestBPIdx] = min(abs(cols - leftLine));
%         breakLineL = cols(closestBPIdx);
%     end
end
%

if breakLineR >0
    rightLine = breakLineR;
end
if breakLineL >0
    leftLine = breakLineL;
end

digit  = imcrop(img, [leftLine, y , max(rightLine - leftLine, 10), h]); %keep original hight [x,y,w,h]
if sum(digit(:)) > 5
    [digitBox, ~] = get_convex_box(digit);  %[x1,y1,x2,y2]
    digitBox = [leftLine + digitBox(1), y+digitBox(2), digitBox(3) - digitBox(1), digitBox(4) - digitBox(2)]; %[x,y,w,h]
else
    digitBox = [leftLine, y, max(rightLine - leftLine, 10), h]; %[x,y,w,h]
end

% digit  = imcrop(img,digitBox); %[x,y,w,h]
end

