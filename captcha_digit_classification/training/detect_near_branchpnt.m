function [rightLine] = detect_near_branchpnt(indices, rightLine, fixRatio, start, bboxWidth, bboxHeight, cols)
    diff = cols(indices) - rightLine;
    diff(diff <= 0) = Inf;
    [~, breakIdxR] = min(diff);
    rightNear = cols(indices(breakIdxR));
    
    diff = cols(indices) - rightLine;
    diff(diff > 0) = Inf;
    [~, breakIdxL] = max(diff);
    leftNear = cols(indices(breakIdxL));
    rightWidth = rightNear - start;
    leftWidth = leftNear - start;
    rightLenRatio = bboxHeight / rightWidth;
    leftLenRatio = bboxHeight / leftWidth;
    if abs(rightLenRatio - fixRatio) > abs(leftLenRatio - fixRatio)
        rightLine = rightNear;
    else
        rightLine = leftNear;
    end
end

