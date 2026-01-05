function [total_digit_num] = get_digit_total_num(img_bw)
skel= bwskel(img_bw>0,'MinBranchLength',10);
stats = regionprops(img_bw,  'BoundingBox');
% Fs = [stats.BoundingBox(3), stats.ConvexArea, sum(skel(:))];
% total_digit_num = predict(Mdl_digit_num, Fs); %ensemble tree
x1 = stats.BoundingBox(3);
x2 = sum(skel(:));

% decision tree
if x1 < 254.5
    if x2 < 919.5
        total_digit_num = 3;
    else
        total_digit_num = 4;
    end
else % x1 >= 254.5
    if x2 < 781.5
        if x1 < 266.5
            total_digit_num = 3;
        else
            total_digit_num = 4;
        end
    else
        total_digit_num = 4;
    end
end

end

