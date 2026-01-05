function [L] = watershed_seg(BW)
D = bwdist(~BW);
L = watershed(~D);
L(~BW) = 0;

% uniqueLabels = unique(L);
% uniqueLabels(uniqueLabels == 0) = [];
% numObjects = numel(uniqueLabels);

% rgb = label2rgb(L,'jet',[.5 .5 .5]);
% imshow(rgb)
% title('Watershed Transform');
end

