function [orientation] = get_orientation(img)

[y, x] = find(img> 0);
convex_hull = minBoundingBox([x'; y'])';
convex_hull = [convex_hull; convex_hull(1, :)];
[coeff, ~, ~] = pca(convex_hull); 
main_direction = coeff(:, 1); 
orientation = atan2d(main_direction(2), main_direction(1));
end

