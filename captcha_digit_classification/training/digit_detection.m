function [digits_bboxs_sort, rotation_angle, img_out] = digit_detection(img, totDigitCnt)
rotation_angle = get_orientation(img);
img = imrotate(img, rotation_angle,'crop');
img_out = img;
[img, sigleBbox, singleDigitCnt] = get_single_digit(img);

%% all digit are seperated
is_all_digit_seperate = (sum(img(:)) == 0 && singleDigitCnt == totDigitCnt);
if is_all_digit_seperate
    [~, boxOrderIdx] = sort(sigleBbox(:, 1));
    digits_bboxs_sort = sigleBbox(boxOrderIdx, :);
    fprintf('all digit are seperated\n');
    return
end

is_over_seg = singleDigitCnt > totDigitCnt;
if (sum(img(:)) == 0 || is_over_seg) % redo in overlapping process
    sigleBbox = [];
    singleDigitCnt = 0;
    img = img_out;
    fprintf('is_over_seg = %d ', is_over_seg);
end

%% get skeleten
[bbox] = getConvex(img);
skel= bwskel(img>0,'MinBranchLength',30);
skel = bwmorph(skel,'spur');
branchPoint = bwmorph(skel,'branchpoints');
% figure;
% imshow(img);  % Display the skeleton
% hold on;

% Plot the branch points on top of the skeleton
% [rows, cols] = find(branchPoint);  % Find the row and column indices of branch points
% plot(cols, rows, 'ro', 'MarkerSize', 5, 'LineWidth', 2);  % Mark branch points with red circles

%% caculate total digit count
overlap_digit_cnt = totDigitCnt - singleDigitCnt;
fprintf('overlap = %d, total=%d\n', overlap_digit_cnt, totDigitCnt);

%% cuting box with kmean
overlap_digits_bbox = seg_overlap_digit(img, overlap_digit_cnt, bbox, branchPoint, skel);
for i = 1:overlap_digit_cnt
    overlap_digits_bbox(i,:) = extendBoundingBox(overlap_digits_bbox(i,:), 5);
end
%% bounding box
digits_bboxs = overlap_digits_bbox;
digits_bboxs(overlap_digit_cnt + 1 : overlap_digit_cnt + singleDigitCnt, :) = sigleBbox;

%% sorted based on x coordinate (left to right bbox)
[~, boxOrderIdx] = sort(digits_bboxs(:, 1));
digits_bboxs_sort = digits_bboxs(boxOrderIdx, :);


end

