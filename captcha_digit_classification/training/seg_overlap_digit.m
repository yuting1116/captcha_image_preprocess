function [overlap_digits_bbox] = seg_overlap_digit(img, K, bbox, branchPoint,skel)
% digit localization

proj = sum(img, 1);
[~, xIdx] = find(proj);
cluster_edges = round(linspace(xIdx(1), xIdx(end), K+1));
cluster_centers = round((cluster_edges(1:end-1) + cluster_edges(2:end)-1)/2);

% figure;imshow(convexMask);hold on
overlap_digits_bbox = zeros(K,4);
for i = 1:K
    isLast = (i == K);  
    isFirst = (i == 1);

    [digitBox] = cutBox_skel2(K,branchPoint,i, cluster_centers, bbox, img, isFirst, isLast,skel);

    overlap_digits_bbox(i,:) = digitBox;
%     line([cluster_centers(i) cluster_centers(i)], [1 435])
end

end

