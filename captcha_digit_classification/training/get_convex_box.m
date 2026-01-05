function [bbox, convex_hull] = get_convex_box(mask)
    [row, col] = find(mask);  % 返回非零点的行列坐标

    k = convhull(col, row);  % convex hull index
    convex_hull = [col(k), row(k)];

    min_x = min(convex_hull(:,1));
    max_x = max(convex_hull(:,1));
    min_y = min(convex_hull(:,2));
    max_y = max(convex_hull(:,2));
    
    % 最小边界框的四个角
    bbox = [min_x, min_y, max_x, max_y];
    
    % 5. 可视化凸包和最小边界框
%     figure;
%     imshow(mask);
%     hold on;
%     plot(convex_hull(:,1), convex_hull(:,2), 'r-', 'LineWidth', 2); % 绘制凸包边界
%     rectangle('Position', [bbox(1), bbox(2), bbox(3)-bbox(1), bbox(4)-bbox(2)], ...
%               'EdgeColor', 'g', 'LineWidth', 2);  % 绘制边界框
%     title('物体的凸包和最小边界框');
%     hold off;
end