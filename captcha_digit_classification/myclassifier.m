function S = myclassifier(im, Mdl)

% This classifier is not state of the art... but should give you an idea of
% the format we expect to make it easy to keep track of your scores. 
%
% Input is the image, output is a 1 x 4 vector of the three or four numbers 
% visible in the image, where, if there are only three numbers, pad the 
% output with a zero to the left; i.e., 123 => [0,1,2,3].
%
% This baseline classifier tries to guess... so should score on average
% about: 1/2*1/2 * 1/3^3 + 1/2*1/2 * 1/3^4 = 0.01234567, 
% A 1.2% chance of guessing the correct answer. 
img_rgb =im2double(im); 
img_gray = rgb2gray(img_rgb);
img_gray = fft_denoise(img_gray);
img_bw = im2double(Preprocessing(img_gray));


totDigitCnt = get_digit_total_num(img_bw);
% totDigitCnt = 4;
[bboxs, rotate_angle, img_gray_out] = digit_detection(img_bw, totDigitCnt);
% img_gray_out = imrotate(img_gray_out, rotate_angle,'crop');
% figure;imshow(img_gray_out)
% for i = 1:totDigitCnt
%     rectangle('Position', [bboxs(i,1), bboxs(i,2), bboxs(i,3), bboxs(i,4)], ...
%               'EdgeColor', 'g', 'LineWidth', 2);
% end


validation_patterns = FeatureExtraction(img_gray_out, bboxs, totDigitCnt);

pred = str2double(predict(Mdl,validation_patterns)');
if (totDigitCnt == 3) % Three digits
    S=[0, pred]; % Padding with a zero to the left
else % Four digits
    S=pred;
end
