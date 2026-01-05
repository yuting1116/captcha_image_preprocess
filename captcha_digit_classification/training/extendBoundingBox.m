function bbox_ext = extendBoundingBox(bbox, x, imgSize)
% Inputs:
%   bbox    - [x y width height]
%   x       - number of pixels to extend
%   imgSize - optional image size [height width]
%
% Output:
%   bbox_ext - extended bounding box [x y width height]

% Original bounding box
x0 = bbox(1);
y0 = bbox(2);
w  = bbox(3);
h  = bbox(4);

% Extend box
x_new = x0 - x;
y_new = y0 - x;
w_new = w + 2*x;
h_new = h + 2*x;

% Clip to image boundaries if image size is provided
if nargin == 3
    imgH = imgSize(1);
    imgW = imgSize(2);
    
    x_new = max(1, x_new);
    y_new = max(1, y_new);
    
    w_new = min(w_new, imgW - x_new + 1);
    h_new = min(h_new, imgH - y_new + 1);
end

bbox_ext = [x_new, y_new, w_new, h_new];
end