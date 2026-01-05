function I4=Preprocessing(I)
    % GAUSSIAN FILTERING
    I2 = imgaussfilt(I,2);
    
    % BINARIZE THE IMAGE USING OTSU'S THRESHOLDING
    I3 = ~imbinarize(I2);
    
    % EROSION
    I3 = imerode(I3, strel('disk',4));
    
    % REMOVE UNWANTED REGIONS
    I3 = bwareaopen(I3, 300); % Remove components with < 400 pixels
    
    % DILATION
    I4 = imdilate(I3, strel('disk',2));
    I4 = bwmorph(I4>0,'spur');
%     imshow(I4);title('i4')
end

