function [Iout] = fft_denoise(I)
F = fftshift(fft2(I));
% S = log(abs(F) + 1); 
% figure; imshow(S, []); title('Original Spectrum');

%% remove periodic pattern
zeroPoints = [156 215; 170 221];
for k = 1:size(zeroPoints,1)
    F(zeroPoints(k,1), zeroPoints(k,2)) = 0;
end

F_filtered = F; 

%% Visualize Filtered Spectrum
% S_filtered = log(abs(F_filtered) + 1); 
% figure; imshow(S_filtered, []); title('Filtered Spectrum');

%% Inverse Fourier Transform
Iout = real(ifft2(ifftshift(F_filtered)));
% figure;imshow(Iout, []);title('Output Image After Filtering');
end


