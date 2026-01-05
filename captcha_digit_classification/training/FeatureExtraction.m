function [K] = FeatureExtraction(img,bboxs,digitCnt)
    K = [];
    for i = 1:digitCnt
        digit = imcrop(img, bboxs(i,:));
        digit = imresize(digit,[28 28]);
%         figure;imshow(digit);
%         K(i,:) = ShapeFeats(digit);
        K(i,:) = digit(:);
    end

end

function F=ShapeFeats(S)
	fts={'Circularity','Area','Centroid','Orientation','Solidity'}; 
	Ft=regionprops('Table',S,fts{:});
	[~,idx]=max(Ft.Area);
	F=[Ft(idx,:).Variables];
end

