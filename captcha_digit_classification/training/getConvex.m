function [rotate_bbox] = getConvex(img)
[w, h] = size(img);
[~, convex_hull] = get_convex_box(img);
convexMask = poly2mask(convex_hull(:,1), convex_hull(:,2), w, h);

[rotate_bbox, ~] = get_convex_box(convexMask);
end

